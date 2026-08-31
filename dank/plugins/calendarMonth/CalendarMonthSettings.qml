// One component serves two panes: DMS renders it under the plugin in Settings,
// and again under each desktop widget instance -- and in the instance pane it
// swaps in a pluginService whose saves go to that instance's config. So
// anything the widget reads through pluginData belongs in the instance pane,
// and only genuinely global preferences go in the other.
//
// Declaring a settings component replaces the instance pane's built-in block
// wholesale -- PluginDesktopWidgetSettings renders its display picker AND its
// reset buttons only when settingsPath is empty. PluginSettings puts the picker
// back for plugins of type "desktop", which this is, but nothing puts the reset
// back, so it is rebuilt below.
import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "calendarMonth"

    // DMS sets this only in the instance pane; the plugin pane leaves it empty.
    property string instanceId: ""
    readonly property bool perInstance: root.instanceId !== ""

    SliderSetting {
        visible: root.perInstance
        settingKey: "upcomingCount"
        label: I18n.tr("Upcoming Events")
        description: I18n.tr("How many of the next events to list under the grid")
        defaultValue: 3
        minimum: 0
        maximum: 8
    }

    SliderSetting {
        visible: root.perInstance
        settingKey: "transparency"
        label: I18n.tr("Opacity")
        description: I18n.tr("Background opacity of this desktop widget")
        // 80 is the 0.8 the builtin desktop widgets store; they use a 0-1
        // scale, SliderSetting is int-only.
        defaultValue: 80
        minimum: 20
        maximum: 100
        unit: "%"
    }

    // DMS offers this as two buttons, but both clear the same positions map,
    // so one honest label replaces them.
    DankButton {
        visible: root.perInstance
        text: I18n.tr("Reset Position & Size")
        backgroundColor: Theme.surfaceHover
        textColor: Theme.surfaceText
        buttonHeight: 36
        onClicked: SettingsData.updateDesktopWidgetInstance(root.instanceId, {
            "positions": {}
        })
    }
}
