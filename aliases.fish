# vim: filetype=sh

# Tip from M Subelsky:
set -u aliases ~/.config/fish/aliases.fish
function ea; vim $aliases; and . $aliases; end
function ag; if test (grep "function "$argv[1] $aliases); set target "function "$argv[1]; else; set target $argv[1]; end; for line in (grep $target $aliases 2>/dev/null | pp_fish_aliases); echo $line | grep $target; or echo $line; end; end

# helper
function pp_fish_aliases; sed -ue "s/\([^)]\);\s*/\1\n/g" $argv[1] | fish_indent; end

# helper
function with_silent_errors; echo '2>/dev/null'; end

function up; cd ..; end
function bk; cd - ; end
function hm; cd ~ ; end

function bx; bundle exec $argv; end
function rsh; pry --require rake; end

function gs; git status -s $argv; end
function gd; git diff -b --color $argv; end
function gl; git log $argv; end
function gb; git branch $argv; end
function gp; git pull $argv; end
function GP; git push $argv; end


function s -d "Find the given argument in any file within the current directory or its subdirectories";  grep $argv[1] -Rin . | more; or echo $argv[1] not found; end
function md;  mkdir $argv[1]; and cd $argv[1]; end

function f -d "Find files with the given argument in their name in the current directory or its subdirectories"; find . $argv[1] 2> /dev/null | grep -i $argv[1]"[^/]*\$"; end

function blerg; echo blerg $argv[1] ferg snerg; end

function tmux_launch; if test (tmux ls); tmux -2 attach; else; tmux -2; end; end
