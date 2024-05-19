local Util = require("../util")
local a = require("plenary.async")

local conf = require("telescope.config").values
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

local special_branches = {
  "develop",
  "master",
  "main",
}

local has_matching_branch_name = function(branches, branch_name)
  return Util.tbl_some(function(branch)
    return vim.endswith(branch_name, branch)
  end, branches)
end

local get_branches = function()
  local all_branches = vim.fn.systemlist("git branch --all")

  local branches = vim.tbl_filter(function(branch)
    return not has_matching_branch_name(special_branches, branch)
  end, all_branches)

  return vim.list_extend(
    vim.tbl_filter(function(branch)
      return has_matching_branch_name(all_branches, branch)
    end, special_branches),
    branches
  )
end

local pick_branch = function(opts, branches)
  local tx, rx = a.control.channel.oneshot()

  pickers
    .new(opts, {
      prompt_title = "Pick a branch",
      finder = finders.new_table(branches),
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          a.run(function()
            tx(selection)
          end)
        end)
        return true
      end,
    })
    :find()

  return rx()
end

local git_diff_merge_head = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  local branches = get_branches()

  if not branches or #branches == 0 then
    return
  end

  opts.merge_head = opts.merge_head or pick_branch(opts, branches)

  vim.print(opts.merge_head)
  local finder = finders.new_async_job({
    command_generator = function()
      return { "git", "diff", "--name-only", opts.merge_head }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      finder = finder,
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

return git_diff_merge_head
