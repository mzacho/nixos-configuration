;;;; package -- mail conf -*- lexical-binding:t; coding:utf-8 -*-
;;; Commentary:
;; Author: Martin Zacho
;; Created: Nov 02 2024

;;; Code:

(use-package mu4e
  :ensure nil
  :bind (("C-x m" . mu4e))
  :preface
  (defun my/offline-update-hook ()
    (unless (my/internet-up-p)
      (error "offline, not retrieving mails")))
  (defun my/mu4e-quit(&optional bury)
    "buries buffer without prefix argument"
    (interactive "P")
    (mu4e-quit (not bury)))
  (setq offlineimap (my/which "offlineimap")
        msmtp (my/which "msmtp")
        address "hi@martinzacho.net"
        localhost "127.0.0.1"
        maildir (expand-file-name "~/mail/proton"))
  :bind (:map mu4e-main-mode-map ("q" . my/mu4e-quit))
  :hook (mu4e-update-pre . my/offline-update-hook)
  :hook (mu4e-headers-mode . my-disable-global-line-mode)
  :hook (mu4e-headers-mode . (lambda () (setq-local mu4e-split-view 'single-window)))
  :hook (mu4e-compose-mode . (lambda ()
                               (turn-off-auto-fill)
                               (paragraph-indent-minor-mode)
                               (electric-indent-local-mode -1)
                               (turn-on-flyspell)))
  :custom  
  ;; ------------------------------------ basics and connections
  (user-mail-address address)
  (user-full-name "Martin Zacho")
  (mu4e-get-mail-command "true")  ;; offlineimap run with systemd timer
  (sendmail-program msmtp)
  (send-mail-function 'smtpmail-send-it)
  (smtpmail-debug-info nil)
  (smtpmail-smtp-server localhost)
  (smtpmail-smtp-service 1025)
  (smtpmail-default-smtp-server localhost)
  (smtpmail-smtp-user address)          ;; pass reads from .authinfo.gpg
  (smtpmail-stream-type 'starttls)
  ;; ------------------------------------ maildirs and bookmarks
  (mu4e-maildir maildir)
  (mu4e-sent-folder "/Sent")
  (mu4e-drafts-folder "/Drafts")
  (mu4e-refile-folder "/Archive")
  (mu4e-trash-folder "/Trash")
  (mu4e-maildir-shortcuts
   '(( :maildir "/INBOX"
       :key ?i)
     ( :maildir "/Sent"
       :key ?s)
     ( :maildir "/Drafts"
       :key ?d)
     ( :maildir "/Archive"
       :key ?a)
     ( :maildir "/Trash"
       :key ?t)
     ( :maildir "/Spam"
       :key ?x)))
  (mu4e-bookmarks
   '(( :name "Unread messages"
       :query "flag:unread AND maildir:/INBOX"
       :key ?u)
     ( :name "Today's messages"
       :query "date:today..now AND maildir:/INBOX"
       :key ?t)
     ( :name "Last 7 days"
       :query "date:7d..now AND maildir:/INBOX"
       :hide-unread t
       :key ?w)
     ( :name "github"
       :query "from:/.*@github.com/"
       :hide-unread nil
       :key ?g)
     ( :name "nixpkgs"
       :query "to:nixpkgs@martinzacho.net"
       :hide-unread nil
       :key ?i)
     ( :name "kernel lists"
       :query "maildir:/Folders.lists-kernel"
       :hide-unread nil
       :key ?v)
     ( :name "this week in rust"
       :query "from:twir@rust-lang.org"
       :hide-unread nil
       :key ?r)
     ( :name "lwn"
       :query "from:lwn@lwn.net"
       :hide-unread nil
       :key ?l)
     ( :name "other lists"
       :query "to:lists@martinzacho.net OR maildir:/Folders.lists"
       :hide-unread nil
       :key ?o)
     ( :name "kombardo confirmations"
       :query "/billet_at_kombardoexpressen.*@.*/"
       :hide-unread nil
       :key ?k)
     ( :name "nordnet"
       :query "maildir:/Folders.lists-Nordnet"
       :hide-unread t
       :key ?n)
     ( :name "jobalerts"
       :query "maildir:/Folders.jobalerts"
       :hide-unread t
       :key ?j)
     ( :name "business"
       :query "to:business@martinzacho.net"
       :hide-unread nil
       :key ?b)
     ( :name "flagged"
       :query "flag:flagged"
       :hide-unread t
       :key ?f)
     ))
  ;; ------------------------------------------ search result headers
  (mu4e-headers-fields
   '((:human-date . 12)
     (:flags . 4)
     (:from-or-to . 20)
     (:subject)))
  ;; ------------------------------------------- misc
  (mail-user-agent 'mu4e-user-agent)
  (message-send-mail-function 'message-send-mail-with-sendmail)
  (message-kill-buffer-on-exit t)
  ;; citation style and signature
  (message-signature "Kindly,\nMartin")
  (message-citation-line-function 'message-insert-formatted-citation-line)
  (message-cite-reply-position 'above)
  (message-yank-prefix "> ")
  (message-yank-cited-prefix ">")
  (message-yank-empty-prefix ">")
  (message-citation-line-format "\nOn %D %R %p, %N wrote:")
  ;; attachments
  (mu4e-attachment-dir (expand-file-name "~/Downloads"))
  (mu4e-icalendar-diary-file "~/.emacs.d/diary")
  (mu4e-confirm-quit nil)
  ;; auto update and indexing
  (mu4e-update-interval 60)
  (mu4e-hide-index-messages t)
  ;; use verbose threading syntax, credit
  ;; https://groups.google.com/g/mu-discuss/c/XiNkHmSdbfw
  (mu4e-headers-thread-root-prefix '("* " . "┌ "))
  (mu4e-headers-thread-child-prefix '("|- " . "├ "))
  (mu4e-headers-thread-first-child-prefix '("- " . "╴ "))
  (mu4e-headers-thread-last-child-prefix '("\\- " . "└ "))
  (mu4e-headers-thread-connection-prefix '("| " . "│ "))
  (mu4e-headers-thread-blank-prefix '(" " . " "))
  (mu4e-headers-thread-orphan-prefix '("+ " . "╒ "))
  (mu4e-headers-thread-single-orphan-prefix '(" " . "═ "))
  (mu4e-headers-thread-duplicate-prefix '("~ " . "~ "))
  :config
  ;; apply git patches from emails
  (add-to-list
   'mu4e-view-actions
   '("Apply Email" . mu4e-action-git-apply-mbox) t))

(use-package mu4e-column-faces
  :after mu4e
  :config (mu4e-column-faces-mode))

(use-package message-view-patch
  :after mu4e
  :config
  (add-hook 'gnus-part-display-hook 'message-view-patch-highlight))

;;; conf-mail.el ends here
