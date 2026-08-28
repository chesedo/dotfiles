// Display profile switching, plus whatever else should happen when a profile
// becomes active.
//
// DMS has no hook for that: bars and desktop widgets can only be conditioned on
// which screen they are on, never on the active profile, and the stock display
// profile plugin is a chooser with no extension point. Since profiles decide
// which screens exist, "when docked" is only expressible by acting at the
// moment of the switch -- which is what this does.
//
// The actions hang off DisplayConfigState's profileActivated signal rather than
// off the click handler. activateProfile() is asynchronous underneath: it ends
// in a Proc that writes outputs.kdl, and the active profile is only recorded in
// that write's success handler. Acting on the signal means the actions follow
// the geometry rather than racing it, and it also covers switches made from
// DMS's own display settings and from `dms ipc`, neither of which comes through
// this plugin.
//
// It does NOT cover auto-select: applyConfigEntry only emits profileActivated
// when isManual, and the auto path passes false. Auto-select is off here, but
// turning it on would leave bars and widgets unmanaged.
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.Settings.DisplayConfig

Singleton {
    id: root

    // Everything below is derived from DMS's own state, so it tracks changes
    // made anywhere rather than needing a refresh or a poll.
    readonly property var validated: DisplayConfigState.validatedProfiles || ({})

    readonly property var profiles: {
        const names = [];
        for (const id in root.validated) {
            const name = root.validated[id]?.name;
            // Auto-select writes unnamed profiles when nothing matches; they
            // are not user facing.
            if (name && name.length > 0) {
                names.push(name);
            }
        }
        return names;
    }

    readonly property string activeProfileName: {
        const id = SettingsData.activeDisplayProfile?.[CompositorService.compositor] ?? "";
        return root.validated[id]?.name ?? "";
    }

    property string lastError: ""
    property bool busy: false

    // Profiles whose activation should leave desktop widgets on. Anything else
    // turns them off.
    //
    // Read here rather than in the settings pane: that component is only
    // instantiated while its row is expanded in DMS Settings, so a value read
    // there would never be applied at startup. Bound to SettingsData.pluginSettings
    // so edits land without a reload.
    readonly property var widgetProfiles: {
        const stored = SettingsData.pluginSettings?.profileSwitcher?.widgetProfiles;
        return (Array.isArray(stored) && stored.length > 0) ? stored : ["Docked"];
    }

    // barId -> list of profiles in which that bar is enabled. Bars not named
    // here are never touched: the externals bar is left alone because its
    // screenPreferences already make it disappear when the monitors are gone.
    //
    // The laptop has two bars rather than one: docked it only needs a stub,
    // because the desktop widgets show the clock, weather and system stats on
    // that screen; undocked it is the only screen and needs the full set.
    property var barProfiles: ({
        "laptopDocked": ["Docked"],
        "laptopFull": ["Laptop only"]
    })

    function _profileIdFor(profileName) {
        for (const id in root.validated) {
            if (root.validated[id]?.name === profileName) {
                return id;
            }
        }
        return null;
    }

    function activate(profileName) {
        if (!profileName || profileName.length === 0 || root.busy) {
            return;
        }

        if (SettingsData.displayProfileAutoSelect) {
            root.lastError = "Auto profile selection is on; turn it off to switch by hand";
            ToastService.showError("Profile switch refused", root.lastError);
            return;
        }

        const profileId = root._profileIdFor(profileName);
        if (!profileId) {
            root.lastError = "Profile not found: " + profileName;
            ToastService.showError("Profile switch failed", root.lastError);
            return;
        }

        root.busy = true;
        root.lastError = "";
        watchdog.restart();
        DisplayConfigState.activateProfile(profileId);
    }

    Connections {
        function onProfileActivated(profileId, profileName) {
            watchdog.stop();
            root.lastError = "";
            root._applyProfileActions(profileName || root.validated[profileId]?.name || "");
            root.busy = false;
        }

        function onProfileError(message) {
            watchdog.stop();
            root.lastError = message || "Profile switch failed";
            root.busy = false;
            ToastService.showError("Profile switch failed", root.lastError);
        }

        target: DisplayConfigState
    }

    // activateProfile can fail in ways that emit neither signal, and a stuck
    // busy flag would leave every row dimmed and unclickable until DMS restarts.
    Timer {
        id: watchdog

        interval: 10000
        onTriggered: {
            root.busy = false;
            root.lastError = "Profile switch timed out";
            ToastService.showError("Profile switch failed", root.lastError);
        }
    }

    // Both of these go straight through SettingsData rather than shelling out
    // to dms ipc: a plugin runs inside DMS, and the IPC handlers are themselves
    // thin wrappers over these same calls.
    function _applyProfileActions(profileName) {
        if (!profileName || profileName.length === 0) {
            return;
        }
        root._setBars(profileName);
        root._setDesktopWidgets(root.widgetProfiles.indexOf(profileName) !== -1);
    }

    // updateBarConfig deep copies, merges, sanitises and persists -- the same
    // path the settings UI uses.
    function _setBars(profileName) {
        // Work out the end state first. Switching every managed bar off would
        // leave no bar carrying this widget and no way back to it -- which a
        // profile named in no list does, and so does a list naming a bar that
        // has since been renamed or deleted in DMS Settings. Checking that a
        // bar both wants enabling AND still exists covers both.
        const plan = [];
        let survivor = false;
        for (const barId in root.barProfiles) {
            const current = SettingsData.getBarConfig(barId);
            if (!current) {
                continue;
            }
            const wanted = root.barProfiles[barId].indexOf(profileName) !== -1;
            if (wanted) {
                survivor = true;
            }
            if (current.enabled !== wanted) {
                plan.push({
                    "barId": barId,
                    "wanted": wanted
                });
            }
        }
        if (!survivor) {
            return;
        }

        // Disable before enabling: both laptop bars sit at the same position on
        // the same screen, and enabling first puts two bar windows on one edge
        // for a frame.
        for (const step of plan) {
            if (!step.wanted) {
                SettingsData.updateBarConfig(step.barId, {
                    "enabled": false
                });
            }
        }
        for (const step of plan) {
            if (step.wanted) {
                SettingsData.updateBarConfig(step.barId, {
                    "enabled": true
                });
            }
        }
    }

    function _setDesktopWidgets(enabled) {
        const instances = SettingsData.desktopWidgetInstances || [];
        for (const instance of instances) {
            if (!instance || !instance.id || instance.enabled === enabled) {
                continue;
            }
            SettingsData.updateDesktopWidgetInstance(instance.id, {
                "enabled": enabled
            });
        }
    }
}
