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
  -- Shellcheck
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "gbprod/none-ls-shellcheck.nvim",
    },
    opts = function(_, opts)
      opts.sources = vim.tbl_extend("force", opts.sources, {
        require("none-ls-shellcheck.diagnostics"),
        require("none-ls-shellcheck.code_actions"),
        require("null-ls.builtins.formatting.alejandra"),
        require("null-ls.builtins.code_actions.statix"),
        require("null-ls.builtins.diagnostics.statix"),
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
