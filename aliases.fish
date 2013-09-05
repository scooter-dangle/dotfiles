# vim: filetype=sh

# Tip from M Subelsky:
set -u aliases ~/.config/fish/aliases.fish
function ea; vim $aliases; and . $aliases; end
function ag; if test (grep -l "function "$argv[1] $aliases); set target "function "$argv[1]; else; set target "$argv[1]"; end; grep $target $aliases ^ /dev/null | pp_fish_aliases | pygmenter | highlight $target; end

function al; pp_fish_aliases $aliases | pygmenter | more; end

# helper
function pp_fish_aliases; sed -ue "s/\([^)]\);\s*/\1\n/g" $argv[1] | fish_indent; end
# helper
function prettify_aliases -d "Prettifies contents of aliases.fish"; pp_fish_aliases $aliases > $aliases; end
# helper
# Still under construction
function uglify_aliases -d "Uglifies contents of aliases.fish"; end
# helper
function pygmenter -d "Runs argument through pygmentize -lbash only if pygmentize can be found"; if test (which pygmentize); pygmentize -lbash $argv[1]; else; cat $argv[1]; end; end
# helper
function highlight; while read line; if test (echo $line | grep -l "$argv[1]" ^ /dev/null); echo $line | grep "$argv[1]"; else; echo $line; end; end; end

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

function gh; git clone "https://github.com/$argv[1]/$argv[2].git"; end

function vv; vim . $argv; end

function pp; pygmentize $argv; end

function s -d "Find the given argument in any file within the current directory or its subdirectories";  grep $argv -RIin .; or echo $argv[1] not found; end
function md;  mkdir $argv[1]; and cd $argv[1]; end


function rspecall; rspec $argv; and rspec1.8 $argv; and rspec2.0; and jrspec1.9 $argv; and jrspec1.8 $argv; and rbx -X1.9 (which rspec) $argv;  and rbx -X1.8 (which rspec) $argv; end
function mruby; ~/ruby/mruby/bin/mruby $argv; end
function rbx; ~/.rbx/usr/bin/rbx $argv; end
function rspec1.8; ruby1.8 (which rspec) $argv; end
function rspec2.0; ruby2.0 (which rspec) $argv; end
function irb2.0; ruby2.0 (which irb) $argv; end
function jruby; ~/.jruby-1.7.4/bin/jruby $argv; end
function jrspec; jruby (which rspec) $argv; end
function jrspec1.8; jruby --1.8 (which rspec) $argv; end
function jrspec1.9; jruby --1.9 (which rspec) $argv; end
function topaz; ~/.topaz/bin/topaz $argv; end

function f -d "Find files with the given argument in their name in the current directory or its subdirectories"; find . $argv[1] 2> /dev/null | grep -i $argv[1]"[^/]*\$"; end

function blerg; echo blerg $argv[1] ferg snerg; end

function tmux_launch; if test (tmux ls); tmux -2 attach; else; tmux -2; end; end
