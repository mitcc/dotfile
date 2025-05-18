;; -*- lexical-binding: t; -*-
(use-package neotree
  :ensure t
  :config
  (setq neo-smart-open t) ;; 智能窗口切换
  (setq neo-window-fixed-size nil) ;; 支持鼠标拖拽窗口大小
  ;; neotree theme: classic (default), ascii, arrow, icons, nerd-icons, nerd
  (setq neo-theme (if (display-graphic-p) 'arrow))
  ;; neotree 在 evil normal 模式下的按键配置
  (define-key evil-normal-state-map (kbd "C-n") 'neotree-toggle)
  (define-key evil-normal-state-map (kbd "RET") 'neotree-enter)
  (define-key evil-normal-state-map (kbd "SPC") 'neotree-enter))

(with-eval-after-load 'neotree
  (defun my/neo-buffer--insert-root-entry (node)
    "自定义版本 - 去掉上级目录行的箭头"
    (neo-buffer--node-list-set nil node)
    (cond ((eq neo-cwd-line-style 'button)
           (neo-path--insert-header-buttonized node))
          (t
           (neo-buffer--insert-with-face (neo-path--shorten node (window-body-width))
                                         'neo-root-dir-face)))
    (neo-buffer--newline-and-begin)
    (when neo-show-updir-line
      (insert-button ".."
                     'action '(lambda (x) (neotree-change-root))
                     'follow-link t
                     'face neo-dir-link-face
                     'neo-full-path (neo-path--updir node))
      (neo-buffer--newline-and-begin))))

;; 替换原始函数
(defalias 'neo-buffer--insert-root-entry 'my/neo-buffer--insert-root-entry)

