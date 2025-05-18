;; -*- lexical-binding: t; -*-
;; 增强版 *scratch* buffer 光标定位
(defun my-smart-scratch-position ()
  "智能定位 *scratch* buffer 的光标位置。"
  (when (string= (buffer-name) "*scratch*")
    (let ((content (buffer-string)))
      ;; 检查是否是初始内容
      (when (or (string= content initial-scratch-message)
		(string-prefix-p ";;" content))
	(goto-char (point-min))
	(condition-case nil
	    (progn
	      ;; 跳过所有注释行
	      (while (looking-at "\\s-*;")
		(forward-line 1))
	      ;; 如果跳过注释后是空行，则移动到下一行
	      (when (looking-at "\\s-*$")
		(forward-line 1)))
	  (error nil))
	(beginning-of-line)))))

;; 添加多个 hook 确保覆盖各种情况
(dolist (hook '(lisp-interaction-mode-hook
		window-configuration-change-hook
		buffer-list-update-hook
		after-change-major-mode-hook))
  (add-hook hook 'my-smart-scratch-position))

