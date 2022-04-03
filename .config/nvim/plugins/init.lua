require('packer-config')

local function vimrequire(filename)
  local nvim_plugin_dir = os.getenv('NVIM_PLUGIN_DIR')
  local path = string.format('%s/%s.vim', nvim_plugin_dir, filename)
  vim.cmd('source ' .. path)
end
vimrequire('markdown-preview.nvim')
vimrequire('telescope.nvim')
vimrequire('coc.nvim')
require('blamer')
