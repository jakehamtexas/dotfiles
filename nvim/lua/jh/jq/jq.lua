-- Inspired by https://github.com/jrop/jq.nvim/commit/b9879798f25a9318894456dc7464af0904c08958

---@class JqOpts
---@field new_tab boolean # Whether to open a new tab

local IDENTIFIER = "~jq"
local JQ_JQ_BUFNR_TAB_KEY = "jq_bufnr"
local JQ_TAB_NAME_KEY = "jq_tab_name"
local JQ_JSON_BUFNR_TAB_KEY = "jq_json_bufnr"
local JQ_OUTPUT_BUFNR_TAB_KEY = "jq_output_bufnr"

local JQ_BUF_HEIGHT = 10

---@return number? bufnr, string? err # The buffer number
local function create_scratch_buf()
  local bufnr = vim.api.nvim_create_buf(false, true)

  if bufnr == 0 then
    return nil, "Failed to create buffer"
  end

  return bufnr, nil
end

---@param tab_id number # The tab's ID
---@param key string # The key to get
---@return string? # The value, or nil if not found
local get_tabpage_var = function(tab_id, key)
  local s, v = pcall(function()
    return vim.api.nvim_tabpage_get_var(tab_id, key)
  end)

  if s and type(v) == "string" then
    return v
  else
    return nil
  end
end

---@return number? # The tab's ID
local find_jq_tab = function()
  for _, tab_id in ipairs(vim.api.nvim_list_tabpages()) do
    vim.print(tab_id)
    local tab_name = get_tabpage_var(tab_id, JQ_TAB_NAME_KEY)
    vim.print(tab_name)
    if tab_name == IDENTIFIER then
      return tab_id
    end
  end
end

---@param bufnr number # The buffer to open in the tab
---@return number # The tab's ID
local function create_jq_tab(bufnr)
  -- If we didn't find the tab, create it
  vim.cmd("tab sb " .. bufnr)
  local tab_id = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_tabpage_set_var(tab_id, JQ_TAB_NAME_KEY, IDENTIFIER)

  return tab_id
end

---@param bufnr number # The buffer number
local function get_buffer_text(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(bufnr), true)
  local text = ""
  for _, line in ipairs(lines) do
    text = text .. line .. "\n"
  end
  return text
end

---@param text string | string[] # The text to set in the buffer
---@param bufnr number # The buffer number
local function set_buffer_text(text, bufnr)
  if type(text) == "string" then
    text = vim.fn.split(text, "\n")
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, text)
end

---@param json_bufnr number # The json buffer number
---@param tab_id number # The tab ID
---@return boolean # Whether the tab has the json buffer
local function should_keep_tab(json_bufnr, tab_id)
  return get_tabpage_var(tab_id, JQ_JSON_BUFNR_TAB_KEY) == tostring(json_bufnr)
end

---@param json_bufnr number # The json bufnr
---@param opts JqOpts? # The options
local function setup_windows(json_bufnr, opts)
  local tab_id = find_jq_tab()
  if tab_id and should_keep_tab(json_bufnr, tab_id) then
    -- Focus the jq buffer
    local jq_bufnr = get_tabpage_var(tab_id, JQ_JQ_BUFNR_TAB_KEY)

    if not jq_bufnr then
      error("unreachable")
      return
    end

    vim.cmd("buffer " .. jq_bufnr)

    return
  end

  if tab_id then
    -- destroy the tab and rerun the function
    vim.cmd(tab_id .. "tabclose")

    return setup_windows(json_bufnr, opts)
  end

  -- Open json buffer in new tab
  tab_id = create_jq_tab(json_bufnr)
  vim.api.nvim_tabpage_set_var(tab_id, JQ_JSON_BUFNR_TAB_KEY, json_bufnr)

  -- Set up buffers
  -- Create a new buffer for jq - use it as the bottom-left buffer
  -- Create a new buffer for jq error messages - pop it up within the jq buffer, on the bottom
  -- Create a new buffer for the output - use it as the right buffer (vsplit)

  -- Create the output buffer first
  vim.cmd("vsplit")
  local win_id = vim.api.nvim_get_current_win()
  local output_buf, output_err = create_scratch_buf()

  if not output_buf then
    error("Error creating output buffer: " .. output_err)
    return
  end

  vim.api.nvim_buf_set_option(output_buf, "filetype", "json")
  vim.api.nvim_tabpage_set_var(tab_id, JQ_OUTPUT_BUFNR_TAB_KEY, output_buf)
  vim.api.nvim_win_set_buf(win_id, output_buf)

  -- Next, create the jq buffer
  -- First, we have to navigate to the left buffer so we can make the split
  -- We also need to keep track of the original height of the window so we can set the height of the jq buffer
  local max_height = vim.api.nvim_win_get_height(win_id)
  vim.cmd("wincmd h")
  vim.cmd("split")

  local jq_buf, jq_err = create_scratch_buf()
  if not jq_buf then
    error("Error creating jq buffer: " .. jq_err)
    return
  end

  win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_tabpage_set_var(tab_id, JQ_JQ_BUFNR_TAB_KEY, jq_buf)
  vim.api.nvim_win_set_buf(win_id, jq_buf)
  vim.api.nvim_buf_set_option(jq_buf, "filetype", "conf")
  set_buffer_text("# JQ filter: enter normal mode, or press <CR> to execute\n\n.", jq_buf)

  vim.cmd("split")

  local jq_err_buf, jq_err_err = create_scratch_buf()
  if not jq_err_buf then
    error("Error creating jq error buffer: " .. jq_err_err)
    return
  end
  vim.api.nvim_tabpage_set_var(tab_id, "jq_err_bufnr", jq_err_buf)

  win_id = vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_buf(win_id, jq_err_buf)
  vim.api.nvim_buf_set_option(jq_err_buf, "filetype", "conf")

  set_buffer_text("# JQ error", jq_err_buf)

  -- Refocus the json buffer to set its height
  vim.cmd("wincmd k")
  vim.cmd("wincmd k")
  win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win_id, max_height - JQ_BUF_HEIGHT)

  -- Refocus the jq buffer to set its height
  vim.cmd("wincmd j")

  win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win_id, JQ_BUF_HEIGHT)

  -- Refocus the jq error buffer to set its height
  vim.cmd("wincmd j")

  win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win_id, 4)

  -- Refocus the jq buffer
  vim.cmd("wincmd k")
