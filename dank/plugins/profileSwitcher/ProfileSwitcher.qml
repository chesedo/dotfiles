import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "." as Local

PluginComponent {
    id: root

    // PluginComponent wraps these in a BasePill, which draws the pill chrome
    // and sizes itself as content.implicitWidth + horizontalPadding * 2. The
    // content must therefore declare only its implicit size and no background:
    // drawing another rect here nests a pill inside a pill and the text spills
    // out. Same contract the built-in widgets use.
    //
    // The content is loaded into a Loader inside BasePill's visualContent, so
    // BasePill itself is three levels up. Reaching it through `parent` alone
    // lands on the Loader and silently yields NaN.
    horizontalBarPill: Component {
        Item {
            id: hPill

            readonly property var pill: parent?.parent?.parent ?? null

            implicitWidth: pillRow.implicitWidth
            implicitHeight: root.widgetThickness - (pill?.horizontalPadding ?? 0) * 2

            Row {
                id: pillRow
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                DankIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "display_settings"
                    size: root.iconSize
                    color: Theme.widgetIconColor
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Local.ProfileSwitcherService.activeProfileName || "No profile"
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            id: vPill

            readonly property var pill: parent?.parent?.parent ?? null
            readonly property real side: root.widgetThickness - (pill?.horizontalPadding ?? 0) * 2

            implicitWidth: side
            implicitHeight: side

            DankIcon {
                anchors.centerIn: parent
                name: "display_settings"
                size: root.iconSize
                color: Theme.widgetIconColor
            }
        }
    }

    // PopoutComponent is itself a Column with spacing 0, whose header and
    // details indent themselves by Theme.spacingS. Content added here is just
    // appended, so it has to carry the same padding or it sits flush against
    // the edges while the header does not.
    popoutContent: Component {
        PopoutComponent {
            headerText: "Display profiles"
            detailsText: Local.ProfileSwitcherService.lastError.length > 0 ? Local.ProfileSwitcherService.lastError : "Switching also turns desktop widgets on or off"
            showCloseButton: true

            Column {
                id: profileList

                width: parent.width
                leftPadding: Theme.spacingS
                rightPadding: Theme.spacingS
                bottomPadding: Theme.spacingS
                spacing: Theme.spacingXS

                Repeater {
                    model: Local.ProfileSwitcherService.profiles

                    StyledRect {
                        id: profileRow

                        required property string modelData
                        readonly property bool isActive: modelData === Local.ProfileSwitcherService.activeProfileName
                        readonly property bool keepsWidgets: Local.ProfileSwitcherService.widgetProfiles.indexOf(modelData) !== -1

                        width: profileList.width - profileList.leftPadding - profileList.rightPadding
                        height: 36
                        radius: Theme.cornerRadius
                        color: profileRow.isActive ? Theme.primaryContainer : (rowHover.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
                        opacity: Local.ProfileSwitcherService.busy ? 0.5 : 1

                        StyledText {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            text: profileRow.modelData
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        StyledText {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            visible: profileRow.keepsWidgets
                            text: "widgets"
                            color: Theme.surfaceVariantText
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        MouseArea {
                            id: rowHover

                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !Local.ProfileSwitcherService.busy
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Local.ProfileSwitcherService.activate(profileRow.modelData)
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 320
}
