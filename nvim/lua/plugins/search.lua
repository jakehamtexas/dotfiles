local find_files = require("telescope.builtin").find_files
local live_grep = require("jh.telescope.multi_rg")
local git_merge_conflicts = require("jh.telescope.git_merge_conflicts")

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          hidden = true,
        },
      },
    },
    keys = {
      { "<leader>ff", find_files, { desc = "Find files" } },
      { "<leader>fF", false },
      { "<leader><leader>", find_files, { desc = "Find files" } },
      { "<leader>/", live_grep, { desc = "Live grep" } },
      { "<leader>fg", live_grep, { desc = "Live grep" } },
      { "<leader>fGu", git_merge_conflicts, { desc = "Git merge conflicts" } },
      { "<leader>sGu", git_merge_conflicts, { desc = "Git merge conflicts" } },
    },
  },
}
