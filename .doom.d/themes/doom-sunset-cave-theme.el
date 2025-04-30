;;; doom-sunset-cave-theme.el --- inspired by a sunset through a cave -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Author: chesedo <https://github.com/chesedo>
;; Maintainer:
;; Source: Original color palette from a cave sunset image
;;
;;; Commentary:
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup doom-sunset-cave-theme nil
  "Options for the `doom-sunset-cave' theme."
  :group 'doom-themes)

(defcustom doom-sunset-cave-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-sunset-cave-theme
  :type 'boolean)

(defcustom doom-sunset-cave-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-sunset-cave-theme
  :type 'boolean)

(defcustom doom-sunset-cave-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'doom-sunset-cave-theme
  :type '(choice integer boolean))


;;
;;; Theme definition

(def-doom-theme doom-sunset-cave
                "A dark theme inspired by a sunset viewed through a cave"

                ;; name        default   256       16
                ((bg         '("#1A1A1D" nil       nil        ))
                 (fg         '("#E6DDD1" "#E6DDD1" "white"    ))

                 ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
                 ;; but can also be useful as a basis for subtle highlights (e.g. for hl-line
                 ;; or region), especially when paired with the `doom-darken', `doom-lighten',
                 ;; and `doom-blend' helper functions.
                 (bg-alt     '("#2C3241" nil       nil        ))
                 (fg-alt     '("#A7B1C1" "#A7B1C1" "white"    ))

                 ;; These should represent a spectrum from bg to fg, where base0 is a starker
                 ;; bg and base8 is a starker fg. For example, if bg is light grey and fg is
                 ;; dark grey, base0 should be white and base8 should be black.
                 (base0      '("#1A1614" "black"   "black"    ))      ; Dark orange-tinted black
                 (base1      '("#211C1A" "#1e1e1e" "brightblack"))    ; Dark orange-brown
                 (base2      '("#303542" "#2e2e2e" "brightblack"))    ; Slightly lighter
                 (base3      '("#3B4252" "#262626" "brightblack"))    ; Mid grey
                 (base4      '("#4C566A" "#3f3f3f" "brightblack"))    ; Mid-light grey
                 (base5      '("#616E88" "#525252" "brightblack"))    ; Light grey for comments
                 (base6      '("#728096" "#6b6b6b" "brightblack"))    ; Lighter grey
                 (base7      '("#838BA3" "#979797" "brightblack"))    ; Very light grey
                 (base8      '("#97A1B8" "#dfdfdf" "white"    ))      ; Lightest grey

                 (grey       '("#3c98e0" "#3c98e0" "brightblack"))  ; Bright blue for dimmed text
                 (red        '("#E8846C" "#E8846C" "red"          ))  ; Sunset orange
                 (orange     '("#FFB4A2" "#FFB4A2" "brightred"    ))  ; Light coral
                 (green      '("#88C0D0" "#88C0D0" "green"        ))  ; Light blue instead
                 (teal       '("#B48EAD" "#B48EAD" "brightgreen"  ))  ; Purple
                 (yellow     '("#A7B1C1" "#A7B1C1" "yellow"       ))  ; Muted blue-grey
                 (blue       '("#3c98e0" "#3c98e0" "brightblue"   ))  ; Bright blue
                 (dark-blue  '("#465366" "#465366" "blue"         ))  ; Dark blue-grey
                 (magenta    '("#E8846C" "#E8846C" "magenta"      ))  ; Sunset orange
                 (violet     '("#B48EAD" "#B48EAD" "brightmagenta"))  ; Purple
                 (cyan       '("#88C0D0" "#88C0D0" "brightcyan"   ))  ; Light blue
                 (dark-cyan  '("#2C3241" "#2C3241" "cyan"         ))  ; Dark background color

                 ;; These are the "universal syntax classes" that doom-themes establishes.
                 ;; These *must* be included in every doom themes, or your theme will throw an
                 ;; error, as they are used in the base theme defined in doom-themes-base.
                 (highlight      orange)     ; Changed from blue to be more sunset-themed
                 (vertical-bar   (doom-darken base1 0.5))
                 (selection      dark-blue)
                 (builtin        red)       ; Changed to our sunset orange
                 (comments       base5)     ; Keep gray comments
                 (doc-comments   (doom-lighten red 0.25))   ; Lighter version of our sunset orange
                 (constants      magenta)   ; Changed from blue to warmer color
                 (functions      red)       ; Keep consistent with builtin
                 (keywords       orange)    ; Changed from green to be warmer
                 (methods        red)       ; Keep consistent with functions
                 (operators      red)       ; Changed from orange to match other syntax
                 (type           orange)    ; Changed from yellow to be more consistent
                 (strings        yellow)    ; Changed from green to be warmer
                 (variables      fg)        ; Keep default
                 (numbers        violet)    ; Keep for contrast
                 (region         base2)     ; Keep for selection
                 (error          red)       ; Keep
                 (warning        yellow)    ; Keep
                 (success        green)     ; Keep
                 (vc-modified    orange)    ; Changed from blue to match theme
                 (vc-added       "#119e44") ; Keep green for clear meaning
                 (vc-deleted     red)       ; Keep

                 ;; custom categories
                 (-modeline-bright doom-sunset-cave-brighter-modeline)
                 (-modeline-pad
                  (when doom-sunset-cave-padded-modeline
                    (if (integerp doom-sunset-cave-padded-modeline) doom-sunset-cave-padded-modeline 4)))

                 (modeline-fg     'unspecified)
                 (modeline-fg-alt base5)

                 (modeline-bg
                  (if -modeline-bright
                      base3
                    `(,(doom-darken (car bg) 0.15) ,@(cdr base0))))
                 (modeline-bg-alt
                  (if -modeline-bright
                      base3
                    `(,(doom-darken (car bg) 0.1) ,@(cdr base0))))
                 (modeline-bg-inactive     (doom-darken bg 0.1))
                 (modeline-bg-inactive-alt `(,(car bg) ,@(cdr base1))))


                ;;;; Base theme face overrides
                (((font-lock-comment-face &override)
                  :slant 'italic
                  :background (if doom-sunset-cave-brighter-comments
                                  (doom-lighten bg 0.05)
                                'unspecified))
                 ((font-lock-keyword-face &override)  :weight 'bold)
                 ((font-lock-constant-face &override) :weight 'bold)
                 ((font-lock-type-face &override)     :slant 'italic)
                 ((font-lock-builtin-face &override)  :slant 'italic)

                 ((line-number &override) :foreground base4)
                 ((line-number-current-line &override) :foreground fg)
                 (mode-line
                  :background modeline-bg :foreground modeline-fg
                  :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
                 (mode-line-inactive
                  :background modeline-bg-inactive :foreground modeline-fg-alt
                  :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
                 (mode-line-emphasis :foreground (if -modeline-bright base8 highlight))
                 (tooltip              :background bg-alt :foreground fg)

                 ;;;; centaur-tabs
                 (centaur-tabs-active-bar-face :background orange)  ; Changed from blue - the active tab indicator
                 (centaur-tabs-modified-marker-selected :inherit 'centaur-tabs-selected
                                                        :foreground orange)  ; Changed from blue - modified file marker
                 (centaur-tabs-modified-marker-unselected :inherit 'centaur-tabs-unselected
                                                          :foreground orange)  ; Changed from blue
                 ;;;; company
                 (company-tooltip-selection :background dark-cyan)
                 ;;;; css-mode / scss-mode
                 (css-proprietary-property :foreground red)       ; Changed from orange - webkit/moz prefixed properties
                 (css-property             :foreground orange)    ; Changed from green - normal CSS properties
                 (css-selector             :foreground red)       ; Changed from blue - CSS selectors
                 ;;;; doom-modeline
                 (doom-modeline-bar :background orange)           ; Changed from blue - the colored bar in modeline
                 (doom-modeline-evil-emacs-state  :foreground magenta)  ; Keep
                 (doom-modeline-evil-insert-state :foreground orange)   ; Changed from blue
                 ;;;; elscreen
                 (elscreen-tab-other-screen-face :background "#353a42" :foreground "#1e2022")
                 ;;;; eshell-git-prompt powerline theme
                 (eshell-git-prompt-powerline-dir-face :background "steel blue" :foreground bg)
                 (eshell-git-prompt-powerline-clean-face :background "foreset green" :foreground bg)
                 (eshell-git-prompt-powerline-not-clean-face :background "indian red" :foreground bg)
                 ;;; helm
                 (helm-selection :inherit 'bold
                                 :background selection
                                 :distant-foreground bg
                                 :extend t)
                 ;;;; markdown-mode
                 (markdown-markup-face :foreground base5)
                 (markdown-header-face :inherit 'bold :foreground orange)  ; Changed from violet
                 (markdown-url-face    :foreground violet :weight 'normal) ; Changed from teal
                 (markdown-reference-face :foreground base6)
                 ((markdown-bold-face &override)   :foreground fg)
                 ((markdown-italic-face &override) :foreground fg-alt)
                 ;;;; outline (affects org-mode)
                 ((outline-1 &override) :foreground orange)                      ; Changed from blue
                 ((outline-2 &override) :foreground red)                        ; Changed from green
                 ((outline-3 &override) :foreground magenta)                    ; Changed from teal
                 ((outline-4 &override) :foreground (doom-darken orange 0.2))   ; Changed from blue
                 ((outline-5 &override) :foreground (doom-darken red 0.2))      ; Changed from green
                 ((outline-6 &override) :foreground (doom-darken magenta 0.2))  ; Changed from teal
                 ((outline-7 &override) :foreground (doom-darken orange 0.4))   ; Changed from blue
                 ((outline-8 &override) :foreground (doom-darken red 0.4))      ; Changed from green
                 ;;;; org <built-in>
                 ((org-block &override) :background base0)
                 ((org-block-begin-line &override) :foreground comments :background base0)
                 ;;;; git-gutter-fringe
                 (git-gutter-fr:modified :foreground vc-modified)
                 ;;;; rainbow-delimeters
                 (rainbow-delimiters-depth-1-face :foreground orange)   ; Changed from blue
                 (rainbow-delimiters-depth-2-face :foreground yellow)   ; Keep
                 (rainbow-delimiters-depth-3-face :foreground red)      ; Changed from orange
                 (rainbow-delimiters-depth-4-face :foreground magenta)  ; Changed from green
                 (rainbow-delimiters-depth-5-face :foreground violet)   ; Changed from cyan
                 (rainbow-delimiters-depth-6-face :foreground cyan)     ; Changed from violet
                 ;;;; solaire-mode
                 (solaire-mode-line-face
                  :inherit 'mode-line
                  :background modeline-bg-alt
                  :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt)))
                 (solaire-mode-line-inactive-face
                  :inherit 'mode-line-inactive
                  :background modeline-bg-inactive-alt
                  :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-alt)))
                 ;;;; vterm
                 (vterm-color-black   :background (doom-lighten base0 0.75)   :foreground base0)
                 (vterm-color-red     :background (doom-lighten red 0.75)     :foreground red)
                 (vterm-color-green   :background (doom-lighten green 0.75)   :foreground green)
                 (vterm-color-yellow  :background (doom-lighten yellow 0.75)  :foreground yellow)
                 (vterm-color-blue    :background (doom-lighten blue 0.75)    :foreground blue)
                 (vterm-color-magenta :background (doom-lighten magenta 0.75) :foreground magenta)
                 (vterm-color-cyan    :background (doom-lighten cyan 0.75)    :foreground cyan)
                 (vterm-color-white   :background (doom-lighten base8 0.75)   :foreground base8)
                 ))

;;; doom-sunset-cave-theme.el ends here
