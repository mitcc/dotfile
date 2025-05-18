;; -*- lexical-binding: t; -*-

;; 只加载本地已安装的包，不在启动时访问网络
(package-initialize)

(require 'benchmark-init)
;; To disable collection of benchmark data after init is done.
(add-hook 'after-init-hook 'benchmark-init/deactivate)

(setq load-prefer-newer t)
(setq inhibit-startup-screen t
      inhibit-startup-message t)

;; load configuration from files
(load (expand-file-name "configs/init_base" user-emacs-directory)
      nil 'nomessage)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e81fa2f29ff307623de1a5daca80bee8c4f744109ca206f26c580996ec04bf9a"
     "bb0f3ae2f6f6f6dbbbe03df66d74ca0aecefa6723ac1686f421dd1ffe26b71c3"
     "ba4f725d8e906551cfab8c5f67e71339f60fac11a8815f51051ddb8409ea6e5c"
     default))
 '(package-selected-packages
   '(alert all-the-icons-dired benchmark-init cape clipetty
           color-identifiers-mode corfu-terminal counsel csv-mode
           dashboard diminish dired-hacks-utils doom-modeline
           doom-themes ef-themes eglot embark-consult emojify
           evil-anzu evil-collection evil-leader evil-matchit
           evil-nerd-commenter evil-traces exec-path-from-shell
           expand-region flycheck fringe-helper git-gutter
           heaven-and-hell helm-descbinds helm-lsp helm-swoop
           highlight highlight-indent-guides iedit indent-bars
           indent-guide inline-docs json-mode json5-ts-mode keycast
           lsp-java lsp-ui magit-section marginalia
           markdown-preview-mode markdown-ts-mode material-theme
           memoize merlin neotree orderless org-contrib org-modern ov
           persp-mode popper popup powerline project-explorer
           projectile protobuf-mode protobuf-ts-mode
           quelpa-use-package quick-peek quickrun rainbow-delimiters
           rainbow-mode rich-minority simpleclip sqlformat svg-lib
           transient treesit-auto tuareg undo-tree use-package-chords
           vertico vimrc-mode wgrep with-editor yafolding
           yasnippet-classic-snippets yasnippet-snippets)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-ex-substitute-matches ((t (:inherit diff-removed :foreground unspecified :background unspecified))))
 '(evil-ex-substitute-replacement ((t (:inherit diff-added :foreground unspecified :background unspecified))))
 '(evil-traces-change ((t (:inherit diff-removed))))
 '(evil-traces-copy-preview ((t (:inherit diff-added))))
 '(evil-traces-copy-range ((t (:inherit diff-changed))))
 '(evil-traces-delete ((t (:inherit diff-removed))))
 '(evil-traces-global-match ((t (:inherit diff-added))))
 '(evil-traces-global-range ((t (:inherit diff-changed))))
 '(evil-traces-join-indicator ((t (:inherit diff-added))) t)
 '(evil-traces-join-range ((t (:inherit diff-changed))))
 '(evil-traces-move-preview ((t (:inherit diff-added))))
 '(evil-traces-move-range ((t (:inherit diff-removed))))
 '(evil-traces-normal ((t (:inherit diff-changed))))
 '(evil-traces-shell-command ((t (:inherit diff-changed))))
 '(evil-traces-substitute-range ((t (:inherit diff-changed))))
 '(evil-traces-yank ((t (:inherit diff-changed)))))

