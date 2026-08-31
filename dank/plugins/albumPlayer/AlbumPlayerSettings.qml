import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "albumPlayer"

    ToggleSetting {
        settingKey: "showTrackInfo"
        label: I18n.tr("Show Track Info")
        description: I18n.tr("Show the track title and artist over the cover")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showProgress"
        label: I18n.tr("Show Progress")
        description: I18n.tr("Show a seekable progress bar with elapsed and total time")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "hideWhenIdle"
        label: I18n.tr("Hide When Idle")
        description: I18n.tr("Hide the widget when no MPRIS player is active")
        defaultValue: false
    }
}
