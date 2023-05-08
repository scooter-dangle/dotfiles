" Title: Abbreviation expansions
" Author: Michael Geddes <michael at frog dot wheelycreek dot net>
" Version: 0.1.1
"
" This was created at the request of Marsha Gilliland for her work doing
" Medical Transcription.
"
" As such, if you add an abbreviation such as   wrt=with respect to
" then a corresponding abbreviation Wrt=With respect to is also created.
"
" Usage: 
" :Myabbrev {abbrev} {expanded}
" Add an abbreviation of {lhs} to {expanded}
" use ;; to expand an abbreviation that does not already exist... eg:
" typing..
"    mrg ;;
" will prompt for the abbreviation, and then replace mrg with whatever is
" typed... as well as adding it to the persistent list for future.
"
" g:abbrevlist_filename   This is where the abbreviations are stored.
"
" g:abbrevpunctuationslist_filename   This is where possible preceding
" punctuations are stored. So far, it needs to be manually opened up to be
" edited. (i.e. There is no means in this script for adding new punctuation
" sequences with a tidy command like :Myabbrev .)
"

if ! exists('g:abbrevlist_filename')
  let g:abbrevlist_filename='~/.vim/abbrevs.txt'
endif

" The following is the supplementary file where each line is a combination of
" punctuation that could potentially precede a single-character abbreviation.
if ! exists('g:abbrevpunctuationslist_filename')
  let g:abbrevlistpunctuations_filename='~/.vim/abbrevspunctuations.txt'
endif

" I’m not experienced enough to know whether pulling out this one line into
" its own function is bad practice or not. I was considering, however,
" having s:AddAbbrevWithPunctuation call s:AddAbbrev, but that seemed to
" require far more resources than just running the iabb command itself. At
" that, I thought separating out the iabb line into something like
" s:AddAbbrevSimple might help a reader see that the two different functions
" have that key line/function in common.
fun! s:AddAbbrevSimple(lhs, rhs)
  exe 'iabbrev '.a:lhs.' '.a:rhs
"  The following 2 lines fix a problem but slow vim startup way too much.
"  exe 'iabbrev '.a:lhs.'!'.' '.a:rhs.'!'
"  exe 'iabbrev '.a:lhs.'?'.' '.a:rhs.'?'
endfun
"
fun! s:AddAbbrev(lhs, rhs)
  call s:AddAbbrevSimple(a:lhs, a:rhs)
  call s:AddAbbrevSimple('X'.a:lhs, a:lhs)
  if len(a:lhs)==1
    call s:AddAbbrevWithPunctuation(a:lhs, a:rhs)
  endif
  if a:lhs =~# '^[a-z]' && a:rhs =~# '^[a-z]'
    let lhs=substitute(a:lhs, '.*', '\u&','')
    let rhs=substitute(a:rhs, '.*', '\u&','')
    call s:AddAbbrevSimple(lhs, rhs)
    call s:AddAbbrevSimple('x'.lhs, lhs)
    if len(a:lhs)==1
      call s:AddAbbrevWithPunctuation(lhs, rhs)
    endif
  endif
endfun

fun! s:AddAbbrevWithPunctuation(lhs, rhs)
  for line in readfile(expand(g:abbrevlistpunctuations_filename))
    let lhs=line.a:lhs
    let rhs=line.a:rhs
    call s:AddAbbrevSimple(lhs, rhs)
  endfor
endfun

fun! s:LoadAbbrevs(filename)
  for line in readfile(a:filename)
    let lhs=matchstr(line, '^\s*\zs\k\+\>')
    let rhs=matchstr(line, '^\k\+\>\s\+\zs.\{-}\ze\s*$')
    if lhs !~ '^\s*$' && rhs !~ '^\s*$'
      call s:AddAbbrev(lhs,rhs)
    endif
  endfor
endfun

fun! s:AddAbbrevFile(filename, lhs, rhs)
  exe 'redir >> '.a:filename
  silent echo a:lhs a:rhs
  redir END
  call s:AddAbbrev(a:lhs,a:rhs)
endfun

fun! s:AddMyAbbrev(myab)
  let lhs=matchstr(a:myab,'^\S\+')
  let rhs=matchstr(a:myab,'^\S\+\s\+\zs.\{-}\ze\s*$')
  if rhs =~ '^\s*$'
    echoerr 'Supply abbreviation and expanded text'
  else
    if lhs == '.'
      let lhs=expand('<cword>')
      if lhs == ''
        echoerr 'No word under cursor'
        return
      endif
    endif
    call s:AddAbbrevFile(expand(g:abbrevlist_filename),lhs,rhs)
  endif
endfun

" use Myabbrev {lhs} {rhs} to add an abbreviation
com! -nargs=+ Myabbrev call s:AddMyAbbrev(<q-args>)

" Used by ;; abbreviation to trigger adding an abbreviation
fun! s:InputAbbrev(abblen)
  " Gobble the character
  let ch=nr2char(getchar())
  let c=col('.')-(2+a:abblen)
  let line=getline('.')
  " Find the end
  while c > 0 
    if line[c] =~ '\k' | break | endif
    let c-=1
  endwhile
  " Find the start
  let b=c-1
  while b>=0
    if line[b] !~ '\k' | break | endif
    let b -= 1
  endwhile
  let lhs = line[b+1:c]
  " Prompt for the expansion
  let rhs=input(lhs.' expands to>')
  if rhs==''
    return (ch == ' ')?'':ch
  else
    call s:AddAbbrevFile(expand(g:abbrevlist_filename),lhs,rhs)
    return repeat("\<BS>",(col('.')-b)-(2+a:abblen)).rhs.ch
  endif
endfun
"
" If the abbreviation is not recognized - use ;; to trigger to prompt for the
" required expansion.
iabbrev <expr> ;; <SID>InputAbbrev(2)

if filereadable(expand(g:abbrevlist_filename))
  " Load the file if it exists
  call s:LoadAbbrevs(expand(g:abbrevlist_filename))
else
  echo 'Loading defaults'
  " This is an example of usage - and sets up the defaults.
"  Myab tp the patient
"  Myab lac lungs are clear
"  Myab hir heart is regular
"  Myab IMP IMPRESSION:
"  Myab CC CHIEF COMPLAINT:
"  Myab HPI HISTORY OF PRESENT ILLNESS:
"  Myab CM CURRENT MEDICATIONS:
"  Myab ALS ALLERGIES:
"  Myab PMH PAST MEDICAL HISTORY
"  Myab SH SOCIAL HISTORY:
"  Myab FH FAMILY HISTORY:
"  Myab ROS REVIEW OF SYSTEMS:
"  Myab PX PHYSICAL EXAMINATION:
"  Myab IMP IMPRESSION:
"  Myab PL PLAN:
endif

" vim: sw=2 sts=2 et
