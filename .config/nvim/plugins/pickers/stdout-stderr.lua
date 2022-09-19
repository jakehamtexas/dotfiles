local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local concatenate_sync_command = function(command)
  if type(command) == 'string' then
    return command
  end
  local concated = command.command
  for _, arg in pairs(command.args or {}) do
    concated = concated .. " " .. arg
  end
  return concated
end

local DEFAULT_ENTRY_MAKER = function(entry)
  return {
    display = entry,
    ordinal = entry,
    path = entry,
  }
end

local job_state = {}
-- Picker that reads a command and pipes its stderr and stdout to make_entry
--- @param command_opts table
--- @key name string: The name of the picker
--- @key command table: The shell command of the form { command = '', args = { '' }, cwd? = '' }
--- @key pipe_command optional table: An optional command to pipe output to.
--- @key entry_maker function optional: function(entry: string) => table
--- @key filetypes table optional: The filetypes that the command is valid for. Defaults to all.
--- @param picker_opts table optional: The usual opts that may be passed to a picker
return function(command_opts, picker_opts)
  -- Required
  local command = command_opts.command

  if command == nil then
    print("Empty picker command.")
    return
  end

  command_opts.name = command_opts.name
  if command_opts.name == nil then
    print("Empty picker name.")
    return
  end


  local entry_maker = command_opts.entry_maker or DEFAULT_ENTRY_MAKER

  picker_opts = picker_opts or {}
  picker_opts.prompt_title = picker_opts.prompt_title or "Stdout-Stderr Picker"
  picker_opts.sorter = picker_opts.sorter or conf.generic_sorter(command_opts)

  return {
    name = command_opts.name,
    filetypes = command_opts.filetypes,
    async = command_opts.async,
    build_picker = function(bufnr, winnr, cb)
      picker_opts.bufnr = bufnr
      picker_opts.winnr = winnr

      if not command_opts.async then
        local sync_command = "(" .. concatenate_sync_command(command) .. ")" .. "2>&1"

        if command_opts.pipe_command ~= nil then
          local pipe_command = concatenate_sync_command(command_opts.pipe_command)
          sync_command = sync_command .. ' | ' .. pipe_command
        end
        local handle = io.popen(sync_command)

        if handle == nil then
          print("Command failed: " .. sync_command)
          cb('Command failed.')
          return true
        end

        local result = handle:read("*a")
        handle:close()

        local lines = {}

        for part in string.gmatch(result, "([^\n]+)") do
          table.insert(lines, part)
        end

        local picker = pickers.new(picker_opts, {
          finder = finders.new_table
          {
            results = lines,
            entry_maker = entry_maker
          },
        })
        return false, picker
      end


      local command_job_id = concatenate_sync_command(command)
      if job_state[command_job_id] then
        return false
      end

      vim.notify("Starting '" .. command_opts.name .. "'.", "info", { render = "minimal" })
      local Job = require('plenary.job')

      local command_job = Job:new({
        command = command_opts.command.command,
        args = command_opts.command.args,
        cwd = command_opts.command.cwd,
      })

      local lines = {}

      local pipe_rcv_command = (command_opts.pipe_command or { command = 'cat' }).command
      local pipe_rcv_args = nil
      if command_opts.pipe_command and command_opts.pipe_command.command then
        pipe_rcv_args = command_opts.pipe_command.args
      end

      command_job:start()

      job_state[command_job_id] = true

      Job:new({
        writer = command_job,
        command = pipe_rcv_command,
        args = pipe_rcv_args,
        cwd = command_opts.command.cwd,
        on_stdout = function(_, line)
          -- TODO: Use error format regex from config to get proper lines
          if string.match(line, "([^\n]+)") then
            table.insert(lines, line)
          end
        end,
        on_exit = function(self)
          cb({
            name = function(time)
              local DAY_SECONDS = 24 * 60 * 60
              local now = os.time()

              local was_today = (now - time) < DAY_SECONDS

              local date_str = os.date("%X", time)
              if not was_today then
                date_str = os.date('%x %X', time)
              end
              return date_str .. " Result: " .. command_opts.name
            end,
            filetypes = command_opts.filetypes,
            time = os.time(),
            build_picker = function(bufnrr, winnrr)
              picker_opts.bufnr = bufnrr
              picker_opts.winnr = winnrr

              local picker = pickers.new(picker_opts, {
                finder = finders.new_table
                {
                  results = lines,
                  entry_maker = entry_maker
                },
              })
              return false, picker
            end
          })

          vim.notify("'" .. command_opts.name .. "' Complete!", "info",
            { render = "minimal" })
          job_state[command_job_id] = nil
        end
      }):start()

      return false
    end
  }
end
