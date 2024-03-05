return {
  {
    "mbbill/undotree",
    config = function() end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.tsserver.root_dir = function(...)
        return require("lspconfig.util").root_pattern(".git")(...)
      end
      return opts
    end,
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
  },
}
