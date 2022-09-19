require('packer-config')
vim.notify = require('notify')

local function source(name)
  local path = os.getenv('NVIM_PLUGIN_DIR') .. '/' .. name .. '.vim'
  vim.cmd('source ' .. path)
end

source('markdown-preview')
require('pickers.init')
source('telescope-config')
source('coc')
source('blamer')
