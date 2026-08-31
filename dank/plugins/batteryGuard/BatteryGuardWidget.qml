// Bar pill for the guard. It deliberately says nothing about the charge level:
// DMS's own battery widget sits in the same bar and already shows that. What
// the guard adds is the reason a plugged-in laptop is not charging, so the pill
// carries the phase and leaves the numbers to the popout.
//
// All state comes from the daemon; this reads and never decides.
import QtQuick
import qs.Common
import qs.Services
import qs.Modules.Plugins
import qs.Widgets

PluginComponent {
    id: root

    // The service reassigns this map wholesale when daemons load or unload, so
    // the binding re-evaluates instead of going stale across a plugin reload.
    readonly property var daemon: {
        const instances = PluginService.pluginDaemonInstances;
        return instances ? (instances[root.pluginId] ?? null) : null;
    }

    readonly property bool guardEnabled: daemon?.guardEnabled ?? (pluginData.guardEnabled ?? true)
    readonly property string phase: daemon?.phase ?? ""
    readonly property int upperLimit: daemon?.upperLimit ?? 80
    readonly property int lowerLimit: daemon?.lowerLimit ?? 40
    readonly property int limit: daemon?.observedThreshold ?? -1
    readonly property string lastError: daemon?.lastError ?? ""

    readonly property bool holding: phase === "holding"
    readonly property int secondaryLimit: root.holding ? root.upperLimit : root.lowerLimit

    // Same words as the desktop widget, so the two never describe the same
    // state differently.
    readonly property string phaseLabel: {
        if (!root.guardEnabled) {
            return I18n.tr("Off");
        }
        return root.holding ? I18n.tr("Holding") : I18n.tr("Charging");
    }

    readonly property string statusIcon: {
        if (!root.guardEnabled) {
            return "battery_alert";
        }
        return root.holding ? "battery_saver" : "battery_charging_full";
    }

    readonly property color statusColor: {
        if (root.lastError !== "") {
            return Theme.error;
        }
        if (!root.guardEnabled) {
            return Theme.surfaceTextMedium;
        }
        return Theme.surfaceText;
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: root.statusIcon
                size: root.iconSize
                color: root.statusColor
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.phaseLabel
                font.pixelSize: Theme.fontSizeSmall
                color: root.statusColor
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: I18n.tr("Battery Guard")
            // Errors only. "Off" would just repeat the pill, and the track
            // already dims itself when the guard is disabled.
            detailsText: root.lastError
            showCloseButton: true

            Column {
                id: body

                width: parent.width
                leftPadding: Theme.spacingS
                rightPadding: Theme.spacingS
                bottomPadding: Theme.spacingS
                spacing: Theme.spacingS

                readonly property real innerWidth: body.width - body.leftPadding - body.rightPadding

                // The same track the desktop widget draws, so the popout is a
                // full substitute for it when undocked -- solid marks where
                // charging stops now, dotted where the guard flips to next.
                Item {
                    width: body.innerWidth
                    height: 24

                    Rectangle {
                        id: miniTrack

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 8
                        radius: height / 2
                        color: Theme.surfaceVariant

                        Rectangle {
                            x: miniTrack.width * (root.lowerLimit / 100)
                            width: Math.max(0, miniTrack.width * ((root.upperLimit - root.lowerLimit) / 100))
                            height: parent.height
                            radius: parent.radius
                            color: Theme.withAlpha(Theme.primary, root.guardEnabled ? 0.28 : 0.12)
                        }

                        Rectangle {
                            width: Math.max(0, Math.min(miniTrack.width, miniTrack.width * (BatteryService.batteryLevel / 100)))
                            height: parent.height
                            radius: parent.radius
                            color: BatteryService.isCharging ? Theme.primary : Theme.surfaceText
                            opacity: 0.9
                        }

                        Rectangle {
                            visible: root.limit > 0 && root.guardEnabled
                            x: Math.min(miniTrack.width - width, miniTrack.width * (root.limit / 100))
                            y: -3
                            width: 2
                            height: parent.height + 6
                            color: Theme.surfaceText
                        }

                        Item {
                            visible: root.guardEnabled
                            x: Math.min(miniTrack.width - width, miniTrack.width * (root.secondaryLimit / 100))
                            y: -3
                            width: 2
                            height: miniTrack.height + 6

                            Column {
                                anchors.fill: parent
                                spacing: 3

                                Repeater {
                                    model: Math.max(1, Math.floor((miniTrack.height + 6 + 3) / 6))

                                    Rectangle {
                                        width: 2
                                        height: 3
                                        color: Theme.surfaceTextMedium
                                    }
                                }
                            }
                        }
                    }

                    StyledText {
                        id: miniLower

                        anchors.bottom: parent.bottom
                        x: Math.max(0, Math.min(parent.width - width, miniTrack.width * (root.lowerLimit / 100) - width / 2))
                        text: root.lowerLimit + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        x: Math.min(parent.width - width, Math.max(miniLower.x + miniLower.width + Theme.spacingS, miniTrack.width * (root.upperLimit / 100) - width / 2))
                        text: root.upperLimit + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                }
            }
        }
    }

    popoutWidth: 340
}
