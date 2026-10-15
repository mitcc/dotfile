;; -*- lexical-binding: t; -*-
(use-package helm
  :ensure t
  :defer 1

  :init
  (setq helm-buffers-fuzzy-matching t)

  :bind
  (("C-c h" . helm-command-prefix)
   ("M-x" . helm-M-x)
   ("C-x C-f" . helm-find-files)
   ("C-x b" . helm-buffers-list)
   ("C-c b" . helm-bookmarks)
   ("C-c f" . helm-recentf)
   ("C-c g" . helm-grep-do-git-grep))

  :config
  ;; 启动后空闲约 1 秒再启用全局 Helm 模式
  (helm-mode 1))
