local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local packer = require('packer')
local util = require('packer.util')

packer.init({
  compile_path = util.join_paths(vim.fn.stdpath('config'), '.packer', 'packer_compiled.lua')
})

-- When plugins are updated, run PackerCompile
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins/packer-config.lua source <afile> | PackerCompile
  augroup end
]])

return packer.startup(function()
  local use = use
  use 'wbthomason/packer.nvim'

  use 'neovim/nvim-lspconfig'

  use 'ellisonleao/gruvbox.nvim'
  use 'folke/lsp-colors.nvim'

  use { 'iamcco/markdown-preview.nvim', run = ':call mkdp#util#install()' }

  use { 'neoclide/coc.nvim', branch = 'release', run= ':CocInstall' }
  use 'sheerun/vim-polyglot'

  use { 'prettier/vim-prettier', run = 'yarn install' }
  use 'svermeulen/vimpeccable'

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/plenary.nvim'},
      { 'nvim-telescope/telescope-live-grep-args.nvim' }
    }
  }

  use {'axkirillov/easypick.nvim', requires = 'nvim-telescope/telescope.nvim'}

  use 'APZelos/blamer.nvim'

  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'

  use 'christoomey/vim-tmux-navigator'

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    packer.sync()
  end
end)
