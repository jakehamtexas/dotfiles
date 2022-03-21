" Remaps
let mapleader = " "

" ~/.config/nvim/lua/init.lua
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
set nowritebackup
set cmdheight=2
set undodir="~/.vim/undodir"
set undofile
set incsearch
set termguicolors
set scrolloff=8
set noshowmode
set colorcolumn=120
set autochdir

filetype plugin indent on

" CoC
source $NVIM_DIR/coc.nvim.vim

" Markdown
source $NVIM_DIR/markdown-preview.vim

" Neovide
let g:neovide_cursor_animation_length=0.13

" Netrw
" Disable top info in netrw
let g:netrw_banner = 0
" Tree style explorer
let g:netrw_liststyle = 3

" Color scheme
syntax enable
colorscheme gruvbox

" Tabs
command! -nargs=1 -complete=file NewTabOpen :tabe <args>
nnoremap <leader>et :NewTabOpen<space>
nnoremap <leader>l :tabn<CR>
nnoremap <leader>h :tabp<CR>

" Configuration
" Open vimrc
nnoremap <leader><CR> :NewTabOpen $MYVIMRC<CR>
" Edit plugins
nnoremap <leader>ep :NewTabOpen ~/.config/nvim/lua/plugins.lua<CR>
" Source vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

" I don't remember what this does~
vnoremap <leader>p "_dP

" Clipboard
vnoremap <leader>c "+y
nnoremap <leader>p "+p
