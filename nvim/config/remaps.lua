local function critical(keymap)
  -- Fresh source for everything and open MYVIMRC
  keymap.n('<leader> ', function()
      -- Make sure all open buffers are saved
      vim.cmd('silent wa')

      keymap.unmap_all()
      package.unload('config')

      local vimrc = os.getenv('MYVIMRC')
      -- Execute our vimrc lua file again to add back our maps
      dofile(vimrc)

      print('Reloaded Neovim config.')
    end,
    { desc = 'Reload Neovim config.' }
  )

  -- Edit plugins
  keymap.n('<leader>ed', ':e $NVIM_DIR<CR>', { desc = '(e)dit config (d)irectory' })
  keymap.n('<leader>ep', ':e $NVIM_DIR/init.lua<CR>', { desc = '(e)dit config (p)lugins' })
  keymap.n('<leader>ec', ':e $NVIM_DIR/config/init.lua<CR>', { desc = '(e)dit secondary (c)onfig' })
  keymap.n('<leader>er', ':e $NVIM_DIR/config/remaps.lua<CR>', { desc = '(e)dit (r)emaps' })
  keymap.n('<leader>ez', ':e $HOME/.zshrc<CR>', { desc = '(e)dit .(z)shrc' })
  keymap.n('<leader>et', ':e $TMUX_DIR/tmux.conf<CR>', { desc = '(e)dit (t)mux.conf' })
end

local function general(keymap)
  keymap.v('<leader>p', '"_dP',
    { desc = 'Delete selected text into _ register and paste before cursor, i.e. replace the selected text' })

  keymap.n('<leader>ca', ':up | %bd | e#<CR>',
    { desc = '(c)lose (a)ll buffers (except this one)' })


  -- Clipboard
  keymap.v('<leader>mc', '"+y', { desc = '(m)ouse (c)opy' })
  keymap.n('<leader>mp', '"+p', { desc = '(m)ouse (p)aste' })

  -- RegExp Magic mode
  keymap.n('/', '/\\v', { desc = 'Make search very magic' })
  keymap.v('/', '/\\v', { desc = 'Make search very magic' })
  keymap.c('%s/', '%smagic/', { desc = 'Make replace very magic' })
  keymap.c('>s/', '>smagic/', { desc = 'Make replace very magic' })

  -- CTRL+d/u niceness
  keymap.n('<C-d>', '<C-d>zz', { desc = 'Center the cursor when using CTRL+d' })
  keymap.n('<C-u>', '<C-u>zz', { desc = 'Center the cursor when using CTRL+u' })
end

local function get_file_pwd()
  return vim.fn.system("pwd | tr -d '\n'")
end

local function get_home_dir()
  return vim.fn.expand '$HOME'
end

