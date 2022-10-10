local function critical(keymap)
  -- Fresh source for everything and open MYVIMRC
  keymap.nnoremap('<leader> ', function()
    keymap.unmap_all()
    -- Unload the lua namespace so that the next time require('config.X') is called
    -- it will reload the file
    package.unload('config')
    -- Make sure all open buffers are saved
    vim.cmd('silent wa')

    local vimrc = os.getenv('MYVIMRC')
    -- Execute our vimrc lua file again to add back our maps
    dofile(vimrc)
  end,
  { desc = 'Reload Neovim config.' }
  )
  -- Edit plugins
  keymap.nnoremap('<leader>ed', ':e $NVIM_DIR<CR>', { desc = '(e)dit config (d)irectory' })
  keymap.nnoremap('<leader>ep', ':e $NVIM_DIR/init.lua<CR>', { desc = '(e)dit config (p)lugins' })
  keymap.nnoremap('<leader>ec', ':e $NVIM_DIR/config/init.lua<CR>', { desc = '(e)dit secondary (c)onfig' })
  keymap.nnoremap('<leader>er', ':e $NVIM_DIR/config/remaps.lua<CR>', { desc = '(e)dit (r)emaps' })
  keymap.nnoremap('<leader>ez', ':e $HOME/.zshrc<CR>', { desc = '(e)dit .(z)shrc' })
  keymap.nnoremap('<leader>et', ':e $TMUX_DIR/tmux.conf<CR>', { desc = '(e)dit (t)mux.conf' })
end

local function general(keymap)
  keymap.vnoremap('<leader>p', '"_dP', { desc = 'Delete selected text into _ register and paste before cursor, i.e. replace the selected text' })

  -- Splits
  keymap.nnoremap('<C-j>', '<C-w>j', { desc = 'Move to split buffer - down' })
  keymap.nnoremap('<C-k>', '<C-w>k', { desc = 'Move to split buffer - up' })
  keymap.nnoremap('<C-h>', '<C-w>h', { desc = 'Move to split buffer - left' })
  keymap.nnoremap('<C-l>', '<C-w>l', { desc = 'Move to split buffer - right', override = true })

  keymap.nnoremap('<leader>cd', ':cd %:p:h<CR>:pwd<CR>', { desc = '(c)hange (d)irectory (pwd) to the dir of the current buffer' })
  keymap.nnoremap('<leader>lex', ':Lex %:p:h<CR>', { desc = 'Open (l)eft (ex)plorer in pwd of the current buffer' })

  -- Clipboard
  keymap.vnoremap('<leader>mc', '"+y', { desc = '(m)ouse (c)opy' })
  keymap.nnoremap('<leader>mp', '"+p', { desc = '(m)ouse (p)aste' })

  -- Make terminal easier to escape
  keymap.tnoremap('<Esc>', '<C-\\><C-n>', { desc = 'Enter normal mode in terminal' })

  -- RegExp Magic mode
  keymap.nnoremap('/', '/\\v', { desc = 'Make search very magic' })
  keymap.vnoremap('/', '/\\v', { desc = 'Make search very magic' })
  keymap.cnoremap('%s/', '%smagic/', { desc = 'Make replace very magic' })
  keymap.cnoremap('>s/', '>smagic/', { desc = 'Make replace very magic' })
end

local function telescope(keymap)
  keymap.nnoremap('<leader>ff', '<CMD>Telescope find_files hidden=true<CR>', { desc = '(f)ind (f)iles' })
  keymap.nnoremap('<leader>fg', function()
    require('telescope').extensions.live_grep_args.live_grep_args()
  end, { desc = '(f)ind with (g)rep' })
  keymap.nnoremap('<leader>fhg', '<CMD>Telescope grep_string hidden=true<CR>', { desc = '(f)ind in (h)idden files with (g)rep' })

  keymap.nnoremap('<leader>fb', '<CMD>Telescope buffers<CR>', { desc = '(f)ind (b)uffers' })

  keymap.nnoremap('<leader>fGs', '<CMD>Telescope git_status<CR>', { desc = '(f)ind files in (G)it (s)tatus' })
  keymap.nnoremap('<leader>fGB', '<CMD>Telescope git_branches<CR>', { desc = '(f)ind (G)it (b)ranches' })
  keymap.nnoremap('<leader>fGc', '<CMD>Telescope git_commits<CR>', { desc = '(f)ind (G)it (c)ommits for the current repo' })
  keymap.nnoremap('<leader>fGb', '<CMD>Telescope git_bcommits<CR>', { desc = '(f)ind (G)it commits for the current (b)uffer' })

  keymap.nnoremap('<leader>fGfd', '<CMD>:Picker changed_files_develop<CR>', { desc = '(f)ind (G)it (f)iles from (d)evelop' })
  keymap.nnoremap('<leader>fGfm', '<CMD>:Picker changed_files_main<CR>', { desc = '(f)ind (G)it (f)iles from (m)ain' })

  keymap.nnoremap('<leader>fp', '<CMD>:PickPicker<CR>', { desc = '(f)ind custom (p)ickers' })

  keymap.nnoremap('<leader>fl', '<CMD>Telescope builtin<CR>', { desc = '(f)ind in the (l)ist of builtin pickers' })
  keymap.nnoremap('<leader>fd', '<CMD>Telescope diagnostics<CR>', { desc = '(f)ind (d)iagnostics in the current buffer' })
  keymap.nnoremap('<leader>fqf', '<CMD>Telescope quickfix<CR>', { desc = '(f)ind entries in the (q)uickfix list' })
  keymap.nnoremap('<leader>fo', '<CMD>Telescope oldfiles<CR>', { desc = '(f)ind (o)ld files' })
  keymap.nnoremap('<leader>fr', '<CMD>Telescope resume<CR>', { desc = '(r)esume last search' })
end

local function toggleterm(keymap)
  keymap.nnoremap('<leader>tf', ':ToggleTerm direction=float<CR>', { desc = '(t)oggle (f)loating terminal' })
  keymap.nnoremap('<leader>th', ':ToggleTerm direction=horizontal<CR>', { desc = '(t)oggle (h)orizontal terminal' })
  keymap.nnoremap('<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = '(t)oggle (v)ertical terminal' })

  -- Just toggle (once one of the above is set)
  keymap.nnoremap('<leader>tt', ':ToggleTerm<CR>', { desc = '(t)oggle any (t)erminal' })
end

return { critical = critical, general = general, telescope = telescope, toggleterm = toggleterm }
