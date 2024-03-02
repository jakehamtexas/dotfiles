local find_files = function()
  require("telescope.builtin").find_files()
end

local live_grep = function()
  require("telescope.builtin").live_grep()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>ff", find_files, { desc = "Find files" } },
      { "<leader>fF", false },
      { "<leader><leader>", find_files, { desc = "Find files" } },
      { "<leader>/", live_grep, { desc = "Live grep" } },
      { "<leader>fg", live_grep, { desc = "Live grep" } },
    },
  },
}
