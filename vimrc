set nocompatible " be iMproved, required

" 禁止生成临时文件
set nobackup
set noswapfile
set noundofile

set fileencodings=utf-8,gb18030,ucs-bom,gbk,gb2312,cp936
set encoding=utf-8
set ambiwidth=double
set termencoding=utf-8

"终端、gui不同配色方案、字体
if has("gui_running")
    colo materialtheme
endif

syntax enable "语言高亮
syntax on

set hlsearch "高亮显示搜索结果
set incsearch "搜索逐字符高亮
"set ignorecase "搜索时大小写不敏感

set noshowmode "不显示输入模式
set laststatus=2 "总是显示状态栏

"set cursorline "突出显示当前行
"highlight CursorLine guibg=#303000 ctermbg=234

"允许退格键删除和tab操作
set smartindent
set smarttab
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set backspace=2
set textwidth=79

" OCaml 文件2空格缩进
set sw=4
set ts=4
autocmd Filetype ocaml set softtabstop=2
autocmd Filetype ocaml set sw=2
autocmd Filetype ocaml set ts=2
"autocmd FileType ocaml set ts=2|set sw=2

"set columns=85 "设置行宽(开启之后，在iTerm2、terminal下打开文件会显示一片空白)

set nu "启用行号
set mouse=a "启用鼠标
"set clipboard=unnamed "复制进系统剪贴

filetype on "侦测文件类型
filetype plugin on "载入文件类型插件
filetype indent on "为特定文件类型载入相关缩进文件
filetype plugin indent on

set foldmethod=indent "代码折叠
"set foldmethod=syntax "基于缩进或语法进行代码折叠
set nofoldenable "启动 vim 时关闭折叠代码

set textwidth=0 wrapmargin=0 " this turns off physical line wrapping (ie: automatic insertion of newlines)

"设置光标位于上次关闭时位置
"如果不生效，可能是由于~/.viminfo没有访问权限，需要修改owner: "chown yourname ~/.viminfo
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

" Change cursor shape in different modes(For iTerm2 on OS X) " 兼容tmux
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" trim tailing whitespace start
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

command! TrimWhitespace call TrimWhitespace()
" trim tailing whitespace end

"<leader>j to prettify the current line
"<leader>j in visual mode to prettify highlighted
"nnoremap <leader>j !!python -mjson.tool --no-ensure-ascii<cr>
"vnoremap <leader>j :!python -mjson.tool --no-ensure-ascii<cr>

"--------------vim-plug configuration start--------------
call plug#begin('~/.vim/plugged')
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdtree', { 'on': ['NERDTree', 'NERDTreeVCS', 'NERDTreeFromBookmark', 'NERDTreeToggle', 'NERDTreeToggleVCS', 'NERDTreeFocus', 'NERDTreeMirror', 'NERDTreeClose', 'NERDTreeFind', 'NERDTreeCWD', 'NERDTreeRefreshRoot']}
Plug 'Xuyuanp/nerdtree-git-plugin'
"Plug 'jiangmiao/auto-pairs'
Plug 'luochen1990/rainbow'
Plug 'mitcc/vim-json-line-format'
Plug 'bronson/vim-trailing-whitespace'
Plug 'airblade/vim-gitgutter'
"Plug 'lfv89/vim-interestingwords'
"Plug 'mileszs/ack.vim'
"Plug 'benmills/vimux'
Plug 'majutsushi/tagbar'
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'"
Plug 'google/vim-codefmt'
Plug 'google/vim-searchindex'
Plug 'ybian/smartim' "vim insert 状态下按 Esc 键自己切回英文状态
Plug 'dense-analysis/ale' "check syntax
Plug 'ycm-core/YouCompleteMe', { 'frozen': 1, 'for': ['cpp', 'c', 'go', 'java', 'ocaml', 'python', 'sh'], 'on': ['YcmCompleter', 'YcmDiags', 'YcmForceCompileAndDiagnostics']}
Plug 'RRethy/vim-illuminate' "vim-illuminate
"Plug 'artur-shaik/vim-javacomplete2'
Plug 'sbdchd/neoformat'
Plug 'dstein64/vim-startuptime'
call plug#end()
"--------------vim-plug configuration end--------------

" YCM configuration
autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif
let g:syntastic_java_checkers = []

let g:smartim_default = 'com.apple.keylayout.ABC'

