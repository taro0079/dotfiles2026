-- 同梱の indent/php.vim は noautoindent を設定するが、GetPhpIndent() は
-- 状況によって -1（現在のインデントを維持）を返す。autoindent が無いと
-- そのとき新規行（o など）のインデントが 0 桁になってしまうため、
-- autoindent を戻して前行のインデントを引き継がせる。
vim.bo.autoindent = true
