local dap = require('dap')

vim.api.nvim_set_keymap('n', '<leader>dc', [[<cmd>lua require('dap').continue()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>db', [[<cmd>lua require('dap').toggle_breakpoint()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>do', [[<cmd>lua require('dap').step_over()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>di', [[<cmd>lua require('dap').step_into()<CR>]], { noremap = true, silent = true })

-- Go setup
dap.adapters.go = function(callback, config)
  local stdout = vim.loop.new_pipe(false)
  local handle
  local pid_or_err
  local port = 38697
  local opts = {
    stdio = {nil, stdout},
    args = {"dap", "-l", "127.0.0.1:" .. port},
    detached = true
  }
  handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
    stdout:close()
    handle:close()
    if code ~= 0 then
      print('dlv exited with code', code)
    end
  end)
  assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
  stdout:read_start(function(err, chunk)
    assert(not err, err)
    if chunk then
      vim.schedule(function()
        require('dap.repl').append(chunk)
      end)
    end
  end)
  -- Wait for delve to start
  vim.defer_fn(
  function()
    callback({type = "server", host = "127.0.0.1", port = port})
  end,
  100)
end
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "go",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "go",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "go",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

dap.adapters.lldb = {
  type = 'executable',
  command = '/nix/store/5zjg5jw821grfvfnkyika9lxqy8ndcqy-lldb-13.0.0/bin/lldb-vscode', -- adjust as needed
  -- command = '/usr/bin/env lldb-vscode', -- adjust as needed
  name = "lldb"
}
dap.configurations.rust = {
    {
        type = 'lldb',
        name = 'Debug',
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/' .. '')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        initCommand = {},
        runInTerminal = false
    }
}
