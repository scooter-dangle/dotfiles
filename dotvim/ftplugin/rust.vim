nnoremap <buffer> <Leader>r :RustRun<CR>
set hidden
set shiftwidth=4
" Not sure if RUST_SRC_PATH is needed anymore. Doesn't seem
" to be used.
let $RUST_SRC_PATH = expand("~/stuffs/rust/src")
let $CARGO_HOME = expand("~/.cargo")
" let RUST_SRC_PATH = expand("~/stuffs/rust/src")
" let CARGO_HOME = expand("~/.cargo")
" let g:racer_cmd = "/home/scott/.cargo/bin/racer"
nmap <buffer> <C-]> gd
" let g:racer_experimental_completer = 1
" let g:echodoc_enable_at_startup = 1

" Slows down saves "
" let g:syntastic_rust_rustc_exe = 'cargo check'
" let g:syntastic_rust_rustc_fname = ''
" let g:syntastic_rust_rustc_args = '--'
" let g:syntastic_rust_checkers = ['rustc']

" We only want the whitespace-fixing lints...we don't want the others
let b:ale_linters_explicit = 1

" nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
" vnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
nmap <buffer> <silent> K <Plug>(lcn-hover)
vmap <buffer> <silent> K <Plug>(lcn-hover)
nmap <buffer> <silent> <Leader>K <Plug>(lcn-menu)
vmap <buffer> <silent> <Leader>K <Plug>(lcn-menu)

" nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
nmap <buffer> <silent> gd <Plug>(lcn-definition)

" nnoremap <buffer> <silent> <Leader>/s :call LanguageClient#textDocument_rename()<CR>
nmap <buffer> <silent> <Leader>/s <Plug>(lcn-rename)
" nnoremap <buffer> <silent> <Leader>/* :call LanguageClient#textDocument_references()<CR>
nmap <buffer> <silent> <Leader>/* <Plug>(lcn-references)

" Not exactly working yet
" function! RustBreadCrumbs()
"   return luaeval("require('nvim-treesitter').statusline({ type_patterns = { 'impl', 'function' } })")
" endfunction
"
" call airline#parts#define('breadcrumbs', {'function': 'RustBreadCrumbs', 'accents': 'bold'})
"
" let g:airline_section_c .= airline#section#create(['breadcrumbs'])
let b:airline_rust_bread_crumbs = 1
