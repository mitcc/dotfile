;; -*- lexical-binding: t; -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 修复鼠标滚轮/触控板滚动时选区遇边缘扩大的问题（完整修复版）
;;
;; 核心机制：
;; 1. 精准选区捕获：统一通过真实边界提取选区 [beg, end]，杜绝 Evil 下方向反选导致的选区退化。
;; 2. 端点智能调换 (Endpoint Anchoring)：当一端滚出视口、另一端仍可见时，
;;    强制将活动端点 (point) 锚定在当前可视端，锚点 (mark) 处于出界端（Emacs 允许 mark 越界）。
;; 3. 全局越界安全挂起与无缝唤醒：两端均滚出时静默挂起并清除高亮；
;;    滚回任一端点（支持亚像素/部分行露出）时瞬间无缝重建并精准高亮。
;; 4. 越界操作兜底：选区越界不可见时按复制、删除等任意操作命令，执行前瞬间恢复原始选区范围。
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(declare-function evil-visual-state-p "evil-states")
(declare-function evil-exit-visual-state "evil-states")
(declare-function evil-visual-select "evil-states")
(declare-function evil-active-region "evil-states")
(declare-function evil-visual-type "evil-states")

(defvar-local my-scroll--saved-selection nil
  "暂存的选区数据。格式为 plist: (:beg BEG :end END :type TYPE :evil IS-EVIL)")

