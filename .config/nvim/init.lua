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

vim.opt.switchbuf = vim.opt.switchbuf + "newtab"

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

local function remaps()
  local vimp = require('vimp')

  vim.cmd([[command! -nargs=1 -complete=file NewTabOpen :tabe <args>]])

  -- Open new tab at specified path
  vimp.nnoremap('<leader>et', ':NewTabOpen<space>')

  -- Splits
  vimp.nnoremap('<C-j>', '<C-w>j')
  vimp.nnoremap('<C-k>', '<C-w>k')
  vimp.nnoremap('<C-h>', '<C-w>h')
  vimp.bind('n', { 'override' }, '<C-l>', '<C-w>l')

  -- Change dir to current buffer path
  vimp.nnoremap('<leader>cd', '%:p:h<CR>:pwd<CR>')

  -- Left explore opened at buffer dir, with pwd unchanged
  vimp.nnoremap('<leader>lex', ':Lex %:p:h<CR>')

  -- Open $MYVIMRC
  vimp.nnoremap('<leader><CR>', ':NewTabOpen $MYVIMRC<CR>')
  -- Edit plugins
  vimp.nnoremap('<leader>ep', ':NewTabOpen $NVIM_PLUGIN_DIR<CR>')
  -- Source vimrc
    vimp.nnoremap('<leader>sv', function()
      -- Remove all previously added vimpeccable maps
      vimp.unmap_all()
      -- Unload the lua namespace so that the next time require('config.X') is called
      -- it will reload the file
      require("config.util").unload_lua_namespace('config')
     -- Make sure all open buffers are saved
      vim.cmd('silent wa')
      -- Execute our vimrc lua file again to add back our maps
      dofile(vim.fn.stdpath('config') .. '/init.lua')

      print("Reloaded vimrc!")
    end)

  -- Delete selected text into _ register and paste on line above
  -- i.e. replace the selected text
  vimp.vnoremap('<leader>p', '"_dP')

  -- Clipboard
  vimp.vnoremap('<leader>mc', '"+y')
  vimp.nnoremap('<leader>mp', '"+p')

  vimp.tnoremap('<Esc>', '<C-\\><C-n>')

  local sesh = require('git-sesh')
  vimp.nnoremap('<leader>ss', sesh.git_sesh_save)
  vimp.nnoremap('<leader>sl', sesh.git_sesh_load)
end

remaps()
