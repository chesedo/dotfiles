-- Map leader to space
vim.global.mapleader = ' '

-- My defaults
vim.opt.number = true          -- Show numbers in left column
vim.opt.relativenumber = true  -- Make numbers relative
vim.opt.mouse = 'n'            -- Enable mouse in normal mode

-- Idents
vim.opt.expandtab = true                -- Use space for tabs
vim.opt.shiftwidth = 2                  -- Indents for << and >>
-- vim.opt.softtabstop = vim.o.shiftwidth -- Space indent uses 2 spaces
vim.opt.tabstop = vim.o.shiftwidth      -- Tabs use 2 spaces

-- Bootstrap
require('bootstrap')

-- Load plugins and auto reload on changes
require('plugins')
vim.cmd([[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]])

