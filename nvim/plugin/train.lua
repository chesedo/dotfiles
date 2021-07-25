-- Automatically Trigger Train when idle for 10 seconds
vim.api.nvim_command [[ augroup auto_show_train ]]
vim.api.nvim_command [[ au! ]]
vim.api.nvim_command [[ setlocal updatetime=10000 ]]
vim.api.nvim_command [[ autocmd CursorHold * if &l:buftype !=# 'help' | :exec 'TrainTextObj' | endif ]]
vim.api.nvim_command [[ augroup end ]]
