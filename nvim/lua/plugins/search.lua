local find_files = require("telescope.builtin").find_files
local live_grep = require("jh.telescope.multi_rg")
local git_merge_conflicts = require("jh.telescope.git_merge_conflicts")
local git_diff_merge_head = require("jh.telescope.git_diff_merge_head")

return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      {
        "<leader>fg",
        function()
          vim.api.nvim_input(vim.g.mapleader .. "sg")
        end,
        { desc = "Live grep" },
      },
    },
  },
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
      { "<leader>fGb", git_diff_merge_head, { desc = "Diff merge head" } },
      { "<leader>sGb", git_diff_merge_head, { desc = "Diff merge head" } },
    },
  },
}
