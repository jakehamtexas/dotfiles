local previewers = require 'telescope.previewers'
local stdout_stderr_picker = require "pickers.stdout-stderr"
local pickers = {}

-- Git diff pickers
for _, branch in pairs({ "develop", "main" }) do
  local with_origin = "origin/" .. branch
  local picker = stdout_stderr_picker(
    {
      command = "git diff --name-only $(git merge-base HEAD " .. with_origin .. ")",
      name = "changed_files_" .. branch
    },
    {
      prompt_title = "Git Diff (" .. with_origin .. ")",
      previewer = previewers.git_file_diff.new({}),
    })

  if picker ~= nil then
    table.insert(pickers, picker)
  end
end

return pickers
