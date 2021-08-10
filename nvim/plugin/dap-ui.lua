require("dapui").setup()

vim.api.nvim_set_keymap('n', '<leader>dui', [[<cmd>lua require('dapui').toggle()<CR>]], { noremap = true, silent = true })
