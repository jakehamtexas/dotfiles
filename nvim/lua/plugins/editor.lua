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
}
