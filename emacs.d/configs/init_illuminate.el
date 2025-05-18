;;; cursor-highlight-word.el --- Highlight all word occurrences at point with underline -*- lexical-binding: t; -*-

(defgroup cursor-highlight-word nil
  "Highlight all occurrences of word under cursor with underline."
  :group 'convenience)

(defface cursor-highlight-word-face
  '((t :underline t))
  "Face for word highlighting"
  :group 'cursor-highlight-word)

(defvar-local cursor-highlight-word--overlays nil
  "Active highlight overlays")

(defvar cursor-highlight-word--current-word nil
  "Currently highlighted word")

(defvar cursor-highlight-word--timer nil
  "Idle timer for highlighting")

(defcustom cursor-highlight-word-delay 0.05
  "Delay in seconds before highlighting"
  :type 'number
  :group 'cursor-highlight-word)

;;;###autoload
(define-minor-mode cursor-highlight-word-mode
  "Toggle word occurrence highlighting"
  :global t
  :group 'cursor-highlight-word
  (if cursor-highlight-word-mode
      (cursor-highlight-word--enable)
    (cursor-highlight-word--disable)))

(defun cursor-highlight-word--enable ()
  "Enable highlighting"
  (add-hook 'post-command-hook #'cursor-highlight-word--schedule-update)
  (add-hook 'before-change-functions #'cursor-highlight-word--clear))

(defun cursor-highlight-word--disable ()
  "Disable highlighting"
  (remove-hook 'post-command-hook #'cursor-highlight-word--schedule-update)
  (remove-hook 'before-change-functions #'cursor-highlight-word--clear)
  (cursor-highlight-word--clear-all))

(defun cursor-highlight-word--schedule-update ()
  "Schedule delayed highlight update"
  (when cursor-highlight-word--timer
    (cancel-timer cursor-highlight-word--timer))
  (setq cursor-highlight-word--timer
	(run-with-idle-timer cursor-highlight-word-delay nil
			     #'cursor-highlight-word--update)))

(defun cursor-highlight-word--update ()
  "Update word highlights"
  (when (and cursor-highlight-word-mode
	     (not (region-active-p))
	     (not (minibufferp)))
    (let ((current-word (cursor-highlight-word--get-current-word)))
      ;; 扩展清除条件：当前词变化或从有效词变为nil
      (unless (and cursor-highlight-word--current-word
		   (equal current-word cursor-highlight-word--current-word))
	(cursor-highlight-word--clear-all))
      ;; 独立判断高亮条件
      (when (and current-word (>= (length current-word) 2)
		 (cursor-highlight-word--highlight-matches current-word))
	;; 始终同步当前词状态
	(setq cursor-highlight-word--current-word current-word)))))

(defun cursor-highlight-word--get-current-word ()
  "Get valid word at point with strict boundaries, including underscores."
  (with-syntax-table (copy-syntax-table (syntax-table))
    (modify-syntax-entry ?_ "w")
    (when-let ((bounds (bounds-of-thing-at-point 'word)))
      (let ((word (buffer-substring-no-properties (car bounds) (cdr bounds))))
	(if (string-match-p "\\`\\w+\\'" word) word nil)))))

(defun cursor-highlight-word--highlight-matches (word)
  "Highlight all exact word matches"
  (save-excursion
    (goto-char (point-min))
    (with-syntax-table (copy-syntax-table (syntax-table))
      (modify-syntax-entry ?_ "w")
      (let ((regex (concat "\\<" (regexp-quote word) "\\>")) ; 严格单词边界
	    (case-fold-search nil))
	(while (re-search-forward regex nil t)
	  (let ((ov (make-overlay (match-beginning 0) (match-end 0))))
	    (overlay-put ov 'face 'cursor-highlight-word-face)
	    (overlay-put ov 'priority 1000)
	    (push ov cursor-highlight-word--overlays)))))))

(defun cursor-highlight-word--clear (&rest _)
  "Clear current highlights"
  (mapc #'delete-overlay cursor-highlight-word--overlays)
  (setq cursor-highlight-word--overlays nil
	cursor-highlight-word--current-word nil))

(defun cursor-highlight-word--clear-all ()
  "Clear all highlights in all buffers"
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (cursor-highlight-word--clear))))

(provide 'cursor-highlight-word)

(cursor-highlight-word-mode 1) ; 全局启用
