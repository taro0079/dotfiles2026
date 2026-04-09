" basic settings ---------------------------- {{{1
set title
set clipboard=unnamed,unnamedplus
set showcmd
set ruler
set undofile
set relativenumber
set linebreak
set display+=lastline
set number
set showmatch
set incsearch
set nocompatible
" set signcolumn=yes
set smartcase
" set signcolumn=yes
set hlsearch
set autoread
set incsearch
set nobackup
set nowb
set noswapfile
set noundofile
set wildmenu
set backspace=indent,eol,start
set expandtab
" set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
" set list
set tabstop=4
set shiftwidth=4
set showtabline=2
set showcmd
set ai "Auto Indent"
set si "Smart Indent"
set wrap "Wrap lines"
set hidden
set cursorline
set ignorecase
set t_Co=256
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
"set foldmethod=indent
set laststatus=3
set path+=**
" Use English interface.
language message C
" set statusline=%F%m%h%w\ %<[ENC=%{&fenc!=''?&fenc:&enc}]\ [FMT=%{&ff}]\[TYPE=%Y]\ %=[POS=%l/%L(%02v)]
if executable('rg')
    let &grepprg = 'rg --vimgrep --hidden'
    set grepformat=%f:%l:%c:%m
endif
" Plugins ---------------------------- {{{1
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    \ >/dev/null 2>&1
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin()
Plug 'taro0079/path_to_clipboard'
Plug 'vim-denops/denops.vim'
Plug 'ojroques/vim-oscyank'
Plug 'wolverian/minimal',
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion' "Optional
Plug 'junegunn/vim-easy-align'
Plug 'yami-beta/asyncomplete-omni.vim'
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
Plug 'tpope/vim-repeat'
Plug 'diepm/vim-rest-console'
Plug 'tpope/vim-endwise'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'  " ← これを追加
Plug 'mattn/vim-starwars'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
" Plug 'jiangmiao/auto-pairs'
Plug 'mattn/emmet-vim'
Plug 'vim-skk/eskk.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-signify'
Plug 'lambdalisue/suda.vim'
Plug 'kana/vim-textobj-user'
Plug 'osyo-manga/vim-textobj-blockwise'
Plug 'dracula/vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'phpactor/phpactor', {'for': 'php', 'tag': '*', 'do': 'composer install --no-dev -o'}
Plug 'vim-test/vim-test'
Plug 'dense-analysis/ale'
Plug 'lifepillar/vim-solarized8'
Plug 'thinca/vim-quickrun'
Plug 'easymotion/vim-easymotion'
Plug 'morhetz/gruvbox'
" Plug 'hrsh7th/vim-vsnip'
" Plug 'hrsh7th/vim-vsnip-integ'
if has('python3')
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
endif
Plug 'ghifarit53/tokyonight-vim'
Plug 'aerosol/dumbotron.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-sneak'
call plug#end()

" ESKK setting ------------------------------- {{{1
let g:eskk#directory        = "~/.config/eskk"
let g:eskk#dictionary       = { 'path': "~/.config/eskk/my_jisyo", 'sorted': 1, 'encoding': 'utf-8',}
let g:eskk#large_dictionary = {'path': "~/.config/eskk/SKK-JISYO.L", 'sorted': 1, 'encoding': 'euc-jp',}
imap <C-j> <Plug>(eskk:toggle)

" Color settings ------------------------------- {{{1
syntax enable
filetype plugin on
set background=dark
set termguicolors
colorscheme industry


" list settings ---------------------- {{{1
nnoremap <leader>lt :set list!<CR>

" ultisnips config --- {{1
if has('python3')
  let g:UltiSnipsSnippetDirectories = ['UltiSnips', "plugged/vim-snippets/UltiSnips"]
  let g:UltiSnipsExpandTrigger="<c-e>"
  let g:UltiSnipsJumpForwardTrigger="<c-b>"
  let g:UltiSnipsJumpBackwardTrigger="<c-z>"
  call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
        \ 'name': 'ultisnips',
        \ 'allowlist': ['*'],
        \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
        \ }))
  let g:ultisnips_php_scalar_types = 1
