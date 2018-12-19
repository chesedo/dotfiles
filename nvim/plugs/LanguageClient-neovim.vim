" LanguageClient-neovim configurations
let g:LanguageClient_serverCommands = {
\ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
\ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
\ }

noremap <F5> :call LanguageClient_contextMenu()<cr>
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
