vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>c', '<cmd>lua require("rest-nvim").run()<CR>', { noremap=true, silent=true })
