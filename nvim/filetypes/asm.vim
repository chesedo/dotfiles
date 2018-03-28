" Build file
nnoremap <leader>b :!nasm -f bin % -o %:r.com -l %:r.lst<cr>

" Do some column highlighting for alignment
set formatoptions-=t
let &l:textwidth=60

let &l:colorcolumn="+1"
highlight ColorColumn ctermbg=24

highlight Cols ctermbg=8
match Cols /\%18v\|\%24v/

" Convert to comment
map <leader>h :center0r;llvwhhr-A 60A-59d\|
" Remove comment
map <leader>H 0dex$dbxx
