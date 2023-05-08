set shiftwidth=4
set nowrap
nnoremap <buffer> <Leader>C :w<CR>:!haml --format html5 % %:t:r.html<CR>
