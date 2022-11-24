vim.notify = require('notify')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- OPTIONS!
local o = vim.o
o.exrc = true
o.smartindent = true
o.relativenumber = true
o.nu = true
o.hlsearch = false
o.hidden = true
o.errorbells = false

o.tabstop = 2
o.softtabstop = o.tabstop
o.shiftwidth = o.tabstop

o.expandtab = true
o.wrap = false
o.backup = false

o.cmdheight = 0

local nvim_dir = os.getenv('NVIM_DIR')
o.undodir = nvim_dir .. "/.undodir"
o.undofile = true
o.incsearch = true
o.scrolloff = 10
o.sidescrolloff = 10

o.showmode = false

o.colorcolumn = '120'

o.statusline = "%=%f | %{strftime('%H:%M')}"
o.mouse = 'a'

-- Case insensitive searching UNLESS /C or capital letter is in search
o.ignorecase = true
o.smartcase = true
o.completeopt = 'menuone,noselect'

vim.wo.signcolumn = 'yes'

vim.opt.splitright = true

vim.cmd('filetype plugin indent on')

local g = vim.g
-- Disable top info in netrw
g.netrw_banner = 0
-- Tree style explorer
g.netrw_liststyle = 3
-- Set size to 25%
g.netrw_winsize = 25
-- Make copy work
g.netrw_keepdir = 0

g.sql_type_default = 'pgsql'

-- REMAPS!
g.mapleader = " "
g.maplocalleader = " "

local keymap = require('config.keymap')
local remaps = require('config.remaps')
remaps.critical(keymap)
remaps.general(keymap)
remaps.telescope(keymap)
remaps.terminal(keymap)

vim.cmd('syntax enable')
vim.cmd('colorscheme gruvbox')

-- CoC is the last thing in vim
vim.source('coc')

require('markdown-preview')
require('pickers.init')

-- Git stuff
vim.g.blamer_enabled = 1
