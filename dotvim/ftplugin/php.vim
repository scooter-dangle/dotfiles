set shiftwidth=4
set expandtab
set nowrap
nnoremap <buffer> <Leader>r :w<CR>:!php %<CR>
set omnifunc=phpcomplete#Complete
let php_sql_query = 1
let php_htmlInStrings = 1
let php_noShortTags = 1
inoremap <buffer> <C-J><C-J> <Space>=><Space>

" from http://www.slideshare.net/andreizm/vim-for-php-programmers-pdf "
nmap <silent> <buffer> <F4>
        \ :!ctags -f ./tags
        \ --langmap="php:+.inc"
        \ -h ".php.inc" -R --totals=yes
        \ --tag-relative=yes --PHP-kinds=+cf-v . <CR>
set tags=./tags,tags
