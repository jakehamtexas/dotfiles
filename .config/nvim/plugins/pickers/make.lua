local previewers = require 'telescope.previewers'
local stdout_stderr_picker = require "pickers.stdout-stderr"

local function tsc_entry(entry)
  local path_col = string.match(entry, '(.-)%s')
  local path = string.match(path_col, '(.-):')

  if path == nil then
    return
  end

  local line = string.split(path_col, ':')[2]


  local resolved_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. path)
  return {
    value = entry,
    display = entry,
    ordinal = path_col,
    path = resolved_path,
    lnum = tonumber(line),
  }
end

local function file_exists(name)
  local file = io.open(name, "r")
  if file ~= nil then
    io.close(file)

    return true
  end

  return false
end

local eslint_entry_state = {
  file = nil
}

-- "   54:25   error  'p' is already defined                           no-redeclare",
local function get_lnum_error_text(entry)
  local lnum = string.match(entry, '.-(%d+)')
  if lnum ~= nil then
    lnum = tonumber(lnum)
  end

  local message = string.match(entry, 'error (.*)%s%s')
  local rulename = string.match(entry, 'error (.*)%s%s')
  if not message or not rulename then
    return nil, nil
  end

  local error_text = rulename .. ", " .. message
  return lnum, error_text
end

local function eslint_entry(entry)
  local entry_is_path = file_exists(entry)

  if entry_is_path then
    eslint_entry_state.file = entry
    return
  end

  local lnum, error_text = get_lnum_error_text(entry)
  if not lnum or not error_text then
    return
  end

  local filename_error_text = eslint_entry_state.file .. ":" .. lnum .. " - " .. error_text

  return {
    value = entry,
    display = filename_error_text,
    ordinal = filename_error_text,
    path = eslint_entry_state.file,
    lnum = lnum,
  }
end

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local commands = {
  ["npm run tsc"] = {
    name = 'npm run tsc',
    filetypes = { "javascript", "typescript" },
    entry_maker = tsc_entry,
    command = { command = 'npm', args = { 'run', 'tsc' } },
    pipe_command = { command = 'sed', args = { '-r', "s/\\x1B\\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" } },
    async = true
  },
  ["npm run lint"] = {
    name = 'npm run lint',
    filetypes = { "javascript", "typescript" },
    entry_maker = eslint_entry,
    command = { command = 'npm', args = { 'run', 'lint' } },
    async = true
  }
}

local pickers = {}

for name, opts in pairs(commands) do
  local picker = stdout_stderr_picker({
    name = name,
    command = opts.command,
    entry_maker = opts.entry_maker,
    filetypes = opts.filetypes,
    pipe_command = opts.pipe_command,
    async = opts.async
  }, {
    prompt_title = "Make (" .. name .. ")",
    previewer = previewers.vim_buffer_vimgrep.new({}),
  })

  table.insert(pickers, picker)
end

return pickers
