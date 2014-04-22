# vim: filetype=sh

# Tip from M Subelsky:
set -u aliases ~/.config/fish/aliases.fish
function ea; vim $aliases; and . $aliases; end
function ag; if test (grep -l "function "$argv[1] $aliases); set target "function "$argv[1]; else; set target "$argv[1]"; end; grep $target $aliases ^ /dev/null | pp_fish_aliases | pygmenter | highlight $target; end

function al; pp_fish_aliases $aliases | pygmenter | more; end

# helper
function pp_fish_aliases; sed -ue "s/\([^)]\);\s*/\1\n/g" $argv[1] | fish_indent; end
# helper
function prettify_aliases --description "Prettifies contents of aliases.fish"; pp_fish_aliases $aliases > $aliases; end
# helper
# Still under construction
function uglify_aliases --description "Uglifies contents of aliases.fish"; end
# helper
function pygmenter --description "Runs argument through pygmentize -lbash only if pygmentize can be found"; if test (which pygmentize); pygmentize -lbash $argv[1]; else; cat $argv[1]; end; end
# helper
function highlight; while read line; if test (echo $line | grep -l "$argv[1]" ^ /dev/null); echo $line | grep "$argv[1]"; else; echo $line; end; end; end

function up; cd ..; end
function bk; cd - ; end
function hm; cd ~ ; end

function la; ls --almost-all --human-readable -l --group-directories-first --classify $argv; end

function bx; bundle exec $argv; end
function rsh; pry --require rake; end

function gs; git status -s $argv; end
function gd; git diff -b --color --ignore-all-space $argv; end
function gl; git log $argv; end
function gb; git branch $argv; end
function gp; git pull $argv; end
function GP; git push $argv; end
function gsolt --description "Default git push for minor tweak for soluteandsolvent.com subdomain"; git commit --all --message $argv; and git push origin master; and git push dokku master; end

function cne; crontab -e; end

function where --description "Get the directory of an executable"; dirname (which $argv[1]); end

function gh; git clone "https://github.com/$argv[1]/$argv[2].git"; end
function ghcd; git clone "https://github.com/$argv[1]/$argv[2].git"; and cd $argv[2]; end

function vv; vim . $argv; end
function vimp --description "Run vim with project.vim enabled"; vim --cmd "let bundle_project_dot_vim = 1" $argv; end

function pp; pygmentize $argv; end

function s --description "Find the given argument in any file within the current directory or its subdirectories";  grep $argv -RIin .; or echo $argv[1] not found; end
function l --description "Grab a particular line from file or pipe"; paj 1 $argv[1]; end
function paj --description "Paginate result chunk"; set increment $argv[1]; set chunk $argv[2]; set startIndex (math "("$chunk" + 1) *"$increment); head -n $startIndex | tail -n $increment; end
function md;  mkdir --parents $argv[1]; and cd $argv[1]; end

function psfind --description "Search for processes with a given string"; ps aux | grep $argv[1] | grep grep --invert-match; end

function composer --description "php package manager"; php ~/emoxie/composer.phar $argv; end
function phpdoc_gen --description "Run phpdoc in current directory"; phpdoc -d . -t docs; end

function rspecall; rspec $argv; and rspec1.8 $argv; and rspec2.1; and jrspec1.9 $argv; and jrspec1.8 $argv; and rbx -X1.9 (which rspec) $argv;  and rbx -X1.8 (which rspec) $argv; end
function mruby; ~/ruby/mruby/bin/mruby $argv; end
function mirb; ~/ruby/mruby/bin/mirb $argv; end
function mrbc; ~/ruby/mruby/bin/mrbc $argv; end
function rbx; ~/ruby/rubinius/bin/rbx $argv; end
function rbx1.9; ~/ruby/rubinius/bin/rbx -X1.9 $argv; end
function rspec1.8; ruby1.8 (which rspec) $argv; end
function rspec2.1; ruby2.1 (which rspec) $argv; end
function irb2.1; ruby2.1 (which irb) $argv; end
function jruby; ~/.jruby-1.7.4/bin/jruby $argv; end
function jruby1.9; ~/.jruby-1.7.4/bin/jruby --1.9 $argv; end
function jrspec; jruby (which rspec) $argv; end
function jrspec1.8; jruby --1.8 (which rspec) $argv; end
function jrspec1.9; jruby --1.9 (which rspec) $argv; end
function topaz; ~/.topaz/bin/topaz $argv; end

function bundle-bootstrap; bundle install --shebang (which ruby) --binstubs=.bundle/bin --path .bundle/gems; end

function parallel --description "Provide POSIX shell to Gnu parallel"; set -lx SHELL bash; command parallel $argv; end

function podders --description "Run Hpodder with necessary intermediate shell steps"; set current_dir (pwd); hpodder update; cd ~/.hpodder; ruby update_auth.rb; cd $current_dir; hpodder download; end

function mmc --description "Mercury Compiler, version 14.01"; ~/.mercury/scripts/mmc $argv; end

function img --description "Fake Erlang image parser"; set current_dir (pwd); bk; set prev_dir (pwd); cd ~/erlang/voroni; ./img.escript $argv; cd $prev_dir; cd $current_dir; end

function f --description "Find files with the given argument in their name in the current directory or its subdirectories"; find . $argv[1] 2> /dev/null | grep -i $argv[1]"[^/]*\$"; end

function blerg; echo blerg $argv[1] ferg snerg; end

function lsusers --description "List all users"; cat /etc/passwd; end

function tm; if test (tmux ls); tmux -2 attach; else; tmux -2; end; end

function xcape --description "Run xcape keymappings"; ~/apps/xcape/xcape -e 'Alt_L=Control_L|S'; ~/apps/xcape/xcape -e 'Control_L=Escape'; end
