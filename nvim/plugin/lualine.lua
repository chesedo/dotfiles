local lualine_require = require 'lualine_require'
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}

-- Section is taken from https://github.com/nvim-lualine/lualine.nvim/blob/4231b63196a0dcc94e62e914d2b768ef31b5beb7/lua/lualine/components/diagnostics/config.lua
-- Get all the required colors
local colors = {
  error = {
    fg = modules.utils.extract_color_from_hllist(
    'fg',
    { 'DiagnosticError', 'LspDiagnosticsDefaultError', 'DiffDelete' },
    '#e32636'
    ),
  },
  warn = {
    fg = modules.utils.extract_color_from_hllist(
    'fg',
    { 'DiagnosticWarn', 'LspDiagnosticsDefaultWarning', 'DiffText' },
    '#ffa500'
    ),
  },
  info = {
    fg = modules.utils.extract_color_from_hllist(
    'fg',
    { 'DiagnosticInfo', 'LspDiagnosticsDefaultInformation', 'Normal' },
    '#ffffff'
    ),
  },
  hint = {
    fg = modules.utils.extract_color_from_hllist(
    'fg',
    { 'DiagnosticHint', 'LspDiagnosticsDefaultHint', 'DiffChange' },
    '#273faf'
    ),
  },
}

-- Section is taken from https://github.com/nvim-lualine/lualine.nvim/blob/4231b63196a0dcc94e62e914d2b768ef31b5beb7/lua/lualine/components/diagnostics/config.lua
local icons = {
  error = ' ', -- xf659
  warn = ' ', -- xf529
  info = ' ', -- xf7fc
  hint = ' ', -- xf835
}

-- Register theme to be able to create highlight groups next
modules.highlight.create_highlight_groups(require 'lualine.themes.nord')

-- Section is taken from https://github.com/nvim-lualine/lualine.nvim/blob/f4ab5b56dae695657cb15ae69e938038c0acfa62/lua/lualine/components/diagnostics/init.lua
-- self.section is the lualine section the global diagnostics will be in. Get it wrong and no coloring will work
local highlight_groups = {
  error = modules.highlight.create_component_highlight_group(
    colors.error,
    'diagnostics_error',
    { self = { section = 'lualine_b' } }

  ),
  warn = modules.highlight.create_component_highlight_group(
    colors.error,
    'diagnostics_warn',
    { self = { section = 'lualine_b' } }
  ),
  info = modules.highlight.create_component_highlight_group(
    colors.info,
    'diagnostics_info',
    { self = { section = 'lualine_b' } }
  ),
  hint = modules.highlight.create_component_highlight_group(
    colors.hint,
    'diagnostics_hint',
    { self = { section = 'lualine_b' } }
  ),
}

-- Helper function to format each line
local function diagnostic_renderer(result, key, count)
    if count > 0 then
        -- print("test")
        table.insert(result, string.format("%s%s%s", modules.highlight.component_format_highlight(highlight_groups[key]), icons[key], count))
    end
    print(vim.inspect(result))
end

-- Get diagnostic for all files
local function global_diagnostics()
  -- nil gets diagnostic info for all buffers
  local diagnostics = vim.diagnostic.get(nil)
  local count = {0, 0, 0, 0}
  local result = {}

  for _, diagnostic in ipairs(diagnostics) do
    count[diagnostic.severity] = count[diagnostic.severity] + 1
  end

  diagnostic_renderer(result, "error", count[vim.diagnostic.severity.ERROR])
  diagnostic_renderer(result, "warn", count[vim.diagnostic.severity.WARN])
  diagnostic_renderer(result, "info", count[vim.diagnostic.severity.INFO])
  diagnostic_renderer(result, "hint", count[vim.diagnostic.severity.HINT])

  return table.concat(result, ' ')
end

require('lualine').setup{
  options = {
    theme = 'nord'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  tabline = {
    lualine_a = {},
    lualine_b = {global_diagnostics},
    lualine_c = {'buffers'},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'branch'}
  }
}