"--------------vim-airline configuration--------------
let g:airline_theme="powerlineish"
let g:airline_powerline_fonts = 1
"打开tabline功能,方便查看Buffer和切换,省去了minibufexpl插件，在1个Tab下用多个buffer"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

"设置切换Buffer快捷键"
"nnoremap <C-N> :bn<CR>
"nnoremap <C-P> :bp<CR>

" 关闭状态显示空白符号计数"
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#whitespace#symbol = '!'

" 设置字体
"set guifont=Powerline\ Consolas:h14
set guifont=Monaco\ for\ Powerline:h12

"lightline 配置开始
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
          \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
set showtabline=2
let g:lightline.tabline = { 'left': [ [ 'buffers' ] ], 'right': [ [ 'bufnum' ] ] }
let g:lightline.component_expand = { 'buffers': 'lightline#bufferline#buffers' }
let g:lightline.component_type = { 'buffers': 'tabsel' }
let g:lightline.separator = { 'left': '', 'right': '' }
let g:lightline.subseparator = {'left': '', 'right': '' }
let g:lightline#bufferline#show_number = 1
let g:lightline#bufferline#unnamed = '[No Name]'
if has("gui_running")
    set guioptions-=e
endif
"lightline 配置结束

"NERD Tree configuration
map <C-n> :NERDTreeToggle<CR>
nmap <silent> <c-n> :NERDTreeToggle<CR>
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"nerdtree-git-plugin 配置
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

" rainbow configuration
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle"
let g:rainbow_conf = {
	\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
	\	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
	\	'operators': '_,_',
	\	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
	\	'separately': {
	\		'*': {},
	\		'tex': {
	\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
	\		},
	\		'lisp': {
	\			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
	\		},
	\		'vim': {
	\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
	\		},
	\		'html': {
	\			'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
	\		},
	\		'css': 0,
	\	}
	\}

" run python in vim
"nnoremap <buffer> <F10> :exec '!python' shellescape(@%, 1)<cr>
nnoremap <silent> <F10> :!clear;python %<CR>

"vim-gitgutter configuration
set updatetime=250

"To always have the sign column
if exists('&signcolumn')  " Vim 7.4.2201
    set signcolumn=yes
else
    let g:gitgutter_sign_column_always = 1
endif

let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '-^'
let g:gitgutter_sign_modified_removed = '~-'

"tagbar
nmap <F8> :TagbarToggle<CR>

" vim-interestingwords
let g:interestingWordsGUIColors = ['#8CCBEA', '#A4E57E', '#FFDB72', '#FF7272', '#FFB3FF', '#9999FF']
let g:interestingWordsTermColors = ['154', '121', '211', '137', '214', '222']

"ag
"let g:ackprg = 'ag --nogroup --nocolor --column'
let g:ackprg = 'ag --vimgrep'

if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

"vim-illuminate configuration
hi illuminatedWord cterm=underline gui=underline

" fzf
set rtp+=/usr/local/opt/fzf

" ale
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

" Neoformat for OCaml
let g:opambin = substitute(system('opam config var bin'),'\n$','','''')
let $PATH .= ":" . g:opambin
let g:neoformat_ocaml_ocamlformat = {
            \ 'exe': g:opambin . '/ocamlformat',
            \ 'no_append': 1,
            \ 'stdin': 1,
            \ 'args': ['--disable-outside-detected-project', '--name', '"%:p"', '-']
            \ }
let g:neoformat_enabled_ocaml = ['ocamlformat']

" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 ## you can edit, but keep this line
let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
  execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
  execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
  let l:dir = s:opam_share_dir . "/merlin/vim"
  execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_available_tools = []
for tool in s:opam_packages
  " Respect package order (merlin should be after ocp-index)
  if isdirectory(s:opam_share_dir . "/" . tool)
    call add(s:opam_available_tools, tool)
    call s:opam_configuration[tool]()
  endif
endfor
" ## end of OPAM user-setup addition for vim / base ## keep this line
" ## added by OPAM user-setup for vim / ocp-indent ## f7039fd270b9b9ba8bf408baa7f55c03 ## you can edit, but keep this line
if count(s:opam_available_tools,"ocp-indent") == 0
  source "/Users/mitcc/.opam/rwo/share/ocp-indent/vim/indent/ocaml.vim"
endif
" ## end of OPAM user-setup addition for vim / ocp-indent ## keep this line

