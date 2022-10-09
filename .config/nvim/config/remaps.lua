local function critical(vimp)
  -- Fresh source for everything and open MYVIMRC
  vimp.nnoremap('<leader> ', function()
    vimp.unmap_all()
    -- Unload the lua namespace so that the next time require('config.X') is called
    -- it will reload the file
    package.unload('config')
    -- Make sure all open buffers are saved
    vim.cmd('silent wa')

    local vimrc = os.getenv('MYVIMRC')
    -- Execute our vimrc lua file again to add back our maps
    dofile(vimrc)
    -- Open vimrc
    vim.cmd('e ' .. vimrc)
  end
  )
  -- Edit plugins
  vimp.nnoremap('<leader>ev', ':e $NVIM_DIR<CR>')
  vimp.nnoremap('<leader>ep', ':e $NVIM_DIR/init.lua<CR>')
  vimp.nnoremap('<leader>ec', ':e $NVIM_DIR/config/init.lua<CR>')
  vimp.nnoremap('<leader>er', ':e $NVIM_DIR/config/remaps.lua<CR>')
  vimp.nnoremap('<leader>ez', ':e $HOME/.zshrc<CR>')
  vimp.nnoremap('<leader>et', ':e $TMUX_DIR/tmux.conf<CR>')
end

local telescope = function(vimp)
  vimp.nnoremap('<leader>ff', '<CMD>Telescope find_files hidden=true<CR>')
  vimp.nnoremap('<leader>fg', function()
    require('telescope').extensions.live_grep_args.live_grep_args()
  end)
  vimp.nnoremap('<leader>fcg', '<CMD>Telescope grep_string hidden=true<CR>')

  vimp.nnoremap('<leader>fb', '<CMD>Telescope buffers<CR>')

  vimp.nnoremap('<leader>fGs', '<CMD>Telescope git_status<CR>')
  vimp.nnoremap('<leader>fGc', '<CMD>Telescope git_commits<CR>')
  vimp.nnoremap('<leader>fGb', '<CMD>Telescope git_bcommits<CR>')

  vimp.nnoremap('<leader>fGfd', '<CMD>:Picker changed_files_develop<CR>')
  vimp.nnoremap('<leader>fGfm', '<CMD>:Picker changed_files_main<CR>')

  vimp.nnoremap('<leader>fGG', '<CMD>:PickPicker<CR>')

  vimp.nnoremap('<leader>fl', '<CMD>Telescope builtin<CR>')
  vimp.nnoremap('<leader>fd', '<CMD>Telescope diagnostics<CR>')
  vimp.nnoremap('<leader>fqf', '<CMD>Telescope quickfix<CR>')
  vimp.nnoremap('<leader>fh', '<CMD>Telescope search_history<CR>')
end

local function default(vimp)

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

  -- Make terminal easier to escape
  vimp.tnoremap('<Esc>', '<C-\\><C-n>')

  -- RegExp Magic mode
  vimp.nnoremap('/', '/\\v')
  vimp.vnoremap('/', '/\\v')
  vimp.cnoremap('%s/', '%smagic/')
  vimp.cnoremap('>s/', '>smagic/')
end

return { critical = critical, default = default, telescope = telescope }
