{
  scheme = "Alpine Slate";
  author = "chesedo";
  # Sampled from the 6016x1840 image area of leftwm/themes/current/background.jpg
  # (alpine granite at dawn) -- NOT the whole 6352x2584 file, a third of which is
  # black padding that would drag the darks to #000000. The darkened eDP rect
  # lies inside the image area and IS included in these figures:
  # darkest 5% #1C1B1A, peaks #61646B, sky #9899A7, lightest 5% #D1C7C6.
  # Backgrounds and foregrounds follow the image; the accent slots keep real
  # saturation on purpose -- the wallpaper is near-monochrome, and deriving
  # base08..base0F literally from it makes syntax highlighting unreadable.
  base00 = "16181C"; # bg — deep neutral slate
  base01 = "1F232A"; # bg-alt — slate one step up
  base02 = "2C323C"; # border / selection bg
  base03 = "4A515E"; # comments / inactive
  base04 = "8A919E"; # muted — blue-grey stone
  base05 = "D6DAE0"; # fg — cool silver
  base06 = "E4E8EE"; # lighter fg
  base07 = "F1F4F8"; # lightest
  base08 = "B05656"; # red — errors / diffs
  base09 = "C4813F"; # orange — warm alpenglow
  base0A = "CBA05A"; # yellow — amber on the peaks
  base0B = "6E8C74"; # green — conifer
  base0C = "7FA0B8"; # cyan — glacier blue
  base0D = "5F87AE"; # blue — steel blue highlight
  base0E = "9C7FA6"; # magenta — muted mauve (cloud light)
  base0F = "7D6552"; # brown — wet rock
}
