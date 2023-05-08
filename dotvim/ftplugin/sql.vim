" augroup dbextExtras
"     autocmd!
"     autocmd User dbextPreConnection :echo 'dbextPreConnection fired'
"     autocmd User dbextPreConnection :DBSetOption 'dbname=distil_development'
"     autocmd User dbextPreConnection :DBSetOption 'host=localhost'
"     autocmd User dbextPreConnection :DBSetOption 'type=pgsql'
"     autocmd User dbextPreConnection :DBSetOption 'user=scott'
"     autocmd User dbextPreConnection :DBSetOption 'passwd='
" augroup END
