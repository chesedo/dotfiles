" LanguageClient-neovim configurations
let g:LanguageClient_serverCommands = {
\ 'rust': ['rls'],
\ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
\ 'cpp': ['clangd'],
\ }

noremap <F5> :call LanguageClient_contextMenu()<cr>
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