endif

" phpファイルの保存時にphp-cs-fixerを適用する
function! s:php_fixer() abort
    let current_file = expand('%')
    let output =  system(printf('php-cs-fixer fix %s', current_file))
    silent! edit
    echo(output)
endfunction
" augroup php_cs_fixer
"     autocmd!
"     autocmd BufWritePre *.php silent! call s:php_fixer()
" augroup END

" lsp settings --- {{{1
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)
" vim lsp settings --- {{{1

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    setlocal completeopt=menu,menuone,noinsert,noselect
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>ca <plug>(lsp-code-action)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
" set list
" set listchars=tab:»-,trail:-,eol:¿,extends:»,precedes:«,nbsp:%
" vim color scheme settings --- {{{1

" OSC52 setting --- {{{1
"nmap <leader>c <Plug>OSCYankOperator
"nmap <leader>cc <leader>c_
"vmap <leader>c <Plug>OSCYankVisual

" keymaps
" vimrc setting --- {{{1
nnoremap <silent> <leader><CR> :source ~/.vimrc<CR>
nnoremap <silent> <leader>v :e ~/.vimrc<CR>

"vim EasyAlign setting ---- {{{1
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" phpactor setting
" autocmd FileType php setlocal omnifunc=phpactor#Complete
" useの補完
nmap <silent><Leader>u      :<C-u>call phpactor#UseAdd()<CR>
" コンテキストメニューの起動(カーソル下のクラスやメンバに対して実行可能な選択肢を表示してくれます)
nmap <silent><Leader>mm     :<C-u>call phpactor#ContextMenu()<CR>
" ナビゲーションメニューの起動(クラスの参照元を列挙したり、他ファイルへのジャンプなど)
nmap <silent><Leader>nn     :<C-u>call phpactor#Navigate()<CR>
" カーソル下のクラスやメンバの定義元にジャンプ
nmap <silent><Leader>o      :<C-u>call phpactor#GotoDefinition()<CR>
" 編集中のクラスに対し各種の変更を加える(コンストラクタ補完、インタフェース実装など)
nmap <silent><Leader>tt     :<C-u>call phpactor#Transform()<CR>
" 新しいクラスを生成する(編集中のファイルに)
nmap <silent><Leader>cc     :<C-u>call phpactor#ClassNew()<CR>
" 選択した範囲を変数に抽出する
nmap <silent><Leader>ee     :<C-u>call phpactor#ExtractExpression(v:false)<CR>
" 選択した範囲を変数に抽出する
vmap <silent><Leader>ee     :<C-u>call phpactor#ExtractExpression(v:true)<CR>
" 選択した範囲を新たなメソッドとして抽出する
vmap <silent><Leader>em     :<C-u>call phpactor#ExtractMethod()<CR>
" split → jump
nmap <silent><C-w><Leader>o :<C-u>call DefinitionJumpWithPhpactor()<CR>
" カーソル下のクラスや変数の情報を表示する
" 他のエディタで、マウスカーソルをおいたときに表示されるポップアップなどに相当
vmap <silent><Leader>hh     :<C-u>call phpactor#Hover()<CR>

" vim-vsnip -- {{1
" Expand
" imap <expr> <C-d>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-d>'
" smap <expr> <C-d>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-d>'

" Expand or jump
" imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" " Jump forward or backward
" imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
" smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
" nmap        s   <Plug>(vsnip-select-text)
" xmap        s   <Plug>(vsnip-select-text)
" nmap        X   <Plug>(vsnip-cut-text)
" xmap        X   <Plug>(vsnip-cut-text)



" quickrun config --- {{1
nmap <leader>q :QuickRun<cr>

