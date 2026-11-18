;; .emacs --- Emacs configuration -*- lexical-binding: t; -*-
(scroll-bar-mode -1)
(electric-pair-mode 1)
(menu-bar-mode 1)
(scroll-bar-mode 1)
(global-visual-line-mode 1)
(tool-bar-mode -1)
;; key setting
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
;; (load-theme 'ef-day t)
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
(let ((mono-spaced-font "Cascadia Code")
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

;; Org の画像や長い行もピクセル単位で滑らかにスクロールする。
(use-package ultra-scroll
  :straight (:host github :repo "jdtsmith/ultra-scroll")
  :init
  (setq scroll-conservatively 3)
  :config
  (ultra-scroll-mode 1))

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))
(use-package emacs
  :custom
  (tab-always-indent 'complete)
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
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
  (setq skk-large-jisyo "~/.config/SKK-JISYO.L")
  (setq skk-server-host "localhost")
  (setq skk-server-portnum 1178))
;; 候補を縦に並べる
(use-package vertico
  :straight t
  ;; RET (vertico-exit) は「選択中の候補」で確定するため、C-x C-f で
  ;; 既存ファイルに部分一致する新規ファイル名を入力すると、その既存ファイルが
  ;; 開かれてしまう (例: newfile.txt.bak がある所で newfile.txt と入力)。
  ;; C-j に vertico-exit-input を割り当てて「入力した文字列そのまま」で
  ;; 確定できるようにする (M-RET と同じ動作。ido の C-j と同じ感覚)。
  ;; 元の C-j は minibuffer-local-map の exit-minibuffer が vertico-exit に
  ;; リマップされたもの、つまり RET と同じ動作なので失うものは無い。
  :bind (:map vertico-map
              ("C-j" . vertico-exit-input))
  :init
  (vertico-mode))
;; 絞り込みロジックを「順不同・部分一致」にする
(use-package orderless
  :straight t
  :custom
  (completion-styles '(orderless basic))
  (orderless-matching-styles '(orderless-literal orderless-regexp orderless-flex))
  (completion-category-overrides '((file (styles basic partial-completion)))))
(use-package color-theme-modern
  :ensure t
  :config
;;   (load-theme 'ef-tritanopia-light)
  )
(use-package marginalia
  :straight t
  :init
  (marginalia-mode))
(use-package consult
  :ensure t
  ;; よく使う標準コマンドを Consult の便利なコマンドに置き換える
  :bind (("C-x b" . consult-buffer)         ;; バッファ切り替え（最近使ったファイルなども含む）
         ("C-x k" . my/consult-kill-buffer) ;; プレビューしながら削除するバッファを選択
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-c l" . consult-line)             ;; 現在のバッファ内を検索（プレビュー付き）
         ("C-c t" . consult-theme)         ;; プレビューしながらテーマを選択
         ("M-y" . consult-yank-pop)         ;; クリップボード（kill-ring）の履歴から貼り付け
         ("M-g g" . consult-goto-line)      ;; 行指定ジャンプ
         ("M-g i" . consult-imenu)          ;; 関数や見出しへのジャンプ
         ("C-c f f" . consult-find) ;; find
         ("C-c r" . consult-ripgrep))       ;; ripgrepを使ったプロジェクト内検索（※rgのインストールが必要）
         
  :config
  ;; テーマは候補移動が落ち着いてからプレビューする。
  (consult-customize consult-theme :preview-key '(:debounce 0.2 any))
  (defun my/consult-kill-buffer ()
    "プレビューしながらバッファを選び、確定後に削除する。"
    (interactive)
    ;; preview のみを使い、確定時にも元の表示へ戻してから削除する。
    ;; buffer-state は確定時にバッファを切り替えるため、ここでは使わない。
    (let* ((name (consult--read
                  (consult--buffer-query :filter nil :as #'buffer-name)
                  :prompt "Kill buffer: "
                  :category 'buffer
                  :history 'buffer-name-history
                  :default (buffer-name)
                  :require-match t
                  :sort nil
                  :state (consult--buffer-preview)))
           (buffer (get-buffer name)))
      ;; 選択中に対象が消えても、現在のバッファを誤って削除しない。
      (when (buffer-live-p buffer)
        (kill-buffer buffer))))
  ;; 候補を移動するたびにプレビューする。
  (setq consult-preview-key 'any))

;; terminal emulator
(use-package vterm
  :ensure t
  :bind ("C-c C-v" . vterm))
;; どこにでもジャンプできるやつ
(use-package avy
  :straight t
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)
         ("M-g w" . avy-goto-word1)
         ("M-g l" . avy-goto-line)))
(use-package consult-ghq
  :straight t
  :bind
  ("C-c g p" . consult-ghq-switch-project)
  ("C-c g f" . consult-ghq-find)
  ("C-c g g" . consult-ghq-grep))

(use-package fzf
  :ensure t
  :bind
  (("C-c f f" . fzf-find-file)
   ("C-c f g" . fzf-grep)
   ("C-c f b" . fzf-switch-buffer)))


(with-eval-after-load 'eglot
  (defun my-eglot-disable-file-watching (orig-fn &rest args)
    (let ((caps (apply orig-fn args)))
      ;; didChangeWatchedFiles のサポートを偽装（false）する
      (setf (cl-getf (cl-getf caps :workspace) :didChangeWatchedFiles)
            '(:dynamicRegistration :json-false :relativePatternSupport :json-false))
      caps))
  (advice-add 'eglot-client-capabilities :around #'my-eglot-disable-file-watching))

;; jsonrpc は eglot より新しい版が必要 (:cancel-on-quit 引数)。
;; 同梱の古い版が使われると corfu 補完時に
;; "Keyword argument :cancel-on-quit not one of ..." エラーになるため
;; eglot より先に straight 経由で更新版をロードする。
(use-package jsonrpc
  :straight t)

(use-package citar
    :straight t
  :custom
  (org-cite-global-bibliography
   '("~/memos/roam/references.bib"))
  (citar-bibliography
   '("~/memos/roam/references.bib")))  

;; uv の標準環境 (.venv) を Pyright と Python REPL で共有する。
(defun my-python-eglot-ensure ()
  "Use the nearest .venv for Python completion, then start Eglot."
  (let* ((root (locate-dominating-file default-directory ".venv"))
         (python (and root (expand-file-name ".venv/bin/python" root))))
    (when (and python (file-executable-p python))
      (setq-local python-shell-interpreter python)
      (setq-local eglot-workspace-configuration
                  (let* ((config (copy-tree eglot-workspace-configuration))
                         (settings (plist-get config :python)))
                    (plist-put config :python
                               (plist-put settings :pythonPath python))))))
  (eglot-ensure))

;; サーバープログラムの設定 (Node 20とメモリ拡張の安全設定は維持)
(use-package eglot
  :straight t
  :custom
  (eglot-sync-connect 1)
  (eglot-autoshutdown t)
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  
  :config
  (add-to-list 'eglot-server-programs
               '((php-mode php-ts-mode) . ("mise" "exec" "node@20" "--" "env" "NODE_OPTIONS=--max-old-space-size=8192" "intelephense" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(sql-mode . ("~/go/bin/sqls")))
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode)
                 . (,(expand-file-name "~/.local/bin/pyright-langserver") "--stdio")))

  :hook
  ((python-mode . my-python-eglot-ensure)
   (python-ts-mode . my-python-eglot-ensure)
   (lua-ts-mode . eglot-ensure)
   (go-ts-mode . eglot-ensure)
   (go-mode . eglot-ensure)
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
  (corfu-popupinfo-delay '(0.2 . 0.1))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode 1))
;; Cape
(use-package cape
  :ensure t
  :after corfu
  :demand t
  :bind ("C-c p" . cape-prefix-map)
  :config
  (defun my/elisp-capf ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'cape-elisp-symbol
                       #'yasnippet-capf
                       #'cape-dabbrev
                       #'cape-file))))
  (add-hook 'emacs-lisp-mode-hook #'my/elisp-capf)

  (defun my/eglot-capf ()
    (setq-local completion-at-point-functions
                (list (cape-capf-super
                       #'eglot-completion-at-point
                       #'yasnippet-capf)
                      #'cape-file
                      #'cape-keyword
                      #'cape-dabbrev)))
  (add-hook 'eglot-managed-mode-hook #'my/eglot-capf)
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
  :demand t
  :after cape)

(use-package diff-hl
  :ensure t
  :init
  (setq diff-hl-draw-borders nil)
  
  :config
  (global-diff-hl-mode)
  (add-hook 'after-save-hook 'diff-hl-update)
  (diff-hl-flydiff-mode 1)
  (diff-hl-margin-mode 1))
;;  (add-hook 'dired-mode-hook 'diff-hl-dired-mode-hook))

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
         ))
(use-package org-download
  :ensure t
  :after org
  :hook (org-mode . org-download-enable)
  :config
  (setq org-download-method 'directory)
  (setq-default org-download-image-dir "./images"
                org-download-heading-lvl nil)

  (defun my-org-download-clipboard-wayland (original &optional basename)
    "Check Wayland clipboard capture before inserting an image.
Call ORIGINAL with BASENAME on other platforms."
    (if (not (and (eq system-type 'gnu/linux)
                  (or (equal (getenv "XDG_SESSION_TYPE") "wayland")
                      (getenv "WAYLAND_DISPLAY"))))
        (funcall original basename)
      (unless (executable-find "wl-paste")
        (user-error "Please install wl-clipboard (wl-paste)"))
      ;; A private directory avoids stale screenshots and concurrent captures.
      (let* ((capture-dir (make-temp-file "org-download-" t))
             (org-download-screenshot-file
              (expand-file-name
               (file-name-nondirectory
                (or basename org-download-screenshot-file))
               capture-dir)))
        (unwind-protect
            (progn
              (with-temp-buffer
                (set-buffer-multibyte nil)
                (let* ((coding-system-for-read 'binary)
                       (status (call-process "wl-paste" nil '(t nil) nil
                                             "--type" "image/png")))
                  (unless (and (eq status 0)
                               (>= (buffer-size) 8)
                               (equal (buffer-substring-no-properties 1 9)
                                      (unibyte-string 137 80 78 71 13 10 26 10)))
                    (user-error "Could not read a PNG image from the clipboard; copy an image first")))
                (let ((coding-system-for-write 'binary))
                  (write-region (point-min) (point-max)
                                org-download-screenshot-file nil 'silent)))
              (org-id-get-create)
              (org-download-image org-download-screenshot-file))
          (delete-directory capture-dir t)))))

  (advice-add 'org-download-clipboard :around
              #'my-org-download-clipboard-wayland))


(use-package majutsu
  :straight (:host github :repo "0WD0/majutsu"))

(put 'upcase-region 'disabled nil)

;; org
(custom-set-faces
 '(org-document-title ((t (:height 1.8 :weight bold))))
 '(org-level-1 ((t (:height 1.5 :weight bold))))
 '(org-level-2 ((t (:height 1.3 :weight bold))))
 '(org-level-3 ((t (:height 1.2 :weight bold))))
 '(org-level-4 ((t (:height 1.1 :weight bold)))))
(use-package org
  :straight t
  :bind
  (("C-c c" . org-capture)
   ("C-c a" . org-agenda)
   ("C-c i" . (lambda () (interactive) (find-file "~/memos/inbox.org"))))
  :config
  (setq org-use-sub-superscripts '{})
  (setq org-babel-python-command "python3")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (ruby . t)))

  :custom
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)

  (org-todo-keywords
        '((sequence "TODO(t)" "DOING(i)" "|" "DONE(d)")))  
  (org-directory "~/memos")
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  ;; inbox.org だけでなく ~/memos 配下の .org を全てアジェンダ対象にする
  (org-agenda-files '("~/memos" "~/memos/inbox.org" "~/memos/rpst.org" "~/memos/research.org"))
  (org-default-notes-file (expand-file-name "inbox.org" org-directory))

  ;; --- weekly summary の前提 ---
  ;; DONE にした時刻を CLOSED: として記録する。
  ;; これが無いとアジェンダの log-mode (l) が「今週やったこと」を表示できない。
  (org-log-done 'time)
  (org-log-into-drawer t)           ;; ログは :LOGBOOK: ドロワーに畳む
  (org-agenda-span 'week)
  (org-agenda-start-on-weekday 1)   ;; 週の始まりを月曜にする

  ;; --- 週次レビュー: C-c a w ---
  ;; 直近1週間に完了した項目 + 作業時間集計 + 残 TODO を1画面で出す
  (org-agenda-custom-commands
   '(("w" "Weekly review"
      ((agenda "" ((org-agenda-span 'week)
                   (org-agenda-start-day "-7d")
                   (org-agenda-start-with-log-mode '(closed clock state))
                   (org-agenda-start-with-clockreport-mode t)
                   (org-agenda-archives-mode t)))
       (todo "TODO" ((org-agenda-overriding-header "未完了のタスク")))))))

  ;; Task は SCHEDULED (アクティブタイムスタンプ) を持たせてアジェンダに載せる。
  ;; %U は非アクティブなのでアジェンダには出ない → 作成日時は CREATED プロパティへ。
  (org-capture-templates
   '(("t" "Task" entry (file+headline org-default-notes-file "Tasks")
      "* TODO %?\n SCHEDULED: %t\n :PROPERTIES:\n :CREATED: %U\n :END:\n")
     ("n" "Note" entry (file+headline org-default-notes-file "Notes")
      "* %?\n created_at: %U\n %i")
     ("m" "Mail" entry (file+headline org-default-notes-file "Mails")
      "* %:subject\n:PROPERTIES:\n:CREATED: %U\n:END:\nFrom: %:from\nDate: %:date\n%a\n\n%i\n%?"))))
(put 'narrow-to-region 'disabled nil)

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/memos/roam/"))
  (org-roam-dailies-directory "daily/")
  (org-roam-node-display-template
   (concat "${title:*} "
           (propertize "${tags:10}" 'face 'org-tag)))
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n c" . org-roam-capture)
   ("C-c n l" . org-roam-buffer-toggle)
   ("C-c n g" . org-roam-graph)
   ("C-c n t" . org-roam-dailies-goto-today)
   ("C-c n d" . org-roam-dailies-capture-today)
   ("C-c n D" . org-roam-dailies-goto-date))
  :config
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target
           (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                      ":PROPERTIES:\n:CREATED: %U\n:TYPE: %^{Type|idea|literature|project}\n:STATUS: draft\n:END:\n#+title: ${title}\n\n")
           :unnarrowed t)))
  (with-eval-after-load 'org-roam-dailies
    ;; Daily Note 内の TODO も Org Agenda に表示する。
    (add-to-list 'org-agenda-files
                 (expand-file-name org-roam-dailies-directory
                                   org-roam-directory))
    (setq org-roam-dailies-capture-templates
          '(("d" "daily" entry
             "* %<%H:%M> %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: idea\n:STATUS: draft\n:END:\n"
             :target
             (file+head "%<%Y-%m-%d>.org"
                        "#+title: %<%Y-%m-%d>\n\n"))
            ("t" "task" entry
             "* TODO %?\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:TYPE: task\n:END:\n"
             :target
             (file+head "%<%Y-%m-%d>.org"
                        "#+title: %<%Y-%m-%d>\n\n")))))
  (org-roam-db-autosync-mode))

(use-package flyspell
  :hook
  (php-ts-mode . flyspell-mode)
  (ruby-ts-mode . flyspell-mode))
(use-package tex
  :straight auctex
  :ensure nil
  :defer t
  :hook
  (LaTeX-mode . turn-on-reftex)
  :config
  (add-to-list 'TeX-command-list
               '("LuaLaTeX" "lualatex -synctex=1 %s" TeX-run-TeX nil t
                 :help "Run LuaLaTeX"))
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-PDF-mode t)
  (setq-default TeX-engine 'luatex)
  ;; pdf viewer settings
  (setq TeX-view-program-selection
        '((output-pdf "PDF Tools")))
  (setq TeX-view-program-list
        '(("PDF Tools" TeX-pdf-tools-sync-view)))
  (setq-default TeX-command-default "LaTeX"))
(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))
(add-to-list 'load-path "/opt/homebrew/share/emacs/site-lisp/mu/mu4e")
(use-package mu4e
  :ensure nil
  :straight nil
  :commands mu4e
  :bind (:map mu4e-headers-mode-map
              ("C-c c" . mu4e-org-store-and-capture)
         :map mu4e-view-mode-map
              ("C-c c" . mu4e-org-store-and-capture))
  :config
  (require 'mu4e-org)
  (require 'smtpmail)
  (require 'auth-source)
  ;; GUI Emacs の PATH に Homebrew がなくても実行できるようにする。
  (setq mu4e-mu-binary (or (executable-find "mu") "/opt/homebrew/bin/mu")
        mu4e-get-mail-command
        (concat (shell-quote-argument
                 (or (executable-find "mbsync") "/opt/homebrew/bin/mbsync"))
                " gmail")
        mu4e-update-interval 300
        ;; mbsync の UID と移動先のファイル名が衝突するのを防ぐ。
        mu4e-change-filenames-when-moving t
        mu4e-drafts-folder "/gmail/[Gmail]/Drafts"
        mu4e-sent-folder "/gmail/[Gmail]/Sent Mail"
        mu4e-trash-folder "/gmail/[Gmail]/Trash"
        mu4e-refile-folder "/gmail/[Gmail]/All Mail"
        ;; Gmail が送信済みメールを保存するので、二重保存しない。
        mu4e-sent-messages-behavior 'delete
        mu4e-headers-skip-duplicates t
        mu4e-maildir-shortcuts
        '((:maildir "/gmail/INBOX" :key ?i)
          (:maildir "/gmail/[Gmail]/Sent Mail" :key ?s)
          (:maildir "/gmail/[Gmail]/Drafts" :key ?d)
          (:maildir "/gmail/[Gmail]/All Mail" :key ?a)
          (:maildir "/gmail/[Gmail]/Trash" :key ?t))
        message-send-mail-function #'smtpmail-send-it
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        smtpmail-stream-type 'starttls)
  ;; SMTP と mbsync は同じインターネットパスワードを参照する。
  (when (eq system-type 'darwin)
    (add-to-list 'auth-sources 'macos-keychain-internet))
  ;; アドレスや Gmail の言語によるフォルダー名の差はローカル設定で上書き。
  (load (expand-file-name "private-mail.el" user-emacs-directory) t))
(use-package ef-themes
  :straight t
  :config
  (load-theme 'ef-duo-dark)
  )

(use-package org-modern
  :straight t
  :hook
  (org-mode . org-modern-mode)
  :custom
  (org-modern-star 'replace)
  (org-modern-hide-stars 'leading)  
  (org-modern-todo t)
  (org-modern-timestamp t)
  (org-modern-priority t)
  (org-modern-tag t)  
  (org-modern-block-fringe 4)
  (org-modern-replace-stars "◉○◆◇✦")
  (org-modern-list '((?+ . "➤")
                     (?- . "–")
                     (?* . "•")))
  (org-modern-checkbox '((?X . "☑")
                         (?- . "◩")
                         (?\s . "☐")))  
  )

(defun my/org-region-to-markdown (beg end)
  "Convert selected Org region to Markdown and copy it"
  (interactive "r")
  (let* ((org-text (buffer-substring-no-properties beg end))
         (markdown (org-export-string-as org-text 'md t)))
    (kill-new markdown)
    (message "Converted Org region to Markdown and copied to clipboard.")))

(defun my-org-daily-report-entry (title)
  "現在のOrg見出しから、TITLEと親見出しの情報を取得する。"
  (save-excursion
    (org-back-to-heading t)
    (let ((id (cons (current-buffer) (point)))
          (ancestors '()))
      (while (org-up-heading-safe)
        (push (cons (current-buffer) (point)) ancestors))
      (list :id id :ancestors ancestors :title title))))

(defun my/wsl-copy-to-clipboard (text &rest _)
  "TEXTをwindowsのクリップボードに送信する"
  (let ((coding-system-for-write 'utf-16le-dos))
    (with-temp-buffer
      (insert text)
      (call-process-region
       (point-min) (point-max)
       "/mnt/c/Windows/System32/clip.exe"
       nil nil nil))))
(cond
 ((eq system-type 'darwin)
  (setq select-enable-clipboard t))
 ((and (eq system-type 'gnu/linux)
       (or (getenv "WSL_DISTRO_NAME")
           (getenv "WSL_INTEROP")))
  (setq interprogram-cut-function #'my/wsl-copy-to-clipboard)))
