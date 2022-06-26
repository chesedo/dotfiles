;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(after! lsp-rust
  (setq lsp-rust-analyzer-server-display-inlay-hints t
        lsp-rust-analyzer-display-chaining-hints t
        lsp-rust-analyzer-display-parameter-hints t)
  (require 'dap-gdb-lldb))

(after! dap-cpptools
  (dap-register-debug-template "Rust::CppTools Run Configuration"
                                 (list :type "cppdbg"
                                       :request "launch"
                                       :name "Rust::Run"
                                       :MIMode "gdb"
                                       :miDebuggerPath "rust-gdb"
                                       :environment []
                                       :program "${workspaceFolder}/target/debug/api"
                                       :cwd "${workspaceFolder}"
                                       :console "external"
                                       :dap-compilation "cargo build"
                                       :dap-compilation-dir "${workspaceFolder}")))

(after! dap-mode
  (setq dap-default-terminal-kind "integrated") ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
  (dap-auto-configure-mode t))

(after! org-journal
  (setq org-journal-dir "~/org/roam/journal/"
        org-journal-date-format "%a, %Y-%b-%d"
        org-journal-file-format "%Y-%V.org"
        org-journal-file-type 'weekly
        org-journal-after-entry-create-hook
        (lambda ()
          (save-excursion
            (beginning-of-buffer)
            (let ((template (org-id-get-create)))
              (unless (search-forward template nil t)
                (insert template "\n\n")
                )
              )
            )
          )
        )
  )

(after! org-roam
  (setq org-roam-capture-templates '(
                                    ("d" "default" plain "%?"
                                     :target (file+head "%<%Y-%m-%d %a %H%M>-${slug}.org" "#+title: ${title}\n")
                                     :unnarrowed t)
                                    ("c" "masters chapter" plain "%?"
                                     :target (file+head "masters/%<%Y-%m-%d %a %H%M>-${slug}.org" "#+title: ${title}\n")
                                     :unnarrowed t)
                                    ("a" "masters article" plain "* Synopsis\n%?"
                                     :target (file+head "masters/articles/${slug}.org" ":PROPERTIES:\n:BIB_TITLE:   %^{Title}\n:BIB_AUTHOR:  %^{Author}\n:BIB_YEAR:    %^{Year}\n:Publication: %^{Publication}\n:END:\n#+title: ${title}\n#+FILETAGS: :article:")
                                     :unnarrowed t)
                                    )
        )
  )

(setq org-agenda-files '("~/org" "~/org/roam/journal"))

(add-hook! text-mode
  (require 'lsp-grammarly)
  (lsp)
  )

(setq lsp-ui-sideline-show-code-actions t)

(after! lsp-grammarly
  (map! :leader :desc "Apply grammarly code actions" :n "c a" #'lsp-ui-sideline-apply-code-actions)
  (add-to-list 'lsp-language-id-configuration '(org-journal-mode . "org"))
  )

(after! lsp-latex
       (setq lsp-latex-build-executable "tectonic")
       (setq lsp-latex-build-args '("-X" "compile" "%f" "--synctex" "--keep-logs" "--keep-intermediates"))
       (setq lsp-latex-forward-search-executable "zathura")
       (setq lsp-latex-forward-search-args '("--synctex-forward" "%l:1:%f" "%p"))
)

(setq lsp-ltex-enabled t)
(setq lsp-ltex-version "15.2.0")
(setq lsp-ltex-language "en-ZA")
(setq lsp-ltex-additional-rules-enable-picky-rules t)

(defun chesedo/synctex-pos ()
    (concat
        (number-to-string (line-number-at-pos))
        ":"
        (number-to-string (current-column))
        ":"
        (buffer-file-name)
    )
)

(defcustom synctex-forward-pdf-file nil
  "PDF file to open and sync"
  :type 'string)

(defun chesedo/synctex-forward (program)
  (let
      (
        (cmd (concat program " --synctex-forward " (chesedo/synctex-pos) " " synctex-forward-pdf-file))
        (async-shell-command-buffer nil)
      )
    (save-window-excursion
      (async-shell-command cmd)
    )
   )
)
(defun chesedo/synctex-forward-zathura ()
  "Open and/or sync latex postision in zathura"
  (interactive)
  (chesedo/synctex-forward "zathura")
)

(map! :localleader :map latex-mode-map :desc "Sync zathura with cursor location" :n "l" #'chesedo/synctex-forward-zathura)
