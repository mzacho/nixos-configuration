;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.


(defun my/xref-advice (func &rest args)
  (let (orig-buf (current-buffer))
    (apply func args)
    (if (eq orig-buf (current-buffer))
        (message "same buffer"))))

(advice-remove 'xref--find-definitions
               #'my/xref-advice)

(advice-add 'xref--find-definitions
            :around
            #'my/xref-advice)

(setq xref-after-jump-hook
      (list #'recenter
            #'xref-pulse-momentarily))
