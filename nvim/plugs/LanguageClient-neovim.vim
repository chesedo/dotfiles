" LanguageClient-neovim configurations
let g:LanguageClient_serverCommands = {
\ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
\ }

noremap <F5> :call LanguageClient_contextMenu()<cr>