local function telescope(keymap)
  keymap.n('<leader>ff', function()
    local pwd = get_file_pwd()
    local home_dir = get_home_dir()
    local find_command = { "rg", "--files", "--color", "never" }

    if (pwd == home_dir) then
      table.insert(find_command, '--ignore-file')
      table.insert(find_command, home_dir .. '/.gitignore')
    end

    require('telescope.builtin').find_files({
      hidden = true,
      find_command = find_command,
    })
  end, { desc = '(f)ind (f)iles' })
  keymap.n('<leader>fg', function()
    local vimgrep_arguments = function()
      local pwd = get_file_pwd()
      local home_dir = get_home_dir()
      if (pwd == home_dir) then
        return {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          '--ignore-file',
          home_dir .. '/.gitignore'
        }
      end
      return nil
    end
    require('telescope').extensions.live_grep_args.live_grep_args({
      vimgrep_arguments = vimgrep_arguments(),
    })
  end, { desc = '(f)ind with (g)rep' })
  keymap.n('<leader>fhg', '<CMD>Telescope grep_string hidden=true<CR>', { desc = '(f)ind in (h)idden files with (g)rep' })

  keymap.n('<leader>fb', '<CMD>Telescope buffers<CR>', { desc = '(f)ind (b)uffers' })

  keymap.n('<leader>fGs', '<CMD>Telescope git_status<CR>', { desc = '(f)ind files in (G)it (s)tatus' })
  keymap.n('<leader>fGB', '<CMD>Telescope git_branches<CR>', { desc = '(f)ind (G)it (b)ranches' })
  keymap.n('<leader>fGc', '<CMD>Telescope git_commits<CR>', { desc = '(f)ind (G)it (c)ommits for the current repo' })
  keymap.n('<leader>fGb', '<CMD>Telescope git_bcommits<CR>', { desc = '(f)ind (G)it commits for the current (b)uffer' })

  keymap.n('<leader>fGfd', '<CMD>:Picker changed_files_develop<CR>', { desc = '(f)ind (G)it (f)iles from (d)evelop' })
  keymap.n('<leader>fGfm', '<CMD>:Picker changed_files_main<CR>', { desc = '(f)ind (G)it (f)iles from (m)ain' })

  keymap.n('<leader>fp', '<CMD>:PickPicker<CR>', { desc = '(f)ind custom (p)ickers' })

  keymap.n('<leader>fl', '<CMD>Telescope builtin<CR>', { desc = '(f)ind in the (l)ist of builtin pickers' })
  keymap.n('<leader>fd', '<CMD>Telescope diagnostics<CR>', { desc = '(f)ind (d)iagnostics in the current buffer' })
  keymap.n('<leader>fqf', '<CMD>Telescope quickfix<CR>', { desc = '(f)ind entries in the (q)uickfix list' })
  keymap.n('<leader>fo', '<CMD>Telescope oldfiles<CR>', { desc = '(f)ind (o)ld files' })
  keymap.n('<leader>fr', '<CMD>Telescope resume<CR>', { desc = '(r)esume last search' })

  keymap.n('<leader>f/', '<CMD>Telescope current_buffer_fuzzy_find<CR>', { desc = '(f)uzzy find in current buffer' })
end

