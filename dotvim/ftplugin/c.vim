
" C compilation mappings "
nnoremap <Leader>1 :update<CR>:!gcc %:p -o %:p:r -lm -std=c99<CR>
nnoremap <Leader>2 :update<CR>:!gcc %:p -o %:p:r -lm -std=c99 && ./%:t:r<CR>
nnoremap <Leader>3 :!./%:t:r<CR>
" "

