-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local o = vim.o --options

-- Unset lazyvim's clipboard settings
o.clipboard = ""

-- Scroll offset
o.scrolloff = 10
o.sidescrolloff = 10

local zz_group = vim.api.nvim_create_augroup("ZZ", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinResized" }, {
  group = zz_group,
  callback = function()
    if vim.api.nvim_get_mode()["mode"] == "n" then
      vim.cmd("normal! zz")
    end
  end,
})

-- Backing up/undoing
o.backup = true
o.writebackup = true

local state_dir = vim.fn.stdpath("state")
o.backupdir = state_dir .. "/backup"
o.undodir = state_dir .. "/undo"

-- Config
o.exrc = true
o.colorcolumn = "120"

-- Indentation/Sign-column numbers
o.smartindent = true
o.relativenumber = true
o.nu = true

-- Misc
o.showmode = false

-- Search
o.incsearch = true
-- Case insensitive searching UNLESS /C or capital letter is in search
o.ignorecase = true
o.smartcase = true
o.completeopt = "menuone,noselect,preview,noinsert"

-- Tabs
o.expandtab = true
o.tabstop = 2
o.softtabstop = o.tabstop
o.shiftwidth = o.tabstop