local function terminal(keymap)
  -- Make terminal easier to escape
  keymap.t(';a', '<C-\\><C-n>', { desc = 'Enter normal mode in terminal' })

  keymap.n('<leader>tf', ':ToggleTerm direction=float<CR>', { desc = '(t)oggle (f)loating terminal' })
  keymap.n('<leader>th', ':ToggleTerm direction=horizontal<CR>', { desc = '(t)oggle (h)orizontal terminal' })
  keymap.n('<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = '(t)oggle (v)ertical terminal' })

  -- Just toggle (once one of the above is set)
  keymap.n('<leader>tt', ':ToggleTerm<CR>', { desc = '(t)oggle any (t)erminal' })

  -- TODO: Open term at buffer's current dir
  keymap.n('<leader>td', ':ToggleTerm<CR>', { desc = '(t)oggle any (t)erminal' })
end

local function oil(keymap)
  keymap.n("<leader>-", require("oil").open, { desc = "Open parent directory" })
end

local function git(keymap)
  keymap.n("<leader>Gb", ':BlamerToggle<CR>', { desc = "Toggle (G)it (b)lame in the buffer." })
end

local function lazy(keymap)
  keymap.n("<leader>l", ':Lazy<CR>', { desc = "Open (L)azy" })
end

local function fenced_code_editing(keymap)
  keymap.n('<leader>fe', require('femaco.edit').edit_code_block, { desc = 'Open (f)enced code block edit buffer' })
end

-- TODO: Put the test output in a colorized, floating buffer. Add a command to open and close this special buffer
local function safebase(keymap)
  local test_output_relative_dir = '.vim'
  local test_output_filename = 'test_output.txt'
  function get_test_output_dir()
    return vim.loop.cwd() .. '/' .. test_output_relative_dir
  end

  function get_test_output_filepath()
    return get_test_output_dir() .. '/' .. test_output_filename
  end

  function get_yarn_test_arg()
    local current_file = vim.fn.expand('%:p')
    -- RIP no optional capture groups in lua
    local is_spec_file = string.match(current_file, '.*%.spec%.ts$') or string.match(current_file, '.*%.spec%.tsx$') or
        string.match(current_file, '.*%.spec%.js$') or string.match(current_file, '.*%.spec%.jsx$')
    local is_typescript_file = string.match(current_file, '.*%.ts$') or string.match(current_file, '.*%.tsx$')
    local is_test_file = string.match(current_file, '.*%.test%.ts$') or string.match(current_file, '.*%.test%.tsx$')

    local extension = string.match(current_file, '.*%.(%w+)$')
    local maybe_companion_test_filepath = string.gsub(current_file, '%.' .. extension .. '$', '.test.' .. extension)

    local companion_test_file_exists = vim.fn.filereadable(maybe_companion_test_filepath) == 1

    -- Check if it is a testable file (ends with .ts, .tsx, .js, .jsx, but not .spec.ts)
    if not is_typescript_file or is_spec_file then
      return
    end

    if is_test_file then
      return current_file
    end

    if companion_test_file_exists then
      return maybe_companion_test_filepath
    end

    return nil
  end

  local function run_safebase_test_command(yarn_test_path_arg)
    if yarn_test_path_arg == nil then
      vim.notify('Arg is not testable', "warn")
      return
    end

    local test_output_filepath = get_test_output_filepath()
    vim.fn.system('touch ' .. test_output_filepath)

    local function open_test_output()
      os.execute("mkdir -p " .. get_test_output_dir())
      return io.open(get_test_output_filepath(), 'a')
    end

    -- TODO: Figure out how to reuse the same notification object
    --       1. Keep the notification around until the `on_exit` function is called.
    --       1. When the test passes, say "test passed" in the same notification. Auto dismiss.
    --       1. When the test fails, say "fail", do not dismiss. Add a button to open the test output file.
    vim.notify('Running tests for ' .. yarn_test_path_arg, "info")
    vim.fn.jobstart('yarn test ' .. yarn_test_path_arg, {
      on_stdout = function(_, data)
        local file = open_test_output()
        for _, line in ipairs(data) do
          file:write(line .. '\n')
        end
        file:close()
      end,
      on_stderr = function(_, data)
        local file = io.open(test_output_filepath, 'a')
        for _, line in ipairs(data) do
          file:write(line .. '\n')
        end
        file:close()
      end,
      on_exit = function(_, code)
        if code == 0 then
          vim.notify('Test passed for ' .. yarn_test_path_arg)
        else
          vim.notify('Test failed, check ' .. test_output_filepath .. ' for details', "error")
        end
      end
    })
  end

  keymap.n('<leader>stv', ':e ' .. get_test_output_filepath() .. '<CR>', { desc = '(S)afeBase (t)est output (v)iew' })
  keymap.n('<leader>std', function()
    local yarn_test_path_arg = vim.fn.expand('%:p:h')
    run_safebase_test_command(yarn_test_path_arg)
  end, { desc = '(R)un `yarn (t)est` on the current (d)irectory' })
  keymap.n('<leader>stf', function()
    local yarn_test_path_arg = get_yarn_test_arg()
    run_safebase_test_command(yarn_test_path_arg)
  end, { desc = '(R)un `yarn (t)est` on the current (f)ile' })
  keymap.n('<leader>stR', function()
    vim.fn.system('rm ' .. get_test_output_filepath())
    run_safebase_test_command()
  end, { desc = 'Clear the test output file, then (R)un `yarn (t)est` on the current buffer' })
end

return {
  critical = critical,
  general = general,
  telescope = telescope,
  terminal = terminal,
  oil = oil,
  git = git,
  lazy = lazy,
  fenced_code_editing = fenced_code_editing,
  safebase = safebase,
}
