// Album-cover desktop widget: transport controls centred on the cover, with
// the track title, artist, a seekable progress bar and the elapsed/total times
// laid over a scrim along the bottom edge.
//
// Derived from kmf's dankAlbumWidget (MIT, see LICENSE), which draws the cover
// and controls but shows nothing about what is actually playing. The additions
// here are the title/artist lines, the seekbar and the elapsed/total readout.
//
// Track metadata comes from MprisController's stable* properties rather than
// straight off the player: they hold the last non-empty value, so the text does
// not blink to "Unknown" during the gap between tracks. Position needs no timer
// of its own either -- MprisController already pulses positionChanged() once a
// second while playing, and binding to activePlayer.position picks that up.
import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    width: widgetWidth
    height: widgetHeight
    implicitWidth: widgetWidth
    implicitHeight: widgetHeight

    minWidth: 140
    minHeight: 140
    readonly property int defaultWidth: 260
    readonly property int defaultHeight: 260
    readonly property bool forceSquare: true

    property bool hideWhenIdle: pluginData.hideWhenIdle ?? false
    property bool showTrackInfo: pluginData.showTrackInfo ?? true
    property bool showProgress: pluginData.showProgress ?? true

    property MprisPlayer activePlayer: MprisController.activePlayer
    property real scrollAccumulatorY: 0
    property real touchpadThreshold: 100
    property string lastArtUrl: ""

    readonly property bool hoverPreview: MprisController.isFirefoxYoutubeHoverPreview(activePlayer)
    readonly property bool hasPlayer: activePlayer !== null && !hoverPreview
    readonly property bool hideChrome: hideWhenIdle && !hasPlayer
    readonly property bool isPlaying: hasPlayer && activePlayer.playbackState === MprisPlaybackState.Playing

    readonly property color accent: MediaAccentService.accent
    readonly property color onAccent: MediaAccentService.onAccent

    readonly property string artUrl: {
        const resolved = TrackArtService.resolvedArtUrl;
        if (resolved !== "")
            return resolved;
        const p = activePlayer;
        if (!p)
            return "";
        if (p.trackArtUrl)
            return p.trackArtUrl;
        const m = p.metadata;
        return m && m["mpris:artUrl"] ? m["mpris:artUrl"].toString() : "";
    }
    readonly property string displayArt: artUrl || lastArtUrl
    readonly property bool hasArt: displayArt !== "" && hasPlayer

    onArtUrlChanged: {
        if (artUrl !== "")
            lastArtUrl = artUrl;
        if (!hasPlayer)
            lastArtUrl = "";
    }

    readonly property real side: Math.min(width, height)
    readonly property int playSize: Math.round(Math.max(40, Math.min(60, side * 0.20)))
    readonly property int skipSize: Math.round(Math.max(34, Math.min(48, playSize * 0.82)))
    readonly property int playIconSize: Math.round(playSize * 0.5)
    readonly property int skipIconSize: Math.round(skipSize * 0.5)
    readonly property int controlMargin: Math.round(Math.max(Theme.spacingS, side * 0.05))
    readonly property int controlSpacing: Math.round(Math.max(Theme.spacingS, side * 0.04))

    // The overlay stacks upward from the bottom edge, so on a small widget it
    // would swallow the cover entirely. Title, artist and the bar come in
    // together at 170; the time readout is the least useful of them and waits
    // until 210.
    readonly property bool roomForInfo: side >= 170
    readonly property bool roomForTimes: side >= 210
    readonly property bool infoVisible: showTrackInfo && roomForInfo && hasPlayer
    // Radio streams, and any player without lengthSupported, end up with a
    // stable length of 0 -- MPRIS simply omits mpris:length and MprisController
    // maps that (and anything under a second) to 0. DankSeekbar hides its own
    // track in that case, so showing the row anyway would leave a blank band
    // sitting over a frozen "0:00 / 0:00".
    readonly property bool progressVisible: showProgress && roomForInfo && hasPlayer && trackLength > 0
    readonly property bool timesVisible: progressVisible && roomForTimes

    // The scrim fades only across the empty strip ABOVE the overlay, then holds
    // near-solid behind it. Ramping across the whole scrim instead put the top
    // row -- the elapsed/total times -- in the weakest part of the gradient,
    // which is exactly where it was unreadable over busy artwork.
    readonly property real scrimFade: Math.round(root.side * 0.22)
    readonly property real scrimHeight: overlay.height + root.controlMargin + root.scrimFade
    readonly property real scrimSolidStop: Math.max(0.2, Math.min(0.8, root.scrimFade / Math.max(1, root.scrimHeight)))

    readonly property real trackLength: MprisController.activePlayerStableLength
    readonly property real trackPosition: {
        const p = root.activePlayer;
        if (!p || root.trackLength <= 0)
            return 0;
        return Math.max(0, Math.min(root.trackLength, p.position || 0));
    }

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds <= 0)
            return "0:00";
        const total = Math.floor(seconds);
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = total % 60;
        if (h > 0)
            return h + ":" + String(m).padStart(2, "0") + ":" + String(s).padStart(2, "0");
        return m + ":" + String(s).padStart(2, "0");
    }

    function handleVolumeWheel(wheelEvent) {
        if (root.hideChrome || !AudioService.sink?.audio)
            return;

        wheelEvent.accepted = true;
        const deltaY = wheelEvent.angleDelta.y;
        if (deltaY === 0)
            return;

        const step = AudioService.wheelVolumeStep || SettingsData.audioWheelScrollAmount || 5;
        const isMouseWheelY = Math.abs(deltaY) >= 120 && (Math.abs(deltaY) % 120) === 0;
        if (isMouseWheelY) {
            AudioService.adjustDefaultSinkVolume(String(step), deltaY > 0 ? 1 : -1);
            return;
        }

        root.scrollAccumulatorY += deltaY;
        if (Math.abs(root.scrollAccumulatorY) >= root.touchpadThreshold) {
            AudioService.adjustDefaultSinkVolume("1", root.scrollAccumulatorY > 0 ? 1 : -1);
            root.scrollAccumulatorY = 0;
        }
    }

    ClippingRectangle {
        id: sleeve
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        visible: !root.hideChrome

        Image {
            id: cover
            anchors.fill: parent
            source: root.displayArt
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            visible: root.hasArt && status === Image.Ready
        }

        // Settles the artwork while the controls are up, so they are not read
        // against whatever the cover happens to be underneath them -- pale busy
        // art was exactly the problem the bottom scrim had to solve too. 0.45
        // is enough to carry the buttons without losing the picture.
        //
        // Declared straight after the cover and left at the default z, so it
        // paints over the art but under the controls and the metadata.
        Rectangle {
            anchors.fill: parent
            color: Theme.withAlpha(Theme.surface, 0.45)
            visible: root.hasPlayer
            opacity: coverHover.hovered ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.longDuration
                    easing.type: Theme.emphasizedEasing
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            z: 1
            onWheel: wheel => root.handleVolumeWheel(wheel)
        }

        // A passive handler, not the MouseArea above: that one sits under the
        // buttons, so reaching for a button would hand the hover to it and fade
        // the controls out from under the pointer.
        HoverHandler {
            id: coverHover
        }

        // Gated on the player too, not just on missing art: the controls now sit
        // in the middle, so a track playing without cover art would otherwise
        // put this icon directly underneath them.
        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingS
            visible: !cover.visible && !root.hasPlayer
            width: parent.width - Theme.spacingL * 2

            DankIcon {
                name: "album"
                size: Math.round(Math.max(Theme.iconSizeLarge, root.side * 0.28))
                color: Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: I18n.tr("No Media")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        // The fade runs only across the strip above the overlay and then holds
        // at 0.78-0.86 behind it, so every text row sits on the same backing
        // whatever the cover happens to look like there. Ramping across the
        // whole scrim instead left the top row -- the times -- in the weakest
        // part of the gradient, which is where it washed out over busy art.
        // Both colours come from the theme, so this holds in light and dark.
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Math.round(root.scrimHeight)
            visible: root.hasPlayer && overlay.height > 0

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Theme.withAlpha(Theme.surface, 0)
                }
                GradientStop {
                    position: root.scrimSolidStop * 0.5
                    color: Theme.withAlpha(Theme.surface, 0.16)
                }
                GradientStop {
                    position: root.scrimSolidStop
                    color: Theme.withAlpha(Theme.surface, 0.78)
                }
                GradientStop {
                    position: 1.0
                    color: Theme.withAlpha(Theme.surface, 0.86)
                }
            }
        }

        // Centred on the artwork rather than stacked with the text: the
        // buttons are opaque enough to stand on their own, and it leaves the
        // bottom strip to the metadata. Hidden with no player so it does not
        // collide with the centred "No Media" placeholder -- which is why the
        // dimmed/disabled idle states upstream carried are gone from here.
        Row {
            anchors.centerIn: parent
            spacing: root.controlSpacing
            visible: root.hasPlayer
            z: 2

            // Opacity rather than visible: it animates, and it keeps the row
            // hit-testable throughout, so a click during the fade still lands.
            // Only a touch tap could reach an invisible button, since it
            // arrives without the hover that would have revealed it.
            // longDuration, not the shortDuration DMS uses for hover chrome:
            // that is 75ms at this animation speed, which reads as a pop rather
            // than a reveal. The cost is 1s for anyone on the Long setting.
            opacity: coverHover.hovered ? 1 : 0
            scale: coverHover.hovered ? 1 : 0.86

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.longDuration
                    easing.type: Theme.emphasizedEasing
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.longDuration
                    easing.type: Theme.emphasizedEasing
                }
            }

            DankActionButton {
                buttonSize: root.skipSize
                radius: root.skipSize / 2
                iconName: "skip_previous"
                iconSize: root.skipIconSize
                iconColor: Theme.surfaceText
                backgroundColor: Theme.withAlpha(Theme.surfaceContainerHighest, 0.95)
                tooltipText: I18n.tr("Previous")
                onClicked: MprisController.previousOrRewind()
            }

            StyledRect {
                width: root.playSize
                height: root.playSize
                radius: root.playSize / 2
                color: root.accent

                DankIcon {
                    anchors.centerIn: parent
                    name: root.isPlaying ? "pause" : "play_arrow"
                    size: root.playIconSize
                    color: root.onAccent
                }

                StateLayer {
                    disabled: !(root.activePlayer?.canTogglePlaying ?? false)
                    stateColor: root.onAccent
                    cornerRadius: parent.radius
                    tooltipText: root.isPlaying ? I18n.tr("Pause") : I18n.tr("Play")
                    onClicked: {
                        if (root.activePlayer?.canTogglePlaying)
                            root.activePlayer.togglePlaying();
                    }
                }
            }

            DankActionButton {
                buttonSize: root.skipSize
                radius: root.skipSize / 2
                iconName: "skip_next"
                iconSize: root.skipIconSize
                iconColor: Theme.surfaceText
                backgroundColor: Theme.withAlpha(Theme.surfaceContainerHighest, 0.95)
                tooltipText: I18n.tr("Next")
                onClicked: MprisController.next()
            }
        }

        Column {
            id: overlay

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: root.controlMargin
            anchors.rightMargin: root.controlMargin
            anchors.bottomMargin: root.controlMargin
            spacing: Theme.spacingXXS
            z: 2

            Item {
                visible: root.progressVisible
                width: parent.width
                height: 20

                StyledText {
                    id: elapsed

                    visible: root.timesVisible
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.formatTime(root.trackPosition)
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }

                StyledText {
                    id: total

                    visible: root.timesVisible
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.formatTime(root.trackLength)
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }

                // Spans the full width whenever the times are collapsed away,
                // so the bar never leaves a gap where they would have been.
                DankSeekbar {
                    anchors.left: root.timesVisible ? elapsed.right : parent.left
                    anchors.right: root.timesVisible ? total.left : parent.right
                    anchors.leftMargin: root.timesVisible ? Theme.spacingS : 0
                    anchors.rightMargin: root.timesVisible ? Theme.spacingS : 0
                    anchors.verticalCenter: parent.verticalCenter
                    activePlayer: root.activePlayer
                }
            }

            StyledText {
                visible: root.infoVisible
                text: MprisController.stableTitle || I18n.tr("Unknown")
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            StyledText {
                visible: root.infoVisible
                text: MprisController.stableArtist || I18n.tr("Unknown Artist")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
