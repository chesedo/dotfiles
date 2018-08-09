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

" Relative line numbering
function! NumberToggle()
  if (&relativenumber == 1)
    set nornu
  else
    set rnu
  endif
endfunc

nnoremap <leader>r :call NumberToggle()<cr>

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
map <leader>p :bprevious<cr>        " Switch to previous buffer
map <leader>n :bnext<cr>            " Switch to next buffer

" Custom terminal mappings
tnoremap <Esc> <C-\><C-n>

" Extra sources for filetypes
au FileType javascript source ~/.config/nvim/filetypes/javascript.vim
au FileType python source ~/.config/nvim/filetypes/python.vim
au FileType go source ~/.config/nvim/filetypes/go.vim
au FileType cpp source ~/.config/nvim/filetypes/cpp.vim
au FileType asm source ~/.config/nvim/filetypes/asm.vim

" VIM-Plug Data
call plug#begin('~/.local/share/nvim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'mattn/emmet-vim'
Plug 'valloric/MatchTagAlways'
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'benmills/vimux'
Plug 'benmills/vimux-golang'
Plug 'mxw/vim-jsx'
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/syntastic'
Plug 'rust-lang/rust.vim'
Plug 'morhetz/gruvbox'
Plug 'yggdroot/indentline'
Plug 'elzr/vim-json'
Plug 'majutsushi/tagbar'
Plug 'ap/vim-buftabline'
call plug#end()

source ~/.config/nvim/plugs/lightline.vim
source ~/.config/nvim/plugs/nerdtree.vim
source ~/.config/nvim/plugs/vim-fugitive.vim
source ~/.config/nvim/plugs/deoplete.vim
source ~/.config/nvim/plugs/emmet-vim.vim
source ~/.config/nvim/plugs/MatchTagAlways.vim
source ~/.config/nvim/plugs/vim-go.vim
source ~/.config/nvim/plugs/vimux.vim
source ~/.config/nvim/plugs/gruvbox.vim
source ~/.config/nvim/plugs/indentLine.vim
source ~/.config/nvim/plugs/vim-json.vim
source ~/.config/nvim/plugs/tagbar.vim
