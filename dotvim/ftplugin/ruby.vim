" NeoCompleteLock

set shiftwidth=4
set nowrap
set omnifunc=rubycomplete#Complete

" Allow Ruby functions ending with ? or ! to be found as tags by Vim (ctags) "
set iskeyword+=?
set iskeyword+=!
" "

nnoremap <buffer> <Leader>r :w<CR>:!ruby %<CR>
nnoremap <buffer> <Leader>T :w<CR>:!rspec --color %<CR>
inoremap <buffer> <C-J><C-J> <Space>=><Space>
" xmpfilter
nmap <buffer> <Leader>gm <Plug>(xmpfilter-mark)
nmap <buffer> <Leader>GM <Plug>(xmpfilter-run)
nmap <buffer> <Leader>R <Plug>(xmpfilter-mark)<Plug>(xmpfilter-run)
xmap <buffer> <Leader>gm <Plug>(xmpfilter-mark)
xmap <buffer> <Leader>GM <Plug>(xmpfilter-run)
xmap <buffer> <Leader>R <Plug>(xmpfilter-mark)<Plug>(xmpfilter-run)
runtime macros/matchit.vim

" yardoc formatting
highlight link yardGenericTag rubyInstanceVariable
highlight link yardReturn rubyControl
