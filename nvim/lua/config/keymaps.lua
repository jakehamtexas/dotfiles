-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- The best keymap ever
vim.keymap.set(
  "v",
  "<leader>p",
  '"_dP',
  { desc = "Delete selected text into _ register and paste before cursor, i.e. replace the selected text" }
)

-- Clipboard
vim.keymap.set({ "v", "n" }, "<leader>mc", '"+y', { desc = "(m)ouse (c)opy" })
vim.keymap.set({ "v", "n" }, "<leader>mp", '"+p', { desc = "(m)ouse (p)aste" })

-- RegExp Magic mode
vim.keymap.set({ "n", "v" }, "/", "/\\v", { desc = "Make search very magic" })
vim.keymap.set("c", "%s/", "%smagic/", { desc = "Make replace very magic" })
vim.keymap.set("c", ">s/", ">smagic/", { desc = "Make replace very magic" })

-- CTRL+d/u niceness
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center the cursor when using CTRL+d" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center the cursor when using CTRL+u" })
