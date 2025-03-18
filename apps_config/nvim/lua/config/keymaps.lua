-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
map("i", "jj", "<Esc>", { noremap = true, silent = true })
map("i", "<C-f>", "<Right>", { noremap = true, silent = true })
map("i", "<C-b>", "<Left>", { noremap = true, silent = true })
map({ "i" }, "<C-a>", "<Esc>^i", { noremap = true, silent = true })
map({ "n", "v" }, "<C-a>", "^", { noremap = true, silent = true })
map({ "i", "n", "v" }, "<C-e>", "<End>", { noremap = true, silent = true })

map({ "n", "v" }, "y", '"+y', { noremap = true })
map("n", "<C-n>", ":nohlsearch<CR>", { noremap = true, silent = true })

vim.keymap.del({ "n", "v" }, "<leader>cf")
map("n", "<leader>lf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })
