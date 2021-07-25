-- Setup packer
return require('packer').startup(function()
  -- Load telescope for all files
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- LSP config
  use 'neovim/nvim-lspconfig'
end)
