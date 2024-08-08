-- Save file
vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-s>", "<C-o>:w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-s>", "<C-c>:w<CR>", { noremap = true, silent = true })
