;; -*- lexical-binding: t; -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 双击选中单词
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-select-word-on-double-click (event)
  (interactive "e")
  ;; 1. 确保在正确的窗口和位置执行
  (with-current-buffer (window-buffer (posn-window (event-end event)))
    (goto-char (posn-point (event-end event))))
  ;; 2. 检查当前光标位置是否在单词字符上。如果不在，则不进行任何操作。
  ;;    使用 \w 来匹配任何单词构成字符（由语法表定义）。
  (when (looking-at "\\w")
    (let (bounds)
      ;; 3. 定义一个临时的语法表，将下划线 '_' 设置为单词构成字符
      (let ((table (copy-syntax-table)))
        (modify-syntax-entry ?_ "w" table)
        (with-syntax-table table
          (setq bounds (bounds-of-thing-at-point 'word))))
      ;; 4. 如果成功找到了单词的边界，则精确设置选区
      (when bounds
        ;; 这是设置选区的标准且最可靠的方法：
        ;; 将光标(point)移动到单词的起点
        (goto-char (car bounds))
        ;; 将标记(mark)设置在单词的终点，并激活选区使其高亮
        (push-mark (cdr bounds) t t))))
  ;; 5. 返回 nil 允许事件传播（例如，为了可能的拖动选择扩展）
  nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 三连击选中整行非空部分
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-select-trimmed-line-on-tripple-click (event)
  (interactive "e")
  ;; 1. 确保光标移动到鼠标点击的位置
  (mouse-set-point event)

  (let (start-pos end-pos)
    ;; 2. 寻找选区的起点 (第一个非空字符的位置)
    ;; 使用 save-excursion 来进行搜索，这样不会移动最终的光标
    (save-excursion
      (beginning-of-line)
      ;; re-search-forward 是更现代的正则搜索函数
      ;; 如果找到，它会返回非 nil 值
      (when (re-search-forward "\\S-" (line-end-position) t)
        ;; (match-beginning 0) 返回整个匹配的起始位置
        (setq start-pos (match-beginning 0))))

    ;; 3. 寻找选区的终点 (最后一个非空字符的位置)
    (save-excursion
      (end-of-line)
      (when (re-search-backward "\\S-" (line-beginning-position) t)
        ;; (match-end 0) 返回整个匹配的结束位置
        (setq end-pos (match-end 0))))

    ;; 4. 如果起点和终点都找到了，就设置选区
    (if (and start-pos end-pos)
        (progn
          ;; 将光标移动到选区起点
          (goto-char start-pos)
          ;; 将标记(mark)设置在选区终点，并激活选区使其高亮
          ;; push-mark 的参数分别是：位置，是否不通知(no-message)，是否激活(activate)
          (push-mark end-pos t t)))))

(global-set-key (kbd "<double-mouse-1>") #'my-select-word-on-double-click)
(global-set-key [double-down-mouse-1] (lambda (event) (interactive "e") nil)) ;; 双击:传递事件给操作系统
(global-set-key (kbd "<triple-mouse-1>") #'my-select-trimmed-line-on-tripple-click)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 链接鼠标操作：悬停显示下划线，Ctrl+点击打开
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst my-smart-click--url-regexp
  "https?://[^ \t\n\r\"'<>]+")

(defun my-smart-click--url-at-event (event)
  (let* ((start (event-start event))
         (window (posn-window start))
         (position (posn-point start)))
    (when (and (windowp window) (integer-or-marker-p position))
      (with-current-buffer (window-buffer window)
        (save-excursion
          (goto-char position)
          (let ((line-end (line-end-position)) found)
            (beginning-of-line)
            (while (and (not found)
                        (re-search-forward my-smart-click--url-regexp line-end t))
              (when (<= (match-beginning 0) position (match-end 0))
                (setq found (match-string-no-properties 0))))
            found))))))

(defun my-smart-click--open-url (event)
  (interactive "e")
  (when (memq 'control (event-modifiers event))
    (when-let ((url (my-smart-click--url-at-event event)))
      (browse-url url))))

(defun my-smart-click--enable-url-mouse-face ()
  (font-lock-add-keywords
   nil `((,my-smart-click--url-regexp
          (0 (put-text-property (match-beginning 0) (match-end 0)
                                'mouse-face '(:underline t)) nil)))))

(add-hook 'font-lock-mode-hook #'my-smart-click--enable-url-mouse-face)
(global-set-key (kbd "C-<down-mouse-1>") #'my-smart-click--open-url)
