" ~/.config/nvim/lua/init.lua
" lua require('init')
lua require('init')
set exrc
set smartindent
set relativenumber
set nu
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=2
set expandtab
set nowrap
set nobackup
set undodir="~/.vim/undodir"
set undofile
set incsearch
set termguicolors
set scrolloff=8
set noshowmode
set signcolumn=yes
set colorcolumn=120
set cmdheight=2
set updatetime=50
set autochdir

filetype plugin indent on

" Neovide
let g:neovide_cursor_animation_length=0.13

" Netrw
" 25% of screen
let g:netrw_winsize = 25
" Disable top info in netrw
let g:netrw_banner = 0
" Tree style explorer
let g:netrw_liststyle = 3

syntax enable
colorscheme gruvbox
let mapleader = " "

" Open vimrc
nnoremap <leader><CR> :e $MYVIMRC<CR>
" Source vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

" I don't remember what this does~
vnoremap <leader>p "_dP

nnoremap <leader>ep :e ~/.config/nvim/lua/plugins.lua<CR>
