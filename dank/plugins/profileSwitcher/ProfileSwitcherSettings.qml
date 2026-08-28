pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

// Writes only. The value is read back in ProfileSwitcherService, because this
// component is instantiated only while its row is expanded in DMS Settings --
// anything read here would never be applied at startup.
PluginSettings {
    id: root

    Column {
        width: parent.width
        spacing: Theme.spacingM

        StyledText {
            text: "Profiles that keep desktop widgets on"
            color: Theme.surfaceText
            font.pixelSize: Theme.fontSizeMedium
        }

        StyledText {
            width: parent.width
            text: "Comma separated profile names. Activating any other profile turns the desktop widgets off."
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
        }

        DankTextField {
            width: parent.width
            text: (SettingsData.pluginSettings?.profileSwitcher?.widgetProfiles ?? ["Docked"]).join(", ")
            onEditingFinished: {
                const names = text.split(",").map(s => s.trim()).filter(s => s.length > 0);
                root.saveValue("widgetProfiles", names);
            }
        }
    }
}
