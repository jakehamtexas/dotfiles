local disabled_plugins = {
  "neo-tree.nvim",
  "flash.nvim",
  "dashboard-nvim",
  "mini.ai",
  "nvim-spectre",
  "mini.pairs",
  "mini.surround",
}

return vim.tbl_map(function(plugin)
  return { [1] = plugin, enabled = false }
end, disabled_plugins)
