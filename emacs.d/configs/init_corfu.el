;; -*- lexical-binding: t; -*-
(use-package corfu
  :init
  (progn
	(setq corfu-auto t)
	(setq corfu-cycle t)
	(setq corfu-quit-at-boundary t)
	(setq corfu-quit-no-match t)
	(setq corfu-preview-current nil)
	(setq corfu-min-width 80)
	(setq corfu-max-width 100)
	(setq corfu-auto-delay 0.2)
	(setq corfu-auto-prefix 1)
	(setq corfu-on-exact-match nil)
	(global-corfu-mode))
  :config
  (defun my-corfu-escape ()
	(interactive)
	(if (ignore-errors (when (corfu--visible-p) (corfu-quit) t))
		(message "Corfu popup closed")
	  (evil-normal-state)))
  (defun corfu--visible-p ()
	(and (symbol-value 'corfu--frame)
		 (frame-visible-p (symbol-value 'corfu--frame))))
  (with-eval-after-load 'evil (define-key evil-insert-state-map (kbd "<escape>") #'my-corfu-escape))
  (defun my/corfu-smart-tab ()
    "如果只有一个候选项，则直接插入；否则切换到下一个候选项。"
    (interactive)
    (if (= 1 corfu--total)
        (corfu-insert)
      (corfu-next)))
  :bind
  (:map corfu-map
        ("TAB" . my/corfu-smart-tab)
        ([tab] . my/corfu-smart-tab)
		("RET" . corfu-insert)
		([return] . corfu-insert)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)))

(unless (display-graphic-p)
  (corfu-terminal-mode +1))

(corfu-history-mode 1)
(savehist-mode 1)
(add-to-list 'savehist-additional-variables 'corfu-history)

(defun my-ignore-elisp-keywords (cand)
  (or (not (keywordp cand))
      (save-excursion
        (skip-syntax-backward "w_")
        (eq (char-after) ?:))))

(defun my-current-input-capf ()
  "通用 Capf：捕获当前光标处的输入符号（包含 : @ # 等前缀），作为首选候选提供。"
  (save-excursion
    (let ((end (point)))
      ;; 1. 向前跳过单词和符号字符（遇到 '(' ')' ' ' 等立即停止）
      (skip-syntax-backward "w_")
      ;; 2. 如果非 elisp 模式下冒号等被视作标点，向前一步纳入前缀符
      (when (memq (char-before) '(?: ?@ ?# ?/))
        (backward-char 1))
      (when (< (point) end)
        (let ((beg (point))
              (input (buffer-substring-no-properties (point) end)))
          (when (and input (not (string-blank-p input)))
            (list beg end
                  (list input)
                  :exclusive 'no
                  :company-kind (lambda (_) 'text))))))))


(defun my/setup-general-capf ()
  (setq-local completion-at-point-functions
              `(,(cape-capf-super
                  #'my-current-input-capf
                  #'cape-dabbrev
                  #'cape-file
                  #'cape-emoji
                  #'cape-keyword))))

(defun my/setup-emacs-lisp-capf ()
  (setq-local completion-at-point-functions
              `(,(cape-capf-super
                  #'my-current-input-capf
                  (cape-capf-predicate
                   #'elisp-completion-at-point
                   #'my-ignore-elisp-keywords)
                  #'cape-dabbrev
                  #'cape-file
                  #'cape-emoji
                  #'cape-keyword))))

(defun my-corfu-combined-sort (candidates)
  "Sort CANDIDATES using display-sort-function & corfu-sort-function, then deduplicate."
  (let* ((candidates
          (let ((display-sort-func (corfu--metadata-get 'display-sort-function)))
            (if display-sort-func
                (funcall display-sort-func candidates)
              candidates)))
         (sorted (if corfu-sort-function
                     (funcall corfu-sort-function candidates)
                   candidates)))
    ;; 自动消除多后端重叠项，确保 my-current-input-capf 的内容排在唯一第 1 位
    (delete-dups sorted)))

(setq corfu-sort-override-function #'my-corfu-combined-sort)

(require 'dabbrev)
(require 'cape)
(use-package cape
  :bind (("C-n" . cape-dabbrev)
		 ("C-c p h" . cape-history)
		 ("C-c p e" . cape-emoji)
		 ("C-c p f" . cape-file))
  :init
  (setq dabbrev-abbrev-char-regexp "[[:alnum:]_]")
  (setq dabbrev-case-replace nil)
  (add-hook 'prog-mode-hook #'my/setup-general-capf)
  (add-hook 'text-mode-hook #'my/setup-general-capf)
  (add-hook 'emacs-lisp-mode-hook #'my/setup-emacs-lisp-capf))
