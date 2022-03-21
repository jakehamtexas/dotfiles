return require('packer').startup(function()
  use 'wbthomason/packer.nvim' 
  use 'neovim/nvim-lspconfig'
  use 'ellisonleao/gruvbox.nvim'
  use 'iamcco/markdown-preview.nvim'
  use { 'neoclide/coc.nvim', branch = 'release' }
end)
