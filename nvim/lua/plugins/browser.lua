local firenvim_group = vim.api.nvim_create_augroup("Firenvim", { clear = true })
local profile_firenvim = false

return {
  {
    "glacambre/firenvim",
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      if profile_firenvim then
        vim.profile("firenvim")
      end

      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = firenvim_group,
        callback = function(e)
          if vim.g.timer_started == true then
            return
          end
          vim.g.timer_started = true
          vim.fn.timer_start(10000, function()
            vim.g.timer_started = false
            vim.cmd.write()
          end)
        end,
      })

      vim.api.nvim_create_autocmd("ExitPre", {
        group = firenvim_group,
        -- Close all buffers
        command = ":%bd",
      })
      local firenvim_config = {
        globalSettings = {
          alt = "all",
        },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "always",
          },
        },
      }
      local forbidden_domains = { ".*localhost.*", ".*safebase.io*", ".*linear.*", ".*notion.so*" }

      for _, value in ipairs(forbidden_domains) do
        firenvim_config.localSettings[value] = { takeover = "never", priority = 1 }
      end
      vim.g.firenvim_config = firenvim_config
    end,
  },
  {
    "AckslD/nvim-FeMaco.lua",
    config = function()
      require("femaco").setup({})
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    keys = {
      {
        "<leader>fe",
        function()
          require("femaco.edit").edit_code_block()
        end,
        { desc = "Open (f)enced code block edit buffer" },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
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
