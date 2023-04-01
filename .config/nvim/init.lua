function vim.script_path()
   local str = debug.getinfo(2, 'S').source:sub(2)
   return str:match('(.*/)')
end

vim.nvim_dir = os.getenv('NVIM_DIR') or vim.script_path():sub(0, -2)
package.path = vim.nvim_dir .. '/?.lua;' .. package.path

require('global')
package.path_add(vim.nvim_dir .. '/config')

local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
print(fn.stdpath("data"))
if not vim.loop.fs_stat(lazypath) then
   IS_BOOTSTRAPPING = true
   fn.system('with_unset_git_env git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ' ..
   lazypath)
end
vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy");
-- "Re sourcing your config is not supported with lazy.nvim"
-- When plugins are updated, run Lazy sync
--vim.api.nvim_create_autocmd('BufWritePost', {
--command = 'source <afile> | Lazy! sync',
--group = vim.api.nvim_create_augroup('Lazy', { clear = true }),
--pattern = vim.fn.expand '$MYVIMRC'
--})

lazy.setup({
   {
      "folke/neoconf.nvim", cmd = "Neoconf"
   },
   "folke/neodev.nvim",
   'neovim/nvim-lspconfig',

   { 'ellisonleao/gruvbox.nvim',
      lazy = false,
      priority = 1000,
      init = function()
         vim.opt.termguicolors = true
         vim.cmd('colorscheme gruvbox')
      end
   },
   'folke/lsp-colors.nvim',
   {
      "folke/which-key.nvim",
      config = function()
         require("which-key").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
         })
      end
   },

   {
      'iamcco/markdown-preview.nvim',
      build = ':call mkdp#util#install()'
   },

   {
      'neoclide/coc.nvim',
      branch = 'release',
      build = ':CocInstall'
   },
   'sheerun/vim-polyglot',

   { 'prettier/vim-prettier',      build = 'yarn install' },

   {
      'nvim-telescope/telescope.nvim',
      dependencies = {
         { 'nvim-lua/plenary.nvim' },
         { 'nvim-telescope/telescope-live-grep-args.nvim' },
         { 'nvim-treesitter/nvim-treesitter' }
      }
   },

   {
      "rcarriga/nvim-notify",
      cond = not vim.g.started_by_firenvim,
      config = function()
         vim.notify = require('notify')
      end
   },

   {
      'APZelos/blamer.nvim',
      cond = not vim.g.started_by_firenvim,
   },
   {
      'lewis6991/gitsigns.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
         vim.o.termguicolors = true
         require('gitsigns').setup()
      end
   },

   'tpope/vim-eunuch',
   'tpope/vim-surround',
   'tpope/vim-dadbod',

   'pantharshit00/vim-prisma',

   'christoomey/vim-tmux-navigator',
   { 'norcalli/nvim-colorizer.lua',
      config = function()
         require('colorizer').setup()
      end },

   { "akinsho/toggleterm.nvim", version = '*', config = function()
      local toggleterm = require("toggleterm")
      toggleterm.setup({
         direction = 'float',
         on_open = function(term)
            local term_group = vim.api.nvim_create_augroup('TermQuickExit', { clear = true })
            vim.api.nvim_create_autocmd('TermEnter', {
               callback = function()
                  require('config.keymap').n('<esc>', function()
                     toggleterm.toggle(term.count or 0)
                  end, { desc = 'Close the terminal', bufnr = term.bufnr })
               end,
               buffer = term.bufnr,
               group = term_group,
            })
         end
      })
   end },

   { 'Shatur/neovim-session-manager',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
         local Path = require('plenary.path')
         require('session_manager').setup({
            sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
            path_replacer = '__', -- The character to which the path separator will be replaced for session files.
            colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
            autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
            autosave_last_session = true, -- Automatically save last session on exit and on session switch.
            autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
            autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
               'gitcommit',
            },
            autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
            max_path_length = 80, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
         })
      end,
   },

   {
      'glacambre/firenvim',
      build = function() vim.fn['firenvim#install'](0) end,
      config = function()
         local firenvim_config = {
            globalSettings = {
               alt = 'all',
            },
            localSettings = {
               ['.*'] = {
                  cmdline = 'neovim',
                  content = 'text',
                  priority = 0,
                  selector = 'textarea',
                  takeover = 'always',
               },
            }
         }
         local forbidden_domains = { '.*localhost.*', '.*safebase.io*', '.*linear.*', '.*notion.so*' }

         for _, value in ipairs(forbidden_domains) do
            firenvim_config.localSettings[value] = { takeover = 'never', priority = 1 }
         end
         vim.g.firenvim_config = firenvim_config
      end
   },

   {
      'lbrayner/vim-rzip'
   },

   { 'nvim-tree/nvim-web-devicons' },
   {
      'stevearc/oil.nvim',
      config = function() require('oil').setup() end
   },

   { 'itchyny/vim-qfedit' },

   {
      'tummetott/reticle.nvim',
      config = function()
         vim.wo.cursorline = true
         require('reticle').setup {}
      end
   },
})


require('config.init')
