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
  (neo-theme 'nerd-icons)
  (neo-vc-integration '(char face))
  :config
  (setq window-divider-default-places 'right-only
        window-divider-default-right-width 1)
  (window-divider-mode 1)
  (set-face-attribute 'window-divider nil :foreground "#546e7a")
  (set-face-attribute 'window-divider-first-pixel nil :foreground "#78909c")
  (set-face-attribute 'window-divider-last-pixel nil :foreground "#78909c")

  (defvar my/neo-width-by-frame (make-hash-table :test #'eq)
    "NeoTree widths remembered per frame.")

  (defun my/neo-remember-window-width (&rest _)
    "Remember the current NeoTree width for its frame."
    (when (window-live-p neo-global--window)
      (let ((frame (window-frame neo-global--window)))
        (puthash frame (cons (frame-pixel-width frame)
                             (window-total-width neo-global--window))
                 my/neo-width-by-frame))))

  (defun my/neo-keep-width-on-frame-resize (frame)
    "Keep NeoTree's width when FRAME changes width.
Dragging NeoTree's own divider updates the remembered width instead."
    (when (and (window-live-p neo-global--window)
               (eq (window-frame neo-global--window) frame))
      (let* ((window neo-global--window)
             (frame-width (frame-pixel-width frame))
             (saved (gethash frame my/neo-width-by-frame)))
        (cond
         ((null saved)
          (my/neo-remember-window-width))
         ((/= frame-width (car saved))
          (let ((delta (- (cdr saved) (window-total-width window))))
            (when (/= delta 0)
              (condition-case nil
                  (window-resize window delta t)
                (error nil))))
          (puthash frame (cons frame-width (window-total-width window))
                   my/neo-width-by-frame))
         (t
          (my/neo-remember-window-width))))))

  (defun my/neo-scroll-bar-on-left (&rest _)
    (when (window-live-p neo-global--window)
      (set-window-scroll-bars neo-global--window nil 'left nil t t)
      (my/neo-remember-window-width)))

  (defun my/neo-compact-nerd-icons (orig name &optional node-name)
    "Insert compact Nerd Icons without NeoTree's tab-based padding."
    (if (eq neo-theme 'nerd-icons)
        (progn
          (require 'nerd-icons)
          (pcase name
            ((or 'open 'close)
             (let ((chevron (nerd-icons-octicon
                             (format "nf-oct-chevron_%s"
                                     (if (eq name 'open) "down" "right"))
                             :height 0.8 :v-adjust -0.1))
                   (icon (nerd-icons-icon-for-dir
                          (directory-file-name node-name))))
               (insert chevron " " icon)))
            ('leaf
             (insert (nerd-icons-icon-for-file node-name)))))
      (funcall orig name node-name)))

  (add-hook 'neo-after-create-hook #'my/neo-scroll-bar-on-left)
  (add-hook 'window-size-change-functions #'my/neo-keep-width-on-frame-resize)
  (unless (advice-member-p #'my/neo-compact-nerd-icons
                           'neo-buffer--insert-fold-symbol)
    (advice-add 'neo-buffer--insert-fold-symbol :around
                #'my/neo-compact-nerd-icons))

  (defconst my/neo-git-status-indicator-alist
    '((modified . ?✹) (staged . ?✚) (untracked . ?✭)
      (renamed . ?➜) (unmerged . ?═) (deleted . ?✖)
      (dirty . ?✗) (ignored . ?☒) (unknown . ??)))

  (defface my/neo-git-staged-indicator-face
    '((t :foreground "#98c379"))
    "Face for staged and renamed Git indicators.")
  (defface my/neo-git-modified-indicator-face
    '((t :foreground "#e5c07b"))
    "Face for modified and unsaved Git indicators.")
  (defface my/neo-git-error-indicator-face
    '((t :foreground "#e06c75"))
    "Face for untracked, deleted, and conflicted Git indicators.")
  (defface my/neo-git-ignored-indicator-face
    '((t :foreground "#5c6370"))
    "Face for ignored Git indicators.")

  (defvar my/neo-git-status-cache (make-hash-table :test #'equal)
    "Git status tables, keyed by repository root.")
  (defvar my/neo-git-keep-status-cache nil)
  (defvar my/neo-pending-refresh-timer nil)

  (defun my/neo-git-root (file)
    "Return FILE's Git root, or nil when it is not in a local repository."
    (when (and file (executable-find "git") (not (file-remote-p file)))
      ;; `locate-dominating-file' may abbreviate $HOME as "~".  Expand it
      ;; because `git -C' receives its argument literally and does not do
      ;; shell-style tilde expansion.
      (when-let ((root (locate-dominating-file
                        (if (file-directory-p file)
                            file
                          (file-name-directory file))
                        ".git")))
        (expand-file-name root))))

  (defun my/neo-git-status-from-porcelain (xy)
    "Translate the two-column Git porcelain state XY to a NeoTree state."
    (cond ((string= xy "??") 'untracked)
          ((string= xy "!!") 'ignored)
          ((string-match-p "U" xy) 'unmerged)
          ((string-match-p "R" xy) 'renamed)
          ((string-match-p "D" xy) 'deleted)
          ((not (eq (aref xy 0) ?\s)) 'staged)
          ((not (eq (aref xy 1) ?\s)) 'modified)
          (t 'clean)))

  (defun my/neo-git-status-table (root)
    "Return cached Git status table for ROOT, reading Git once when needed."
    (or (gethash root my/neo-git-status-cache)
        (let ((table (make-hash-table :test #'equal)))
          (with-temp-buffer
            (when (zerop (process-file "git" nil t nil "-C" root "status"
                                       "--porcelain=v1" "-z" "--ignored"
                                       "--untracked-files=all"))
              (let ((entries (split-string (buffer-string) "\0" t)))
                (while entries
                  (let* ((entry (pop entries))
                         (xy (substring entry 0 2))
                         (path (substring entry 3)))
                    (puthash (expand-file-name path root)
                             (my/neo-git-status-from-porcelain xy)
                             table)
                    (when (string-match-p "[RC]" xy)
                      (pop entries)))))))
          (puthash root table my/neo-git-status-cache)
          table)))

  (defun my/neo-git-status-face (status)
    "Return the NeoTree face matching Git STATUS."
    (pcase status
      ((or 'modified 'dirty) neo-vc-edited-face)
      ('staged neo-vc-added-face)
      ('untracked neo-vc-unregistered-face)
      ('renamed neo-vc-user-face)
      ('unmerged neo-vc-conflict-face)
      ('deleted neo-vc-removed-face)
      ('ignored neo-vc-ignored-face)
      ('clean neo-vc-up-to-date-face)
      (_ neo-vc-default-face)))

  (defun my/neo-git-indicator-face (status)
    "Return the conventional Git color for STATUS's indicator."
    (pcase status
      ((or 'staged 'renamed) 'my/neo-git-staged-indicator-face)
      ((or 'modified 'dirty) 'my/neo-git-modified-indicator-face)
      ((or 'untracked 'unmerged 'deleted) 'my/neo-git-error-indicator-face)
      ('ignored 'my/neo-git-ignored-indicator-face)
      (_ 'default)))

  (defun my/neo-insert-git-indicator (status)
    "Insert STATUS's indicator, or a blank alignment cell when absent."
    (let ((indicator (alist-get status my/neo-git-status-indicator-alist)))
      (if indicator
          (insert (propertize (char-to-string indicator)
                              'face (my/neo-git-indicator-face status)))
        (insert-char ?\s))))

  (defun my/neo-git-status-for-file (node)
    "Return NODE's Git status, including unsaved buffer edits."
    (let* ((file (expand-file-name node))
           (buffer (find-buffer-visiting file))
           (root (my/neo-git-root file)))
      (when root
        (if (and buffer (buffer-modified-p buffer))
            'dirty
          (gethash file (my/neo-git-status-table root))))))

  (defun my/neo-vc-for-node (_ node)
    "Provide Git-aware, NerdTree-style indicators for NeoTree file NODE."
    (let ((status (my/neo-git-status-for-file node)))
      (cons (or (alist-get status my/neo-git-status-indicator-alist) ?\s)
            (my/neo-git-status-face status))))

  (defun my/neo-git-directory-dirty-p (directory)
    "Return non-nil when DIRECTORY contains a non-clean Git file.
The repository root itself is deliberately excluded from the indicator."
    (let* ((directory (file-name-as-directory (expand-file-name directory)))
           (root (my/neo-git-root directory)))
      (when (and root (not (equal directory root)))
        (let ((dirty nil)
              (table (my/neo-git-status-table root)))
          (maphash (lambda (file status)
                     ;; Ignored files have their own marker but do not make
                     ;; a parent directory dirty.
                     (when (and (not (eq status 'ignored))
                                (file-in-directory-p file directory))
                       (setq dirty t)))
                   table)
          (dolist (buffer (buffer-list))
            (when (and (not dirty)
                       (buffer-live-p buffer))
              (with-current-buffer buffer
                (when (and buffer-file-name
                           (buffer-modified-p buffer)
                           (equal (my/neo-git-root buffer-file-name) root)
                           (file-in-directory-p buffer-file-name directory))
                  (setq dirty t)))))
          dirty))))

  (defun my/neo-buffer--insert-dir-entry (node depth expanded)
    "Insert a directory entry with a dirty marker when it has changed files."
    (let ((node-short-name (neo-path--file-short-name node)))
      (insert-char ?\s (* (- depth 1) 2))
      (neo-buffer--insert-fold-symbol (if expanded 'open 'close) node)
      (when (memq 'char neo-vc-integration)
        (my/neo-insert-git-indicator
         (when (my/neo-git-directory-dirty-p node) 'dirty)))
      (insert-button (if neo-show-slash-for-folder
                         (concat node-short-name "/")
                       node-short-name)
                     'follow-link t
                     'face neo-dir-link-face
                     'neo-full-path node
                     'keymap neotree-dir-button-keymap
                     'help-echo (neo-buffer--help-echo-message node-short-name))
      (neo-buffer--node-list-set nil node)
      (neo-buffer--newline-and-begin)))

  (defun my/neo-buffer--insert-file-entry (node depth)
    "Insert a file entry without a spacer after its Git status marker."
    (let ((node-short-name (neo-path--file-short-name node))
          (vc (when neo-vc-integration (neo-vc-for-node node))))
      (insert-char ?\s (* (- depth 1) 2))
      (neo-buffer--insert-fold-symbol 'leaf node-short-name)
      (when (memq 'char neo-vc-integration)
        (my/neo-insert-git-indicator
         (my/neo-git-status-for-file node)))
      (insert-button node-short-name
                     'follow-link t
                     'face (if (memq 'face neo-vc-integration)
                               (cdr vc)
                             neo-file-link-face)
                     'neo-full-path node
                     'keymap neotree-file-button-keymap
                     'help-echo (neo-buffer--help-echo-message node-short-name))
      (neo-buffer--node-list-set nil node)
      (neo-buffer--newline-and-begin)))

  (defun my/neo-clear-git-status-cache (&rest _)
    "Discard cached Git state before a normal NeoTree redraw."
    (unless my/neo-git-keep-status-cache
      (clrhash my/neo-git-status-cache)))

  (defun my/neo-refresh-visible-tree (&optional keep-git-cache)
    "Refresh a visible NeoTree without moving focus from the edited file."
    (when (neo-global--window-exists-p)
      (let ((my/neo-git-keep-status-cache keep-git-cache))
        (neotree-refresh t))))

  (defun my/neo-refresh-after-buffer-change ()
    "Refresh the dirty marker after Emacs has been idle briefly."
    (setq my/neo-pending-refresh-timer nil)
    (my/neo-refresh-visible-tree t))

  (defun my/neo-schedule-refresh-after-buffer-change (&rest _)
    "Debounce NeoTree redraws while editing a file shown in the tree."
    (when (and buffer-file-name
               (my/neo-git-root buffer-file-name)
               (neo-global--window-exists-p)
               (neo-global--file-in-root-p buffer-file-name))
      (when (timerp my/neo-pending-refresh-timer)
        (cancel-timer my/neo-pending-refresh-timer))
      (setq my/neo-pending-refresh-timer
            (run-with-idle-timer 0.4 nil #'my/neo-refresh-after-buffer-change))))

  (defun my/neo-refresh-after-save ()
    "Refresh Git state immediately when a file shown in NeoTree is saved."
    (when (and buffer-file-name
               (my/neo-git-root buffer-file-name)
               (neo-global--window-exists-p)
               (neo-global--file-in-root-p buffer-file-name))
      (when (timerp my/neo-pending-refresh-timer)
        (cancel-timer my/neo-pending-refresh-timer)
        (setq my/neo-pending-refresh-timer nil))
      (my/neo-refresh-visible-tree)))

  (defun my/neo-remove-trailing-empty-line (&rest _)
    "Remove NeoTree's final navigable blank line after a refresh."
    (when-let ((buffer (neo-global--get-buffer)))
      (with-current-buffer buffer
        (let ((inhibit-read-only t))
          (save-excursion
            (goto-char (point-max))
            (when (and (bolp) (> (point) (point-min)))
              (delete-char -1)))))))

  (defun my/neo-mode-line-index-only (parent index ndirs nfiles)
    (let ((text (if index (format "[%s/%s]" index (+ ndirs nfiles)) "")))
      (propertize text 'help-echo (decode-coding-string parent 'utf-8))))

  (unless (advice-member-p #'my/neo-vc-for-node 'neo-vc-for-node)
    (advice-add 'neo-vc-for-node :around #'my/neo-vc-for-node))
  (unless (advice-member-p #'my/neo-clear-git-status-cache 'neotree-show)
    (advice-add 'neotree-show :before #'my/neo-clear-git-status-cache))
  (unless (advice-member-p #'my/neo-clear-git-status-cache 'neotree-refresh)
    (advice-add 'neotree-refresh :before #'my/neo-clear-git-status-cache))
  (unless (advice-member-p #'my/neo-remove-trailing-empty-line
                           'neo-buffer--refresh)
    (advice-add 'neo-buffer--refresh :after #'my/neo-remove-trailing-empty-line))
  (unless (advice-member-p #'my/neo-mode-line-index-only
                           'neo-mode-line--compute-format)
    (advice-add 'neo-mode-line--compute-format :override
                #'my/neo-mode-line-index-only))
  (add-hook 'after-change-functions #'my/neo-schedule-refresh-after-buffer-change)
  (add-hook 'after-save-hook #'my/neo-refresh-after-save)

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
    #'my/neo-buffer--insert-root-entry)
  (defalias 'neo-buffer--insert-dir-entry
    #'my/neo-buffer--insert-dir-entry)
  (defalias 'neo-buffer--insert-file-entry
    #'my/neo-buffer--insert-file-entry))
