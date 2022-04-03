local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function()
  use 'wbthomason/packer.nvim' 
  use 'neovim/nvim-lspconfig'
  use 'ellisonleao/gruvbox.nvim'
  use { 'iamcco/markdown-preview.nvim', run = ':call mkdp#util#install()' }
  use { 'neoclide/coc.nvim', branch = 'release', run= ':CocInstall' }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 
      {'nvim-lua/plenary.nvim'},
      { 'nvim-telescope/telescope-live-grep-raw.nvim' }
    }
  }


  use 'APZelos/blamer.nvim'
  use 'folke/lsp-colors.nvim'

  use 'tpope/vim-eunuch'

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)
