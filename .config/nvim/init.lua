local nvim_dir = os.getenv('NVIM_DIR')
local nvim_plugin_dir = os.getenv('NVIM_PLUGIN_DIR')

local function packagepath(str)
	return string.format("%s/?.lua;", str);
end
package.path = packagepath(nvim_dir) .. packagepath(nvim_plugin_dir) .. packagepath(nvim_dir .. '/config') .. package.path


local g = vim.g
-- Remaps
g.mapleader = " "

require('plugins.init')

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

o.cmdheight = 2

o.undodir =  nvim_dir .. "/undodir"
o.undofile = true
o.incsearch = true
o.termguicolors = true
o.scrolloff = 10
o.sidescrolloff = 10

o.showmode = false

o.colorcolumn = '120'

o.statusline = "%=%f\\ %{strftime('%H:%M')}"

vim.opt.splitright = true

vim.cmd('filetype plugin indent on')

local function netrw()
  -- Disable top info in netrw
  g.netrw_banner = 0
    -- Tree style explorer
  g.netrw_liststyle = 3
    -- Set size to 25%
  g.netrw_winsize = 25
    -- Make copy work
  g.netrw_keepdir = 0
end

local function neovide()
  g.neovide_cursor_animation_length = 0.13
end

local function colorscheme()
  vim.cmd('syntax enable')
  vim.cmd('colorscheme gruvbox')
end

netrw()
neovide()
colorscheme()

local function critical_remaps()
  local vimp = require('vimp')
  -- Open $MYVIMRC
  vimp.nnoremap('<leader><CR>', ':e $MYVIMRC<CR>')
  -- Edit plugins
  vimp.nnoremap('<leader>ep', ':e $NVIM_PLUGIN_DIR<CR>')
  -- Source vimrc
  vimp.nnoremap('<leader>sv', function()
    -- Remove all previously added vimpeccable maps
    vimp.unmap_all()
    -- Unload the lua namespace so that the next time require('config.X') is called
    -- it will reload the file
    require('config.util').unload_lua_namespace('config')
   -- Make sure all open buffers are saved
    vim.cmd('silent wa')
    -- Execute our vimrc lua file again to add back our maps
    dofile(vim.fn.stdpath('config') .. '/init.lua')

    print("Reloaded vimrc!")
  end)
end

critical_remaps()
require('remaps')
