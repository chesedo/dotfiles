" Lightline config
let g:lightline = {
\ 'colorscheme': 'wombat',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'readonly', 'filename', 'modified', 'syntastic' ] ]
\ },
\ 'component_function': {
\   'syntastic': 'SyntasticStatuslineFlag',
\ },
\}
