set shiftwidth=4
set nowrap
set omnifunc=coffeecomplete#Complete
nnoremap <buffer> <Leader>r :w<CR>:!coffee %<CR>
nnoremap <buffer> <Leader>P :w<CR>:!coffee --print %<CR>
nnoremap <buffer> <Leader>C :w<CR>:!coffee --compile %<CR>

