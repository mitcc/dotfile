;; -*- lexical-binding: t; -*-
(use-package neotree
  :ensure t
  :commands (neotree-toggle
             neotree-enter
             neotree-find)
  :defer t
  :custom
  (neo-smart-open t)
  (neo-window-fixed-size nil)
  (neo-theme (when (display-graphic-p) 'arrow))
  :config
  (define-key evil-normal-state-map (kbd "RET") #'neotree-enter)
  (define-key evil-normal-state-map (kbd "SPC") #'neotree-enter)

  (defun my/neo-buffer--insert-root-entry (node)
    "自定义 NeoTree 根目录显示。"
    (neo-buffer--node-list-set nil node)
    (cond ((eq neo-cwd-line-style 'button)
           (neo-path--insert-header-buttonized node))
          (t
           (neo-buffer--insert-with-face
            (neo-path--shorten node (window-body-width))
            'neo-root-dir-face)))
    (neo-buffer--newline-and-begin)
    (when neo-show-updir-line
      (insert-button ".."
                     'action '(lambda (_) (neotree-change-root))
                     'follow-link t
                     'face neo-dir-link-face
                     'neo-full-path (neo-path--updir node))
      (neo-buffer--newline-and-begin)))

  (defalias 'neo-buffer--insert-root-entry
    #'my/neo-buffer--insert-root-entry))
