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

o.cmdheight = 2

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

local function remap_by(mode)
  return function(lhs, rhs, opts)
    opts = opts or {}
    local options = { noremap = true }

    if opts then
      options = vim.tbl_extend("force", options, opts)
    end

    local mode_remaps = vim.api.nvim_get_keymap(mode)
    local existing_remap = table.find_by(mode_remaps, function (remap)
      return remap.lhs == string.gsub(lhs, '<leader>', vim.g.mapleader)
    end)

    if not opts.override and existing_remap then
      vim.print({
        desc = "Remap found for LHS when 'override' option not specified. Remap skipped.",
        mode = mode,
        lhs = lhs,
        rhs_of_attempted_remap = rhs,
        rhs_of_existing = existing_remap.rhs
      })
      return
    end

    if existing_remap then
      vim.api.nvim_del_keymap(mode, lhs)
    end

    options.override = nil

    if type(rhs) == 'string' then
      vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    else
      options.callback = rhs
      vim.api.nvim_set_keymap(mode, lhs, '', options)
    end
  end
end

local modes = { 'n', 'x', 'o', 'l', 's', 'v', 'i', 't', 'c' }
local keymap = {
  nnoremap = remap_by('n'),
  xnoremap = remap_by('x'),
  onoremap = remap_by('o'),
  lnoremap = remap_by('l'),
  snoremap = remap_by('s'),
  vnoremap = remap_by('v'),
  inoremap = remap_by('i'),
  tnoremap = remap_by('t'),
  cnoremap = remap_by('c'),
  unmap_all = function()
    for _, mode in ipairs(modes) do
      local mode_remaps = vim.api.nvim_get_keymap(mode)
      for _, mode_remap in ipairs(mode_remaps) do
        vim.api.nvim_del_keymap(mode_remap.mode, mode_remap.lhs)
      end
    end
  end
}

local remaps = require('config.remaps')
remaps.critical(keymap)
remaps.general(keymap)
remaps.telescope(keymap)
remaps.toggleterm(keymap)

vim.cmd('syntax enable')
vim.cmd('colorscheme gruvbox')

-- CoC is the last thing in vim
vim.source('coc')

require('markdown-preview')
require('pickers.init')

-- Git stuff
vim.g.blamer_enabled = 1
