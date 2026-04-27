;; .emacs --- Emacs configuration -*- lexical-binding: t; -*-
(scroll-bar-mode -1)
(electric-pair-mode 1)
(menu-bar-mode 1)
(scroll-bar-mode 1)
(tool-bar-mode -1)
;; key setting
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
;; backup file
(setq my-backup-dir (expand-file-name "~/.emacs.d/backups/"))
(unless (file-exists-p my-backup-dir)
  (make-directory my-backup-dir t))
(setq backup-directory-alist `(("." . ,my-backup-dir)))
(setq auto-save-file-name-transforms `((".*" ,my-backup-dir t)))
(setq create-lockfiles nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(global-display-line-numbers-mode t)
(global-auto-revert-mode 1)
(let ((mono-spaced-font "CaskaydiaCove Nerd Font")
      (proportionately-spaced-font "Sans"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 140)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0))

(setq custom-file (locate-user-emacs-file "custome.el"))
(load custom-file :no-error-file-is-missing)

;; package.el is not needed — straight.el handles everything
(require 'package)

;; straight setting
 (defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-use-package-by-default t)
(setq straight-repository-branch "master")
(require 'straight-x)
(straight-use-package 'use-package)

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))
(use-package emacs
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package php-mode
  :straight t
  :hook (php-mode . (lambda ()
                      (setq-local company-backends '(company-phpactor company-files))
                      ))
  :mode "\\.php\\'"
    )
(use-package ddskk
  :straight t
  :bind
  (("C-x j" . skk-mode))
  :config
  (setq skk-show-mode-show t)
  (setq skk-egg-like-newline t)
  (setq skk-jisyo-code 'utf-8)
  (setq skk-large-jisyo "~/.config/SKK-JISYO.L")yy
  (setq skk-server-host "localhost")
  (setq skk-server-portnum 1178))
;; 候補を縦に並べる
(use-package vertico
  :straight t
  :init
  (vertico-mode))
;; 絞り込みロジックを「順不同・部分一致」にする
(use-package orderless
  :straight t
  :custom
  (completion-styles '(orderless basic))
  (orderless-matching-styles '(orderless-literal orderless-regexp orderless-flex))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :straight t
  :init
  (marginalia-mode))
(use-package consult
  :ensure t
  ;; よく使う標準コマンドを Consult の便利なコマンドに置き換える
  :bind (("C-x b" . consult-buffer)         ;; バッファ切り替え（最近使ったファイルなども含む）
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-s" . consult-line)             ;; 現在のバッファ内を検索（プレビュー付き）
         ("M-y" . consult-yank-pop)         ;; クリップボード（kill-ring）の履歴から貼り付け
         ("M-g g" . consult-goto-line)      ;; 行指定ジャンプ
         ("M-g i" . consult-imenu)          ;; 関数や見出しへのジャンプ
         ("C-c r" . consult-ripgrep))       ;; ripgrepを使ったプロジェクト内検索（※rgのインストールが必要）
         
  :config
  ;; Consultのプレビューを遅延させる（動作を軽くするため）
  (setq consult-preview-key 'any))
(use-package consult-ghq
  :straight t
  :bind
  ("C-c g p" . consult-ghq-switch-project)
  ("C-c g f" . consult-ghq-find)
  ("C-c g g" . consult-ghq-grep)
)
;; (use-package inkpot-theme
;;   :straight t
;;   :config
;;   (load-theme 'inkpot)
;;   )
(with-eval-after-load 'eglot
  (defun my-eglot-disable-file-watching (orig-fn &rest args)
    (let ((caps (apply orig-fn args)))
      ;; didChangeWatchedFiles のサポートを偽装（false）する
      (setf (cl-getf (cl-getf caps :workspace) :didChangeWatchedFiles)
            '(:dynamicRegistration :json-false :relativePatternSupport :json-false))
      caps))
  (advice-add 'eglot-client-capabilities :around #'my-eglot-disable-file-watching))

;; サーバープログラムの設定 (Node 20とメモリ拡張の安全設定は維持)
(use-package eglot
  :custom
  (eglot-sync-connect 1)
  (eglot-autoshutdown t)
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  
  :config
  (add-to-list 'eglot-server-programs
               '((php-mode php-ts-mode) . ("mise" "exec" "node@20" "--" "env" "NODE_OPTIONS=--max-old-space-size=8192" "intelephense" "--stdio")))

  :hook
  ((python-ts-mode . eglot-ensure)
   (lua-ts-mode . eglot-ensure)
   (js-ts-mode . eglot-ensure)
   (typescript-ts-mode . eglot-ensure)
   (php-mode . eglot-ensure)
   (php-ts-mode . eglot-ensure)
   (rust-ts-mode . eglot-ensure)))

;; Completion: Corfu
(use-package corfu
;;  :after eglot                         
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-quit-no-match nil)
  (corfu-always-indent 'complete)
  :init
  (global-corfu-mode))
;; Cape
(use-package cape
  :ensure t
  :after corfu
  :bind ("C-c p" . cape-prefix-map)
  :config
  (defun my/elisp-capf ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'cape-elisp-symbol
                       #'yasnippet-capf
                       #'cape-dabbrev
                       #'cape-file)))
    (add-hook 'emacs-lisp-mode-hook #'my/elisp-capf)
  (defun my/eglot-capf ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'eglot-completion-at-point
                       #'yasnippet-capf
                       #'cape-keyword
                       #'cape-dabbrev)
                      #'cape-file)))
  (add-hook 'eglot-managed-mode-hook #'my/eglot-capf))
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev t)
  (add-hook 'completion-at-point-functions #'cape-file t)
  (add-hook 'completion-at-point-functions #'cape-elisp-block t)
  (add-hook 'completion-at-point-functions #'yasnippet-capf))
;;(add-hook 'completion-at-point-functions #'eglot-completion-at-point))
(use-package eldoc-box
  :straight t
  :config
  (setq eldoc-box-hover-render-function
        (lambda (contents)
          (with-temp-buffer
            (insert contents)
            (markdown-mode)
            (font-lock-ensure)
            (buffer-string)))))

;; Yasnippet
(use-package yasnippet
  :after cape
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet
  :config
  (yas-reload-all))

(use-package yasnippet-capf
  :ensure t
  :after cape)

(use-package magit
  :straight t
  :custom
  (magit-auto-revert-mode t)
  :bind
  (("C-x g" . magit-status)))
(use-package puni
  :defer t
  
  )
(use-package meow
  :ensure t
  :custom
  (meow-use-clipboard t)
  :config
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet)
     
     '("j" . "H-j")
     '("k" . "H-k")
     '("f" . find-file)
     '("b" . switch-to-buffer))
    (meow-normal-define-key
     '("M-i" . puni-mark-list-around-point)
     '("M-a" . puni-mark-sexp-around-point)
     '("+ +" . puni-expand-region)
     '("0" . meow-expand-0)
     '("1" . meow-expand-1)
     '("2" . meow-expand-2)
     '("3" . meow-expand-3)
     '("4" . meow-expand-4)
     '("5" . meow-expand-5)
     '("6" . meow-expand-6)
     '("7" . meow-expand-7)
     '("8" . meow-expand-8)
     '("9" . meow-expand-9)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("g l" . move-end-of-line)
     '("g h" . move-beginning-of-line)
     '("g" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-next-word)
     '("W" . meow-next-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)))
  (meow-setup)
  (meow-global-mode 1))

(use-package majutsu
  :straight (:host github :repo "0WD0/majutsu"))

(put 'upcase-region 'disabled nil)

(use-package web-mode
  :ensure t
  :mode ("\\.tpl\\'" . web-mode)
  :custom
  (web-mode-markup-indent-offset 4)
  (web-mode-css-indent-offset 4)
  (web-mode-code-indent-offset 4)
  (web-mode-attr-indent-offset 4)
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-css-colorization t)

  :config
  (add-to-list 'web-mode-engines-alist '("smarty" . "\\.tpl\\'")))
