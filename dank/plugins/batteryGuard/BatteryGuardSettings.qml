// One settings component serves two panes. DMS renders it under the plugin in
// Settings, and again under each desktop widget instance -- and in the instance
// pane it swaps in a pluginService whose saves go to that instance's config
// rather than to the plugin's own settings.
//
// That split is invisible to the reader but decides whether a value has any
// effect: the desktop widget reads pluginData, which for an instance IS the
// instance config, so opacity only works when set per instance. The charge band
// is the opposite -- the daemon is a single global object, so a per-instance
// copy of it would be written and never read.
//
// DMS sets instanceId only in the instance pane, so it is the discriminator.
import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "batteryGuard"

    property string instanceId: ""
    readonly property bool perInstance: root.instanceId !== ""

    ToggleSetting {
        visible: !root.perInstance
        settingKey: "guardEnabled"
        label: I18n.tr("Enable Charge Band")
        description: I18n.tr("Cycle the battery between the limits below. Turning this off releases the limit to 100%.")
        defaultValue: true
    }

    SliderSetting {
        visible: !root.perInstance
        settingKey: "upperLimit"
        label: I18n.tr("Upper Limit")
        description: I18n.tr("Stop charging once the battery reaches this level")
        defaultValue: 80
        minimum: 50
        maximum: 100
        unit: "%"
    }

    SliderSetting {
        visible: !root.perInstance
        settingKey: "lowerLimit"
        label: I18n.tr("Lower Limit")
        description: I18n.tr("Let the battery fall to this level before charging again")
        defaultValue: 40
        minimum: 20
        maximum: 80
        unit: "%"
    }

    // Declaring a settings component replaces the instance pane's built-in
    // block wholesale -- PluginDesktopWidgetSettings renders its display picker
    // AND its reset buttons only when settingsPath is empty -- and
    // PluginSettings' own picker is gated on plugin.type === "desktop", which a
    // composite plugin is not. So both are rebuilt here; without them the
    // widget could not be limited to one display, and one dragged off screen
    // could only be recovered by hand editing settings.json.
    Item {
        visible: root.perInstance
        width: parent.width
        height: visible ? displayColumn.implicitHeight : 0

        Column {
            id: displayColumn

            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: I18n.tr("Display Settings")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                width: parent.width
                wrapMode: Text.WordWrap
                text: I18n.tr("Choose which displays show this widget")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            DankToggle {
                width: parent.width
                text: I18n.tr("All displays")
                checked: {
                    const prefs = root.loadValue("displayPreferences", ["all"]);
                    return Array.isArray(prefs) && (prefs.includes("all") || prefs.length === 0);
                }
                onToggled: isChecked => {
                    if (isChecked) {
                        root.saveValue("displayPreferences", ["all"]);
                        return;
                    }
                    const screens = [];
                    for (var i = 0; i < Quickshell.screens.length; i++) {
                        const screen = Quickshell.screens[i];
                        screens.push({
                            "name": screen.name,
                            "model": screen.model || ""
                        });
                    }
                    root.saveValue("displayPreferences", screens);
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS
                visible: {
                    const prefs = root.loadValue("displayPreferences", ["all"]);
                    return Array.isArray(prefs) && !prefs.includes("all");
                }

                Repeater {
                    model: Quickshell.screens

                    DankToggle {
                        required property var modelData

                        width: parent.width
                        text: SettingsData.getScreenDisplayName(modelData)
                        description: modelData.width + "×" + modelData.height
                        checked: {
                            const prefs = root.loadValue("displayPreferences", ["all"]);
                            if (!Array.isArray(prefs) || prefs.includes("all")) {
                                return false;
                            }
                            return prefs.some(p => p.name === modelData.name);
                        }
                        onToggled: isChecked => {
                            var prefs = root.loadValue("displayPreferences", ["all"]);
                            if (!Array.isArray(prefs) || prefs.includes("all")) {
                                prefs = [];
                            }
                            prefs = prefs.filter(p => p.name !== modelData.name);
                            if (isChecked) {
                                prefs.push({
                                    "name": modelData.name,
                                    "model": modelData.model || ""
                                });
                            }
                            root.saveValue("displayPreferences", prefs);
                        }
                    }
                }
            }

            // DMS offers these as two buttons, but both clear the same
            // positions map, so one honest label replaces them.
            DankButton {
                text: I18n.tr("Reset Position & Size")
                backgroundColor: Theme.surfaceHover
                textColor: Theme.surfaceText
                buttonHeight: 36
                enabled: root.instanceId !== ""
                onClicked: SettingsData.updateDesktopWidgetInstance(root.instanceId, {
                    "positions": {}
                })
            }
        }
    }

    SliderSetting {
        visible: root.perInstance
        settingKey: "transparency"
        label: I18n.tr("Opacity")
        description: I18n.tr("Background opacity of this desktop widget")
        // 80 here is the 0.8 the builtin desktop widgets store, so the whole
        // desktop matches. They use a 0-1 scale; SliderSetting is int-only.
        defaultValue: 80
        minimum: 20
        maximum: 100
        unit: "%"
    }
}
