;; load configuration from other files  -*- lexical-binding: t; -*-
(org-babel-load-file "~/.emacs.d/configs/init_evil.el")
(org-babel-load-file "~/.emacs.d/configs/init_neotree.el")
(org-babel-load-file "~/.emacs.d/configs/init_corfu.el")
(org-babel-load-file "~/.emacs.d/configs/init_vertico.el")
(org-babel-load-file "~/.emacs.d/configs/init_illuminate.el")
(org-babel-load-file "~/.emacs.d/configs/init_json_format.el")
(org-babel-load-file "~/.emacs.d/configs/init_smarttab.el")
(org-babel-load-file "~/.emacs.d/configs/init_scratch.el")
(org-babel-load-file "~/.emacs.d/configs/init_smart_click.el")
(org-babel-load-file "~/.emacs.d/configs/init_ocaml.el")
;;(org-babel-load-file "~/.emacs.d/configs/init_helm.el")
(org-babel-load-file "~/.emacs.d/configs/init_text_compare.el")
(org-babel-load-file "~/.emacs.d/configs/init_json_compare.el")

(setq inhibit-splash-screen t) ;; 禁用欢迎界面
(add-hook 'after-init-hook
	  (lambda ()
	    (when (get-buffer "*GNU Emacs*")
	      (kill-buffer "*GNU Emacs*"))
	    (find-file "~/.emacs.d/configs/init_base.el")))

(setq url-gateway-method 'socks)
(setq socks-server '("Default server" "127.0.0.1" 51837 5))

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")))

(package-initialize) ;; 防止反复调用 package-refresh-contents 会影响加载速度
(when (not package-archive-contents)
  (package-refresh-contents))

(use-package exec-path-from-shell :ensure t)
(exec-path-from-shell-initialize)

(setq make-backup-files nil) ;关闭备份文件
(auto-save-visited-mode 1) ;启用自动保存到当前访问的文件
(setq-default show-trailing-whitespace t) ;; 尾部空格设置
(setq delete-trailing-lines nil) ;; 禁止 delete-trailing-whitespace 删除文件末尾的空行
(add-hook 'before-save-hook 'delete-trailing-whitespace) ; 保存前删掉行末空格
(fset 'yes-or-no-p 'y-or-n-p)
(global-display-line-numbers-mode t) ;显示行号
(column-number-mode 1) ;显示光标所在列号
(tool-bar-mode -1) ;关闭工具栏
(scroll-bar-mode -1) ;关闭文件滑动控件
(global-hl-line-mode 1) ;高亮当前行
(xterm-mouse-mode t) ;启用终端鼠标支持
(setq initial-scratch-message nil) ;设置 *scratch* 缓冲区的初始信息为空
(add-hook 'prog-mode-hook (lambda () (modify-syntax-entry ?_ "w"))) ;将下划线 _ 加入单词字符
(add-hook 'text-mode-hook (lambda () (modify-syntax-entry ?_ "w")))

(load-theme 'material t)
;; 更改显示字体大小 16pt
;; http://stackoverflow.com/questions/294664/how-to-set-the-font-size-in-emacs
(set-face-attribute 'default nil :height 130 :family "Monaco for Powerline")
(set-face-attribute 'region nil :background "#777777" :foreground "#CDCDCD")
(setq initial-frame-alist '((width . 100) (height . 40))) ;; 设置初始窗口大小（字符宽度x高度）
;;(add-to-list 'default-frame-alist '(width . 100)) ; （可选）设定启动图形界面时的初始 Frame 宽度（字符数）
;;(add-to-list 'default-frame-alist '(height . 40)) ; （可选）设定启动图形界面时的初始 Frame 高度（字符数）

;; 设置标题显示格式
(setq frame-title-format
	  '((:eval
		 (if (buffer-file-name)
			 (let ((file (file-name-nondirectory (buffer-file-name)))
				   (dir (abbreviate-file-name (file-name-directory (buffer-file-name)))))
			   (concat file " (" dir ")"))
		   "%b"))))

;; 全局启用保存位置功能
(save-place-mode 1)

(use-package recentf
  :init (recentf-mode)
  :custom
  (recentf-max-menu-items 50))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  (setq doom-modeline-buffer-file-name-style 'file-name)
  (setq doom-modeline-project-name t))

;; 编程模式下颜色代码背景色显示
(use-package rainbow-mode
  :ensure t
  :hook (prog-mode . rainbow-mode))

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode) ; 彩色括号
(add-hook 'text-mode-hook 'rainbow-delimiters-mode)

(use-package yasnippet :config (yas-global-mode))
(use-package yasnippet-snippets :ensure t)

; 超过单行长度后隐藏箭头
(with-eval-after-load 'simple
  (setf (cdr (assq 'truncation fringe-indicator-alist)) nil)
  (setf (cdr (assq 'continuation fringe-indicator-alist)) nil))

(use-package git-gutter
  :ensure t
  :hook (after-init . global-git-gutter-mode) ; 启动时全局启用
  :config
  (custom-set-variables '(git-gutter:diff-option "HEAD"))
  (custom-set-variables '(git-gutter:modified-sign " "))
  (set-face-background 'git-gutter:modified "orange")
  (set-face-foreground 'git-gutter:added "green")
  (set-face-foreground 'git-gutter:deleted "red"))

; super-x, super-c, super-v 使用系统粘贴板, 与 emacs/evil 互不影响
(require 'simpleclip)
(simpleclip-mode 1)

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
  :config
  (setq indent-bars-width-frac 0.1)
  (setq indent-bars-color-by-depth nil)
  (setq indent-bars-pattern ".")
  (setq indent-bars-highlight-current-depth '(:face default :blend 0.1 :main-color "white"))
)

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

