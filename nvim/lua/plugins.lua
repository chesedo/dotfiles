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
  use 'tami5/lspsaga.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'hrsh7th/nvim-compe'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Theme
  use 'andersevenrud/nordic.nvim'

  use 'lewis6991/spellsitter.nvim'

  -- GUI basics
  use {
    'nvim-lualine/lualine.nvim',
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
      require 'colorizer'.setup()
    end,
  }
  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      require('gitsigns').setup()
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
      require 'surround'.setup{}
    end
  }
  use {
    'terrortylor/nvim-comment',
    config = function()
      require 'nvim_comment'.setup()
    end
  }
  use {
    "rcarriga/nvim-dap-ui",
    requires = {"mfussenegger/nvim-dap"}
  }

  -- For yuck syntax highlighting
  use "elkowar/yuck.vim"

  -- Tmp
  use 'tjdevries/train.nvim'
  use {
    'saecki/crates.nvim',
    tag = 'v0.1.0',
    requires = { 'nvim-lua/plenary.nvim' },
    event = { "BufRead Cargo.toml" },
    config = function()
        require('crates').setup()

        vim.api.nvim_set_keymap('n', 'K', [[<cmd>lua require('crates').show_popup()<CR>]], { noremap=true, silent=true })
    end,
  }
  use {
    'simrat39/rust-tools.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'mfussenegger/nvim-dap' },
    config = function()
        require('rust-tools').setup({
          server = {
            on_attach = require('lsp_on_attach')
          }
        })
    end,
  }
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup()
    end
  }
end)