(defun my-scroll--is-scroll-command-p (cmd)
  "判断 CMD 是否为滚动或窗口切换类命令。"
  (or (memq cmd '(mwheel-scroll
                  mac-mwheel-scroll
                  pixel-scroll-precision
                  pixel-scroll-up pixel-scroll-down
                  scroll-up scroll-down
                  scroll-up-command scroll-down-command
                  scroll-bar-toolkit-scroll scroll-bar-drag
                  handle-select-window handle-switch-frame))
      (get cmd 'scroll-command)))

(defun my-scroll--get-current-selection ()
  "精准获取当前缓冲区的选区范围及元数据。
返回 plist (:beg BEG :end END :type TYPE :evil BOOL)，未激活时返回 nil。"
  (cond
   ;; Evil Visual State 激活状态
   ((and (bound-and-true-p evil-mode)
         (fboundp 'evil-visual-state-p)
         (evil-visual-state-p))
    (let* ((vb (bound-and-true-p evil-visual-beginning))
           (ve (bound-and-true-p evil-visual-end))
           (b-pos (and (markerp vb) (marker-position vb)))
           (e-pos (and (markerp ve) (marker-position ve))))
      (when (and b-pos e-pos)
        (list :beg (min b-pos e-pos)
              :end (max b-pos e-pos)
              :type (evil-visual-type)
              :evil t))))

   ;; 原生 Emacs Region 激活状态
   ((and (bound-and-true-p mark-active)
         (use-region-p))
    (let ((rb (region-beginning))
          (re (region-end)))
      (list :beg (min rb re)
            :end (max rb re)
            :type nil
            :evil nil)))

   (t nil)))

(defun my-scroll--pos-visible-p (pos win)
  "检查 POS 是否在窗口 WIN 中可见（包含首尾边缘部分露出的情况）。"
  (and pos
       (window-live-p win)
       (or (pos-visible-in-window-p pos win t)
           (let ((ws (window-start win))
                 (we (window-end win t)))
             (and ws we (>= pos ws) (<= pos we))))))

(defun my-scroll--apply-selection (beg end type is-evil &optional preferred-pt win)
  "在当前窗口应用/恢复 [BEG, END] 选区。
PREFERRED-PT 为 \\='beg 或 \\='end，若为 nil 则自动选择当前窗口内可见的端点作为 point。"
  (let* ((w (or win (selected-window)))
         ;; 决定 point 应该放置在哪一端：优先保证 point 处于视口内
         (target-pt (or preferred-pt
                        (cond
                         ((and (my-scroll--pos-visible-p end w)
                               (not (my-scroll--pos-visible-p beg w))) 'end)
                         ((and (my-scroll--pos-visible-p beg w)
                               (not (my-scroll--pos-visible-p end w))) 'beg)
                         (t (if (<= (abs (- (point) beg)) (abs (- (point) end)))
                                'beg 'end))))))
    (if is-evil
        (progn
          ;; dir: 1 代表 point 在 end (mark 在 beg); -1 代表 point 在 beg (mark 在 end)
          (evil-visual-select beg end type (if (eq target-pt 'beg) -1 1))
          (evil-active-region 1)
          (setq deactivate-mark nil))
      (if (eq target-pt 'beg)
          (progn
            (goto-char beg)
            (set-mark end))
        (goto-char end)
        (set-mark beg))
      (activate-mark)
      (setq deactivate-mark nil))))

(defun my-scroll--restore-saved-selection (&optional preferred-pt)
  "恢复暂存的选区。"
  (when my-scroll--saved-selection
    (let* ((beg (plist-get my-scroll--saved-selection :beg))
           (end (plist-get my-scroll--saved-selection :end))
           (type (plist-get my-scroll--saved-selection :type))
           (is-evil (plist-get my-scroll--saved-selection :evil)))
      (setq my-scroll--saved-selection nil)
      (my-scroll--apply-selection beg end type is-evil preferred-pt))))

(defun my-scroll--wheel-scroll-around (orig-fun &rest args)
  "环绕拦截滚轮/触控板滚动，彻底杜绝选区拉伸，保证两端出界挂起与滚回无损恢复。"
  (let* ((win (selected-window))
         (curr-sel (my-scroll--get-current-selection))
         ;; 记录当前激活的选区，若无激活选区则沿用此前暂存的选区
         (active-sel (or curr-sel my-scroll--saved-selection)))

    ;; 执行实际滚动
    (apply orig-fun args)

    ;; 仅在存在选区时介入保护
    (when (and active-sel (window-live-p win))
      (with-selected-window win
        (let* ((beg (plist-get active-sel :beg))
               (end (plist-get active-sel :end))
               (type (plist-get active-sel :type))
               (is-evil (plist-get active-sel :evil))
               (beg-vis (my-scroll--pos-visible-p beg win))
               (end-vis (my-scroll--pos-visible-p end win)))
          (cond
           ;; 情况 1：选区至少有一端重新进入（或仍然在）视口内 -> 维持/恢复激活状态
           ((or beg-vis end-vis)
            ;; 清空暂存标志
            (setq my-scroll--saved-selection nil)
            ;; 智能重定向：哪个端点在视口内，就将 point 锚定在哪端；
            ;; 确保 point 绝对不会落在视口外，防止 Emacs 滚动引擎二次挤压破坏选区
            (let ((pt-target (cond
                              ((and beg-vis (not end-vis)) 'beg)
                              ((and end-vis (not beg-vis)) 'end)
                              (t nil))))
              (my-scroll--apply-selection beg end type is-evil pt-target win)))

           ;; 情况 2：选区两端均处于视口外（越过 title bar 或 mode-line 完全出界）
           (t
            ;; 将选区精准暂存（使用 marker position 数字，杜绝引用破坏）
            (setq my-scroll--saved-selection
                  (list :beg beg :end end :type type :evil is-evil))
            ;; 安全退出高亮，释放视口自由滚动，防止 point 被 C 引擎强推变形
            (if is-evil
                (when (and (fboundp 'evil-visual-state-p) (evil-visual-state-p))
                  (evil-exit-visual-state))
              (when mark-active
                (deactivate-mark))))))))))

(defun my-scroll--pre-command ()
  "在执行非滚动命令前协同处理暂存选区，确保跨屏复制、删除等操作精准生效。"
  (when my-scroll--saved-selection
    (let ((cmd this-command))
      (cond
       ;; 1. 滚动与切窗命令：继续保持安全暂存
       ((my-scroll--is-scroll-command-p cmd) nil)

       ;; 2. 明确的退出/放弃命令：丢弃暂存
       ((memq cmd '(keyboard-quit
                    evil-normal-state
                    evil-force-normal-state
                    top-level
                    abort-recursive-edit))
        (setq my-scroll--saved-selection nil))

       ;; 3. 光标移动、点击、输入类按键：丢弃暂存
       ((or (memq cmd '(self-insert-command
                        newline
                        evil-insert evil-append
                        evil-forward-char evil-backward-char
                        evil-next-line evil-previous-line
                        forward-char backward-char
                        next-line previous-line
                        mouse-set-point evil-mouse-set-point))
            (and (symbolp cmd)
                 (string-match-p "\\(mouse\\|motion\\|move\\)" (symbol-name cmd))))
        (setq my-scroll--saved-selection nil))

       ;; 4. 其它所有操作命令（复制、删除、剪切、代码格式化等，如 Cmd+S/Cmd+C/M-w/y/d）：
       ;;    执行前瞬间重建原始选区，保证命令作用范围绝对精准！
       (t
        (my-scroll--restore-saved-selection))))))

;;; 安装全局 Advice
(dolist (fn '(mwheel-scroll
              mac-mwheel-scroll
              pixel-scroll-precision
              scroll-bar-toolkit-scroll
              scroll-bar-drag))
  (when (fboundp fn)
    (advice-add fn :around #'my-scroll--wheel-scroll-around)))

(add-hook 'pre-command-hook #'my-scroll--pre-command)

(provide 'init_scroll_preserve)
