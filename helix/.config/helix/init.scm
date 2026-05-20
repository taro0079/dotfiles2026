(require "helix/keymaps.scm")
(require "flash.scm")
(require "oil/oil.scm")

(keymap (global)
        (normal
          (space
              (o
                (o ":oil")
                (e ":oil-enter")
                (b ":oil-back")
                (g ":oil-root")
                (s ":oil-save")
                (r ":oil-refresh")
                (q ":oil-close")
                (h ":oil-toggle-hidden")
                (i ":oil-toggle-git-ignored")
                (m
                  (y ":oil-yank")
                  (x ":oil-cut")
                  (p ":oil-paste")
                  (c ":oil-clipboard-clear"))))
          (g
            (/ ":flash-forward")
            (? ":flash-backward")))
        
        (select
          (g
            (/ ":flash-forward")
            (? ":flash-backward"))))
