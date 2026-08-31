// Desktop face of the guard: the charge band drawn as a track, so the whole
// policy is visible at once -- where the battery is, where charging stops, and
// where it picks up again. A bare percentage cannot show that, and the band is
// the part that is easy to forget you configured.
//
// Reads the daemon and BatteryService only; all the logic lives in the daemon.
import QtQuick
import qs.Common
import qs.Services
import qs.Modules.Plugins
import qs.Widgets

DesktopPluginComponent {
    id: root

    width: widgetWidth
    height: widgetHeight
    implicitWidth: widgetWidth
    implicitHeight: widgetHeight

    minWidth: 220
    minHeight: 110
    readonly property int defaultWidth: 340
    readonly property int defaultHeight: 150

    readonly property var daemon: {
        const instances = PluginService.pluginDaemonInstances;
        return instances ? (instances[root.pluginId] ?? null) : null;
    }

    readonly property bool guardEnabled: daemon?.guardEnabled ?? true
    readonly property string phase: daemon?.phase ?? ""
    readonly property int upperLimit: daemon?.upperLimit ?? 80
    readonly property int lowerLimit: daemon?.lowerLimit ?? 40
    readonly property int limit: daemon?.observedThreshold ?? -1
    readonly property string lastError: daemon?.lastError ?? ""

    readonly property bool holding: phase === "holding"
    readonly property real level: BatteryService.batteryAvailable ? BatteryService.batteryLevel : 0

    // Same rule DMS uses in BatteryDetail, so the widget agrees with the rest
    // of the shell about what colour a battery state is.
    readonly property color accent: {
        if (root.lastError !== "") {
            return Theme.error;
        }
        if (BatteryService.isLowBattery && !BatteryService.isCharging) {
            return Theme.error;
        }
        if (BatteryService.isCharging) {
            return Theme.primary;
        }
        return Theme.surfaceText;
    }

    // Solid marks where charging stops right now, dotted marks the limit the
    // guard will flip to next -- so the pair reads as "here now, there after".
    readonly property int secondaryLimit: root.holding ? root.upperLimit : root.lowerLimit

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        // Theme.surface with no border, which is exactly what the builtin
        // desktop widgets do -- nestedSurface is a lighter tone and the border
        // made this one sit forward of the clock and weather beside it.
        // The setting is a percentage; withAlpha wants 0-1.
        color: Theme.withAlpha(Theme.surface, (root.pluginData.transparency ?? 80) / 100)
        border.width: 0

        Column {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Theme.spacingL
            anchors.rightMargin: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                width: parent.width
                spacing: Theme.spacingM

                DankIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: BatteryService.getBatteryIcon()
                    size: Theme.iconSizeLarge
                    color: root.accent
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(root.level) + "%"
                    font.pixelSize: Theme.fontSizeXLarge
                    font.weight: Font.Bold
                    color: root.accent
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.guardEnabled ? (root.holding ? I18n.tr("Holding") : I18n.tr("Charging")) : I18n.tr("Off")
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceTextMedium
                }
            }

            // The band track. Everything is positioned as a fraction of the
            // full 0-100 range so the marker and the shaded band cannot drift
            // apart from each other.
            Item {
                width: parent.width
                height: 26

                Rectangle {
                    id: track

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 10
                    radius: height / 2
                    color: Theme.surfaceVariant

                    Rectangle {
                        // The configured band, shown even when the guard is off
                        // so the numbers stay meaningful.
                        x: track.width * (root.lowerLimit / 100)
                        width: Math.max(0, track.width * ((root.upperLimit - root.lowerLimit) / 100))
                        height: parent.height
                        radius: parent.radius
                        color: Theme.withAlpha(Theme.primary, root.guardEnabled ? 0.28 : 0.12)
                    }

                    Rectangle {
                        // Current charge.
                        width: Math.max(0, Math.min(track.width, track.width * (root.level / 100)))
                        height: parent.height
                        radius: parent.radius
                        color: root.accent
                        opacity: 0.9
                    }

                    Rectangle {
                        // Solid: the threshold the hardware actually reports,
                        // so a failed write shows as the line not moving
                        // rather than as a silently wrong picture.
                        visible: root.limit > 0 && root.guardEnabled
                        x: Math.min(track.width - width, track.width * (root.limit / 100))
                        width: 2
                        height: parent.height + 6
                        y: -3
                        color: Theme.surfaceText
                    }

                    Item {
                        // Dotted: the other end of the band, where the guard
                        // flips to next.
                        visible: root.guardEnabled
                        x: Math.min(track.width - width, track.width * (root.secondaryLimit / 100))
                        y: -3
                        width: 2
                        height: track.height + 6

                        Column {
                            anchors.fill: parent
                            spacing: 3

                            Repeater {
                                model: Math.max(1, Math.floor((track.height + 6 + 3) / 6))

                                Rectangle {
                                    width: 2
                                    height: 3
                                    color: Theme.surfaceTextMedium
                                }
                            }
                        }
                    }
                }

                // Sat at the widget's edges these read as though the track ran
                // 40 to 80. It runs 0 to 100, so they belong under the band
                // boundaries they actually name, clamped so they stay inside
                // the widget when a limit is near either extreme.
                StyledText {
                    id: lowerLabel

                    anchors.bottom: parent.bottom
                    x: Math.max(0, Math.min(parent.width - width, track.width * (root.lowerLimit / 100) - width / 2))
                    text: root.lowerLimit + "%"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                }

                StyledText {
                    anchors.bottom: parent.bottom
                    // Never let the two labels collide when the band is narrow.
                    x: Math.min(parent.width - width, Math.max(lowerLabel.x + lowerLabel.width + Theme.spacingS, track.width * (root.upperLimit / 100) - width / 2))
                    text: root.upperLimit + "%"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                }
            }

            StyledText {
                visible: root.lastError !== ""
                width: parent.width
                text: root.lastError
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.error
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
