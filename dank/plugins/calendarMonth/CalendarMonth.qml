// A month grid for the desktop, with the next few events listed under it.
// Read-only on purpose -- editing belongs in whatever owns the calendar, not
// in a widget you glance at.
//
// The grid carries no per-day marks, so it never queries the calendar and
// stays instant while you page through months. Only the list needs data, and
// it is anchored to today rather than to the month on screen: it answers "what
// is next", which does not change because you looked at March.
//
// Events come from DMS's CalendarService, a front for either khal or the
// separate dankcalendar app. khal is wired up in home.nix, fed by vdirsyncer.
import QtQuick
import Quickshell
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

    // Six grid rows sit at a floor of fontSizeSmall * 1.6 each, and the event
    // list adds its own height on top; both scale with fontScale. A constant
    // minimum is therefore always wrong for some combination, and being wrong
    // means the grid paints straight over the events. upcomingBlock's height
    // comes from text metrics rather than from the widget, so reading it here
    // does not feed back.
    readonly property int gridFloor: Math.round(Theme.fontSizeSmall * 1.6) * 6
    readonly property int headerFloor: Math.round(Theme.fontSizeMedium * 1.5 + Theme.fontSizeSmall * 1.5 + Theme.spacingS * 2)
    readonly property int listFloor: upcomingBlock.visible ? Math.round(upcomingBlock.height) : 0

    minHeight: root.gridFloor + root.headerFloor + root.listFloor + Math.round(Theme.spacingM * 2)
    readonly property int defaultWidth: 320
    readonly property int defaultHeight: root.minHeight + Math.round(Theme.fontSizeSmall * 4)

    // Minutes rather than seconds: the only thing that has to move is the
    // "today" marker at midnight.
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    readonly property date today: clock.date

    // Months away from today. Kept as an offset rather than a date so the grid
    // follows the clock across midnight without having to be re-based, and so
    // "back to today" is just a reset to zero.
    property int monthOffset: 0

    readonly property date displayDate: new Date(root.today.getFullYear(), root.today.getMonth() + root.monthOffset, 1, 12)
    readonly property int displayYear: root.displayDate.getFullYear()
    readonly property int displayMonth: root.displayDate.getMonth()

    // Respects the shell's setting, falling back to the locale the same way
    // DMS's own calendar card does.
    readonly property int firstDayOfWeek: {
        if (SettingsData.firstDayOfWeek >= 7 || SettingsData.firstDayOfWeek < 0) {
            return Qt.locale().firstDayOfWeek;
        }
        return SettingsData.firstDayOfWeek;
    }

    // The Sunday-or-Monday-aligned date the top-left cell shows, which is
    // usually in the previous month.
    // Noon, not midnight. Where a DST jump removes local midnight, QML's V4
    // engine resolves the date BACK to 23:00 the previous day (Node rolls
    // forward instead), so the cell renders the wrong day number -- one
    // duplicated, one missing. Beirut, Gaza, Havana, Santiago, Sao Paulo and
    // Tehran all hit it. Noon is never removed by a one-hour shift.
    readonly property date gridStart: {
        const firstOfMonth = new Date(root.displayYear, root.displayMonth, 1, 12);
        const offset = (firstOfMonth.getDay() - root.firstDayOfWeek + 7) % 7;
        return new Date(root.displayYear, root.displayMonth, 1 - offset, 12);
    }

    readonly property int upcomingCount: pluginData.upcomingCount ?? 3

    // Far enough ahead to find a few events in a quiet calendar, near enough
    // that a backend shelling out to khal is not asked for a year at a time.
    readonly property int lookaheadDays: 90

    readonly property var upcoming: {
        const byDate = CalendarService.eventsByDate;
        if (!byDate) {
            return [];
        }
        const now = root.today;
        // Midnight here would roll back a day on a DST-transition date and let
        // yesterday's all-day events into the list.
        const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12);
        const seen = {};
        const out = [];
        for (const key in byDate) {
            for (const event of byDate[key]) {
                if (!event || seen[event.id]) {
                    continue;
                }
                // eventsByDate is merged with the Todo Planner's tasks; those
                // are not calendar events and should not crowd the list.
                if (String(event.id).startsWith("task_")) {
                    continue;
                }
                // A multi-day event is filed under every date it covers, so
                // dedupe by id or it fills the list on its own.
                const upcomingNow = event.allDay ? event.start >= todayStart : event.end >= now;
                if (!upcomingNow) {
                    continue;
                }
                seen[event.id] = true;
                out.push(event);
            }
        }
        out.sort((a, b) => a.start - b.start);
        return out.slice(0, root.upcomingCount);
    }

    function _whenLabel(event) {
        if (event.allDay) {
            return event.start.toLocaleDateString(I18n.locale(), "ddd");
        }
        return event.start.toLocaleString(I18n.locale(), "ddd HH:mm");
    }

    function _dateForCell(index) {
        const start = root.gridStart;
        return new Date(start.getFullYear(), start.getMonth(), start.getDate() + index, 12);
    }

    function _isSameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    // Anchored to today, not to the month being viewed, so paging the grid
    // costs nothing and the list keeps answering the same question.
    function _loadEvents() {
        if (!CalendarService.calendarAvailable) {
            return;
        }
        const now = root.today;
        const start = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12);
        const end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + root.lookaheadDays, 12);
        CalendarService.loadEvents(start, end);
    }

    HoverHandler {
        id: gridHover
    }
    Component.onCompleted: root._loadEvents()

    // vdirsyncer pulls on its own timer, but nothing re-runs khal -- without
    // this a meeting added today never shows up. It also re-anchors the
    // lookahead window across midnight, and restores it after DankDash's
    // calendar reloads eventsByDate for whatever month it is showing.
    //
    // CalendarService.loadEvents is global, so this cuts both ways: while the
    // dash is open on a month outside today..+90d, this reload will empty it
    // within five minutes. Nothing here can fix that -- one shared window,
    // two readers.
    Timer {
        interval: 5 * 60 * 1000
        repeat: true
        running: true
        triggeredOnStart: false
        onTriggered: root._loadEvents()
    }

    Connections {
        function onCalendarAvailableChanged() {
            root._loadEvents();
        }

        target: CalendarService
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        // Theme.surface with no border, matching the builtin desktop widgets.
        color: Theme.withAlpha(Theme.surface, (root.pluginData.transparency ?? 80) / 100)
        border.width: 0

        Column {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: upcomingBlock.top
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            Item {
                width: parent.width
                height: monthLabel.implicitHeight

                // Revealed on hover so the resting widget is just the month.
                // They keep their place while hidden, so nothing shifts when
                // they appear and the label never has to re-centre.
                DankActionButton {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    buttonSize: 24
                    iconName: "chevron_left"
                    iconSize: 16
                    iconColor: Theme.surfaceText
                    backgroundColor: "transparent"
                    opacity: gridHover.hovered ? 1 : 0
                    tooltipText: I18n.tr("Previous month")
                    onClicked: root.monthOffset -= 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                StyledText {
                    id: monthLabel

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.displayDate.toLocaleDateString(I18n.locale(), "MMMM yyyy")
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText

                    // Clicking the month name is the way back, so a wander
                    // through the year is never a one-way trip.
                    MouseArea {
                        anchors.fill: parent
                        enabled: root.monthOffset !== 0
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.monthOffset = 0
                    }
                }

                DankActionButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    buttonSize: 24
                    iconName: "chevron_right"
                    iconSize: 16
                    iconColor: Theme.surfaceText
                    backgroundColor: "transparent"
                    opacity: gridHover.hovered ? 1 : 0
                    tooltipText: I18n.tr("Next month")
                    onClicked: root.monthOffset += 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }
            }

            Row {
                width: parent.width

                Repeater {
                    model: 7

                    StyledText {
                        required property int index

                        width: content.width / 7
                        horizontalAlignment: Text.AlignHCenter
                        text: I18n.locale().dayName((root.firstDayOfWeek + index) % 7, Locale.NarrowFormat)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }
            }

            Grid {
                id: monthGrid

                width: parent.width
                columns: 7
                rows: 6

                readonly property real cellWidth: width / 7
                // Fills whatever is left under the two headers, so the grid
                // grows with the widget instead of leaving a gap.
                readonly property real cellHeight: Math.max(Theme.fontSizeSmall * 1.6, (content.height - y) / 6)

                Repeater {
                    model: 42

                    Item {
                        id: cell

                        required property int index

                        readonly property date cellDate: root._dateForCell(index)
                        readonly property bool inMonth: cellDate.getMonth() === root.displayMonth
                        readonly property bool isToday: root._isSameDay(cellDate, root.today)
                        width: monthGrid.cellWidth
                        height: monthGrid.cellHeight

                        Rectangle {
                            anchors.centerIn: dayLabel
                            width: Math.min(cell.width, cell.height) - 4
                            height: width
                            radius: width / 2
                            color: Theme.primary
                            visible: cell.isToday
                        }

                        StyledText {
                            id: dayLabel

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            text: cell.cellDate.getDate()
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: cell.isToday ? Font.Medium : Font.Normal
                            color: {
                                if (cell.isToday) {
                                    return Theme.onPrimary;
                                }
                                return cell.inMonth ? Theme.surfaceText : Theme.surfaceVariantText;
                            }
                        }
                    }
                }
            }
        }

        Column {
            id: upcomingBlock

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS
            visible: root.upcoming.length > 0

            Item {
                width: parent.width
                height: 1 + Theme.spacingXS

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: Theme.outlineMedium
                }
            }

            Repeater {
                model: root.upcoming

                Row {
                    required property var modelData

                    width: upcomingBlock.width
                    spacing: Theme.spacingM

                    StyledText {
                        id: whenLabel

                        text: root._whenLabel(modelData)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    StyledText {
                        width: upcomingBlock.width - whenLabel.width - Theme.spacingM
                        text: modelData.title
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }
        }
    }
}
