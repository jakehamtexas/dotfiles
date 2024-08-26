local bin_by_cwd = {}

local log_level = vim.log.levels.WARN -- vim.log.levels.DEBUG

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
    "stevarch/conform.nvim",
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
      level = log_level,
      render = "minimal",
      stages = "static",
    },
  },
}
