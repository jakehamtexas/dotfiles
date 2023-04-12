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
local firenvim_group = vim.api.nvim_create_augroup('Firenvim', { clear = true })
local profile_firenvim = false

if vim.g.started_by_firenvim then
   vim.g.polyglot_disabled = { 'autoindent' }
end

lazy.setup({
   {
      "folke/neoconf.nvim", cmd = "Neoconf"
   },
   {
      'nvim-treesitter/nvim-treesitter',
      config = function()
         require 'nvim-treesitter.configs'.setup {
            -- A list of parser names, or "all" (the five listed parsers should always be installed)
            ensure_installed = { "markdown", "query" },
         }
      end,
   },
   "folke/neodev.nvim",
   'neovim/nvim-lspconfig',

   {
      'ellisonleao/gruvbox.nvim',
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
      config = function()
         require('telescope').setup({
            defaults = {
               vimgrep_arguments = {
                  "rg",
                  "-L",
                  "--color=never",
                  "--no-heading",
                  "--with-filename",
                  "--line-number",
                  "--column",
                  "--smart-case",
               },
               prompt_prefix = "  ",
               selection_caret = "  ",
               entry_prefix = "  ",
               initial_mode = "insert",
               selection_strategy = "reset",
               sorting_strategy = "ascending",
               layout_strategy = "horizontal",
               layout_config = {
                  horizontal = {
                     prompt_position = "top",
                     preview_width = 0.55,
                     results_width = 0.8,
                  },
                  vertical = {
                     mirror = false,
                  },
                  width = 0.87,
                  height = 0.80,
                  preview_cutoff = 120,
               },
               file_sorter = require("telescope.sorters").get_fuzzy_file,
               file_ignore_patterns = { "node_modules" },
               generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
               path_display = { "truncate" },
               winblend = 0,
               border = {},
               borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
               color_devicons = true,
               set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
               file_previewer = require("telescope.previewers").vim_buffer_cat.new,
               grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
               qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
               -- Developer configurations: Not meant for general override
               buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
            },
            extensions_list = { "themes", "terms" },
         })
      end,
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
   {
      'norcalli/nvim-colorizer.lua',
      config = function()
         require('colorizer').setup()
      end
   },

   {
      "akinsho/toggleterm.nvim",
      version = '*',
      config = function()
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
      end
   },

   {
      'Shatur/neovim-session-manager',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
         local Path = require('plenary.path')
         require('session_manager').setup({
            sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),               -- The directory where the session files will be saved.
            path_replacer = '__',                                                      -- The character to which the path separator will be replaced for session files.
            colon_replacer = '++',                                                     -- The character to which the colon symbol will be replaced for session files.
            autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
            autosave_last_session = true,                                              -- Automatically save last session on exit and on session switch.
            autosave_ignore_not_normal = true,                                         -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
            autosave_ignore_filetypes = {                                              -- All buffers of these file types will be closed before the session is saved.
               'gitcommit',
            },
            autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
            max_path_length = 80,             -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
         })
      end,
   },
   {
      'AckslD/nvim-FeMaco.lua',
      config = function()
         require('femaco').setup()
      end,
      dependencies = {
         { 'nvim-treesitter/nvim-treesitter' }
      }
   },
   {
      'glacambre/firenvim',
      lazy = not vim.g.started_by_firenvim,
      build = function() vim.fn['firenvim#install'](0) end,
      config = function()
         if profile_firenvim then
            vim.profile('firenvim')
         end

         vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
            group = firenvim_group,
            callback = function(e)
               if vim.g.timer_started == true then
                  return
               end
               vim.g.timer_started = true
               vim.fn.timer_start(10000, function()
                  vim.g.timer_started = false
                  vim.cmd.write()
               end)
            end
         })

         vim.api.nvim_create_autocmd('ExitPre', {
            group = firenvim_group,
            -- Close all buffers
            command = ':%bd'
         })
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
   { 'github/copilot.vim' },
})


require('config.init')
