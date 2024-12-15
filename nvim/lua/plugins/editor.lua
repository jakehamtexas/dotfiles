local bin_by_cwd = {}

local log_level = vim.log.levels.WARN -- vim.log.levels.DEBUG

return {
  {
    "mbbill/undotree",
    config = function() end,
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        vtsls = {
          enabled = false,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters.prettier.command = function()
        local editor_cwd = vim.fn.getcwd()

        if bin_by_cwd[editor_cwd] == nil and bin_by_cwd[editor_cwd] ~= false then
          bin_by_cwd[editor_cwd] = false

          local handle, err = io.popen("yarn bin prettier")
          if handle and not err then
            local result = handle:read("*a"):gsub("\n", "")
            handle:close()

            -- If the bin is not executable, try to make it executable
            if result and vim.fn.executable(result) == 0 then
              os.execute("chmod +x " .. result)
            end

            if result and vim.fn.executable(result) == 1 then
              bin_by_cwd[editor_cwd] = result
            end
          end
        end

        return bin_by_cwd[editor_cwd] or require("conform.util").from_node_modules("prettier")
      end

      opts.log_level = log_level
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
      level = log_level,
      render = "minimal",
      stages = "static",
    },
  },
}
