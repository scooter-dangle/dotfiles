# Tip from M Subelsky:
set -u aliases ~/.config/fish/aliases.fish
function ea \
  --description "Edit Aliases (and then reload "$aliases")"
    vim $aliases
    and . $aliases
end

function ag_old
    if test (grep -l "function "$argv[1] $aliases)
        set target "function "$argv[1]
    else
        set target $argv[1]
    end
    grep $target $aliases ^ /dev/null \
    | pp_fish_aliases \
    | pygmenter \
    | highlight $target
end

function ag --argument-names target \
  --description "Aliases Grep"
    if test (grep -l "function "$target $aliases)
        set target "function "$target
    end
    set matching_lines (line_number_matches $target $aliases)
    func_blocks $matching_lines \
    | fish_indent \
    | pygmenter \
    | highlight $target
end

function line_number_matches --argument-names target target_file
    grep --line-number $target $target_file \
    | sed --regexp-extended 's/^([0-9]+):.*$/\1/g'
end

function func_blocks \
  --description "Output surrounding function blocks from "$aliases" from line numbers in argv"
    set func_start_lines (line_number_matches '^function ' $aliases)
    set func_end_lines   (line_number_matches '^end'       $aliases)

    set out_start_lines
    set out_end_lines

    set total_matches (count $argv)
    set i 1
    set total_functions (count $func_start_lines)
    set n 1
    while begin test $n -le $total_functions
            and test $i -le $total_matches
          end
        if  begin test $argv[$i] -ge $func_start_lines[$n]
              and test $argv[$i] -lt $func_end_lines[$n]
            end
            set next_index (increment (count $out_start_lines))
            set out_start_lines[$next_index] $func_start_lines[$n]
            set out_end_lines[$next_index]   $func_end_lines[$n]
            set i (increment $i)

            # Eat up additional grep matches for $target
            # from the current function block (i.e., move on
            # from any further grepped matches in this current
            # function...we already marked this block for output)
            while begin test $i -le $total_matches
                    and test $argv[$i] -ge $out_start_lines[-1]
                    and test $argv[$i] -lt $out_end_lines[-1]
                  end
                set i (increment $i)
            end
        end
        set n (increment $n)
    end

    set total_results (count $out_start_lines)
    set m 1
    while test $m -le $total_results
        cat $aliases \
        |   head -n $out_end_lines[$m] \
        |   tail -n (increment (math $out_end_lines[$m]" - "$out_start_lines[$m]))
        set m (increment $m)
    end
    return 0
end

function increment --argument-names i
    math $i" + 1"
end

function al
    pp_fish_aliases $aliases \
    | pygmenter \
    | more
end

function pp_fish_aliases --argument-names target
    # helper
    sed -ue "s/\([^)]\);\s*/\1\n/g" $target \
    | fish_indent
end

function prettify_aliases \
  --description "Prettifies contents of aliases.fish"
    # helper
    pp_fish_aliases $aliases >  $aliases
end

function pygmenter --argument-names target \
  --description "Runs argument through pygmentize -lbash only if pygmentize can be found"
    # helper
    if test (which pygmentize)
        pygmentize -lbash $target
    else
        cat $target
    end
end

function highlight --argument-names target
    # helper
    while read line
        if test (echo $line | grep -l $target ^ /dev/null)
            echo $line \
            | grep $target
        else
            echo $line
        end
    end
    return 0
end

function up
    cd ..
end
function bk
    cd -
end
function hm
    cd ~
end

function qcount \
  --description "Quiet count. Use exit status without printing"
    count $argv >  /dev/null
end

function la
    ls --almost-all --human-readable -l --group-directories-first --classify $argv
end

function bx
    bundle exec $argv
end
function rsh
    pry --require rake
end

function gs
    git status -s $argv
end
function gd
    git diff -b --color --ignore-all-space $argv
end
function gl
    git log $argv
end
function gb
    git branch $argv
end
function gp
    git pull $argv
end
function GP
    git push $argv
end
function gsolt \
  --description "Default git push for minor tweak for soluteandsolvent.com subdomain"
    git commit --all --message $argv
    and git push origin master
    and git push dokku master
end

function cne
    crontab -e
end

function where --argument-names target \
  --description "Get the directory of an executable"
    dirname (which $target)
end

function gh --argument-names user repo
    git clone "https://github.com/$user/$repo.git"
end

function ghcd \
  --argument-names user repo
    git clone "https://github.com/$user/$repo.git"
    and cd $repo
