local function remap_by(mode)
  return function(lhs, rhs, opts)
    opts = opts or {}
    local options = { noremap = true }

    if opts then
      options = vim.tbl_extend("force", options, opts)
    end

    local keymap = {}
    if type(options.bufnr) ~= 'number' then
      keymap.get = vim.api.nvim_get_keymap
      keymap.set = vim.api.nvim_set_keymap
      keymap.del = vim.api.nvim_del_keymap
    else
      local bufnr = options.bufnr
      keymap.get = function(...) vim.api.nvim_buf_get_keymap(bufnr, ...) end
      keymap.set = function(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      keymap.del = function(...) vim.api.nvim_buf_del_keymap(bufnr, ...) end
    end

    local mode_remaps = keymap.get(mode)
    local existing_remap = table.find_by(mode_remaps or {}, function (remap)
      return remap.lhs == string.gsub(lhs, '<leader>', vim.g.mapleader)
    end)

    if not opts.override and existing_remap then
      vim.print({
        desc = "Remap found for LHS when 'override' option not specified. Remap skipped.",
        mode = mode,
        lhs = lhs,
        rhs_of_attempted_remap = rhs,
        rhs_of_existing = existing_remap.rhs
      })
      return
    end

    if existing_remap then
      keymap.del(mode, lhs)
    end

    options.override = nil
    options.bufnr = nil

    if type(rhs) == 'string' then
      keymap.set(mode, lhs, rhs, options)
    else
      options.callback = rhs
      keymap.set(mode, lhs, '', options)
    end
  end
end

local modes = { 'n', 'x', 'o', 'l', 's', 'v', 'i', 't', 'c' }

local keymap = {
  unmap_all = function()
    for _, mode in ipairs(modes) do
      local mode_remaps = vim.api.nvim_get_keymap(mode)
      for _, mode_remap in ipairs(mode_remaps) do
        -- 'christoomey/vim-tmux-navigator' has mappings that have a mode of " ".
        -- This breaks when passed to `nvim_del_keymap`.
        if table.contains(modes, mode_remap.mode) then
          vim.api.nvim_del_keymap(mode_remap.mode, mode_remap.lhs)
        end
      end
    end
  end
}

for _, mode in ipairs(modes) do
  local handler = remap_by(mode)
  local old_key = mode .. 'noremap'
  keymap[mode] = handler
  keymap[old_key] = handler
end

return keymap
