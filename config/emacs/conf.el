;;;; package -- my conf  -*- lexical-binding:t; coding:utf-8 -*-
;;; Commentary:
;; Author: Martin Zacho
;; Created: Jan 22 2022

;;; Code:

(defvar monitor-scaled-p nil
  "t if we're on a 2x scaled display")
(pcase (string-trim (shell-command-to-string "xrdb -get Xft.dpi"))
  ("192" (setq monitor-scaled-p t)))


(defvar light-theme-p nil
  "t if using a light theme")

(setq light-theme-p (file-exists-p "~/.emacs.d/use-light-theme"))


(require 'use-package)
(setq use-package-always-ensure t)

(use-package package
  :ensure nil
  :custom
  (package-archives
   '(("melpa" . "http://melpa.org/packages/")
     ("gnu" . "http://elpa.gnu.org/packages/")))
  :config
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents)))

(use-package diminish) ; for cleaning up the mode line

(add-to-list 'load-path "/etc/nixos/lib/lisp")
(load "my-utils")

(defun scroll-other-window-line ()
  (interactive)
  (scroll-other-window 1))

(defun scroll-other-window-down-line ()
  (interactive)
  (scroll-other-window-down 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ---- built in packages

(use-package emacs
  :ensure nil
  :mode (("\\.tsx\\'" . tsx-ts-mode)
         ("\\.ts\\'" . tsx-ts-mode))
  :bind (("S-s-<return>" . 'my/urxvtc-here)
         ("C-c <tab>" . 'fill-region)
         ("M-n" . scroll-up-line)
         ("M-p" . scroll-down-line)
         ("M-N" . scroll-other-window-line)
         ("M-P" . scroll-other-window-down-line))
  :hook (minibuffer-setup . cursor-intangible-mode)
  :init
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  :custom
  (debug-on-error nil)
  (inhibit-startup-message t)

  ;; Increase how much is read from processes in a single chunk
  (read-process-output-max (* 512 1024))

  ;; Make emacs use Alt and Meta keysyms (left and right) as meta
  ;; I use Meta_R to access symbols layer
  (x-meta-keysym 'meta)
  ;; Put backup files and auto-save files in a designated dir
  (backup-directory-alist
   '(("." . "~/.emacs.d/backups")
     (tramp-file-name-regexp . "~/.emacs.d/backups")))

  (auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save/\\1" t)))

  ;; Ignore the warning "X and Y are the same file"
  (find-file-suppress-same-file-warnings t)

  ;; Resolve symlinks when opening files
  (find-file-visit-truename t)

  ;; I only use emacs as a single user, no need for lock files
  (create-lockfiles nil)

  ;; Automatic line wrapping
  (fill-column 67)

  ;; Spaces over tabs!
  (indent-tabs-mode nil)
  (tab-width 4)
  (indent-line-function 'insert-tab)

  ;; Access registers with C-x r j
  (register-preview-delay 0.01)

  (use-short-answers t)

  ;; switch-to-buffer runs pop-to-buffer-same-window instead
  (switch-to-buffer-obey-display-actions t)

  ;; Improve scrolling? Still not quite happy here
  (pixel-scroll-precision-mode nil)
  (mouse-wheel-scroll-amount '(1 ((shift) . 1)))
  (mouse-wheel-progressive-speed nil)
  (mouse-wheel-tilt-scroll t)
  (focus-follows-mouse t)
  (scroll-margin 1)
  (scroll-step 1)
  (scroll-conservatively 1000)
  (scroll-up-aggressively 0.01)
  (scroll-down-aggressively 0.01)
  (scroll-up-aggressively 0.01)
  (scroll-down-aggressively 0.01)

  ;; isearch
  (isearch-repeat-on-direction-change t)

  ;; Completion
  (completion-ignore-case t)
  ;; Hide commands which do not work in the current mode.
  (read-extended-command-predicate
   #'command-completion-default-include-p)

  ;; minibuffer
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)

  :config
  ;; Font size (120 = 12pt)
  (if monitor-scaled-p
      (set-face-attribute 'default nil :height 120)
    (set-face-attribute 'default nil :height 170))

  ;; backups
  (make-directory "~/.emacs.d/auto-save/" t)

  ;; Clean up the UI
  (set-fringe-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode 0)
  (tooltip-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (column-number-mode)
  (blink-cursor-mode -1)
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; Insertions overwrite marked region
  (delete-selection-mode 1)

  ;; Don't accidentally horizontal scroll with trackpad
  (global-unset-key (kbd "<wheel-right>"))
  (global-unset-key (kbd "<triple-wheel-right>"))
  (global-unset-key (kbd "<wheel-left>"))
  (global-unset-key (kbd "<triple-wheel-left>"))

  ;; Unbind minimize and quit (I use my WM to kill the window)
  (global-unset-key (kbd "s-m"))
  (global-unset-key (kbd "s-q"))
  (global-unset-key (kbd "C-x C-c"))

  ;; Don't accidentally suspend frame
  (global-unset-key (kbd "C-z"))
  (global-unset-key (kbd "C-x C-z"))

  ;; Clean buffers list automatically at midnight
  (midnight-mode)

  ;; Revert buffers automatically when their content changes on
  ;; disk
  (global-auto-revert-mode t)

  ;; Registers
  (set-register ?c '(file . "/etc/nixos/configuration.nix"))
  (set-register ?e '(file . "/etc/nixos/config/emacs/conf.el"))
  (set-register ?n '(file . "/nix/var/nix/profiles/per-user/root/channels/nixos"))
  (set-register ?d '(file . "~/Downloads"))
  (set-register ?p '(file . "~/playground"))
  (set-register ?p '(file . "~/projects"))
  (set-register ?x '(file . "/persist/restic-exclude-list.txt"))
  (set-register ?b '(file . "/persist/etc/nixos/bin"))
  (set-register ?l '(file . "/persist/etc/nixos/lib"))
  (set-register ?k '(file . "/persist/home/dirs/KEEP_LIST"))
  (set-register ?w '(file . "~/projects/factbird/work.org"))
  (set-register ?C '(file . "~/org/cheat-sheet.org"))

  (advice-add #'completing-read-multiple :filter-args #'crm-indicator))

(use-package simple
  :ensure nil
  :diminish visual-line-mode
  :bind (("C--" . pop-global-mark)
         ("C-@" . (lambda () (interactive) (set-mark-command t)))
         ("C-=" . (lambda () (interactive)
                    (set-mark-command nil)
                    (set-mark-command nil))))
  :preface
  (defun my-disable-global-line-mode ()
    (visual-line-mode -1)
    (global-visual-line-mode -1)
    (toggle-truncate-lines 1))
  :hook ((tabulated-list-mode dired-mode recentf-mode)
         . my-disable-global-line-mode)
  :config
  (auto-fill-mode 0)

  ;; Wrap lines globally except in modes like dired and tabulated
  ;; lists
  (global-visual-line-mode 1))

(use-package ibuffer
  :ensure nil
  :bind (:map ibuffer-mode-map
              ("M-o" . other-window)))

(use-package savehist ; Save minibuffer history
  :ensure nil
  :config
  (savehist-mode))


(use-package electric
  :ensure nil
  :hook (prog-mode-hook . electric-indent-local-mode)
  :config
  ;; Turn off global electrict indent mode, since it's otherwise
  ;; enabled in modes that cannot be hooked to turn it off again
  ;; (such as fundamental mode).
  ;;
  ;; Use electric-indent-local-mode instead, and see the package
  ;; `aggressive indent' declared later.
  (electric-indent-mode -1)
  ;; Automatically inserts closing parenthesis/ brackets etc.
  (electric-pair-mode)
  ;; But don't insert newlines plz
  (electric-layout-mode -1)

  :custom
  (electric-pair-delete-adjacent-pairs 't))

(use-package paren
  :ensure nil
  :custom
  (show-paren-delay 0.1)
  (show-paren-highlight-openparen t)
  (show-paren-when-point-inside-paren t)
  (show-paren-when-point-in-periphery t))

(use-package time
  :ensure nil
  :disabled t
  :custom
  (display-time-24hr-format t)
  (display-time-day-and-date t)
  (display-time-default-load-average nil)
  (display-time-format "%T")
  (display-time-interval 1)
  (display-time-mode t))

;; (use-package winner

;;   :ensure nil
;;   :bind (("C-," . winner-undo)
;;          ("C-." . winner-redo))
;;   :config
;;   ;; Modify winner-redo so it doesn't modify the winner-pending-undo-ring
;;   (defun winner-redo ()			; If you change your mind.
;;     "Restore a more recent window configuration saved by Winner mode."
;;     (interactive)
;;     (cond
;;      ((eq last-command 'winner-undo)
;;       (winner-set
;;        (if (zerop (minibuffer-depth))
;;            (ring-remove winner-pending-undo-ring 0)
;;          (ring-ref winner-pending-undo-ring 0)))
;;       (unless (eq (selected-window) (minibuffer-window))
;;         (message "Winner undid undo")))
;;      (t (user-error "Previous command was not a `winner-undo'"))))
;;   :custom
;;   (winner-boring-buffers ("*Completions*" "*Messages*"))
;;   (winner-mode 1))

(use-package window
  :ensure nil
  :preface
  (defun delete-window-or-buffer ()
    (interactive)
    (if (minibufferp (current-buffer))
        (minibuffer-keyboard-quit)
      (condition-case nil (delete-window)
        (error (kill-buffer (current-buffer))))))

  (defun switch-to-prev-buffer-skip-fun (window buf args)
    (string-match "\\*Async-native-compile-log\\*\\|\\*Help\\*\\|\\*IBuffer\\*\\|\\*Messages\\*\\|\\*Flymake log\\*\\|\\*direnv\\*\\|magit-process:.*\\|\\*Warnings\\*\\|\\*EGLOT.*" (buffer-name buf)))

  (defvar saved-window-configuration nil)

  (defun push-window-configuration ()
    (interactive)
    (push (current-window-configuration) saved-window-configuration)
    (message "pushed window config"))

  (defun pop-window-configuration ()
    (interactive)
    (let ((config (pop saved-window-configuration)))
      (if config
          (progn
            (set-window-configuration config)
            (message "popped window config"))
        (user-error "no window config"))))

  ;; Fix annoying vertical window splitting.
  ;; https://lists.gnu.org/archive/html/help-gnu-emacs/2015-08/msg00339.html
  (defcustom split-window-below nil
    "If non-nil, vertical splits produce new windows below."
    :group 'windows
    :type 'boolean)

  (defcustom split-window-right nil
    "If non-nil, horizontal splits produce new windows to the right."
    :group 'windows
    :type 'boolean)

  (fmakunbound #'split-window-sensibly)

  (defun split-window-sensibly
      (&optional window)
    (setq window (or window (selected-window)))
    (or (and (window-splittable-p window t)
             ;; Split window horizontally.
             (split-window window nil (if split-window-right 'left  'right)))
        (and (window-splittable-p window)
             ;; Split window vertically.
             (split-window window nil (if split-window-below 'above 'below)))
        (and (eq window (frame-root-window (window-frame window)))
             (not (window-minibuffer-p window))
             ;; If WINDOW is the only window on its frame and is not the
             ;; minibuffer window, try to split it horizontally disregarding the
             ;; value of `split-width-threshold'.
             (let ((split-width-threshold 0))
               (when (window-splittable-p window t)
                 (split-window window nil (if split-window-right
                                              'left
                                            'right)))))))

  :bind (("M-o" . other-window)
         ("M-0" . (lambda () (interactive)
                    (kill-buffer (current-buffer))))
         ("C-0" . delete-window-or-buffer)
         ("C-1" . delete-other-windows)
         ("C-2" . split-window-below)
         ("C-3" . split-window-right)
         ("C-4" . (lambda () (interactive)
                    (delete-other-windows)
                    (split-window-right)))
         ("C-x C-b" . ibuffer)
         ("C-." . next-buffer)
         ("C-," . previous-buffer)
         ("M--" . pop-window-configuration)
         ("M-=" . push-window-configuration))
  :custom
  (split-width-threshold 101)
  (split-height-threshold 80)
  (same-window-buffer-names '("*compilation*"))
  (switch-to-prev-buffer-skip #'switch-to-prev-buffer-skip-fun))

(use-package dired
  :ensure nil
  :bind (:map dired-mode-map ("<tab>" . dired-find-file))
  :custom
  ;; Configure dired listing as in my terminal
  (insert-directory-program "ls")
  (dired-listing-switches "-ovAFhb --group-directories-first")
  (dired-switches-in-mode-line 'as-is)
  (dired-kill-when-opening-new-dired-buffer t))

(use-package recentf
  :ensure nil
  :bind ("C-x C-r" . recentf-open-files)
  :custom
  (recentf-max-menu-items 100)
  :config
  (recentf-mode t)
  (run-at-time nil (* 5 60) 'recentf-save-list)

  ;; Customize recentf-save-list so it doesn't disturb me in by
  ;; writing "Recenf saved" in the mode line all the time ....
  (defun recentf-save-list ()
    "Save the recent list.
    Write data into the file specified by `recentf-save-file'.

    Note: Customized by passing 'nil 10' to write-region to suppress
    the 'Wrote recentf file' message. From write-region docs:

    If VISIT is neither t nor nil nor a string, or if Emacs is in batch mode,
    do not splay the 'Wrote file' message."
    (interactive)
    (condition-case error
        (with-temp-buffer
          (erase-buffer)
          (set-buffer-file-coding-system recentf-save-file-coding-system)
          (insert (format-message recentf-save-file-header
                                  (current-time-string)))
          (recentf-dump-variable 'recentf-list recentf-max-saved-items)
          (recentf-dump-variable 'recentf-filter-changer-current)
          (insert "\n\n;; Local Variables:\n"
                  (format ";; coding: %s\n" recentf-save-file-coding-system)
                  ";; End:\n")
          (write-region (point-min) (point-max)
                        (expand-file-name recentf-save-file)
                        nil 10)
          (when recentf-save-file-modes
            (set-file-modes recentf-save-file recentf-save-file-modes))
          nil)
      (error
       (warn "recentf mode: %s" (error-message-string error))))))

(use-package subword
  :ensure nil
  :diminish subword-mode
  :config
  (global-subword-mode))

(use-package warnings
  :ensure nil
  :custom
  (warning-suppress-types '((comp))))

(use-package eldoc
  :diminish eldoc-mode
  :ensure nil
  :custom
  (eldoc-echo-area-display-truncation-message t)
  (eldoc-echo-area-prefer-doc-buffer t)
  (eldoc-echo-area-use-multiline-p nil))

(use-package ediff-wind
  :ensure nil
  :custom
  ;; Use a single frame and split windows horizontally in ediff
  (ediff-window-setup-function #'ediff-setup-windows-plain)
  (ediff-split-window-function #'split-window-horizontally))

(use-package ido
  :ensure nil
  :bind ("C-x b" . ido-switch-buffer))

(use-package epa
  :ensure nil
  :custom
  (epg-pinentry-mode 'ask)
  (epg-gpg-program "gpg"))

(use-package auth-source
  :ensure nil
  :custom
  (auth-sources '("~/.authinfo.gpg"))
  (auth-source-debug nil))

(use-package man
  :ensure nil
  :bind (:map Man-mode-map
              ("M-n" . scroll-up-line)
              ("M-p" . scroll-down-line))
  :config
  ;; For some reason interactive parsing of man-args fails for me,
  ;; this fixes that
  (defun man (man-args)
    (interactive "MMan entry: ")
    (setq man-args (Man-translate-references man-args))
    (Man-getpage-in-background man-args))
  :custom
  (Man-notify-method 'aggressive))

(use-package info
  :bind (:map Info-mode-map
              ("M-n" . scroll-up-line)
              ("M-p" . scroll-down-line))
  :custom
  (Info-directory-list
   (append '("/etc/nixos/lib/info") Info-directory-list)))

(use-package org
  :ensure nil
  :init
  (defun my/org-mode-hook ()
    "Stop the org-level headers from increasing in height relative to the other text."
    (dolist (face '(org-level-1
                    org-level-2
                    org-level-3
                    org-level-4
                    org-level-5))
      (set-face-attribute face nil :weight 'semi-bold :height 1.0)))
  :custom
  (org-agenda-files '("~/projects/factbird/work.org"))
  (org-todo-keywords
   '((sequence "READY" "IN PROGRESS" "IN REVIEW" "IN CI" "DONE" "PAUSED")))
  (org-todo-keyword-faces
   `(("READY" :foreground "yellow3" :weight bold)
     ("DONE" :foreground "light sea green" :weight bold)
     ("IN PROGRESS" :foreground "peru" :weight bold)
     ("IN REVIEW" :foreground "pale violet red" :weight bold)
     ("IN CI" :foreground "goldenrod" :weight bold)
     ("PAUSED" :foreground "thistle" :weight bold)))
  (org-capture-templates
   '(("p" "Pull request" entry
      (file+headline "~/projects/factbird/work.org" "Pull Requests")
      "* READY %? %^{ISSUE}p %^{PR|nil}p"
      :prepend t
      :jump-to-captured t)
     ("B" "Break" item
      (file+olp+datetree "~/projects/factbird/work.org" "Interrupts")
      "%T break %?"
      :clock-in t
      :clock-resume t
      :prepend t)
     ("r" "Review" item
      (file+olp+datetree "~/projects/factbird/work.org" "Interrupts")
      "%T review: %?"
      :clock-in t
      :clock-resume t
      :prepend t)
     ("m" "Misc" item
      (file+olp+datetree "~/projects/factbird/work.org" "Interrupts")
      "%T misc: %?"
      :clock-in t
      :clock-resume t
      :prepend t)))
  :config
  (unbind-key (kbd "C-,") org-mode-map)
  (add-hook 'org-mode-hook #'my/org-mode-hook)
  (add-hook 'org-mode-hook 'auto-fill-mode))

(use-package ps-print
  :ensure nil
  :custom
  (ps-print-header nil))

(use-package flyspell
  :ensure nil
  :hook ((text-mode org-mode message-mode) . flyspell-mode)
  :hook ((yaml-mode mhtml-mode claudia-chat-mode) . (lambda ()
                                                      (flyspell-mode 0)))
  :bind (:map flyspell-mode-map
              ("C-S-s" . ispell-word)
              ("C-S-d" . ispell-change-dictionary))
  :custom
  (ispell-program-name "aspell")
  :config
  (unbind-key (kbd "C-.") flyspell-mode-map)
  (unbind-key (kbd "C-,") flyspell-mode-map))

(when (executable-find "ps2pdf")
  (defun my/pdf-print-buffer (&optional filename)
    "Print file in the current buffer as pdf, including font, color,
and underline information.  This command works only if you are using a
window system, so it has a way to determine color values.

C-u COMMAND prompts user where to save the Postscript file (which is
then converted to PDF at the same location."
    (interactive (list (if current-prefix-arg
                           (ps-print-preprint 4)
                         (concat (file-name-sans-extension (buffer-file-name))
                                 ".ps"))))
    (ps-print-without-faces (point-min) (point-max) filename)
    (shell-command (concat "ps2pdf " filename))
    (delete-file filename)
    (message "Deleted %s" filename)
    (message "Wrote %s" (concat (file-name-sans-extension filename) ".pdf"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ----- local packages

;; a better gc strategy
(use-package gcmh
  :if (locate-library "gcmh.el")
  :diminish
  :config
  (gcmh-mode 1))

;; Display Control-l characters in a pretty way
(use-package pp-c-l
  :disabled t
  :if (locate-library "pp-c-l.el")
  :config
  (pretty-control-l-mode))

(use-package savekill ; Save kill ring to disk
  :if (locate-library "savekill.el")
  :custom
  (savekill-max-saved-items 500)
  (kill-ring-max 500))

(use-package breadcrumb
  :disabled t
  :if (locate-library "breadcrumb.el")
  :custom
  (breadcrumb-imenu-crumb-separator "; ")
  (breadcrumb-project-max-length 0)
  (breadcrumb-imenu-max-length 0.5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ---- packages from melpa

(use-package modus-themes
  :if (if light-theme-p t)
  :init
  (load-theme 'modus-operandi t))

(use-package solarized-theme
  :if (not light-theme-p)
  :custom
  (solarized-scale-org-headlines nil)
  (x-underline-at-descent-line t)
  (solarized-high-contrast-mode-line nil)
  (solarized-emphasize-indicators t)
  (solarized-use-less-bold nil)
  (solarized-use-more-italic t)
  (custom-enabled-themes '(solarized-dark))
  ;; make theme safe to load
  (custom-safe-themes t)
  :config
  ;; Make child theme
  (eval-when-compile
    (require 'solarized-palettes))
  (deftheme my-solarized-dark "The dark variant of the Solarized colour theme")
  (deftheme my-solarized-light "The light variant of the Solarized colour theme")
  (solarized-with-color-variables
    'dark 'my-solarized-dark solarized-dark-color-palette-alist
    '("My solarized child theme."
      (custom-theme-set-faces
       theme-name
       `(ivy-current-match ((,class (:weight bold :background ,base02 :underline nil))))
       `(region ((t (:extend t :background "#0e2e3f" :foreground "gray"))))
       `(markdown-inline-code-face ((,class (:foreground "#268bd2"))))
       `(markdown-code-face ((,class (:foreground "#839496"))))
       `(markdown-url-face ((,class (:foreground "#839496"))))
       `(markdown-header-face ((,class (:foreground "#839496" :underline t))))
       `(header-line
         ((,class (:inverse-video unspecified
                                  :height ,(if monitor-scaled-p 120 170)
                                  :overline nil
                                  :underline ,s-header-line-underline
                                  :foreground ,s-header-line-fg
                                  :background ,s-header-line-bg
                                  :box (:line-width 2 :color ,s-header-line-bg
                                                    :style unspecified)))))
       `(mu4e-thread-fold-face ((t (:inherit (mu4e-header-face)))))
       `(which-func ((,class (:foreground "#839496"))))
       '(Info-quoted ((t (:foreground "light salmon" :family "bold"))))
       '(blamer-face ((t :foreground "#7a88cf" :background nil :height 100 :italic t)))
       '(bookmark-face ((t (:background "Black" :foreground "gray19"))))
       '(comint-highlight-prompt ((t (:inherit minibuffer-prompt))))
       '(company-coq-comment-h1-face ((t (:inherit font-lock-doc-face :height 2))))
       '(company-coq-features/code-folding-bullet-face ((t (:inherit link :underline nil))))
       '(coq-cheat-face ((t (:background "red4"))))
       '(diredfl-dir-heading ((t (:foreground "Yellow"))))
       '(diredfl-dir-name ((t (:foreground "#7474FFFFFFFF"))))
       '(diredfl-dir-priv ((t (:foreground "blue"))))
       '(diredfl-exec-priv ((t (:foreground "spring green"))))
       '(diredfl-executable-tag ((t nil)))
       '(diredfl-flag-mark ((t (:background "black" :foreground "green"))))
       '(diredfl-flag-mark-line ((t (:background "gray0"))))
       '(diredfl-no-priv ((t (:foreground "dark slate blue"))))
       '(diredfl-read-priv ((t (:foreground "khaki"))))
       '(diredfl-write-priv ((t (:foreground "orange red"))))
       '(dirvish-hl-line ((t (:extend t :background "gray4"))))
       '(idle-highlight ((t (:inherit region :background "dark slate gray" :foreground "gray"))))
       '(mouse ((t (:background "white smoke"))))
       '(mu4e-column-faces-thread-subject ((t (:foreground "light green"))))
       '(mu4e-column-faces-to-from ((t (:foreground "dark cyan"))))
       '(proof-locked-face ((t (:extend t :background "#002430"))))
       '(proof-mouse-highlight-face ((t (:background "medium spring green"))))
       '(sml/time ((t (:inherit sml/modes))))
       '(world-clock-label ((t (:inherit font-lock-variable-name-face))))
       ))))

(use-package all-the-icons) ; run M-x all-the-icons-install-fonts

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package helpful
  :custom
  (helpful-max-buffers 1)
  (help-window-select t))

(use-package unfill)        ; Provides unfill-region

(use-package mode-line-bell
  :config
  (mode-line-bell-mode))

(use-package hide-mode-line
  :defer t
  :hook (pdf-view-mode . hide-mode-line-mode)
  :hook (pdf-view-mode . (lambda () (setq cursor-type nil))))

(use-package anzu ;; Display isearch info in mode line
  :custom
  (anzu-mode-lighter "")
  (anzu-deactivate-region t)
  (anzu-search-threshold 1000)
  (anzu-replace-threshold 50)
  (anzu-replace-to-string-separator " => ")
  :config
  (global-anzu-mode +1))

(use-package dimmer ;; Dim unactive window slightly
  :disabled t
  :custom
  (dimmer-fraction 0.1)
  :init
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-mode t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package centered-cursor-mode
  :commands centered-cursor-mode)

(use-package shackle ;; Arrange buffers
  :custom
  (shackle-select-reused-windows t)
  (shackle-inhibit-window-quit-on-same-windows t)
  (shackle-rules '())
  ;; '((flymake-diagnostics-buffer-mode  :select nil :align below :size 0.15)
  ;;   (flymake-project-diagnostics-mode :select nil :align below :size 0.15)
  ;;   (compilation-mode :select t :other nil)
  ;;   (help-mode :select t :same t )
  ;;   (helpful-mode :select t :same t )
  ;;   ("*eldoc.*" :select t :same t :regexp t)
  ;;   ("*corfu doc.*" :select t :same t :regexp t)
  ;;   ("*xref*" :select t :other t )
  ;;   (".*ag search.*" :select t :same t  :regexp t)))
  :init
  (shackle-mode))

(use-package aggressive-indent
  :diminish aggressive-indent-mode
  :hook (emacs-lisp-mode . aggressive-indent-mode)
  :hook (sh-mode-hook . aggressive-indent-mode))

(use-package pdf-tools
  :mode ("\\.pdf\\'"    . pdf-view-mode)
  :hook (pdf-view-mode
         . (lambda ()
             (local-set-key (kbd "C-s") 'isearch-forward)
             (local-set-key (kbd "C-r") 'isearch-backward)
             (pdf-isearch-minor-mode)
             (blink-cursor-mode -1)))
  :hook (pdf-view-midnight-minor-mode
         . (lambda()
             (internal-show-cursor nil nil)
             (blink-cursor-mode -1)))
  :custom
  (pdf-view-display-size 'fit-height)
  :config
  (pdf-tools-install))

(use-package visual-regexp)
(use-package visual-regexp-steroids
  :after visual-regexp
  :bind (("C-c r"   . vr/query-replace)))

(use-package god-mode
  :bind ("<escape>" . god-mode-all)
  :bind (:map god-local-mode-map
              (("z" . repeat)
               ("i" . god-local-mode)))
  :bind (:map isearch-mode-map
              (("<f1>" . isearch-repeat-forward)
               ("<f2>" . isearch-repeat-backward)))
  :preface
  (defun my-god-mode-update-cursor-type ()
    (setq cursor-type (if god-local-mode 'hollow 'box))
    (setq blink-cursor-blinks (if god-local-mode 1 0)))
  :custom
  (god-mode-lighter-string "ᐉ")
  (god-mode-enable-function-key-translation nil)
  (god-mode-alist '((nil . "C-") ("g" . "C-M-")))
  :config
  (add-hook 'post-command-hook #'my-god-mode-update-cursor-type))

(use-package which-key
  :defer nil
  :diminish which-key-mode
  :custom
  (which-key-idle-delay 0.2)
  :config
  (which-key-mode)
  (which-key-enable-god-mode-support))

(use-package org-fragtog)

(use-package magit
  :custom
  (magit-refresh-verbose t)
  (magit-diff-refine-hunk t)
  ;; Display all buffers in the same window
  (magit-display-buffer-function
   (lambda (buffer)
     (display-buffer buffer '(display-buffer-same-window))))
  (vc-follow-symlinks t)
  (vc-make-backup-files t)
  (magit-auto-revert-mode t)
  (magit-diff-refine-hunk 'all)
  (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)
  (magit-section-visibility-indicator '("…" . t))
  :config
  (remove-hook 'magit-status-sections-hook #'magit-insert-tags-header)
  (remove-hook 'magit-status-sections-hook #'magit-insert-unpushed-to-upstream-or-recent)
  (remove-hook 'magit-status-sections-hook #'magit-insert-status-headers))

(use-package magit-delta
  :disabled nil
  :after magit
  :config
  (setq magit-delta-default-dark-theme "zenburn")
  (setq magit-delta-hide-plus-minus-markers nil)
  :hook (magit-mode . magit-delta-mode))

(use-package abridge-diff ; improve long one-line diffs
  :diminish abridge-diff-mode
  :after magit
  :config (abridge-diff-mode 1))

(use-package diff-hl
  :init
  (global-diff-hl-mode))

(use-package browse-at-remote)

(use-package ag
  :preface
  (defun my-ag-next-line ()
    "Move to the next entry and display its source in the appropriate window."
    (interactive)
    (compilation-next-error 1)
    (compilation-display-error)
    (recenter-other-window 0))
  (defun my-ag-prev-line ()
    "Move to the previous entry and display its source in the appropriate window."
    (interactive)
    (compilation-next-error -1)
    (compilation-display-error)
    (recenter-other-window 0))
  :bind (:map ag-mode-map
              ("." . my-ag-next-line)
              ("," . my-ag-prev-line))
  :custom
  (ag-reuse-buffers t)
  (ag-highlight-search t)
  (ag-ignore-list '(".git" "dist" "\\_build\\")))

(use-package vertico
  :bind (:map vertico-map
              ("M-n" . vertico-next-group)
              ("M-p" . vertico-previous-group))
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 8)
  (vertico-resize t)
  (vertico-cycle nil)
  (vertico-multiform-commands
   '((execute-extended-command unobtrusive) ; M-x
     (consult-imenu buffer indexed)
     (consult-buffer buffer indexed)
     (consult-git-grep buffer indexed)
     (consult-grep buffer indexed)
     (consult-xref buffer indexed)
     (consult-find buffer indexed)))
  :init
  (vertico-mode)
  (vertico-multiform-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil ; part of vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package corfu
  :bind
  (:map corfu-map
        ;; make help windows persistent so "q" will bury them
        ("M-h" . (lambda () (interactive) (corfu-info-documentation t)))
        ("SPC" . corfu-insert-separator)
        )
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-cycle t)
  (corfu-count 20)
  (eldoc-add-command #'corfu-insert)
  :init
  (corfu-echo-mode)
  (corfu-history-mode)
  (corfu-indexed-mode -1)
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-s" . marginalia-cycle))
  :custom
  (marginalia-align 'left)
  :init
  (marginalia-mode))

(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  (setq consult-async-min-input 1)

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

(use-package embark
  :after which-key
  :bind
  (("C-h b" . embark-bindings))

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package direnv
  :custom
  (direnv-always-show-summary nil)
  :init
  (direnv-mode -1))

(use-package page-break-lines
  :diminish
  :config
  (global-page-break-lines-mode))

(use-package gptel
  :hook (gptel-post-response-functions . gptel-end-of-response)
  :hook (gptel-post-stream-hook . gptel-auto-scroll)
  :config
  (let ((backend
         (gptel-make-anthropic
             "Claude"
           :stream t
           :key (with-temp-buffer
                  (insert-file-contents
                   (let ((tmp-file (make-temp-file "api-key")))
                     (epa-decrypt-file
                      "/persist/misc/anthropic-api-key.gpg"
                      tmp-file)
                     tmp-file))
                  (buffer-string)))))
    (setq gptel-backend backend
          gptel-model 'claude-3-sonnet-20240229
          gptel-use-header-line t)))

(use-package rfc-mode
  :custom
  (rfc-mode-directory (expand-file-name "~/.cache/rfc/")))

(use-package elfeed
  :bind ("C-x w" . elfeed)
  :custom
  (elfeed-feeds
   '(;; tech media
     "https://rss.slashdot.org/Slashdot/slashdotLinux"
     "https://rss.slashdot.org/Slashdot/slashdotSecurity"
     ;; security people
     "https://www.schneier.com/feed/atom/"
     "https://krebsonsecurity.com/feed/"
     "https://maxwelldulin.invades.space/resources-rss.xml"
     "https://portswigger.net/research/rss"
     ;; misc
     "http://nullprogram.com/feed/"
     "https://planet.emacslife.com/atom.xml"))
  (elfeed-search-title-max-width 60)
  (elfeed-search-title-min-width 60))


(load "~/.emacs.d/conf-prog-modes.el")
(load "~/.emacs.d/conf-mail.el")
(load "~/projects/claudia/dev.el")

;;; conf.el ends here
