local nvim_dir = os.getenv('NVIM_DIR')
package.path = nvim_dir .. '/?.lua;' .. package.path

require('global')
package.path_add(nvim_dir .. '/config')

local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
   IS_BOOTSTRAPPING = true
   fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
   vim.cmd [[packadd packer.nim]]
end

local packer = require('packer')

-- When plugins are updated, run PackerCompile
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
   command = 'source <afile> | PackerCompile',
   group = packer_group,
   pattern = nvim_dir .. '.*'
})

packer.startup(function(use)
   use 'wbthomason/packer.nvim'

   use 'neovim/nvim-lspconfig'

   use 'ellisonleao/gruvbox.nvim'
   use 'folke/lsp-colors.nvim'

   use { 'iamcco/markdown-preview.nvim', run = ':call mkdp#util#install()' }

   use { 'neoclide/coc.nvim', branch = 'release', run = ':CocInstall' }
   use 'sheerun/vim-polyglot'

   use { 'prettier/vim-prettier', run = 'yarn install' }
   use 'svermeulen/vimpeccable'

   use {
      'nvim-telescope/telescope.nvim',
      requires = {
         { 'nvim-lua/plenary.nvim' },
         { 'nvim-telescope/telescope-live-grep-args.nvim' }
      }
   }

   use { "rcarriga/nvim-notify" }

   use 'APZelos/blamer.nvim'
   use { 'lewis6991/gitsigns.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = function()
         require('gitsigns').setup()
      end }

   use 'tpope/vim-eunuch'
   use 'tpope/vim-surround'
   use 'tpope/vim-dadbod'
   use 'pantharshit00/vim-prisma'

   use 'christoomey/vim-tmux-navigator'
   use { 'norcalli/nvim-colorizer.lua',
      config = function()
         require('colorizer').setup()
      end }

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
