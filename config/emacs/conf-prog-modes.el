;;;; package -- prog conf -*- lexical-binding:t; coding:utf-8 -*-
;;; Commentary:
;; Author: Martin Zacho
;; Created: Nov 02 2024

;; built-in

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; --- compilation, flymake and eglot

(use-package compile
  :defer t
  :no-require
  :bind (:map compilation-mode-map
              ("c" . compile))
  :preface
  (defun compilation-ansi-color-process-output ()
    (require 'ansi-color)
    (ansi-color-process-output nil)
    (set (make-local-variable 'comint-last-output-start)
         (point-marker)))
  (defun display-buffer-from-compilation-p (_buffer-name _action)
    (unless current-prefix-arg
      (with-current-buffer (window-buffer)
        (derived-mode-p 'compilation-mode))))
  :init
  ;; https://emacs.stackexchange.com/questions/31493/print-elapsed-time-in-compilation-buffer/56130#56130
  (make-variable-buffer-local 'my-compilation-start-time)
  (defun my-compilation-start-hook (proc)
    (setq my-compilation-start-time (current-time)))

  (defun my-compilation-finish-function (buf why)
    (let* ((elapsed  (time-subtract nil my-compilation-start-time))
           (msg (format "Compilation took: %s" (format-time-string "%T.%N" elapsed t))))
      (save-excursion (goto-char (point-max)) (insert msg))
      (message "Compilation %s: %s" (string-trim-right why) msg)))
  (add-hook 'compilation-start-hook #'my-compilation-start-hook)
  (add-hook 'compilation-finish-functions #'my-compilation-finish-function)
  ;; Make compile-goto-error display in same window
  (push '(display-buffer-from-compilation-p
          display-buffer-same-window
          (inhibit-same-window . nil))
        display-buffer-alist)
  :hook (compilation-filter . compilation-ansi-color-process-output)
  :hook (compilation-mode . (lambda () (idle-highlight-mode)))
  :custom
  (ansi-color-for-compilation-mode t)
  (compilation-always-kill t)
  (compilation-auto-jump-to-first-error nil)
  (compilation-scroll-output 'first-error)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  ;; List of regexps to parse error messages into hyperlinks
  ;; Can contain pre-deficed symbol from compilation-error-regexp-alist-alist
  ;; (compilation-error-regexp-alist
  ;;  '(;; Cargo errors
  ;;    ("', \\(\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\)\\)" 2 3 4 nil 1)
  ;;    ("at \\(\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\)\\)" 2 3 4 nil 1)))
  )

(use-package comint-mode
  :ensure nil
  :no-require
  :custom
  (setq comint-process-echoes t)
  (setq comint-move-point-for-output t)
  ;; Parse ubuntu prompts correctly when attaching to Docker containers
  (add-hook 'comint-output-filter-functions 'comint-osc-process-output))

(use-package flymake
  :ensure nil
  :custom
  ;; Don't display error-symbols in fringe, since flymake already
  ;; underlines warnings, errors etc.
  (flymake-fringe-indicator-position nil))

(use-package flymake-diagnostic-at-point
  :after flymake
  :config
  ;; Add hook with DEPTH set to 100
  (remove-hook 'flymake-mode-hook  #'flymake-diagnostic-at-point-mode)
  (add-hook 'flymake-mode-hook  #'flymake-diagnostic-at-point-mode 85)
  :custom
  (flymake-diagnostic-at-point-error-prefix "")
  (flymake-diagnostic-at-point-display-diagnostic-function
   'flymake-diagnostic-at-point-display-minibuffer))

;; (setenv "RA_LOG" "rust_analyzer=debug")

(use-package eglot
  :ensure nil
  :bind (:map eglot-mode-map
              ("C-c C-e a" . eglot-code-actions)
              ("C-c C-e o" . eglot-code-action-organize-imports)
              ("C-c C-e n" . flymake-goto-next-error)
              ("C-c C-e p" . flymake-goto-prev-error)
              ("C-c C-e e" . flymake-show-project-diagnostics)
              ("C-c C-e t" . eglot-find-typeDefinition)
              ("C-c C-e i" . eglot-find-implementation)
              ("C-c C-c" . compile)
              ;; VSCode-ish bindings
              ("<f2>" . eglot-rename)
              ("<f8>" . flymake-goto-next-error)
              ("S-<f8>" . flymake-goto-prev-error)
              ("<f12>" . xref-find-definitions)
              ("<f5>" . recompile))
  :hook (eglot-managed-mode . (lambda () (eglot-inlay-hints-mode -1)))
  :preface
  ;; Change to helpful mode in eglot doc buffers, so it can be
  ;; easily burried with q.
  (defun make-eglot-doc-helpful (orig-fun &rest args)
    (let ((res (apply orig-fun args)))
      (with-current-buffer " *eglot doc*"
        (helpful-mode)
        (setq buffer-read-only nil))
      res))
  (advice-add
   'company-show-doc-buffer
   :around #'make-eglot-doc-helpful)

  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref t)
  (eglot-confirm-server-initiated-edits 'confirm)
  (eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider))
  (eglot-menu-string "eglot")
  :config
  ;; increase timeout for eglot enhanced xref-find-references and friends
  (setq jsonrpc-default-request-timeout 30))

;; linting

(use-package package-lint)

(use-package ws-butler
  :diminish
  :commands ws-butler-mode)

;; misc

(use-package grep
  :config
  (setq grep-program "rg"))

(use-package just-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; --- language modes

(use-package git-modes)

(use-package prog-mode
  :ensure nil
  :bind (:map prog-mode-map ("C-c C-c" . compile))
  :hook (prog-mode . ws-butler-mode)
  :hook (prog-mode . electric-indent-mode)
  :config
  ;; Display boolean operator and such as their unicode equavalent
  (global-prettify-symbols-mode))

(use-package sgml-mode
  :ensure nil
  ;; For some reason electric-indent-mode is not doing it's thing in
  ;; html mode, bind RET to newline-and-indent instead
  :bind (:map html-mode-map ("RET" . newline-and-indent)))

(use-package typescript-ts-mode
  :ensure nil
  :mode (("\\.ts\\'"  . tsx-ts-mode)
         ("\\.mjs\\'" . tsx-ts-mode))
  :hook (tsx-ts-mode . (lambda () (electric-layout-local-mode -1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; --- packages from melpa

(use-package tuareg) ; ocaml

(use-package nix-mode
  :defer t
  :mode "\\.nix\\'"
  :bind (:map nix-mode-map ("C-c C-c" . compile)))

(use-package go-mode
  :defer t
  :bind (:map go-mode-map ("C-c f" . gofmt))
  :custom
  (gofmt-command "goimports"))

(use-package rust-mode
  :custom
  (compile-command "cargo test"))

(use-package graphql-ts-mode
  :ensure t
  :mode ("\\.graphql\\'" "\\.gql\\'"))

(use-package dockerfile-mode
  :defer t)

(use-package docker-compose-mode
  :defer t)

(use-package terraform-mode
  :defer t
  :mode "\.tf\\'")

(use-package sh-script
  :defer t
  :custom
  (sh-basic-offset 2)
  (sh-shell 'bash))

(use-package sql
  :defer t)

(use-package json-mode
  :defer t
  :custom
  (js-indent-level 2))

(use-package markdown-mode
  :mode (("\\`README\\.md\\'" . gfm-mode)
         ("\\.md\\'"          . markdown-mode)
         ("\\.markdown\\'"    . markdown-mode))
  :bind (:map markdown-mode-map
              ("M-n" . scroll-up-line)
              ("M-p" . scroll-down-line))
  :init (setq markdown-command "multimarkdown")
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-hide-markup t))

(use-package tidal
  :defer t
  :custom
  (tidal-interpreter "~/.ghcup/bin/ghci"))

(use-package haskell-mode
  :defer t)

(use-package php-mode
  :defer t)

(use-package dart-mode
  :defer t)

(use-package scala-ts-mode
  :mode "\\.scala\\'"
  :hook ( scala-ts-mode .
          (lambda ()
            (setq-local
             tab-width 2
             treesit-font-lock-level 4))))


;;; conf-prog-modes.el ends here
