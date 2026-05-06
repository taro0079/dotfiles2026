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
(load-theme 'tsdh-dark)
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
;; sql
(load (expand-file-name "~/.emacs.d/private-sql.el") t)
(use-package sql
  :defer t
  :bind (:map sql-mode-map
              ("C-c b" . sql-set-sqli-buffer)))


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
         ("C-c l" . consult-line)             ;; 現在のバッファ内を検索（プレビュー付き）
         ("M-y" . consult-yank-pop)         ;; クリップボード（kill-ring）の履歴から貼り付け
         ("M-g g" . consult-goto-line)      ;; 行指定ジャンプ
         ("M-g i" . consult-imenu)          ;; 関数や見出しへのジャンプ
         ("C-c r" . consult-ripgrep))       ;; ripgrepを使ったプロジェクト内検索（※rgのインストールが必要）
         
  :config
  ;; Consultのプレビューを遅延させる（動作を軽くするため）
  (setq consult-preview-key 'any))

;; どこにでもジャンプできるやつ
(use-package avy
  :straight t
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char2)
         ("M-g w" . avy-goto-word1)
         ("M-g l" . avy-goto-line)))
(use-package consult-ghq
  :straight t
  :bind
  ("C-c g p" . consult-ghq-switch-project)
  ("C-c g f" . consult-ghq-find)
  ("C-c g g" . consult-ghq-grep))

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
  (add-to-list 'eglot-server-programs
               '(sql-mode . ("~/go/bin/sqls")))

  :hook
  ((python-ts-mode . eglot-ensure)
   (lua-ts-mode . eglot-ensure)
   (js-ts-mode . eglot-ensure)
   (sql-mode . eglot-ensure)
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

(use-package diff-hl
  :ensure t
  :init
  (setq diff-hl-draw-borders nil)
  
  :config
  (global-diff-hl-mode)
  (add-hook 'after-save-hook 'diff-hl-update)
  (diff-hl-flydiff-mode 1)
  (diff-hl-margin-mode 1)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode-hook))


(use-package magit
  :straight t
  :custom
  (magit-auto-revert-mode t)
  :bind
  (("C-x g" . magit-status)))
(use-package puni
  :defer t
  :bind (("C-=" . puni-expand-region)
         ("C--" . puni-contract-region)
         )

  
  )
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

;; org
(use-package org
  :straight t
  :bind
  (("C-c c" . org-capture)
   ("C-c a" . org-agenda)
   ("C-c i" . (lambda () (interactive) (find-file "~/notes/inbox.org"))))
  :custom
  (org-directory "~/notes")
  (org-default-notes-file (expand-file-name "inbox.org" org-directory))
  (org-capture-templates
   '(("t" "Task" entry (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n %U\n %a")
     ("n" "Note" entry (file+headline org-default-notes-file "Notes")
      "* %?\n created_at: %U\n %i\n %a"))))
(put 'narrow-to-region 'disabled nil)
