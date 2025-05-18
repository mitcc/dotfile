;; -*- lexical-binding: t; -*-
;; 如果有选中区域，则格式化选中区域，否则格式化当前行
(defun my-json-format ()
  (interactive)
  (if (region-active-p)
      (json-pretty-print (region-beginning) (region-end))
    (let ((start (line-beginning-position))
	  (end (line-end-position)))
      (json-pretty-print start end))))

(evil-leader/set-key "j" 'my-json-format)

