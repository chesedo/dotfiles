require('lualine').setup{
  options = {
    theme = 'nord'
  },
  sections = {
    lualine_x = {
      { 'diagnostics', sources = {"nvim_lsp"}, symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '} },
      'encoding',
      'fileformat',
      'filetype',
    }
  }
}
