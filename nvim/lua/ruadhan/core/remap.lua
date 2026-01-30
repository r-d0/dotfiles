vim.g.mapleader = " "
vim.keymap.set("n","<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<Tab>", "gt")
vim.keymap.set("n", "<S-Tab>", "gT")

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.api.nvim_set_keymap("t", "<Tab>", "<C-\\><C-n>gt", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<S-Tab>", "<C-\\><C-n>gT", { noremap = true, silent = true })
