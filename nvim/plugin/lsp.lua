local nvim_lsp = require('lspconfig')
local on_attach = require('lsp_on_attach')

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "gopls", "terraformls", "tsserver" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }
end

-- Manually setups for servers with custom config

-- LaTex
nvim_lsp.texlab.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    texlab = {
      auxDirectory = ".",
      bibtexFormatter = "texlab",
      build = {
        args = { "%f", "--synctex", "--keep-logs", "--keep-intermediates" },
        executable = "tectonic",
        forwardSearchAfter = true,
        onSave = true
      },
      chktex = {
        onEdit = false,
        onOpenAndSave = false
      },
      diagnosticsDelay = 300,
      formatterLineLength = 80,
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:0:%f", "%p" }
      },
      latexFormatter = "latexindent", -- texlab not implemented yet
      latexindent = {
        modifyLineBreaks = false
      }
    }
  }
}

-- Tailwindcss
nvim_lsp.tailwindcss.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  cmd = { "yarn", "run", "tailwindcss-language-server", "--stdio" };
}

-- Lua

local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = "/usr/bin/lua-language-server"

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

nvim_lsp.sumneko_lua.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
