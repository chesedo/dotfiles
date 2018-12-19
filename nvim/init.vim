" My Defaults
set showcmd         " Show partail command
set noshowmode      " Hide show mode - using lightline instead
set number          " Show line number on left
set rnu             " Show relative line number
set textwidth=0     " Hard-wrap long lines
set scrolloff=3     " Show next 3 lines when scrolling
set sidescrolloff=5 " Show next 5 column when side scrolling
set backupcopy=yes  " Prevent race condition with karma -> http://stackoverflow.com/a/25267106/2727983
set mouse=n         " Enable mouse in normal mode
set updatetime=100  " Update more frequently for gutter and doc plugins
set hidden

" Change split positions
set splitbelow
set splitright

" Set python provider
let g:python3_host_prog='/usr/bin/python3'

" Colors warnings for right wrapper
highlight ColorColumn ctermfg=5 ctermbg=None
highlight OverLength ctermfg=1
let &colorcolumn=join(range(100,120),",")
match OverLength /\%120v.\+/

let mapleader="\<SPACE>"

" Indent settings
set expandtab       " Use space for tabs
set shiftwidth=2    " Indents for << and >>
set softtabstop=2   " Space indent uses 2 spaces
set tabstop=2       " Tabs use 2 spaces

filetype plugin indent on "Use filebased indention scripts

" Set custom filetype for some extensions
au BufRead,BufNewFile *.tpl set filetype=gohtmltmpl

" Custom mappings
map <leader>h <c-w><c-h>
map <leader>j <c-w><c-j>
map <leader>k <c-w><c-k>
map <leader>l <c-w><c-l>
noremap <leader>q :bdelete<cr>      " Close buffer
noremap <leader>Q :%bdelete<cr>     " Close all buffers

" Extra sources for filetypes
au FileType javascript source ~/.config/nvim/filetypes/javascript.vim
au FileType python source ~/.config/nvim/filetypes/python.vim
au FileType go source ~/.config/nvim/filetypes/go.vim
au FileType cpp source ~/.config/nvim/filetypes/cpp.vim
au FileType asm source ~/.config/nvim/filetypes/asm.vim

" VIM-Plug Data
call plug#begin('~/.local/share/nvim/plugged')
" GUI extras
Plug 'itchyny/lightline.vim'
source ~/.config/nvim/plugs/lightline.vim

Plug 'yggdroot/indentline'
source ~/.config/nvim/plugs/indentLine.vim

Plug 'ap/vim-buftabline'
source ~/.config/nvim/plugs/buftabline.vim

Plug 'kshenoy/vim-signature'
Plug 'morhetz/gruvbox'

" File & folder browsers
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
source ~/.config/nvim/plugs/nerdtree.vim

Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'majutsushi/tagbar'
source ~/.config/nvim/plugs/tagbar.vim

" Git
Plug 'tpope/vim-fugitive'
source ~/.config/nvim/plugs/vim-fugitive.vim

Plug 'airblade/vim-gitgutter'

" Completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
source ~/.config/nvim/plugs/deoplete.vim

Plug 'autozimu/LanguageClient-neovim', {
\ 'branch': 'next',
\ 'do': 'bash install.sh',
\ }
source ~/.config/nvim/plugs/LanguageClient-neovim.vim

Plug 'zchee/deoplete-go', {
\ 'do': 'make',
\ 'for': 'go',
\ }

Plug 'townk/vim-autoclose'

" Linting
Plug 'scrooloose/syntastic'
Plug 'prettier/vim-prettier', {
\ 'do': 'npm install',
\ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'],
\ }
source ~/.config/nvim/plugs/prettier.vim

" Web dev
Plug 'mattn/emmet-vim', {
\ 'for': ['html', 'css', 'gohtmltmpl', 'jsx', 'javascript.jsx']
\ }
source ~/.config/nvim/plugs/emmet-vim.vim

Plug 'valloric/MatchTagAlways', {
\ 'for': ['html', 'xml', 'xhml', 'jinja', 'gohtmltmpl']
\ }
source ~/.config/nvim/plugs/MatchTagAlways.vim

" Go
Plug 'fatih/vim-go', {
\ 'for': ['go', 'gohtmltmpl']
\ }
source ~/.config/nvim/plugs/vim-go.vim

" Jsx
Plug 'mxw/vim-jsx', { 'for': ['jsx', 'javascript.jsx'] }

" Rust
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
source ~/.config/nvim/plugs/rust.vim

" Typescript
Plug 'herringtondarkholme/yats.vim', { 'for': 'typescript' }
Plug 'mhartington/nvim-typescript', {
\ 'do': './install.sh',
\ 'for': 'typescript',
\ }

" JSON
Plug 'elzr/vim-json', { 'for': 'json' }
source ~/.config/nvim/plugs/vim-json.vim

" Glsl
Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }

" Tmux
Plug 'benmills/vimux'
source ~/.config/nvim/plugs/vimux.vim

Plug 'benmills/vimux-golang', { 'for': 'go' }

" Testing
Plug 'easymotion/vim-easymotion'
Plug 'Shougo/echodoc.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'wellle/targets.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
source ~/.config/nvim/plugs/fzf.vim
call plug#end()

source ~/.config/nvim/plugs/gruvbox.vim
