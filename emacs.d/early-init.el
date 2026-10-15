;; -*- lexical-binding: t; -*-

;; 启动期间关闭垃圾回收，并在启动完成后恢复为 16MB
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; 临时清空 file-name-handler-alist，启动完毕后恢复
(defvar my--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my--file-name-handler-alist)))

;; 避免加载 site-run-file
(setq site-run-file nil)

;; 禁止 Emacs 在 init.el 之前自动初始化包
(setq package-enable-at-startup nil)

;; 提前关闭 GUI 控件，避免初次绘图闪烁和重排
(push '(menu-bar-lines . 1) default-frame-alist)   ; macOS 建议保留系统顶栏菜单，如不需要可设为 0
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . right) default-frame-alist) ; 在右侧显示垂直滚动条
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(width . 100) default-frame-alist)
(push '(height . 40) default-frame-alist)
(push '(font . "Monaco for Powerline-13") default-frame-alist)
(push '(background-color . "#263238") default-frame-alist)
(push '(foreground-color . "#eeffff") default-frame-alist)

;; MacOS 字体缓存优化
(setq inhibit-compacting-font-caches t)

;; emacs-mac：Finder/右键打开文件时使用新的 Emacs frame
(when (eq system-type 'darwin)
  (setq dnd-open-file-other-window t)
  (setq pop-up-frames 'graphic-only))

(defun my-emacs-placeholder-frame-p ()
  "判断当前是否只有启动时的占位 frame。"
  (and (= (length (frame-list)) 1)
       (let ((buffer (window-buffer (frame-selected-window))))
         (or (string= (buffer-name buffer) "*scratch*")
             (string= (buffer-name buffer) "*dashboard*")))))

(defun my-dnd-open-local-file-advice (orig-fun &rest args)
  "避免启动时的 *scratch* frame 与外部文件各占一个 frame。"
  (let ((dnd-open-file-other-window
         (and dnd-open-file-other-window
              (not (my-emacs-placeholder-frame-p)))))
    (apply orig-fun args)))

(defun my-install-dnd-open-file-advice ()
  "安装 emacs-mac 外部文件打开行为。"
  (when (fboundp 'dnd-open-local-file)
    (unless (advice-member-p
             #'my-dnd-open-local-file-advice
             'dnd-open-local-file)
      (advice-add 'dnd-open-local-file
                  :around
                  #'my-dnd-open-local-file-advice))))

(add-hook 'emacs-startup-hook
          #'my-install-dnd-open-file-advice)
