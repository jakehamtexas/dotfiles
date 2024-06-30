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
    "nvimtools/none-ls.nvim",
    dependencies = {
      "gbprod/none-ls-shellcheck.nvim",
    },
    opts = function(_, opts)
      opts.sources = vim.tbl_extend("force", opts.sources, {
        require("none-ls-shellcheck.diagnostics"),
        require("none-ls-shellcheck.code_actions"),
      })
    end,
  },
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>ZM", ":ZenMode<CR>" },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      level = 3,
      render = "minimal",
      stages = "static",
    },
  },
}
