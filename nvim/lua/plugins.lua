-- Setup packer
return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

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

  -- GUI basics
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }
  use 'xiyaowong/nvim-cursorword'
  use 'lukas-reineke/indent-blankline.nvim'
  use {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup()
    end,
  }
  use {
    'norcalli/nvim-colorizer.lua',
    config = function ()
      require'colorizer'.setup()
    end,
  }

  -- REST requests
  use {
    'NTBBloodbath/rest.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Misc
  use {
    'blackCauldron7/surround.nvim',
    config = function()
      require 'surround'.setup {}
    end
  }


  -- Tmp
  use 'tjdevries/train.nvim'
end)
