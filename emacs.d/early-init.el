;; 禁止 Emacs 在 init.el 之前自动初始化包
(setq package-enable-at-startup nil)

;; 减少启动期间 GC 次数
(setq gc-cons-threshold (* 100 1024 1024)
      gc-cons-percentage 0.6)