end

local jq_filter = function(json_bufnr, jq_filter)
  -- spawn jq and pipe in json, returning the output text
  local modified = vim.bo[json_bufnr].modified
  local fname = vim.fn.bufname(json_bufnr)

  if (not modified) and fname ~= "" then
    -- the following should be faster as it lets jq read the file contents
    return vim.fn.system({ "jq", jq_filter, fname })
  else
    local json = get_buffer_text(json_bufnr)
    return vim.fn.system({ "jq", jq_filter }, json)
  end
end

local jq_group = vim.api.nvim_create_augroup("jq", { clear = true })

---@param tab_id number # The tab ID
---@param opts JqOpts? # The options
local do_jq = function(tab_id, opts)
  local jq_buffer_raw = get_tabpage_var(tab_id, JQ_JQ_BUFNR_TAB_KEY)

  if not jq_buffer_raw then
    print("No jq buffer found")
    return
  end

  local jq_buffer = tonumber(jq_buffer_raw)

  if not jq_buffer then
    print("Invalid jq buffer number")
    return
  end

  local filter = get_buffer_text(jq_buffer)
  local json_bufnr_raw = get_tabpage_var(tab_id, JQ_JSON_BUFNR_TAB_KEY)

  if not json_bufnr_raw then
    print("No json buffer found")
    return
  end
  local json_bufnr = tonumber(json_bufnr_raw)

  if not json_bufnr then
    print("Invalid json buffer number")
    return
  end

  local json = get_buffer_text(json_bufnr)

  local output_bufnr_raw = get_tabpage_var(tab_id, JQ_OUTPUT_BUFNR_TAB_KEY)

  if not output_bufnr_raw then
    print("No output buffer found")
    return
  end

  local output_bufnr = tonumber(output_bufnr_raw)

  if not output_bufnr then
    print("Invalid output buffer number")
    return
  end

  set_buffer_text(jq_filter(json, filter), output_bufnr)
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = jq_group,
  callback = function(opts)
    local bufnr = opts.buf
    local tab_id = find_jq_tab()
    vim.print("bufnr " .. tostring(bufnr))

    -- TODO: Always nil?
    vim.print("tab_id " .. tostring(tab_id))

    if not tab_id then
      return
    end

    local tab_bufnr = get_tabpage_var(tab_id, JQ_JQ_BUFNR_TAB_KEY)
    vim.print("tab_bufnr " .. tostring(tab_bufnr))
    if bufnr == tab_bufnr then
      vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        group = jq_group,
        callback = function()
          tab_id = find_jq_tab()
          vim.print("inner tab_id " .. tab_id)

          if not tab_id then
            return
          end

          return do_jq(tab_id)
        end,
      })

      local jq_buffer_raw = get_tabpage_var(tab_id, JQ_JQ_BUFNR_TAB_KEY)

      if not jq_buffer_raw then
        print("No jq buffer found")
        return
      end

      local jq_buffer = tonumber(jq_buffer_raw)
      if not jq_buffer then
        print("Invalid jq buffer number")
        return
      end

      vim.api.nvim_buf_set_keymap(jq_buffer, "n", "<CR>", "", {
        noremap = true,
        callback = function()
          do_jq(tab_id)
        end,
      })
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = "*.json",
  group = jq_group,
  callback = function(opts)
    vim.api.nvim_buf_set_keymap(opts.buf, "n", "<leader>jq", "", {
      noremap = true,
      callback = function()
        setup_windows(opts.buf, {
          new_tab = true,
        })
      end,
    })
  end,
})

local M = {}

M.setup_windows = setup_windows
M.do_jq = do_jq

return M
