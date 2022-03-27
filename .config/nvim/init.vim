" Remaps
let mapleader = " "

" ~/.config/nvim/lua/init.lua
lua require('init')

" When plugins are updated, run PackerCompile
augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

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
set statusline=%=%f\ %{strftime('%H:%M')}
set switchbuf+=newtab
set splitright


filetype plugin indent on


" Markdown
source $NVIM_DIR/markdown-preview.vim

" Telescope 
source $NVIM_DIR/telescope.nvim.vim

" Neovide
let g:neovide_cursor_animation_length=0.13

" Netrw
" Disable top info in netrw
let g:netrw_banner = 0
" Tree style explorer
let g:netrw_liststyle = 3
" Set size to 25%
let g:netrw_winsize=25
" Make copy work
let g:netrw_keepdir=0

" Color scheme
syntax enable
colorscheme gruvbox

" Navigation
" Tabs
command! -nargs=1 -complete=file NewTabOpen :tabe <args>
nnoremap <leader>et :NewTabOpen<space>
nnoremap <leader>l :tabn<CR>
nnoremap <leader>h :tabp<CR>
" Windows
nnoremap <leader>sr :vne 'splitright'<CR>
" Misc
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
nnoremap <leader>lex :Lex %:p:h<CR>

" Configuration
" Open vimrc
nnoremap <leader><CR> :NewTabOpen $MYVIMRC<CR>
" Edit plugins
nnoremap <leader>ep :NewTabOpen ~/.config/nvim/lua/plugins.lua<CR>
" Edit Coc
nnoremap <leader>ec :NewTabOpen ~/.config/nvim/coc.nvim.vim<CR>
" Source vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

" Delete selected text into _ register and paste on line above
" i.e. replace the selected text
vnoremap <leader>p "_dP

" Clipboard
vnoremap <leader>mc "+y
nnoremap <leader>mp "+p

" Terminal
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
endif

" CoC
source $NVIM_DIR/coc.nvim.vim

" Git
" Blamer (Git Blame)
let g:blamer_enabled = 1
