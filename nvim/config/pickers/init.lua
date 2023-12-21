local new_picker = require("telescope.pickers").new
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local git_pickers = require "pickers.git"
local make_pickers = require "pickers.make"

local pickers = {}

local register_pickers = function(_pickers)
  for _, picker in pairs(_pickers) do
    table.insert(pickers, picker)
  end
end


local function allowed_for_filetype(picker, filetype)
  if picker.filetypes == nil then
    return true
  end

  return table.contains(picker.filetypes, filetype)
end

local ASYNC_ALL_PICKER_NAME_PREFIX = 'All Filetype Commands'

local open_picker = function(opts, bufnr, winnr, filetype)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  winnr = winnr or vim.api.nvim_get_current_win()

  local is_async_all_picker = string.match(opts.args, '^' .. ASYNC_ALL_PICKER_NAME_PREFIX .. '.+')
  for _, picker in pairs(pickers) do
    local picker_name = picker.name
    if type(picker.name) == 'function' then
      picker_name = picker.name(picker.time)
    end

    if picker_name == opts.args or
        (is_async_all_picker and
            picker.async and
            allowed_for_filetype(picker, filetype)
        ) then
      local failed, built = picker.build_picker(bufnr, winnr, function(job_picker)
        register_pickers { job_picker }
      end)

      if failed then
        print('Picker not able to be built: ' .. picker.name)
        return
      end

      if built ~= nil then
        built:find()
      end

      if not is_async_all_picker then
        break
      end
    end
  end
end

local picker_names = function(filetype)
  local names = {}

  local async_all_picker_parts = {}
  for _, picker in pairs(pickers) do
    if allowed_for_filetype(picker, filetype) then
      if type(picker.name) == 'function' and picker.time then
        table.insert(names, picker.name(picker.time))
      else
        table.insert(names, picker.name)
      end

      if picker.async then
        table.insert(async_all_picker_parts, "'" .. picker.name .. "'")
      end
    end
  end

  if #async_all_picker_parts > 0 then

    local async_all_picker_name = ASYNC_ALL_PICKER_NAME_PREFIX ..
        " (" .. table.concat(async_all_picker_parts, ', ') .. ")"
    table.insert(names, async_all_picker_name)
  end

  return names
end

local pick_picker = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_get_current_win()

  local filetype = vim.bo.filetype
  local filetype_picker_names = picker_names(filetype)
  new_picker({}, {
    prompt_title = "Pickle Pickler",
    finder = finders.new_table {
      results = filetype_picker_names,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)

        local selection = action_state.get_selected_entry()
        open_picker({ args = selection[1] }, bufnr, winnr, filetype)
      end)
      return true
    end
  }):find()
end

register_pickers(git_pickers)
register_pickers(make_pickers)

vim.api.nvim_create_user_command('Picker', open_picker, { nargs = 1, complete = picker_names })
vim.api.nvim_create_user_command('PickPicker', pick_picker, { nargs = 0 })
