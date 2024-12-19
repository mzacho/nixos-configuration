;; Author: Martin Zacho
;; Created: Jan 22 2022

(setq custom-file "~/.emacs.d/custom.el")
(if (file-exists-p custom-file)
    (load custom-file))

;; Load core config
(load "~/.emacs.d/conf.el")

;; Set server socket dir
;; (setq server-socket-dir "/tmp/run/user/1000/emacs")
