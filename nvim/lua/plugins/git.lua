return {
  {
    "APZelos/blamer.nvim",
    cond = function()
      return not vim.g.started_by_firenvim
    end,
    dependencies = {
      {
        "glacambre/firenvim",
      },
    },
  },
}
