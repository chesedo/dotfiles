vim.cmd[[colorscheme tokyonight]] -- Hack to get nordbuddy to load
require('nordbuddy').colorscheme {
  -- Underline style used for spelling
  -- Options: 'none', 'underline', 'undercurl'
  underline_option = 'undercurl',

  -- Italics for certain keywords such as constructors, functions,
  -- labels and namespaces
  italic = true,

  -- Italic styled comments
  italic_comments = true,

  -- Minimal mode: different choice of colors for Tabs and StatusLine
  minimal_mode = false
}

-- Keep background transparent
vim.cmd[[highlight Normal ctermbg=none guibg=none]]
