;;; doom-alpine-dusk-theme.el --- inspired by an alpine sunset -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Author: chesedo <https://github.com/chesedo>
;; Maintainer:
;; Source: Original color palette from an alpine sunset image
;;
;;; Commentary:
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup doom-alpine-dusk-theme nil
  "Options for the `doom-alpine-dusk' theme."
  :group 'doom-themes)

(defcustom doom-alpine-dusk-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-alpine-dusk-theme
  :type 'boolean)

(defcustom doom-alpine-dusk-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-alpine-dusk-theme
  :type 'boolean)

(defcustom doom-alpine-dusk-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'doom-alpine-dusk-theme
  :type '(choice integer boolean))


;;
;;; Theme definition

(def-doom-theme doom-alpine-dusk
                "A dark theme inspired by an alpine sunset — deep indigo sky, steel blue cliffs, burnt orange alpenglow"

                ;; name        default   256       16
                ((bg         '("#1A1830" nil       nil        ))
                 (fg         '("#DDE2EC" "#DDE2EC" "white"    ))

                 ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
                 ;; but can also be useful as a basis for subtle highlights (e.g. for hl-line
                 ;; or region), especially when paired with the `doom-darken', `doom-lighten',
                 ;; and `doom-blend' helper functions.
                 (bg-alt     '("#282348" nil       nil        ))
                 (fg-alt     '("#6878A0" "#6878A0" "white"    ))

                 ;; These should represent a spectrum from bg to fg, where base0 is a starker
                 ;; bg and base8 is a starker fg. For example, if bg is light grey and fg is
                 ;; dark grey, base0 should be white and base8 should be black.
                 (base0      '("#0E0C18" "black"   "black"    ))      ; Near black
                 (base1      '("#141228" "#1e1e1e" "brightblack"))    ; Very dark indigo
                 (base2      '("#1E1C38" "#2e2e2e" "brightblack"))    ; Dark indigo
                 (base3      '("#282348" "#262626" "brightblack"))    ; Mid-dark indigo
                 (base4      '("#38305A" "#3f3f3f" "brightblack"))    ; Indigo border
                 (base5      '("#504870" "#525252" "brightblack"))    ; Mid indigo for comments
                 (base6      '("#605888" "#6b6b6b" "brightblack"))    ; Lighter indigo
                 (base7      '("#7870A0" "#979797" "brightblack"))    ; Light indigo
                 (base8      '("#9088B8" "#dfdfdf" "white"    ))      ; Lightest indigo

                 (grey       '("#4A70AA" "#4A70AA" "brightblack"))  ; Steel blue for dimmed text
                 (red        '("#A03838" "#A03838" "red"          ))  ; Muted red (errors/diffs only)
                 (orange     '("#C04848" "#C04848" "brightred"    ))  ; Bright red
                 (green      '("#506080" "#506080" "green"        ))  ; Deep slate blue
                 (teal       '("#7898C0" "#7898C0" "brightgreen"  ))  ; Pale glacier blue
                 (yellow     '("#6878A0" "#6878A0" "yellow"       ))  ; Blue-grey muted
                 (blue       '("#4A70AA" "#4A70AA" "brightblue"   ))  ; Steel blue cliffs
                 (dark-blue  '("#38305A" "#38305A" "blue"         ))  ; Dark indigo border
                 (magenta    '("#8858C8" "#8858C8" "magenta"      ))  ; Purple accent
                 (violet     '("#6A40A8" "#6A40A8" "brightmagenta"))  ; Dark purple
                 (cyan       '("#7898C0" "#7898C0" "brightcyan"   ))  ; Pale glacier blue
                 (dark-cyan  '("#282348" "#282348" "cyan"         ))  ; Dark indigo

                 ;; These are the "universal syntax classes" that doom-themes establishes.
                 ;; These *must* be included in every doom themes, or your theme will throw an
                 ;; error, as they are used in the base theme defined in doom-themes-base.
                 (highlight      magenta)    ; Purple accent
                 (vertical-bar   (doom-darken base1 0.5))
                 (selection      dark-blue)
                 (builtin        magenta)    ; Purple
                 (comments       base5)      ; Mid indigo
                 (doc-comments   (doom-lighten violet 0.25))  ; Lighter purple
                 (constants      magenta)    ; Purple
                 (functions      magenta)    ; Purple
                 (keywords       violet)     ; Dark purple
                 (methods        magenta)    ; Purple
                 (operators      violet)     ; Dark purple
                 (type           teal)       ; Pale glacier blue
                 (strings        blue)       ; Steel blue
                 (variables      fg)         ; Default
                 (numbers        teal)       ; Glacier blue
                 (region         base2)      ; Dark indigo selection
                 (error          red)        ; Actual red
                 (warning        yellow)     ; Blue-grey muted
                 (success        green)      ; Deep slate blue
                 (vc-modified    magenta)    ; Purple
                 (vc-added       "#119e44")  ; Green for clear meaning
                 (vc-deleted     red)        ; Actual red

                 ;; custom categories
                 (-modeline-bright doom-alpine-dusk-brighter-modeline)
                 (-modeline-pad
                  (when doom-alpine-dusk-padded-modeline
                    (if (integerp doom-alpine-dusk-padded-modeline) doom-alpine-dusk-padded-modeline 4)))

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
                  :background (if doom-alpine-dusk-brighter-comments
                                  (doom-lighten bg 0.05)
                                'unspecified))
                 ((font-lock-keyword-face &override)  :weight 'bold)
                 ((font-lock-constant-face &override) :weight 'bold)
                 ((font-lock-type-face &override)     :slant 'italic)
                 ((font-lock-builtin-face &override)  :slant 'italic)

                ;; Add internal border face here
                (internal-border :background bg-alt)

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
                 (centaur-tabs-active-bar-face :background orange)
                 (centaur-tabs-modified-marker-selected :inherit 'centaur-tabs-selected
                                                        :foreground orange)
                 (centaur-tabs-modified-marker-unselected :inherit 'centaur-tabs-unselected
                                                          :foreground orange)
                 ;;;; company
                 (company-tooltip-selection :background dark-cyan)
                 ;;;; css-mode / scss-mode
                 (css-proprietary-property :foreground red)
                 (css-property             :foreground orange)
                 (css-selector             :foreground red)
                 ;;;; doom-modeline
                 (doom-modeline-bar :background orange)
                 (doom-modeline-evil-emacs-state  :foreground magenta)
                 (doom-modeline-evil-insert-state :foreground orange)
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
                 (markdown-header-face :inherit 'bold :foreground orange)
                 (markdown-url-face    :foreground violet :weight 'normal)
                 (markdown-reference-face :foreground base6)
                 ((markdown-bold-face &override)   :foreground fg)
                 ((markdown-italic-face &override) :foreground fg-alt)
                 ;;;; outline (affects org-mode)
                 ((outline-1 &override) :foreground orange)
                 ((outline-2 &override) :foreground red)
                 ((outline-3 &override) :foreground magenta)
                 ((outline-4 &override) :foreground (doom-darken orange 0.2))
                 ((outline-5 &override) :foreground (doom-darken red 0.2))
                 ((outline-6 &override) :foreground (doom-darken magenta 0.2))
                 ((outline-7 &override) :foreground (doom-darken orange 0.4))
                 ((outline-8 &override) :foreground (doom-darken red 0.4))
                 ;;;; org <built-in>
                 ((org-block &override) :background base0)
                 ((org-block-begin-line &override) :foreground comments :background base0)
                 ;;;; git-gutter-fringe
                 (git-gutter-fr:modified :foreground vc-modified)
                 ;;;; rainbow-delimeters
                 (rainbow-delimiters-depth-1-face :foreground orange)
                 (rainbow-delimiters-depth-2-face :foreground yellow)
                 (rainbow-delimiters-depth-3-face :foreground red)
                 (rainbow-delimiters-depth-4-face :foreground magenta)
                 (rainbow-delimiters-depth-5-face :foreground violet)
                 (rainbow-delimiters-depth-6-face :foreground cyan)
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

;;; doom-alpine-dusk-theme.el ends here
