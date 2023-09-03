;;; package -- summary
;;; Commentary:
;; Author: Martin Zacho
;; Created: June 2024

;;; Code:

(defun my/internet-up-p (&optional host)
  (= 0 (call-process "ping" nil nil nil "-c" "1" "-W" "1"
                     (if host host "www.google.com"))))

;; get the path of an executable
(defun my/which (prog)
  (string-trim
   (shell-command-to-string
    (concat "which " prog))))

;; Open current dir in iTerm
(defun my/iterm-here ()
  (interactive)
  (shell-command "open -a iTerm $PWD"))

;; Open current dir in Wezterm
(defun my/wezterm-here ()
  (interactive)
  (shell-command "i3 '[workspace=1]' focus > /dev/null && wezterm cli spawn --cwd $PWD"))

;; Open current dir in urxvt
(defun my/urxvtc-here ()
  (interactive)
  (shell-command "urxvtc +bc -cd $PWD"))

;; Send command output from shell to new buffer
(defun my/new-buffer-from-cmd-output (file pwd)
  (interactive "New buffer from cmd output: \nr")
  (let ((buffer (generate-new-buffer "*cmd output*" nil)))
    (with-current-buffer buffer
      (insert-file file)
      (cd pwd))
    (switch-to-buffer buffer)))

;;; my-utils.el ends here
