function vim.script_path()
   local str = debug.getinfo(2, 'S').source:sub(2)
   return str:match('(.*/)')
end

vim.nvim_dir = os.getenv('NVIM_DIR') or vim.script_path():sub(0, -2)
package.path = vim.nvim_dir .. '/?.lua;' .. package.path

require('global')
package.path_add(vim.nvim_dir .. '/config')

local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
   IS_BOOTSTRAPPING = true
   fn.system('with_unset_git_env git clone --depth 1 https://github.com/wbthomason/packer.nvim ' .. install_path)
   vim.cmd [[packadd packer.nvim]]
end

local packer = require('packer')

-- When plugins are updated, run PackerCompile
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
   command = 'source <afile> | PackerCompile',
   group = packer_group,
   pattern = vim.fn.expand '$MYVIMRC'
})

packer.startup(function(use)
   use 'wbthomason/packer.nvim'

   use 'neovim/nvim-lspconfig'

   use 'ellisonleao/gruvbox.nvim'
   use 'folke/lsp-colors.nvim'
   use {
      "folke/which-key.nvim",
      config = function()
         require("which-key").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
         })
      end
   }

   use {
      'iamcco/markdown-preview.nvim',
      run = ':call mkdp#util#install()'
   }

   use {
      'neoclide/coc.nvim',
      branch = 'release',
      run = ':CocInstall'
   }
   use 'sheerun/vim-polyglot'

   use { 'prettier/vim-prettier', run = 'yarn install' }

   use {
      'nvim-telescope/telescope.nvim',
      requires = {
         { 'nvim-lua/plenary.nvim' },
         { 'nvim-telescope/telescope-live-grep-args.nvim' }
      }
   }

   use {
      "rcarriga/nvim-notify",
      after = 'firenvim',
      config = function()
         if not vim.g.started_by_firenvim then
            vim.notify = require('notify')
         end
      end
   }

   use {
      'APZelos/blamer.nvim',
      after = 'firenvim',
      opt = true,
      cond = function() return not vim.g.started_by_firenvim end
   }
   use {
      'lewis6991/gitsigns.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = function()
         vim.o.termguicolors = true
         require('gitsigns').setup()
      end
   }

   use 'tpope/vim-eunuch'
   use 'tpope/vim-surround'
   use 'tpope/vim-dadbod'
   use 'pantharshit00/vim-prisma'

   use 'christoomey/vim-tmux-navigator'
   use { 'norcalli/nvim-colorizer.lua',
      config = function()
         require('colorizer').setup()
      end }

   use { "akinsho/toggleterm.nvim", tag = '*', config = function()
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
   end }

   use { 'Shatur/neovim-session-manager',
      requires = { 'nvim-lua/plenary.nvim' },
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
   }

   use {
      'glacambre/firenvim',
      run = function() vim.fn['firenvim#install'](0) end,
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
         local forbidden_domains = { '.*localhost.*', '.*safebase.*', '.*linear.*' }

         for _, value in ipairs(forbidden_domains) do
            firenvim_config.localSettings[value] = { takeover = 'never', priority = 1 }
         end
         vim.g.firenvim_config = firenvim_config
      end
   }

   use {
      'lbrayner/vim-rzip'
   }

   -- Automatically set up your configuration after cloning packer.nvim
   if IS_BOOTSTRAPPING then
      packer.sync()
   end
end)

if IS_BOOTSTRAPPING then
   print '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
   print '  You can just restart Neovim when  '
   print '  Packer Sync is completed. :)))))  '
   print '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
   return
end

require('config.init')