end

function vv
    vim . $argv
end

function vimp \
  --description "Run vim with project.vim enabled"
    # Note: Requires project.vim as well as code in vimrc to look
    # for bundle_project_dot_vim variable
    vim --cmd "let bundle_project_dot_vim = 1" $argv
end

function pp
    pygmentize $argv
end

function s \
  --description "Find the given argument in any file within the current directory or its subdirectories"
    grep $argv -RIin .
    or echo $argv[1] not found
end

function l \
  --description "Grab a particular line from file or pipe" \
  --argument-names target
    paj 1 $target
end
function paj \
  --description "Paginate result chunk" \
  --argument-names increment chunk
    set startIndex (math "("$chunk" + 1) *"$increment)
    head -n $startIndex \
    | tail -n $increment
end
function md
    mkdir --parents $argv[1]
    and cd $argv[1]
end

function psfind \
  --description "Search for processes with a given string."
    ps -A \
    | grep $argv \
    | grep grep --invert-match
end

function justpid \
  --description "Extracts pid from psfind"
    sed --regexp-extended 's/^\s*([0-9]+)\s+.*$/\1/g'
end

function composer \
  --description "php package manager"
    php ~/emoxie/composer.phar $argv
end
function phpdoc_gen \
  --description "Run phpdoc in current directory"
    phpdoc -d . -t docs
end

function rspecall
    rspec $argv
    and rspec1.8 $argv
    and rspec2.1
    and jrspec1.9 $argv
    and jrspec1.8 $argv
    and rbx -X1.9 (which rspec) $argv
    and rbx -X1.8 (which rspec) $argv
end
function mruby
    ~/ruby/mruby/bin/mruby $argv
end
function mirb
    ~/ruby/mruby/bin/mirb $argv
end
function mrbc
    ~/ruby/mruby/bin/mrbc $argv
end
function rbx
    ~/ruby/rubinius/bin/rbx $argv
end
function rbx1.9
    ~/ruby/rubinius/bin/rbx -X1.9 $argv
end
function rspec1.8
    ruby1.8 (which rspec) $argv
end
function rspec2.1
    ruby2.1 (which rspec) $argv
end
function irb2.1
    ruby2.1 (which irb) $argv
end
function jruby
    ~/.jruby-1.7.4/bin/jruby $argv
end
function jruby1.9
    ~/.jruby-1.7.4/bin/jruby --1.9 $argv
end
function jrspec
    jruby (which rspec) $argv
end
function jrspec1.8
    jruby --1.8 (which rspec) $argv
end
function jrspec1.9
    jruby --1.9 (which rspec) $argv
end
function topaz
    ~/.topaz/bin/topaz $argv
end

function bundle-bootstrap
    bundle install --shebang (which ruby) --binstubs=.bundle/bin --path .bundle/gems
end

function parallel \
  --description "Provide POSIX shell to Gnu parallel"
    set -lx SHELL bash
    command parallel $argv
end

function podders \
  --description "Run Hpodder with necessary intermediate shell steps"
    set current_dir (pwd)
    hpodder update
    cd ~/.hpodder
    ruby update_auth.rb
    cd $current_dir
    hpodder download
end

# easy fix
function uname \
  --description "If the google-chrome program is properly installed at your site, the command 'google-chrome http://en.wikipedia.org/wiki/Linux' should give you access to the complete article"
    command uname $argv \
    | sed 's/GNU\/Linux/Linux/g'
end

function mmc \
  --description "Mercury Compiler, version 14.01"
    ~/.mercury/scripts/mmc $argv
end

function img \
  --description "Fake Erlang image parser"
    set current_dir (pwd)
    bk
    set prev_dir (pwd)
    cd ~/erlang/voroni
    ./img.escript $argv
    cd $prev_dir
    cd $current_dir
end

function f \
  --description "Find files with the given argument in their name in the current directory or its subdirectories"
    find . $argv[1] ^ /dev/null \
    | grep -i $argv[1]"[^/]*\$"
end

function blerg
    echo blerg $argv[1] ferg snerg
end

function lsusers \
  --description "List all users"
    cat /etc/passwd
end

function tm
    if test (tmux ls)
        tmux -2 attach
    else
        tmux -2
    end
end

function xcape \
  --description "Run xcape keymappings"
    ~/apps/xcape/xcape -e 'Alt_L=Control_L|S'
    ~/apps/xcape/xcape -e 'Control_L=Escape'
end
