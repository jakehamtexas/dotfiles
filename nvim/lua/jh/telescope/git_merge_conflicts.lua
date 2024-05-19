local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

local get_unmerged_files = function()
  return vim.fn.systemlist("git diff --diff-filter=U --name-only")
end

local git_merge_conflicts = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

  local unmerged_files = get_unmerged_files()

  if #unmerged_files == 0 then
    vim.notify("No unmerged files!")

    return
  end

  local finder = finders.new_async_job({
    command_generator = function()
      return vim.tbl_flatten({ { "rg", "--vimgrep", "<<<<<<<" }, unmerged_files })
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      prompt_title = "Git Merge Conflicts",
      finder = finder,
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

return git_merge_conflicts
