;; -*- lexical-binding: t; -*-
(defun my/is-tmp-window-p (window)
  (string-match-p "^\*.*\*$" (buffer-name (window-buffer window))))

(defun my/evil-escape ()
  (interactive)
  (dolist (win (window-list))
	(when (my/is-tmp-window-p win)
	  (delete-window win)))
  (cond ;; 强制回到 normal 模式并保留 evil 的默认行为
   ((evil-insert-state-p) (evil-normal-state))
   ((evil-visual-state-p) (evil-exit-visual-state))
   (t (evil-force-normal-state))))

;; 右移并恢复选中
(defun my/evil-shift-right-visual ()
  (interactive)
  (call-interactively 'evil-shift-right)
  (evil-normal-state)
  (evil-visual-restore))

;; 左移并恢复选中
(defun my/evil-shift-left-visual ()
  (interactive)
  (call-interactively 'evil-shift-left)
  (evil-normal-state)
  (evil-visual-restore))

;; --- 通用搜索函数 ---
(defun my/evil-search-core (&optional backward word-search)
  (interactive)
  ;; 1. 退出视觉模式 (防止 n/N 跳转时拉伸选区)
  (when (evil-visual-state-p)
    (evil-exit-visual-state))
  
  ;; 2. 清除搜索状态变量
  (setq evil-ex-search-last-regexp nil
        evil-ex-last-was-search nil)

  ;; 3. 判断使用哪个搜索函数
  (let* ((is-isearch (eq evil-search-module 'isearch))
         (search-fn
          (cond
           (word-search ;; 单词搜索模式 (*, #)
            (if backward
                (if is-isearch 'isearch-backward-symbol-at-point 'evil-ex-search-word-backward)
              (if is-isearch 'isearch-forward-symbol-at-point 'evil-ex-search-word-forward)))
           (t ;; 普通交互搜索模式 (/, ?)
            (if backward
                (if is-isearch 'isearch-backward 'evil-ex-search-backward)
              (if is-isearch 'isearch-forward 'evil-ex-search-forward))))))
    
    ;; 4. 执行搜索：仅在非 word-search 时使用 minibuffer 钩子，清除历史输入内容
    (if word-search
        (call-interactively search-fn)
      (minibuffer-with-setup-hook
          (lambda () (delete-minibuffer-contents))
        (call-interactively search-fn)))))

(defun my/evil-search-forward () (interactive) (my/evil-search-core)) ; backward=nil, word-search=nil
(defun my/evil-search-backward () (interactive) (my/evil-search-core t)) ; backward=t, word-search=nil
(defun my/evil-search-word-forward () (interactive) (my/evil-search-core nil t)) ; backward=nil, word-search=t
(defun my/evil-search-word-backward () (interactive) (my/evil-search-core t t)) ; backward=t, word-search=t

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-emacs-state-cursor '("red" box))
  (setq evil-normal-state-cursor '("#607d8b" box))
  (setq evil-visual-state-cursor '("orange" box))
  (setq evil-insert-state-cursor '("red" bar))
  (setq evil-replace-state-cursor '("red" bar))
  (setq evil-operator-state-cursor '("red" hollow))
  (evil-mode)
  :config
  (evil-set-initial-state 'lisp-interaction-mode 'insert) ;设置 *scratch* 缓冲区初始状态为插入模式
  (evil-select-search-module 'evil-search-module 'evil-search) ; evil 使用"/"搜索时能够粘贴
  (setcdr evil-insert-state-map nil)
  (define-key evil-insert-state-map [escape] 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "<escape>") (lambda () (interactive) (evil-ex-nohighlight) (my/evil-escape) (keyboard-quit))) ; 清除搜索高亮、执行my/evil-escape逻辑
  (define-key evil-normal-state-map (kbd "[ SPC") (lambda () (interactive) (evil-insert-newline-above) (forward-line)))
  (define-key evil-normal-state-map (kbd "] SPC") (lambda () (interactive) (evil-insert-newline-below) (forward-line -1)))
  (define-key evil-normal-state-map (kbd "C-q") 'evil-visual-block) ;; 在 normal 和 visual 模式下将 C-q 映射为块选择
  (define-key evil-normal-state-map (kbd "[ b") 'previous-buffer)
  (define-key evil-normal-state-map (kbd "] b") 'next-buffer)
  (define-key evil-normal-state-map (kbd "/") 'my/evil-search-forward)
  (define-key evil-normal-state-map (kbd "?") 'my/evil-search-backward)
  (define-key evil-normal-state-map (kbd "*") 'my/evil-search-word-forward)
  (define-key evil-normal-state-map (kbd "#") 'my/evil-search-word-backward)
  (define-key evil-motion-state-map (kbd "[ b") 'previous-buffer)
  (define-key evil-motion-state-map (kbd "] b") 'next-buffer)
  (define-key evil-visual-state-map (kbd "/") 'my/evil-search-forward)
  (define-key evil-visual-state-map (kbd "?") 'my/evil-search-backward)
  (define-key evil-visual-state-map (kbd "*") 'my/evil-search-word-forward)
  (define-key evil-visual-state-map (kbd "#") 'my/evil-search-word-backward)
  (define-key evil-visual-state-map (kbd ">") 'my/evil-shift-right-visual)
  (define-key evil-visual-state-map (kbd "<") 'my/evil-shift-left-visual))

(use-package evil-anzu
  :ensure t
  :after evil
  :diminish
  :demand t
  :init
  (global-anzu-mode t))

(use-package undo-tree
  :diminish
  :init
  (global-undo-tree-mode 1)
  (setq undo-tree-auto-save-history nil)
  (evil-set-undo-system 'undo-tree))

(evil-define-key 'normal dired-mode-map
  (kbd "<RET>") 'dired-find-alternate-file
  (kbd "C-k") 'dired-up-directory
  "`" 'dired-open-term
  "o" 'dired-find-file-other-window
  "s" 'hydra-dired-quick-sort/body
  "z" 'dired-get-size
  ")" 'dired-omit-mode)

(use-package evil-collection
  :custom (evil-collection-setup-minibuffer t)
  :init (evil-collection-init))

(require 'evil-leader)
(global-evil-leader-mode)

(evil-leader/set-key "f" 'find-file)
(evil-leader/set-key "r" 'consult-recent-file)
(evil-leader/set-key "b" 'switch-to-buffer)
(evil-leader/set-key "kb" 'kill-buffer)
(evil-leader/set-key-for-mode 'emacs-lisp-mode "cb" 'byte-compile-file)


(defun color-minibuffer (color)
  `(lambda ()
	 (when (minibufferp)
	   (face-remap-add-relative 'minibuffer-prompt :foreground, color))))

(add-hook 'evil-normal-state-entry-hook   (color-minibuffer "#FF0000"))
(add-hook 'evil-operator-state-entry-hook (color-minibuffer "#FF8000"))
(add-hook 'evil-insert-state-entry-hook   (color-minibuffer "#00FF00"))
(add-hook 'evil-replace-state-entry-hook  (color-minibuffer "#FFFF00"))
(add-hook 'evil-visual-state-entry-hook   (color-minibuffer "#8080FF"))
(add-hook 'evil-motion-state-entry-hook   (color-minibuffer "#A0E0FF"))
(add-hook 'evil-emacs-state-entry-hook    (color-minibuffer "#8000FF"))


(with-eval-after-load 'evil
  (evil-ex-define-cmd "sp"  #'evil-window-split)
  (evil-ex-define-cmd "vsp" #'evil-window-vsplit))

(use-package evil-traces
  :config
  (evil-traces-use-diff-faces)
  (evil-traces-mode))

