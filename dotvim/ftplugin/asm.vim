set hidden
nmap <buffer> <C-]> gd
" We only want the whitespace-fixing lints...we don't want the others
let b:ale_linters_explicit = 1

nmap <buffer> <silent> K <Plug>(lcn-hover)
vmap <buffer> <silent> K <Plug>(lcn-hover)
nmap <buffer> <silent> <Leader>K <Plug>(lcn-menu)
vmap <buffer> <silent> <Leader>K <Plug>(lcn-menu)

nmap <buffer> <silent> gd <Plug>(lcn-definition)

nmap <buffer> <silent> <Leader>/s <Plug>(lcn-rename)
nmap <buffer> <silent> <Leader>/* <Plug>(lcn-references)
