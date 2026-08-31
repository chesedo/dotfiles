// Owns the battery charge band: lets the battery fill to an upper limit, then
// caps the threshold at a lower one so it coasts back down before charging
// again. Framework laptops sit plugged in most of the day, and holding a
// lithium cell at 100% is what ages it.
//
// This replaces a shell loop that polled every 60 seconds and worked out which
// half of the cycle it was in by reading the threshold back. That inference was
// the fragile part -- it silently did the wrong thing if anything else wrote
// the file -- so the phase is explicit here and persisted, and the loop is gone
// in favour of reacting to UPower through BatteryService.
//
// The phase is written to our own file rather than through the plugin state
// API: that path dropped writes three times in two hours here, leaving the
// stored phase disagreeing with the hardware. A guard whose memory is unreliable is
// worse than one with none, so this owns the file. If it is missing or corrupt
// the phase is recovered from the threshold instead, which is near enough
// unambiguous: the guard only ever writes one of the two configured limits, or
// 100 when it is switched off.
//
// The threshold is a plain sysfs attribute, made group writable by a udev rule
// in nixos/configuration-framework-13.nix. That is why this needs no pkexec, no
// ectool and no subprocess: it is just a file. It does mean the band is only
// enforced while DMS runs -- if the shell is down the threshold simply stays
// where it was last put, which stops charging at the wrong number but is never
// unsafe. Disabling the guard releases the limit to 100, but removing the
// plugin outright does not -- the threshold simply stays where it was.
//
// While this runs it owns the threshold: DMS's own charge limit control in
// Settings writes the same file, and the watcher below will re-assert over it.
import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    // BAT1 on the Framework 13; the udev rule matches any BAT? that has the
    // attribute, so this is the only place the number is assumed.
    readonly property string thresholdPath: "/sys/class/power_supply/BAT1/charge_control_end_threshold"

    readonly property bool guardEnabled: pluginData.guardEnabled ?? true
    readonly property int upperLimit: pluginData.upperLimit ?? 80
    // Kept a real distance below the upper limit: the two sliders overlap in
    // range, and a band of nothing would flip the phase on every battery
    // update -- the hardest possible cycling on the cell.
    readonly property int lowerLimit: Math.min(pluginData.lowerLimit ?? 40, root.upperLimit - 5)

    // Charging resumes a point ABOVE the lower limit, not at it. With the
    // threshold set to 40 the EC parks the reported capacity at 41 and leaves
    // it there: on AC the battery neither charges (it is capped) nor drains
    // (the adapter carries the load), so a condition waiting for the level to
    // actually reach 40 never fires and the guard sits stuck forever.
    //
    // The shell version this replaces learned that the hard way and hardcoded
    // 41 (93ecd12, "Trigger recharge at 41% to account for capacity reporting
    // floor"). That reasoning lived only in the commit message, so porting the
    // condition faithfully lost it -- hence the comment here rather than there.
    readonly property int resumeLevel: root.lowerLimit + 1

    readonly property string phasePath: Paths.strip(Paths.state) + "/plugins/batteryGuard_phase.json"

    // "charging" -- threshold sits at upperLimit, battery is filling.
    // "holding"  -- threshold sits at lowerLimit, battery coasts down on use.
    property string phase: ""
    property int appliedThreshold: -1
    property int observedThreshold: -1
    property string lastError: ""

    property bool _thresholdLoaded: false
    property int _reassertCount: 0
    readonly property int _maxReasserts: 5
    property bool _phaseLoaded: false
    property string _restoredPhase: ""
    property bool _initialised: false

    readonly property int targetThreshold: {
        if (!root.guardEnabled) {
            return 100;
        }
        return root.phase === "holding" ? root.lowerLimit : root.upperLimit;
    }

    FileView {
        id: phaseFile

        path: root.phasePath
        atomicWrites: true

        onLoaded: root._onPhaseRead(text())
        onLoadFailed: root._onPhaseRead("")
        onSaveFailed: error => root._report(I18n.tr("Cannot save the charge phase: %1").arg(FileViewError.toString(error)))
    }

    FileView {
        id: thresholdFile

        path: root.thresholdPath
        // sysfs cannot be replaced by write-to-temp-and-rename, which is what
        // atomic writes do, so the write has to go straight at the attribute.
        atomicWrites: false
        watchChanges: true

        onLoaded: root._onThresholdRead(text())
        onLoadFailed: error => root._report(I18n.tr("Cannot read %1: %2").arg(root.thresholdPath).arg(FileViewError.toString(error)))
        onFileChanged: reload()
        // onFileChanged alone is not enough: the reload it issues races the
        // write still in flight and is dropped, leaving the observed value
        // stale after every change we made ourselves. This one lands.
        onSaved: reload()
        onSaveFailed: error => root._onWriteFailed(error)
    }

    function _onThresholdRead(raw) {
        const value = parseInt(String(raw).trim(), 10);
        // Set before the parse check: a bad read must not leave the startup
        // latch half open, or nothing below ever runs again.
        root._thresholdLoaded = true;
        if (!isFinite(value)) {
            root._report(I18n.tr("Cannot read a charge limit from %1").arg(root.thresholdPath));
            root._maybeInitialise();
            return;
        }
        root.observedThreshold = value;

        if (!root._initialised) {
            root._maybeInitialise();
            return;
        }

        // A confirmed read of what we asked for is the only proof the write
        // landed, so it is also what clears a previous failure.
        if (value === root.appliedThreshold) {
            root.lastError = "";
            root._reassertCount = 0;
        }

        // Something else moved it -- DMS's own battery settings can, for one.
        // Re-assert rather than silently drifting out of the band. Bounded,
        // because a driver that clamped or ignored the value would otherwise
        // make this write, re-read and write again forever.
        if (root.appliedThreshold !== -1 && value !== root.targetThreshold) {
            if (root._reassertCount >= root._maxReasserts) {
                root._report(I18n.tr("The charge limit will not hold at %1% (reads %2%)").arg(root.targetThreshold).arg(value));
                return;
            }
            root._reassertCount += 1;
            root._writeThreshold(root.targetThreshold, true);
        }
    }

    function _onPhaseRead(raw) {
        try {
            const parsed = JSON.parse(String(raw || "{}"));
            const saved = parsed.phase ?? "";
            if (saved === "charging" || saved === "holding") {
                root._restoredPhase = saved;
            }
        } catch (e) {
            root._restoredPhase = "";
        }
        root._phaseLoaded = true;
        root._maybeInitialise();
    }

    // Both files have to be in before a phase can be chosen, or the fallback
    // would run against an unread threshold.
    function _maybeInitialise() {
        if (root._initialised || !root._thresholdLoaded || !root._phaseLoaded) {
            return;
        }
        root._initialised = true;

        if (root._restoredPhase !== "") {
            root.phase = root._restoredPhase;
        } else if (root.observedThreshold === root.lowerLimit) {
            root.phase = "holding";
        } else if (root.observedThreshold === root.upperLimit) {
            root.phase = "charging";
        } else {
            // Genuinely first run, or the guard was off: start from wherever
            // the battery already is, so a full battery is not told to charge.
            root.phase = BatteryService.batteryLevel >= root.upperLimit ? "holding" : "charging";
        }

        // Evaluate BEFORE writing. Writing the restored phase's threshold and
        // then letting _evaluate flip it puts a transient wrong limit into
        // sysfs, and the read-back that triggers lands against an
        // appliedThreshold that has already moved on, burning a re-assert.
        // Evaluating first makes the trailing writes byte-identical to
        // whatever _evaluate already wrote, which FileView collapses.
        root._evaluate();
        root._persistPhase();
        root._writeThreshold(root.targetThreshold, true);
    }

    function _persistPhase() {
        phaseFile.setText(JSON.stringify({
            "phase": root.phase
        }) + "\n");
    }

    function _enterPhase(next) {
        if (root.phase === next) {
            return;
        }
        root.phase = next;
        root._persistPhase();
        // Deliberately redundant: assigning phase above already fires
        // onTargetThresholdChanged, which writes. But a flip that fails to
        // write is the one failure that matters, and FileView swallows an
        // identical setText, so the belt costs nothing.
        root._writeThreshold(root.targetThreshold, true);
    }

    function _evaluate() {
        if (!root.guardEnabled || !root._initialised || !BatteryService.batteryAvailable) {
            return;
        }
        const level = BatteryService.batteryLevel;
        if (!isFinite(level) || level <= 0) {
            return;
        }

        if (root.phase === "charging" && level >= root.upperLimit) {
            root._enterPhase("holding");
        } else if (root.phase === "holding" && level <= root.resumeLevel) {
            root._enterPhase("charging");
        }
    }

    function _writeThreshold(value, force) {
        if (!force && root.appliedThreshold === value) {
            return;
        }
        root.appliedThreshold = value;
        // Trailing newline to match what `echo n > attr` writes, which is the
        // form the kernel has always been fed here.
        thresholdFile.setText(String(value) + "\n");
    }

    Timer {
        interval: 15000
        repeat: true
        running: root.lastError !== "" && root.guardEnabled && root._reassertCount < root._maxReasserts
        onTriggered: root._writeThreshold(root.targetThreshold, true)
    }

    Connections {
        function onBatteryLevelChanged() {
            root._evaluate();
        }

        target: BatteryService
    }

    // A limit edited in settings, or the guard being switched off, has to take
    // effect now rather than at the next phase change.
    onTargetThresholdChanged: {
        if (root._initialised) {
            root._writeThreshold(root.targetThreshold, false);
            root._evaluate();
        }
    }

    // A denied write reports itself, so there is no need to infer failure from
    // a read-back -- which is just as well, because the read lags the write.
    // Only speaks when the message changes, so a retry loop against a
    // permission error does not queue a toast every fifteen seconds.
    function _report(message) {
        if (root.lastError === message) {
            return;
        }
        root.lastError = message;
        ToastService.showError("Battery Guard", message, "", "batteryGuard");
    }

    function _onWriteFailed(error) {
        root._report(I18n.tr("Cannot write the charge limit: %1. Is the udev rule applied?").arg(FileViewError.toString(error)));
    }

    Component.onCompleted: {
        console.info("BatteryGuard: watching", root.thresholdPath);
    }
}
