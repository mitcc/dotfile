;; -*- lexical-binding: t; -*-
;; 自定义函数：检查是否存在弹出窗口（popup）
(defun my/popup-active-p ()
  "Check if any completion popup is active."
  (or
   ;; Company-mode 支持
   (and (bound-and-true-p company-mode)
        (company-active-p))

   ;; Corfu-mode 支持
   (and (bound-and-true-p corfu-mode)
        (boundp 'corfu--current-candidates)
        (symbol-value 'corfu--current-candidates)) ; 使用 symbol-value 安全访问变量

   ;; Ivy 补全支持
   (and (bound-and-true-p ivy-mode)
        (window-minibuffer-p))

   ;; Helm 补全支持
   (and (bound-and-true-p helm-mode)
        (window-minibuffer-p))

   ;; Selectrum 支持
   (and (bound-and-true-p selectrum-mode)
        (window-minibuffer-p))

   ;; Yasnippet 支持
   (and (bound-and-true-p yas-minor-mode)
        (fboundp 'yas--snippet-popup-active-p) ; 确保函数存在
        (yas--snippet-popup-active-p))

   ;; LSP 补全支持
   (and (bound-and-true-p lsp-mode)
        (boundp 'lsp-completion--completions)
        (symbol-value 'lsp-completion--completions))

   ;; Eglot 补全支持
   (and (bound-and-true-p eglot--managed-mode)
        (window-minibuffer-p))

   ;; Auto-complete 支持
   (and (bound-and-true-p auto-complete-mode)
        (fboundp 'ac-menu-live-p) ; 确保函数存在
        (ac-menu-live-p))

   ;; Posframe 弹出窗口
   (and (featurep 'posframe)
        (fboundp 'posframe--list) ; 确保函数存在
        (posframe--list))

   ;; 通用弹出窗口检测
   (and (featurep 'popup)
        (boundp 'popup-instances)
        (symbol-value 'popup-instances))

   ;; 其他弹出窗口检测
   ))

;; 主逻辑函数
(defun my/smart-tab ()
  "Smart TAB behavior: use original if popup active, else insert spaces."
  (interactive)
  (cond
   ;; 有弹出窗口时使用原 TAB 行为
   ((my/popup-active-p)
    (call-interactively (key-binding (kbd "TAB"))))

   ;; 无弹出窗口时插入空格
   (t
    (let ((indent-tabs-mode nil))  ; 确保插入空格而非制表符
      (insert (make-string tab-width ?\s))))))

;; 全局设置 TAB 键行为
(global-set-key (kbd "TAB") #'my/smart-tab)

;; 可选：为特定模式保留原始行为
(add-hook 'org-mode-hook (lambda () (local-set-key (kbd "TAB") 'org-cycle)))
(add-hook 'python-mode-hook (lambda () (local-set-key (kbd "TAB") 'indent-for-tab-command)))

;; added at 2025.06.23
;; 设置全局默认值（当无法自动检测时使用）
(setq-default tab-width 4) ; 默认 4 空格
;; 为特定模式设置不同的 tab 宽度
(add-hook 'go-mode-hook (lambda () (setq tab-width 4)))
(add-hook 'rust-mode-hook (lambda () (setq tab-width 4)))
(add-hook 'c-mode-hook (lambda () (setq tab-width 4)))
(add-hook 'c++-mode-hook (lambda () (setq tab-width 4)))
(add-hook 'python-mode-hook (lambda () (setq tab-width 4)))
(add-hook 'java-mode-hook (lambda () (setq tab-width 4)))
(add-hook 'javascript-mode-hook (lambda () (setq tab-width 2)))
(add-hook 'typescript-mode-hook (lambda () (setq tab-width 2)))
(add-hook 'web-mode-hook (lambda () (setq tab-width 2)))
(add-hook 'ruby-mode-hook (lambda () (setq tab-width 2)))
(add-hook 'sh-mode-hook (lambda () (setq tab-width 2)))

;; added at 2026.05.18
(setq-default indent-tabs-mode nil)  ; 所有的缩进都转换为空格
