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
function gd; git diff -b --color --ignore-all-space $argv; end
function gl; git log $argv; end
function gb; git branch $argv; end
function gp; git pull $argv; end
function GP; git push $argv; end

function gh; git clone "https://github.com/$argv[1]/$argv[2].git"; end

function vv; vim . $argv; end
function vimp -d "Run vim with project.vim enabled"; vim --cmd "let bundle_project_dot_vim = 1" $argv; end

function pp; pygmentize $argv; end

function s -d "Find the given argument in any file within the current directory or its subdirectories";  grep $argv -RIin .; or echo $argv[1] not found; end
function l -d "Grab a particular line from file or pipe"; head -n $argv[1] | tail -n 1; end
function md;  mkdir $argv[1]; and cd $argv[1]; end

function composer -d "php package manager"; php ~/emoxie/composer.phar $argv; end
function phpdoc_gen -d "Run phpdoc in current directory"; phpdoc -d . -t docs; end

function rspecall; rspec $argv; and rspec1.8 $argv; and rspec2.1; and jrspec1.9 $argv; and jrspec1.8 $argv; and rbx -X1.9 (which rspec) $argv;  and rbx -X1.8 (which rspec) $argv; end
function mruby; ~/ruby/mruby/bin/mruby $argv; end
function mirb; ~/ruby/mruby/bin/mirb $argv; end
function mrbc; ~/ruby/mruby/bin/mrbc $argv; end
function rbx; ~/.rbx/usr/bin/rbx $argv; end
function rbx1.9; ~/.rbx/usr/bin/rbx -X1.9 $argv; end
function rspec1.8; ruby1.8 (which rspec) $argv; end
function rspec2.1; ruby2.1 (which rspec) $argv; end
function irb2.1; ruby2.1 (which irb) $argv; end
function jruby; ~/.jruby-1.7.4/bin/jruby $argv; end
function jruby1.9; ~/.jruby-1.7.4/bin/jruby --1.9 $argv; end
function jrspec; jruby (which rspec) $argv; end
function jrspec1.8; jruby --1.8 (which rspec) $argv; end
function jrspec1.9; jruby --1.9 (which rspec) $argv; end
function topaz; ~/.topaz/bin/topaz $argv; end

function parallel -d "Provide POSIX shell to Gnu parallel"; set -lx SHELL bash; command parallel $argv; end

function img -d "Fake Erlang image parser"; cd ~/erlang/img; escript img_parse.escript $argv; bk; end

function f -d "Find files with the given argument in their name in the current directory or its subdirectories"; find . $argv[1] 2> /dev/null | grep -i $argv[1]"[^/]*\$"; end

function blerg; echo blerg $argv[1] ferg snerg; end

function lsusers -d "List all users"; cat /etc/passwd; end

function tmux_launch; if test (tmux ls); tmux -2 attach; else; tmux -2; end; end

function xcape -d "Run xcape keymappings"; ~/xcape/xcape -e 'Alt_L=Control_L|S'; ~/xcape/xcape -e 'Control_L=Escape'; end
