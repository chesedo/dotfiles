vim.api.nvim_set_keymap('n', '<C-b>', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>', [[<cmd>lua require('telescope.builtin').file_browser()<CR>]], { noremap = true, silent = true })

-- vim.api.nvim_set_keymap('n', '<C-f>', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], { noremap = true, silent = true })
