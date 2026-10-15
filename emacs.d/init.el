;; -*- lexical-binding: t; -*-

;; 开启 package-quickstart（单文件加载所有包 autoloads）
(setq package-quickstart t)
;; 只加载本地已安装的包，不在启动时访问网络
(package-initialize)

;; to disable collection of benchmark data after init is done.
;;(require 'benchmark-init)
;;(add-hook 'after-init-hook 'benchmark-init/deactivate)

(setq load-prefer-newer t)
(setq inhibit-startup-screen t
      inhibit-startup-message t)

;; load configuration from files
(load (expand-file-name "configs/init_base" user-emacs-directory)
      nil 'nomessage)

