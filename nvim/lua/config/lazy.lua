local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local function build_spec()
  local base_spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  }

  local extra_plugins = vim.tbl_map(function(plugin)
    return { import = "lazyvim.plugins.extras." .. plugin }
  end, {
    "coding.copilot",
    "lang.typescript",
    "formatting.prettier",
    "lang.json",
    "lang.docker",
    "lang.markdown",
    "lang.rust",
    "lang.terraform",
    "lang.yaml",
    "linting.eslint",
    "lsp.none-ls",
    "test.core",
    "ui.edgy",
    "util.project",
    "vscode",
  })

  -- import any extras modules here
  for _, plugin in ipairs(extra_plugins) do
    table.insert(base_spec, plugin)
  end

  -- import/override with your plugins

  table.insert(base_spec, { import = "plugins" })

  return base_spec
end

require("lazy").setup({
  spec = build_spec(),
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { missing = true, colorscheme = { "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
