;; -*- lexical-binding: t; -*-
(require 'package)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("elpa"  . "https://elpa.gnu.org/packages/")
        ("org"   . "https://orgmode.org/elpa/")))

(setq url-gateway-method 'socks)
(setq socks-server '("Default server" "127.0.0.1" 51837 5))

(defconst my-config-dir
  (expand-file-name "configs" user-emacs-directory))

(add-to-list 'load-path my-config-dir)

;; JSON 格式化命令: 如果有选中区域，则格式化选中区域，否则格式化当前行
(defun my-json-format ()
  "格式化选中区域或当前行中的 JSON 内容。"
  (interactive)
  (require 'json)
  (if (region-active-p)
      (json-pretty-print (region-beginning) (region-end))
    (let ((start (line-beginning-position))
          (end (line-end-position)))
      (json-pretty-print start end))))

(dolist (file '("init_evil"
                "init_neotree"
                "init_corfu"
                "init_vertico"
                "init_smarttab"
                "init_scratch"))
  (load (expand-file-name file my-config-dir)
        nil 'nomessage))

(autoload 'text-cmp
  "init_text_compare"
  "启动文本比较工具。"
  t)

(autoload 'json-cmp
  "init_json_compare"
  "启动 JSON 比较工具。"
  t)

(defun my-package-refresh-contents ()
  "手动刷新包索引。"
  (interactive)
  (message "正在刷新 Emacs 包索引...")
  (package-refresh-contents)
  (message "Emacs 包索引刷新完成"))

(setq make-backup-files nil) ;关闭备份文件
(auto-save-visited-mode 1) ;启用自动保存到当前访问的文件
(setq-default show-trailing-whitespace t) ;; 尾部空格设置
(setq delete-trailing-lines nil) ;; 禁止 delete-trailing-whitespace 删除文件末尾的空行
(add-hook 'before-save-hook 'delete-trailing-whitespace) ; 保存前删掉行末空格
(set-scroll-bar-mode 'right) ; 在右侧启用垂直滚动条
;显示行号
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(fset 'yes-or-no-p 'y-or-n-p)
(column-number-mode 1) ;显示光标所在列号
(xterm-mouse-mode t) ;启用终端鼠标支持
(setq initial-scratch-message nil) ;设置 *scratch* 缓冲区的初始信息为空
(add-hook 'after-change-major-mode-hook (lambda () (modify-syntax-entry ?_ "w"))) ;将下划线 _ 加入单词字符
(add-hook 'emacs-startup-hook (lambda () (load-theme 'material t)))
(set-face-attribute 'region nil :background "#777777" :foreground "#CDCDCD")

;; 设置标题显示格式
(setq frame-title-format
	  '((:eval
		 (if (buffer-file-name)
			 (let ((file (file-name-nondirectory (buffer-file-name)))
				   (dir (abbreviate-file-name (file-name-directory (buffer-file-name)))))
			   (concat file " (" dir ")"))
		   "%b"))))

(use-package exec-path-from-shell
  :ensure t
  :defer t
  :init
  ;; 只启动登录 Shell，不启动交互式 Shell
  ;; 避免加载 Oh My Zsh、补全插件等耗时配置
  (setq exec-path-from-shell-arguments '("-l")
        exec-path-from-shell-variables '("PATH")))

(defun my-delayed-exec-path-from-shell ()
  (when (display-graphic-p)
    (require 'exec-path-from-shell)
    (exec-path-from-shell-initialize)))

(use-package recentf
  :defer t
  :custom
  (recentf-max-menu-items 50))

(run-with-idle-timer
  1 nil
  (lambda ()
    (load (expand-file-name "init_illuminate" my-config-dir) nil 'nomessage)
    (load (expand-file-name "init_smart_click" my-config-dir) nil 'nomessage)
    (cursor-highlight-word-mode 1)
    (my-delayed-exec-path-from-shell) ; 从 shell 同步 PATH 等环境变量
    (recentf-mode 1)                  ; 启用最近打开文件
    (save-place-mode 1)               ; 全局启用保存位置功能
    (global-auto-revert-mode 1)       ; 自动加载外部修改过的文件
    (global-hl-line-mode 1)))         ; 高亮当前行

(use-package doom-modeline
  :ensure t
  :defer 1
  :custom
  (doom-modeline-buffer-file-name-style 'file-name)
  (doom-modeline-project-name t)
  :config
  (doom-modeline-mode 1))

;; 编程模式下颜色代码背景色显示
(use-package rainbow-mode
  :ensure t
  :hook (prog-mode . rainbow-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook ((prog-mode . rainbow-delimiters-mode)
         (text-mode . rainbow-delimiters-mode)))

(use-package yasnippet
  :ensure t
  :hook ((prog-mode . yas-minor-mode)
         (text-mode . yas-minor-mode)))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

; 超过单行长度后隐藏箭头
(with-eval-after-load 'simple
  (setf (cdr (assq 'truncation fringe-indicator-alist)) nil)
  (setf (cdr (assq 'continuation fringe-indicator-alist)) nil))

(use-package git-gutter
  :ensure t
  :defer 1
  :custom
  (git-gutter:diff-option "HEAD")
  (git-gutter:modified-sign " ")
  (git-gutter:update-interval 0)
  :config
  (set-face-background 'git-gutter:modified "orange")
  (set-face-foreground 'git-gutter:added "green")
  (set-face-foreground 'git-gutter:deleted "red")
  (global-git-gutter-mode 1)
  (add-hook 'after-save-hook #'git-gutter)
  (add-function :after after-focus-change-function
                (lambda ()
                  (when (frame-focus-state)
                    (when (bound-and-true-p git-gutter-mode)
                      (git-gutter:update-all-windows))))))

; super-x, super-c, super-v 使用系统粘贴板, 与 emacs/evil 互不影响
(use-package simpleclip
  :ensure t
  :defer 1
  :config
  (simpleclip-mode 1))

(electric-pair-mode 1)
(setq electric-pair-pairs '((?\" . ?\") (?\' . ?\') (?\{ . ?\})))

; 在新窗口中创建并打开一个空白缓冲区
(defun new-frame-with-empty-buffer ()
  (interactive)
  (let ((buffer (generate-new-buffer "untitled")))
    (with-current-buffer buffer
      (text-mode))
    (switch-to-buffer-other-frame buffer)))

(global-set-key (kbd "s-n") 'new-frame-with-empty-buffer)

;; 允许补全时进行部分匹配, 这样在 :e 时直接输入文件名即可触发补全，无需 ./ 前缀
(setq completion-styles '(basic partial-completion substring))

;; 部分补全场景下的通用忽略大小写设置, :e ~/Desktop 可输入小写 desktop 匹配
(setq completion-ignore-case t)

;; 编辑超大文件防止卡顿
(setq-default bidi-display-reordering nil)
(setq bidi-inhibit-bpa t
      long-line-threshold 1000
      large-hscroll-threshold 1000
      syntax-wholeline-max 1000)

(use-package indent-bars
  :ensure t
  :hook (prog-mode . indent-bars-mode)
  :custom
  (indent-bars-width-frac 0.1)
  (indent-bars-color-by-depth nil)
  (indent-bars-pattern ".")
  (indent-bars-highlight-current-depth
   '(:face default :blend 0.1 :main-color "white")))

;; 解决 emacs 31 版本 evil 初始化警告异常
(defvar evil-mode-buffers '())

(defun my-smart-close-window ()
  (interactive)
  (let ((window-count (length (window-list)))
        (frame-count (length (frame-list))))
    (if (and (<= window-count 1) (<= frame-count 1))
        (save-buffers-kill-terminal)
      (condition-case nil
          (if (kill-buffer (current-buffer))
              (cond
               ((> window-count 1) (delete-window))
               ((> frame-count 1) (delete-frame))))
        (quit nil)))))

;; 在 emacs-mac 中，变量通常以 mac- 开头，而不是 ns-
(setq mac-command-modifier 'super)        ; 将 Command 键映射为 Super (s-)
(setq mac-option-modifier 'meta)          ; 将 Option 键映射为 Meta (M-)
(setq mac-control-modifier 'control)      ; 将 Control 保持为 Control (C-)
(setq mac-right-option-modifier 'none)    ; 右侧 Option 键建议设为 none，方便输入特殊符号

;; 常用快捷键绑定
(global-set-key (kbd "s-q") 'save-buffers-kill-terminal) ; 退出
(global-set-key (kbd "s-a") 'mark-whole-buffer)          ; 全选
(global-set-key (kbd "s-w") 'my-smart-close-window)      ; 关闭窗口
(global-set-key (kbd "s-f") 'isearch-forward)            ; 查找
(global-set-key (kbd "s-s") 'save-buffer)                ; 保存
(global-set-key (kbd "s-z") 'undo)                       ; 撤销

(defvar my-ocaml-config-loaded nil)

(defun my-load-ocaml-config ()
  "第一次进入 OCaml 模式时加载 OCaml 配置。"
  (unless my-ocaml-config-loaded
    (setq my-ocaml-config-loaded t)
    (load (expand-file-name
           "init_ocaml"
           (expand-file-name "configs" user-emacs-directory))
          nil 'nomessage))
  ;; 当前 buffer 第一次触发 hook 时，立即启用 Merlin
  (when (fboundp 'merlin-mode)
    (merlin-mode 1)))

(add-hook 'tuareg-mode-hook #'my-load-ocaml-config)
(add-hook 'caml-mode-hook #'my-load-ocaml-config)

(use-package dashboard
  :ensure t
  :defer t
  :custom
  (dashboard-items '((recents . 10)))
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-startupify-list
   '(dashboard-insert-banner
     dashboard-insert-newline
     dashboard-insert-banner-title
     dashboard-insert-newline
     dashboard-insert-init-info
     dashboard-insert-items
     dashboard-insert-newline)))

(defun my-started-with-file-p ()
  "判断 Emacs 启动后是否已经打开文件。"
  (catch 'opened
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (buffer-file-name)
          (throw 'opened t))))
    nil))

(defun my-open-dashboard-if-no-file ()
  "没有打开文件时加载并打开 Dashboard。"
  (unless (my-started-with-file-p)
    (require 'dashboard)
    (dashboard-open)))

(run-with-idle-timer
  0.3 nil
  #'my-open-dashboard-if-no-file)
