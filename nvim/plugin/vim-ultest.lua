-- Test on every safe
-- vim.api.nvim_command [[ augroup UltestRunner ]]
-- vim.api.nvim_command [[ au! ]]
-- vim.api.nvim_command [[ au BufWritePost * UltestNearest ]]
-- vim.api.nvim_command [[ augroup end ]]

-- Setup builders
local builders = {
  ["go"] = function(cmd)
    return {
      dap = {
        type = "go",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
      }
    }
  end
}
require("ultest").setup({builders = builders})

-- Mappings
vim.api.nvim_set_keymap('n', '<leader>tt', '<cmd>Ultest<CR>', { noremap=true, silent=true })
vim.api.nvim_set_keymap('n', '<leader>tui', '<cmd>UltestSummary<CR>', { noremap=true, silent=true })
vim.api.nvim_set_keymap('n', '<leader>to', '<cmd>UltestOutput<CR>', { noremap=true, silent=true })
vim.api.nvim_set_keymap('n', '<leader>td', '<cmd>UltestDebugNearest<CR>', { noremap=true, silent=true })
