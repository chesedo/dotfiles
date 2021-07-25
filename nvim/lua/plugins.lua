-- Setup packer
return require('packer').startup(function()
  -- Load telescope for all files
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- LSP related
  use 'neovim/nvim-lspconfig'
  use 'glepnir/lspsaga.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'hrsh7th/nvim-compe'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Theme
  use 'folke/tokyonight.nvim'
  use {'npxbr/gruvbox.nvim', requires = {'rktjmp/lush.nvim'}}
  use 'maaslalani/nordbuddy'

  use 'lewis6991/spellsitter.nvim'
end)
