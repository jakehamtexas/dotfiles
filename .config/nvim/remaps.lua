local config_util = require('config.util')

local function remaps()

  -- Splits
  vimp.nnoremap('<C-j>', '<C-w>j')
  vimp.nnoremap('<C-k>', '<C-w>k')
  vimp.nnoremap('<C-h>', '<C-w>h')
  vimp.bind('n', { 'override' }, '<C-l>', '<C-w>l')

  -- Change dir to current buffer path
  vimp.nnoremap('<leader>cd', '%:p:h<CR>:pwd<CR>')

  -- Left explore opened at buffer dir, with pwd unchanged
  vimp.nnoremap('<leader>lex', ':Lex %:p:h<CR>')

  -- Open terminal in vertical split
  vimp.nnoremap('<leader>te', ':vne | term<CR>')

  -- Delete selected text into _ register and paste on line above
  -- i.e. replace the selected text
  vimp.vnoremap('<leader>p', '"_dP')

  -- Clipboard
  vimp.vnoremap('<leader>mc', '"+y')
  vimp.nnoremap('<leader>mp', '"+p')

  vimp.tnoremap('<Esc>', '<C-\\><C-n>')

  local sesh = require('git-sesh')
  vimp.nnoremap('<leader>ss', sesh.git_sesh_save)
  vimp.nnoremap('<leader>sl', sesh.git_sesh_load)


  vimp.nnoremap('<leader>wo', function()
    vim.cmd('wa')
    local keep = {}
    local tab = vim.fn.tabpagebuflist()

    for pos, buffer in pairs(tab) do
      keep[pos] = vim.fn.expand("#" .. buffer .. ":p")
    end

    vim.cmd('%bd')

    for _, filename in pairs(keep) do
      vim.cmd('vne ' .. filename)
    end

    vim.cmd('bd#')
  end)
end

return remaps()