" asynccomplete settings --- {{1
" ddcを利用するため一旦以下は無効化
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" newtrw settings ---- {{{1
let g:netrw_banner       = 0
let g:netrw_browse_split = 0
let g:netrw_altv         = 1
let g:netrw_liststyle    = 3

" tmux seeting
"let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" lsp settings ---------------------------- {{{1

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
 command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

" my functions
"
"rspt チケット番号抽出コマンド ---- {{{1
"
" function! RpstTicketNum()
"     execute ":%v/^#\\d.\\+/s/.*//g"
"     execute ":%s/^#\\(\\d\\+\\)\\|.+$/\\1/g"
"     execute ":%s/^\\n//g"
" endfunction
" command! RpstTicketNum call RpstTicketNum()
"
" 選択範囲のテキストを取得するコマンド
" 範囲の終端は必ず行末になるように設定してある
function! GetRegionText()
    let start = getpos("v")
    let end = getpos("'>")
    return getregion(start, end)
endfunction

" rpst-symfonyのクラス郡を生成するコマンド

" コミットログからチケット番号を自動抽出してくれるコマンド v1
function! ExtractTicketNumbers()
    " バッファ全体の行についてリストとして格納
    let lines = getline(1, '$')
    let ticket_numbers = []

    let pattern = '^#\(\d\+\)'

    for line in lines
        let matches = matchlist(line, pattern)

        if !empty(matches)
            call add(ticket_numbers, matches[1])
        endif
    endfor

    echo ticket_numbers
    return ticket_numbers
endfunction

command! TicketExtract call ExtractTicketNumbers()


function ExternalCommandOutputToBuffer(command)
    let output = system(a:command)
    let lines =  split(output, '\n')
    " 最初にバッファの全ての行を削除しておく
    execute '%delete _'
    let current_line = 0
    for line in lines
        call append(current_line, line)
        let current_line += 1
    endfor
endfunction

function ExternalCommandOutputToNewBuffer(command)
    enew
    let output = system(a:command)
    let lines =  split(output, '\n')
    " 最初にバッファの全ての行を削除しておく
    execute '%delete _'
    let current_line = 0
    for line in lines
        call append(current_line, line)
        let current_line += 1
    endfor
endfunction
command! IloveRelease call IloveReleaseCommand()

function! PhpUnitRunner()
    let file = expand('%')
    let command = printf('docker compose -f ../docker-compose.yml run --rm devcontainer symfony php bin/phpunit %s', file)
    call ExternalCommandOutputToNewBuffer(command)
endfunction

command! PhpUnitRunner call PhpUnitRunner()
" denops setting --- {{{1
"set runtimepath^=~/dev/denops-tutorial
" let g:denops#debug = 1

" myfd --- {{{1
"nmap <leader>fd :MyFd<cr>

" CtrlP settings --- {{{1
"let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}

" snipmate setting --- {{{1
"let g:snipMate = { 'snippet_version' : 1 }
"imap <C-k> <Plug>snipMateNextOrTrigger


"function! ProfileCursorMove() abort
"  let profile_file = expand('~/log/vim-profile.log')
"  if filereadable(profile_file)
"    call delete(profile_file)
"  endif
"
"  normal! gg
"  normal! zR
"
"  execute 'profile start ' . profile_file
"  profile func *
"  profile file *
"
"  augroup ProfileCursorMove
"    autocmd!
"    autocmd CursorHold <buffer> profile pause | q
"  augroup END
"
"  for i in range(2000)
"    call feedkeys('j')
"  endfor
"endfunction

"let g:loaded_matchparen = 1
"if executable('rg')
"  let g:ctrlp_use_caching = 0
"  "let g:ctrlp_user_command = 'cd %s && rg "" -i -r --no-color -l ./**/*'
"  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
"endif
" 正規表現のマッチングエンジンを変更
" set regexpengine=1

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0
let g:ale_fixers = {'php': ['php_cs_fixer']}
let g:ale_linters = {
      \ 'php': ['phpstan'],
\}
let g:ale_php_phpstan_executable = 'phpstan'
let g:ale_php_phpstan_level=9
" let g:ale_php_phpstan_configuration = ".phpstan.neon"
let g:ale_lint_use_temporary_files = 0

let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0

"" php actor
" 画面を分割して定義元へのジャンプ
function! DefinitionJumpWithPhpactor()
    split
    call phpactor#GotoDefinition()
endfunction

let g:lsp_settings = {
\  'typeprof': {'disabled': 1},
\}
" vim-test --- {{1
let test#php#phpunit#executable = 'docker compose -f ../docker-compose.yml run
            \ --rm php-dev symfony php bin/phpunit' " テストランナーをphpunitに変更


" augroup RpstV2Setting
"     autocmd!
"     autocmd BufEnter /var/www/rpst-v2/dev/* set local path+=app/*,cert/*,ci/*,data/*,html/*,tests/*,frontend/*,ftproot/*
" augroup END

" augroup RpstV2SettingOfApi
"     autocmd!
"     autocmd BufEnter /var/lib/rpst-api-docker/rpst-v2/* set local path+=app/*,cert/*,ci/*,data/*,html/*,tests/*,frontend/*,ftproot/*
" リモートサーバーへのファイル転送ユーティリティ

" 汎用的なリモート転送関数
function! s:ToRemote(local_path, remote_path, use_mkpath) abort
    let file_path = expand('%:p')
    let local_expanded = expand(a:local_path)
    
    " ファイルがプロジェクトディレクトリ内にあるか確認
    if file_path =~# '^' . escape(local_expanded, '/')
        echo 'File is inside the project directory'
        
        " 相対パスを取得
        let relative_path = substitute(file_path, '^' . escape(local_expanded, '/'), '', '')
        
        if a:use_mkpath
            " rsync コマンドを構築
            let cmd = printf("rsync -aqz --no-motd --mkpath -e 'ssh -q' %s %s%s",
                      \ shellescape(file_path),
                      \ a:remote_path,
                      \ relative_path)
        else
            let cmd = printf("rsync -aqz --no-motd -e 'ssh -q' %s %s%s",
                      \ shellescape(file_path),
                      \ a:remote_path,
                      \ relative_path)
        endif

        
        " 非同期でコマンドを実行
        let job = job_start([&shell, &shellcmdflag, cmd], {
                    \ 'out_cb': function('s:OnStdout'),
                    \ 'err_cb': function('s:OnStderr'),
                    \ 'exit_cb': function('s:OnExit')
                    \ })
    else
        echo 'File is not inside the project directory'
    endif
endfunction

" 標準出力のコールバック
function! s:OnStdout(channel, msg) abort
    let msg = trim(a:msg)
    if msg !=# ''
        echom 'Message: ' . msg
    endif
endfunction

" 標準エラー出力のコールバック
function! s:OnStderr(channel, msg) abort
    let err = trim(a:msg)
    if err !=# ''
        echohl ErrorMsg
        echom 'Rsync Error: ' . err
        echohl None
    endif
endfunction

" 終了時のコールバック
function! s:OnExit(job, code) abort
    if a:code == 0
        echohl MoreMsg
        echom 'File transferred successfully'
        echohl None
    else
        echohl ErrorMsg
        echom 'Error: ' . a:code
        echohl None
    endif
endfunction

" rpst-v2 プロジェクト用の転送
function! RpstV2Transport() abort
    let local_project_path = '~/ghq/rpst-v2/'
    let remote_project_path = 'taro_morita@rpst-api:/var/lib/nfs-devel7-volume/dev-tmorita-rpst/var_www/rpst-v2/dev/'
    call s:ToRemote(local_project_path, remote_project_path, 0)
endfunction
"
" rpst プロジェクト用の転送
function! RpstTransport() abort
    let local_project_path = '~/ghq/rpst/'
    let remote_project_path = 'taro_morita@dev-tmorita:/var/www/precs/dev_tmorita/'
    call s:ToRemote(local_project_path, remote_project_path, 0)
endfunction

" rpst-api プロジェクト用の転送
function! RpstApiTransport() abort
    let local_project_path = '~/ghq/rpst-api/'
    let remote_project_path = 'taro_morita@rpst-api:/var/lib/rpst-api-docker/'
    call s:ToRemote(local_project_path, remote_project_path, 0)
endfunction

" コマンドを登録
command! TransportV2 call RpstV2Transport()
command! TransportRpstApi call RpstApiTransport()
command! TransportRpst call RpstTransport()
" リモートでPHPUnitを実行するユーティリティ

augroup RpstV2AutoTransport
    autocmd!
    " ~/ghq/rpst-v2/ 配下のファイルが保存されたら実行する
    autocmd BufWritePost ~/ghq/rpst-v2/* call RpstV2Transport()
augroup END

augroup RpstAutoTransport
    autocmd!
    " ~/ghq/rpst/ 配下のファイルが保存されたら実行する
    autocmd BufWritePost ~/ghq/rpst/* call RpstTransport()
augroup END

" デフォルト設定
let s:default_config = {
    \ 'remote_host': 'dev-tmorita',
    \ 'user': 'taro_morita',
    \ 'base_path': '/var/www/rpst-v2/dev',
    \ 'phpunit_config': '/var/www/rpst-v2/dev/tests/app/phpunit/v9/phpunit.xml.dist',
    \ 'local_base_path': '~/ghq/rpst-v2/'
    \ }

" 設定を取得
function! s:get_config() abort
    return exists('g:rpst_phpunit_config')
                \ ? g:rpst_phpunit_config
                \ : s:default_config
endfunction

" ローカルパスからリモートパスへの相対パスを取得
function! s:get_relative_path(local_base) abort
    let file_path = expand('%:p')
    let local_base_expanded = expand(a:local_base)

    " パスがプロジェクト内にあるか確認
    if file_path !~# '^' . escape(local_base_expanded, '/')
        echohl ErrorMsg
        echo 'File is not in the project directory: ' . a:local_base
        echohl None
        return ''
    endif

    " 相対パスを取得
    let relative_path = substitute(file_path, '^' . escape(local_base_expanded, '/'), '', '')
    " 先頭のスラッシュを削除
    let relative_path = substitute(relative_path, '^/', '', '')

    return relative_path
endfunction

" リモートでPHPUnitを実行
function! RpstPhpunitRun(...) abort
    let cfg = s:get_config()

    " ローカルのプロジェクトベースパスから相対パスを取得
    let relative_path = s:get_relative_path(cfg.local_base_path)
    if empty(relative_path)
        return
    endif

    " リモートの完全パスを構築
    let test_target_path = printf('%s/%s', cfg.base_path, relative_path)

    " PHPUnitコマンドを構築
    let phpunit_cmd = printf('php %s/vendor/bin/phpunit -c %s %s',
                \ cfg.base_path,
                \ cfg.phpunit_config,
                \ test_target_path)

    " SSHコマンド全体を構築
    let full_cmd = printf("ssh %s@%s '%s'",
                \ cfg.user,
                \ cfg.remote_host,
                \ phpunit_cmd)

    " デバッグ情報を表示
    echo '=== Debug Information ==='
    echo 'Local file: ' . expand('%:p')
    echo 'Relative path: ' . relative_path
    echo 'Remote target: ' . test_target_path
    echo 'PHPUnit command: ' . phpunit_cmd
    echo 'Full SSH command: ' . full_cmd
    echo '========================='

    " messagesに保存
    echom '=== RpstPhpunit Command ==='
    echom full_cmd

    " 縦分割してターミナルで実行
    execute 'terminal ++shell ' . full_cmd
endfunction

" コマンドを表示するだけ（実行しない）
function! RpstPhpunitShowCommand() abort
    let cfg = s:get_config()

    let relative_path = s:get_relative_path(cfg.local_base_path)
    if empty(relative_path)
        return
    endif

    let test_target_path = printf('%s/%s', cfg.base_path, relative_path)
    let phpunit_cmd = printf('php %s/vendor/bin/phpunit -c %s %s',
                \ cfg.base_path,
                \ cfg.phpunit_config,
                \ test_target_path)
    let full_cmd = printf("ssh %s@%s '%s'",
                \ cfg.user,
                \ cfg.remote_host,
                \ phpunit_cmd)

    " コマンドをクリップボードにコピー
    let @+ = full_cmd
    let @" = full_cmd

    echo '=== Generated Command ==='
    echo full_cmd
    echo ''
    echo 'Command copied to clipboard and default register'
    echo 'You can paste it with: p (in normal mode) or Ctrl+V (in terminal)'
endfunction

" リモートでファイルが存在するか確認
function! RpstPhpunitCheck() abort
    let cfg = s:get_config()

    let relative_path = s:get_relative_path(cfg.local_base_path)
    if empty(relative_path)
        return
    endif

    let test_target_path = printf('%s/%s', cfg.base_path, relative_path)

    " ファイル存在確認コマンド
    let check_cmd = printf("ssh %s@%s 'test -f %s && echo EXISTS || echo NOT_FOUND'",
                \ cfg.user,
                \ cfg.remote_host,
                \ shellescape(test_target_path))

    echo 'Checking: ' . test_target_path
    let result = system(check_cmd)
    echo 'Result: ' . result

    if result =~# 'EXISTS'
        echohl MoreMsg
        echo 'File exists on remote server!'
        echohl None
    else
        echohl ErrorMsg
        echo 'File NOT FOUND on remote server!'
        echohl None

        " ファイル名で検索
        echo 'Searching for file...'
        let filename = expand('%:t')
        let find_cmd = printf("ssh %s@%s 'find %s -name %s'",
                    \ cfg.user,
                    \ cfg.remote_host,
                    \ cfg.base_path,
                    \ shellescape(filename))
        let found = system(find_cmd)
        if !empty(found)
            echo 'Found at:'
            echo found
        endif
    endif
endfunction

" コマンドを登録
command! RpstPhpunit call RpstPhpunitRun()
command! RpstPhpunitShow call RpstPhpunitShowCommand()
command! RpstPhpunitCheck call RpstPhpunitCheck()

" ログを表示
command! RpstPhpunitLog messages

" fzf config --- {{1
let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['right,50%', 'ctrl-/']
nnoremap <silent> <space>pg :GFiles<CR>
nnoremap <silent> <space>pf :Files<CR>
nnoremap <silent> <space>pb :Buffers<CR>
nnoremap <silent> <space>pq :Rg<CR>

" easymotion config --- {{{1
map <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" pair config --- {{{1
inoremap (; (<CR>)<C-c>O<tab><Esc>zzi
inoremap {, { <CR> },<C-c>O<tab><Esc>zzi
inoremap {; { <CR> }<C-c>O<tab><Esc>zzi
inoremap [; [ <CR> ]<C-c>O<tab><Esc>zzi
inoremap [, [ <CR> ],<C-c>O<tab><Esc>zzi

" move config --- {{{1
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" dadbod config --- {{{1
nmap <space>db :DBUI<CR>
let g:db_ui_save_location = '~/.vim/dadbod-ui'
autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
\ 'name': 'omni',
\ 'allowlist': ['*'],
\ 'blocklist': ['c', 'cpp', 'html'],
\ 'completor': function('asyncomplete#sources#omni#completor'),
\ 'config': {
\ },
\ }))

" autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
