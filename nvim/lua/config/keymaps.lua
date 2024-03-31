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

-- Basically "middle scrolloff" all of these things
vim.keymap.set("n", "j", function()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = vim.api.nvim_win_get_height(0)
  local half = math.floor(lines / 2)

  local is_lower_than_middle = row >= half

  if is_lower_than_middle then
    vim.cmd("normal! zz")
  end

  vim.o.scrolloff = half

  vim.cmd("normal! j")
end, { desc = "Keep the cursor in the middle when scrolling down" })

vim.keymap.set("n", "k", function()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = vim.api.nvim_win_get_height(0)
  local half = math.floor(lines / 2)

  local is_higher_than_middle = row < half

  if is_higher_than_middle then
    vim.cmd("normal! zz")
  end

  vim.o.scrolloff = half

  vim.cmd("normal! k")
end, { desc = "Keep the cursor in the middle when scrolling up" })

vim.keymap.set("n", "n", "nzz", { desc = "Keep the cursor in the middle when searching next" })
vim.keymap.set("n", "N", "Nzz", { desc = "Keep the cursor in the middle when searching previous" })
vim.keymap.set("n", "G", "Gzz", { desc = "Keep the cursor in the middle when going to the bottom of the file" })
