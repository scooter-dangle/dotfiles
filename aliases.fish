set -u aliases ~/.config/fish/aliases.fish

# Tip from M Subelsky:
function ea \
  --description "Edit Aliases (and then reload them)"
    vim $aliases
    and . $aliases
end

# Further tip from B'More on Rails Meetup that was also
# the source of the preceding tip
complete --command ga --arguments '(functions --all --names)' --authoritative --exclusive
function ga \
  --description "Grep Aliases"
    functions $argv | pygmentize -l bash
end

function ga_old --argument target \
  --description 'Grep Aliases'
	if test (grep -l "function "$target $aliases)
        set target "function "$target
    end
    set matching_lines (line_number_matches $target $aliases)
    func_blocks $matching_lines \
    | fish_indent \
    | __conditionally_pygmentize \
    | __grep_highlight $target
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
    while begin; ≤ $n $total_functions
             and ≤ $i $total_matches
      end
        if  begin; ≥ $argv[$i] $func_start_lines[$n]
               and « $argv[$i] $func_end_lines[$n]
            end
            set next_index (++ (count $out_start_lines))
            set out_start_lines[$next_index] $func_start_lines[$n]
            set out_end_lines[$next_index]   $func_end_lines[$n]
            set i (++ $i)

            # Eat up additional grep matches for $target
            # from the current function block (i.e., move on
            # from any further grepped matches in this current
            # function...we already marked this block for output)
            while begin; ≤ $i $total_matches
                     and ≥ $argv[$i] $out_start_lines[-1]
                     and « $argv[$i] $out_end_lines[-1]
                  end
                set i (++ $i)
            end
        end
        set n (++ $n)
    end

    set total_results (count $out_start_lines)
    set m 1
    while ≤ $m $total_results
        cat $aliases \
        |   head -n $out_end_lines[$m] \
        |   tail -n (++ (— $out_end_lines[$m] $out_start_lines[$m]))
        set m (++ $m)
    end
    return 0
end

function amath \
  --description "'Advanced' math (bc with math library option)"
    echo $argv | bc --mathlib
end

function floor \
  --description 'Arithmetic floor function'
    echo $argv \
    | sed --regexp-extended 's/^\./0./' \
    | sed --regexp-extended  's/^([0-9]+)\.?[0-9]*$/\\1/'
end

function digit_padding_width
    amath "length("(count $argv)")"
end

function trash \
  --description "Simple imitation of trash-cli"
    for item in $argv
        __trash $item
    end
end

function __trash --argument-names item __trash_base_dir \
  --description "Worker function behind trash function...use trash instead."
    # $__trash_base_dir must either be nil or an immediate subdirectory
    # of $TRASH where the final directory name is a number
    set TRASH ~/Trash

    if « (count $argv) 2
        set __trash_base_dir $TRASH
        set trash_count 0
    else
        set trash_count (++ (basename $__trash_base_dir))
    end

    set orig_item $item
    set item (pwd)"/"$item
    set parent_dir (dirname $item)
    set trash_parent $__trash_base_dir$parent_dir
    set trash_item $__trash_base_dir$item

    if test -e $trash_item
        if begin
                test -f $trash_item
                and test -f $item
                and == (cat $item | md5sum) (cat $trash_item | md5sum)
            end
            # Current target already exists and is same as file
            # already in trash...just remove the current file
            rm $item
            echo $trash_item
        else
            __trash ''$orig_item'' ''$TRASH/$trash_count''
        end
    else
        if not test -e $trash_parent
            mkdir --parents $trash_parent
        end
        mv $item $trash_parent/
        echo $trash_item
        return 0
    end
end

function restore --argument item \
  --description "For use within Trash directory...use with caution"
    set TRASH ~/Trash
    set orig_item $item
    set item (pwd)"/"$item
    set parent_dir (dirname $item)
    set outside_item (echo $item | sed 's#'$TRASH'##g')
    set outside_parent_dir (dirname $outside_item)
    if != "$parent_dir" "$TRASH$outside_parent_dir"
        echo restore can only be used from within $TRASH
        return 1
    end
    if test -e $outside_item
        echo cannot restore...item already exists:
        echo $outside_item
        return 1
    else if test -d $outside_parent_dir
        mv ''$item'' ''$outside_item''
        echo $outside_item
        return 0
    else
        echo cannot restore...former item directory not found:
        echo $outside_parent_dir
        return 1
    end
end

function make_playlist --argument-names artist_name
    # TODO: Ensure that this works with other artists
    set num_padding (digit_padding_width *''$artist_name''*/*/*)
    mkdir Playlists/''$artist_name''
    set i 1
    # for album in *''$artist_name''*
    for album in (ls --indicator-style=none ''$artist_name'')
        for song in (ls ''$artist_name/$album'')
            ln --symbolic ../../''$artist_name/$album/$song''  Playlists/''$artist_name''/(printf "%."$num_padding"d" $i)\ -\ ''$album''\ -\ ''$song''
        end
        set i (++ $i)
    end
end

function log --argument-names argument base \
  --description 'Logarithm of 1st argument in base of 2nd argument (defaults to base 10)'
    if == (count $argv) 1
        set base 10
    end
    if != $base e
        set denominator "/l($base)"
    end
    amath "l($argument)$denominator"
end

function +_2 --argument-names term1 term2
    math $term1" + "$term2
end

function +
    reduce +_2 0 $argv
end

function —
    if == 1 (count $argv)
        — 0 $argv[1]
    else
        math $argv[1]" - "$argv[2]
    end
end

function ×_2 --argument-names factor1 factor2
    math $factor1" * "$factor2
end

function ×
    reduce ×_2 1 $argv
end

function ÷
    if == 1 (count $argv)
        ÷ 1 $argv[1]
    else
        math $argv[1]" / "$argv[2]
    end
end

function fact --argument-names n
    × (… $n)
end

function == --argument-names leftside rightside
    return (test $leftside = $rightside)
end

function != --argument-names leftside rightside
    return (test $leftside != $rightside)
end

set -u alphabet a b c d e f g h i j k l m n o p q r s t u v w x y z
set -u Alphabet A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

function range
    … $argv
end

function … \
  --description "Numeric or alphabetic range with optional step"
    set compare ≤
    switch (count $argv)
    case 1
        set i 1
        set n $argv[1]
        set incr 1
    case 2
        set i $argv[1]
        set n $argv[2]
        set incr 1
    case 3
        set i $argv[1]
        set n $argv[2]
        set incr $argv[3]
        if « $incr 0
            set compare ≥
        end
    case '*'
        return 1
    end

    if contains -- $n $alphabet
        if == 1 $i
            set i $alphabet[$i]
        end
        set source_size (count $alphabet)
        at_all $source_size $alphabet (… (contains --index $i $alphabet) (contains --index $n $alphabet) $incr)
        return 0
    else if contains -- $n $Alphabet
        if == 1 $i
            set i $Alphabet[$i]
        end
        set source_size (count $Alphabet)
        at_all $source_size $Alphabet (… (contains --index $i $Alphabet) (contains --index $n $Alphabet) $incr)
        return 0
    end

    while eval $compare $i $n
        echo $i
        set i (+ $i $incr)
    end
    return 0
end

function at
    set index $argv[-1]
    echo $argv[$index]
end

function at_all --argument-names source_length
    set i (+ $source_length 2)
    set final (count $argv)
    while ≤ $i $final
        echo $argv[(++ $argv[$i])]
        set i (++ $i)
    end
    return 0
end

function flip
    set tmp     $argv[2]
    set argv[2] $argv[3]
    set argv[3] $tmp
    eval $argv
end

function op --argument-names arg1 operator arg2
    eval $operator $arg1 $arg2
end

function map --argument-names cmd
    set i 2
    set size (count $argv)
    while ≤ $i $size
        echo (eval $cmd $argv[$i])
        set i (++ $i)
    end
    return 0
end

function reduce --argument-names cmd memo
    for element in $argv[3..-1]
        set memo (eval $cmd $memo $element)
    end
    echo $memo
    return 0
end

# function +
#     set eval_string $argv[1]
#     for element in $argv[2..-1]
#         set eval_string "$eval_string + $element"
#     end
#     math $eval_string
# end

function filter --argument-names cmd
    if « (count $argv) 2
        return 0
    end
    for element in $argv[2..-1]
        if eval $cmd $element
            echo $element
        end
    end
    return 0
end

function reverse
    set i (count $argv)
    while ≥ $i 1
        echo $argv[$i]
        set i (decrement $i)
    end
    return 0
end

function decrement --argument-names i
    — $i 1
end

function increment --argument-names i
    ++ $i
end

function ++ --argument-names i
    +_2 $i 1
end

function « --argument-names left_side right_side
    return (test $left_side -lt $right_side)
end

function ≤ --argument-names left_side right_side
    return (test $left_side -le $right_side)
end

function » --argument-names left_side right_side
    return (test $left_side -gt $right_side)
end

function ≥ --argument-names left_side right_side
    return (test $left_side -ge $right_side)
end

function anon --argument-names cmd
    set i 2
    set total (count $argv)
    while ≤ $i $total
        set regex 's/\<A('(decrement $i)')\>/'$argv[$i]'/g'
        set cmd (echo $cmd | sed --regexp-extended $regex)
        set i (++ $i)
    end

    # Allow nested anonymous functions
    set regex 's/\<Aa(a*[0-9]+)\>/A\1/g'
    set cmd (echo $cmd | sed --regexp-extended $regex)

    eval $cmd
end

function £
    # Broken  :(
    set -l clean_args (echo $argv | quote-escape)
    echo '\'anon \\\\\\\''$clean_args'\\\\\\\'\''
end

function quote-escape
    # Doesn't work so well  :(
    sed --regexp-extended \
        --expression "s_((\\\\)+)_\\1\\1\\1\\1_g" \
        --expression "s_([^\\\\]?)(')_\\1\\\\\\\\\\\\\\\\\\\\\\2_g"
end

function quote-unescape
    # Pointless/doesn't work... see preceding function
    sed --expression s/\\\\\'/\'/g
end

function al
    pp_fish_aliases $aliases \
    | __conditionally_pygmentize \
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

function __conditionally_pygmentize --argument-names target \
  --description "Runs argument through pygmentize -lbash only if pygmentize can be found"
    # helper
    if test (which pygmentize)
        pygmentize -lbash $target
    else
        cat $target
    end
end

function __grep_highlight --argument-names target
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
    prevd $argv
end

function fd
    nextd $argv
end

function hm
    cd ~
end

function pwdd --argument-names prev_path_fragment new_path_fragment \
  --description "Echo current directory through sed replace"
    pwd | sed "s/$prev_path_fragment/$new_path_fragment/g"
end

if begin; which brew > /dev/null
          and   test -e /usr/local/opt/gnu-sed/bin/sed
   end
    function sed \
      --description "Remapping of sed for OS X"
        /usr/local/opt/gnu-sed/bin/sed $argv
    end
end

function cdd --argument-names prev_path_fragment new_path_fragment \
  --description "Attempt to mimic zsh cd command"
    if == (count $argv) '2'
        cd (pwdd $argv)
    else
        cd $argv
    end
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

function in_git_repo
    gs ^ /dev/null
end

function git-recent \
  --description "Show recent activity by on all branches"
    # From
    # http://stackoverflow.com/questions/11135052/how-to-list-only-active-recently-changed-branches-in-git
    reverse ( git for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname)' refs/heads refs/remotes )
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
    git pull --rebase $argv
end

function gf
    git fetch $argv
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

function pp
    pygmentize $argv
end

# Note: Largely from
# http://robots.thoughtbot.com/silver-searcher-tab-completion-with-exuberant-ctags
function __s_complete_gen
    cut --fields 1 local.tags ^/dev/null \
    | grep --invert-match '!_TAG' \
    | uniq
end

function __s_complete_test
    test -e local.tags
end

function __s_cleanup --argument-names dir_hash suffix
    for stale_file in (ls /tmp/ | grep $dir_hash)
        rm /tmp/$stale_file
    end
end

function __s_complete
    set dir_hash (readlink --canonicalize local.tags | md5sum | ta 1)
    set stat_hash (stat --format '%z' local.tags | md5sum | ta 1)
    set suffix tag_search_completion
    set filename "/tmp/$dir_hash.$stat_hash.$suffix"

    if test -e $filename
        cat $filename
        return 0
    end

    __s_cleanup $dir_hash $suffix

    __s_complete_gen | tee $filename
end

complete --command s --exclusive --condition "__s_complete_test" --arguments "(__s_complete)" --authoritative
function s \
  --description "Find the given argument in any file within the current directory or its subdirectories"
    search_remember $argv
end

function _s
    ag $argv | sed --regexp-extended 's/^([^:]+):([0-9]+):/\1 \2/'
end

function ta --argument idx \
  --description "Shortcut for commonly used cut functionality"
  cut -d ' ' -f $idx
end

function sf \
  --description "Print out filenames where pattern occurs"
    s $argv | ta 3 | sort --unique
end

function vsf \
  --description 'Because vim (sf $argv) takes too long'
    vim (sf $argv) +/$argv[1]
end

function l \
  --description "Grab a particular line from file or pipe" \
  --argument-names target
    sed (+ $target '-1')"p" --quiet
end

function paj \
  --description "Paginate result chunk" \
  --argument-names increment chunk
    set startIndex (× (++ $chunk) $increment)
    head -n $startIndex \
    | tail -n $increment
end

function md
    mkdir --parents $argv[1]
    and cd $argv[1]
end

function psfind \
  --description "Search for processes with a given string."
    # Usually better to just use process expansion (with the percent
    # sign) instead of this
    ps -A \
    | grep $argv \
    | grep grep --invert-match
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
    # Can't remember if this actually works...  :(
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
    marketplace_renamer
    evacuate_podders
end

function evacuate_podders \
  --description "Use with caution...setup-specific"
    set current_dir (pwd)

    set origin /media/scott/USB30FD/podcasts
    if not test -d $origin
        echo $origin not found
        return 1
    end
    cd $origin

    for podcast in (ls)
        set podcast_dir ~/podcasts/$podcast
        cd $podcast_dir
        set episodes (filter 'test -f' (ls))
        cd $origin
        for episode in $episodes
            echo migrating $episode
            mv $podcast_dir''$episode $podcast
        end
    end
    cd $current_dir
end

# easy fix
function uname \
  --description "The full documentation for Linux is maintained as a Wikipedia article. If the google-chrome program is properly installed at your site, the command 'google-chrome http://en.wikipedia.org/wiki/Linux' should give you access to the complete article."
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

complete --command f --arguments  "(ag -g '.*'  | tr '/.' \"\n\" | sort --unique)" --exclusive --authoritative
function f \
  --description "Find files with the given argument in their name in the current directory or its subdirectories"
    search_remember $argv
end

function _f
    find . $argv[1] ^ /dev/null \
    | grep -i $argv[1]"[^/]*\$"
end

function search_remember
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 20
    end
    set --local search_term $argv[1]

    set --local tmpfile (mktemp --suffix _last_searched_files)

    if == $_ s
        set --local s_opts --ignore tags --ignore log --ignore local.tags --ignore .min.js --ignore docs --ignore doc --smart-case --skip-vcs-ignores --silent
        ag --max-count 5 --{color,head,break,group} --context=1 --before=1 $s_opts $argv | numberer | more -R
        __search_remember_completer_s $argv &
    else if == $_ f
        ag --color --skip-vcs-ignores -g $argv | numberer_simple
        __search_remember_completer_f $argv &
    end
end

function __search_remember_completer_s \
  --no-scope-shadowing
    ag --max-count 1 $s_opts $argv | sed --regexp-extended 's/^([^:]+):([0-9]+):/\1 \2/' | head -n $SEARCH_OPEN_LIMIT > $tmpfile
    __search_remember_close_out &
end

function __search_remember_completer_f \
  --no-scope-shadowing
    ag --skip-vcs-ignores -g $argv | head -n $SEARCH_OPEN_LIMIT > $tmpfile
    __search_remember_close_out &
end

function __search_remember_close_out \
  --no-scope-shadowing
    if test -s $tmpfile
        set --global LAST_SEARCH_TERM $search_term
        if begin
            set --query LAST_SEARCHED_FILES
            and test -f $LAST_SEARCHED_FILES
        end
            rm $LAST_SEARCHED_FILES
        end

        set --global LAST_SEARCHED_FILES $tmpfile

        _gen_vs_completions
        _gen_vf_completions
    end
end

# Trouble getting the following to work when using dollar
# sign to indicate end of range
# function __vs_complete_allows --argument-names target element
#     set target (echo "$target" | sed --regexp-extended 's/\$/$/g')
#     not contains $element (seq $element | sed --quiet "$target p")
# end
function __vs_complete_allows --argument-names target element
    if == $target $element
        return (false)
    end

    if begin; echo $target | grep --quiet ,; end
        set --local lower (echo $target | cut --fields 1 --delimiter ',')
        set --local upper (echo $target | cut --fields 2 --delimiter ',')

        if == $lower '.'
            set lower 0
        end

        if == $upper \\\$
            set upper (++ $element)
        end

        if begin; echo $upper | grep --quiet +; end
            set --local tmp_upper (echo $upper | cut --fields 2 --delimiter +)
            if test -z $tmp_upper
                set tmp_upper 0
            end
            set upper (+ $lower $tmp_upper)
        end

        if begin; ≥ $element $lower; and ≤ $element $upper; end
            return (false)
        end
    end

    return (true)
end

function __vs_complete_arg_filter_gen --argument-names counter
    . (echo 'function __vs_complete_arg_filter_'$counter'; set current_args (__fish_print_cmd_args) ; if ≥ (count $current_args) 2 ; for arg in $current_args[2..-1] ; if not __vs_complete_allows $arg '$counter' ; return (false) ; end ; end ; end ; return (true) ; end' | psub)
    echo __vs_complete_arg_filter_$counter
end

function __vf_complete_arg_filter_gen --argument-names counter path
    . (echo 'function __vf_complete_arg_filter_'$counter'; if contains "'$path'" (__fish_print_cmd_args | sed "s/^vf //"); return (false); else; return (true); end; end' | psub)
    echo __vf_complete_arg_filter_$counter
end

function vs
    if == 0 (count $argv)
        set files (recently_searched_files)
    else
        set files (recently_searched_files | get_lines $argv)
    end
    vim $files +"Ag $LAST_SEARCH_TERM $files" +"let @/ = '$LAST_SEARCH_TERM'" +"set hlsearch"
end

# why not include both vs and vf? vs for select and vf for file?
function vf
    vim $argv +"let @/ = '$LAST_SEARCH_TERM'" +"set hlsearch"
end

function _gen_vs_completions
    complete --command vs --erase
    set --local counterer 1
    for match in (cat $LAST_SEARCHED_FILES)
        complete --command vs --condition (__vs_complete_arg_filter_gen $counterer) --argument $counterer --description ''$match'' --no-files --authoritative
        set counterer (++ $counterer)
    end
end

function _gen_vf_completions
    complete --command vf --erase
    set --local counterer 1
    for file in (cat $LAST_SEARCHED_FILES | ta 1)
        complete --command vf --condition (__vf_complete_arg_filter_gen $counterer $file) --argument $file --description (basename $file) --no-files --authoritative
        set counterer (++ $counterer)
    end
end

function numberer_simple
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 20
    end

    set --local counter_padded_size (amath "length($SEARCH_OPEN_LIMIT)")
    set --local counter_finished (echo $SEARCH_OPEN_LIMIT | tr '01234567890' ' ')

    set --local counter 1

    while read line
        if ≤ $counter $SEARCH_OPEN_LIMIT
            set counter_string (printf '%-'$counter_padded_size'i ' $counter)
            set counter (++ $counter)
        else
            set counter_string "$counter_finished "
        end
        echo $counter_string$line
    end
end

function numberer
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 20
    end

    set --local counter_padded_size (amath "length($SEARCH_OPEN_LIMIT)")
    set --local counter_finished (echo $SEARCH_OPEN_LIMIT | tr '01234567890' ' ')

    set --local blank true
    set --local counter 1

    while read line
        if ≤ $counter $SEARCH_OPEN_LIMIT
            if eval $blank
                if not test -z $line
                    set counter_string (printf '%-'$counter_padded_size'i ' $counter)
                    set counter (++ $counter)
                    set blank false
                end
            else
                if not test -z $line
                    set counter_string "$counter_finished "
                else
                    set blank true
                end
            end
        else
            if not test -z $line
                set counter_string "$counter_finished "
            else
                set counter_string ''
            end
        end
        echo $counter_string$line
    end
end

function get_lines
    if == 1 (count $argv)
        sed --quiet ''$argv[1]'p'
    else
        set --local get_lines_file (mktemp --suffix _get_lines_helper)

        while read line
            echo $line >> $get_lines_file
        end

        for specifier in $argv
            cat $get_lines_file | sed --quiet ''$specifier'p'
        end
        rm $get_lines_file
    end
end

function test_for_has_searched
    set --query LAST_SEARCH_TERM
end

function recently_searched_files
    if not set --query LAST_SEARCHED_FILES
        echo \n
    end
    cat $LAST_SEARCHED_FILES | ta 1 | uniq
end

function blerg --argument-names the_royal_nergin
    echo blerg $the_royal_nergin ferg snerg
end

function lsusers \
  --description "List all users"
    cat /etc/passwd
end

function xcape \
  --description "Run xcape keymappings"
    # For faster tmux use
    ~/apps/xcape/xcape -e 'Alt_L=Control_L|S'
    # For vim happiness
    ~/apps/xcape/xcape -e 'Control_L=Escape'
    # For fast parens
    ~/apps/xcape/xcape -e 'Shift_L=Shift_L|9'
    ~/apps/xcape/xcape -e 'Shift_R=Shift_R|0'
end

function downpour_mp3_rename
    rename 's/\s*\(Unabridged\).* (\d+ of \d+)\](\.mp3)/ $1$2/g' *
end

complete --command downpour_all --arguments '*.zip' --exclusive
function downpour_all --argument-names book
    if != (count $argv) 1
        echo Error: Must specify one argument
        return 1
    end
    set book_name ''(echo $book | sed 's/\.zip$//g' | sed 's/ (Unabridged) .*$//g')''
    mkdir $book_name
    mv $book $book_name/
    cd $book_name
    unzip $book
    trash $book
    downpour_mp3_rename
    cd ..
    mv $book_name ~/Audiobooks/
end

# function default_tmux
#     echo "rename-session temp_session
#           new-session -smusic mocp
#           new-window -c~ -tmusic -d
#           new-window -c~ -tmusic -d
#           kill-session -ttemp_session" \
#     | tmux -2 -q -C
#     tmux -2 attach
# end

function open_bot_windows
    set --local teh_bots ~/codes/bots
    tmux new-window -c $teh_bots/reporting-bot
    tmux split-window -h -c $teh_bots/queue-bot
    tmux select-pane -L
    tmux split-window -v -c $teh_bots/summary-bot
    tmux select-pane -R
    tmux split-window -h -c $teh_bots/parse-bot
    tmux split-window -v -c $teh_bots/retention-bot
    tmux select-pane -L
    tmux split-window -v -c $teh_bots/cleanup-bot
    tmux select-pane -U
    tmux set-option synchronize-panes on
end

function all_bots_skiq --argument-names do_git_update
    open_bot_windows
    if begin; != 0 (count $argv); and contains -- $do_git_update -g --git-update; end
        tmux send-keys g p Enter
        tmux send-keys b u n d l e Enter
    end
    tmux send-keys s k i q Enter
end

function bot_pipeline
    open_bot_windows
    tmux send-keys t a i l Space '-' '-' f o l l o w Space l o g '/' '*' '-'  b o t '.' l o g Enter
    all_bots_skiq $argv
end

function fancy_foreman \
  --description "foreman with RubyMine Ruby args"
    # Attempt to mimic RubyMine foreman setup
    # How to use tail came from coderwall.com/p/6qdp5a
    ruby -e '$stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)' (which foreman) \
        $argv \
        --procfile=(cat (pwd)'/Procfile' (echo \n'log: tail --follow '(pwd)'/log/development.log' | psub) (echo \n'sidekiq: tail --follow '(pwd)'/log/sidekiq.log' | psub) | psub) \
        --root=(pwd)
end

complete --command gmd --arguments '-{l,-local}' --description 'Generate docs for locally bundled gems'
complete --command gmd --arguments '-{g,-global}' --description 'Generate docs for globally installed gems'
function gmd --argument scope \
  --description "gem_docs: Generate ri docs either locally or globally"
    if == (count $argv) 0
        set scope --local
    end

    if contains -- $scope --local -l
        # for bundled gems
        bundle list \
        | tr -d '*(,)' \
        | awk '{print $1, "--version", $2}' \
        | xargs -n3 gem rdoc --ri --no-rdoc
        return 0
    else if contains -- $scope --global -g
        # global gems
        gem list \
        | tr -d '(,)' \
        | awk '{print $1, "--version", $2}' \
        | xargs -n3 gem rdoc --ri --no-rdoc
        return 0
    else
        echo "Unknown option:\t$scope"
        return 1
    end
end

function rl \
  --description "Load up rvm"
    rvm reload > /dev/null; and cd .
end

# function rtags \
#   --description "Generate ctags for a ruby project in a separate tmux session"
#     set --export TMUX (tmux new-session -s "rtags "(basename (pwd)) -P -d -c "#{pane_current_path}" __rtags)
# end

function rtags \
  --description "Generate ctags for a ruby project"
    if which rvm > /dev/null
        set gemdir (rvm gemset dir)
    end

    echo 'Generating combined gem ctags...'
    ctags -R --exclude=doc{,s} --exclude=\*.tags . $gemdir
    rdoc --format=tags --ctags-merge --exclude=.log --exclude=doc{,s} --exclude=tags --exclude=.tags .

    # So hacky  :(
    # Can't figure out how to tell rdoc to use a different file
    mv tags .global.tags

    echo 'Generating local ctags...'
    ctags -R --exclude=doc{,s} --exclude=\*.tags .
    rdoc --format=tags --ctags-merge --exclude=.log --exclude=doc{,s} --exclude=tags --force-update --exclude=.tags .

    # completion of gross hack
    mv tags local.tags
    mv .global.tags tags

    # Disabling for now due to so slow...need to cache
    # or something
    # echo 'Generating ri-tags...'
    # gmd --local

    return 0
end

function skiq \
  --description "Startup sidekiq worker"
    rerun --background --no-growl --pattern '{**/*.rb}' -- bundle exec sidekiq -r ./main.rb -e development -C ./config/sidekiq.yml --verbose
end

function swp_all \
  --description "Print out paths to all files with a corresponding .*.swp file"
    f '\.swp' \
    | sed --regexp-extended 's/\/\.(.+)\.swp$/\/\1/'
end

function marketplace_renamer
    cd ~/podcasts/APM__Marketplace_All-In-One/
    rename 's/^(.*)_(\d{8})/$2_$1/' *.mp3
    rename 's/(\d{8})_(mmr)/$1_00_$2/' *.mp3
    rename 's/(\d{8})_(midday)/$1_01_$2/' *.mp3
    rename 's/(\d{8})_(tech)/$1_02_$2/' *.mp3
    rename 's/(\d{8})_(pm)/$1_03_$2/' *.mp3
    rename 's/(\d{8})_(weekend)/$1_04_$2/' *.mp3
    bk
end

function less
    command less --RAW-CONTROL-CHARS $argv
end

function fish_debug \
  --description "Run fish in debug mode and log stuff out to files and such"
    set --local fish_logs /tmp/fish_logs
    if not test -d $fish_logs
        mkdir --parents $fish_logs
    end

    set --local fish_profiles /tmp/fish_profiles
    if not test -d $fish_profiles
        mkdir --parents $fish_profiles
    end

    set current_date (date +'%Y-%m-%d  %I:%M:%S.%3N %p')
    set log_file $fish_logs/$current_date.log
    set pro_file $fish_profiles/$current_date.profile

    touch $log_file
    touch $pro_file

    fish --interactive --debug 3 --profile $pro_file ^$log_file
end

complete --command vim --authoritative --argument '(ag --depth 7 --max-count 250 -g \'.*\' ^/dev/null)'
# complete --command vim --condition 'test -e .gitignore' --authoritative --argument '(ag --depth 8 --max-count 40 -g \'.*\')'
# complete --command vim --condition 'true' --authoritative --argument '(ag --depth 8 --max-count 40 -g ""(__fish_print_cmd_args | ta (count __fish_print_cmd_args))"" ^/dev/null)'

if == (uname) Darwin
    function postgres_start_server
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
    end
end

for project in ~/codes/{prism,portal,api,database-migrations,automation-rlw} ~/codes/bots/* ~/go/src/github.com/distil/*
    set --local project (echo $project | sed 's#/$##')
    echo "function "(basename $project)"
        cd $project
    end" | source
end

function __psql_all_db_names
    set --local hostname localhost
    set --local username scott
    psql --host $hostname --username $username --command "copy (select datname from pg_database where datistemplate = false) to stdout"
end

function __pcom_complete
    # no-op
    # if count (__fish_print_cmd_args)
end

complete --command pcom --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
function pcom --argument-names dbname
    psql --host localhost --username scott --dbname $dbname --command $argv[2..-1]
end

complete --command pcoms --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
function pcoms --argument-names dbname
    pcom $dbname "copy ($argv[2..-1]) to stdout with (format 'csv', header false, delimiter E'\t')"
end

complete --command pout --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
# complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | ta 2 | grep --quiet distil_summary;   end' --arguments 'summary.(ls_summary_tables)'     --exclusive --authoritative
# complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | ta 2 | grep --quiet distil_reporting; end' --arguments 'reporting.(ls_reporting_tables)' --exclusive --authoritative
# complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | ta 2 | grep --quiet postgres; end'         --arguments 'public.(ls_parse_tables)'        --exclusive --authoritative
complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | ta 2 | tr --delete " "); end'  --arguments '(ls_psql_schema_tables (echo (__fish_print_cmd_args) | ta 2))' --exclusive --authoritative
function pout --argument-names dbname schema_table
    pcoms $dbname "SELECT * FROM $schema_table"
end

complete --command pfout --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
# complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | ta 2 | grep --quiet distil_summary;   end' --arguments 'summary.(ls_summary_tables)'     --exclusive --authoritative
# complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | ta 2 | grep --quiet distil_reporting; end' --arguments 'reporting.(ls_reporting_tables)' --exclusive --authoritative
# complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | ta 2 | grep --quiet postgres; end'         --arguments 'public.(ls_parse_tables)'        --exclusive --authoritative
complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | ta 2 | tr --delete " "); end'  --arguments '(ls_psql_schema_tables (echo (__fish_print_cmd_args) | ta 2))' --exclusive --authoritative
function pfout --argument-names dbname schema_table file_name_tag
    if test -z $file_name_tag
        set file_name_tag ""
    else
        set file_name_tag "__"$file_name_tag
    end
    set branch_name __(git branch --no-color | grep '\*' | ta 2)
    set time_stamp __(date +'%Y-%m-%d_%I:%M:%S.%2N_%p')
    set file_name $schema_table$branch_name$file_name_tag$time_stamp
    pout $dbname $schema_table > $file_name
end

complete --command ls_psql_schemas --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
function ls_psql_schemas --argument-names dbname
    pcoms $dbname "Select distinct table_schema from information_schema.tables where table_schema not in ('pg_catalog', 'information_schema')"
end

complete --command truncate_psql_tables --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
complete --command truncate_psql_tables --condition 'begin; ≥ (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | ta 2 | tr --delete " "); end'  --arguments '(ls_psql_schema_tables (echo (__fish_print_cmd_args) | ta 2))' --exclusive --authoritative
function truncate_psql_tables --argument-names dbname
    for schema_table in $argv[2..-1]
        __truncate_psql_table $dbname $schema_table
    end
end

function __truncate_psql_table --argument-names dbname schema_table
    echo -n truncating $schema_table...
    pcom $dbname "TRUNCATE TABLE $schema_table" > /dev/null
    echo done.
end

complete --command ls_psql_schema_tables --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
function ls_psql_schema_tables --argument-names dbname
    pcoms $dbname "Select distinct(table_schema || '.' || table_name) from information_schema.tables where table_schema not in ('pg_catalog', 'information_schema')"
end

complete --command ls_psql_tables --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
complete --command ls_psql_tables --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | ta 2 | tr --delete " "); end' --arguments '(ls_psql_schemas (echo (__fish_print_cmd_args) | ta 2))' --exclusive --authoritative
# complete --command ls_psql_tables --condition '== (count (__fish_print_cmd_args)) 2' --arguments '(ls_psql_schemas (echo (__fish_print_cmd_args) | ta 2))' --exclusive --authoritative
function ls_psql_tables --argument-names dbname schema
    pcoms $dbname "Select table_schema || '.' || table_name from information_schema.tables where table_schema = '$schema'"
end

function ls_parse_tables
    pcoms postgres "Select table_name from information_schema.tables where table_schema = 'public' and table_name like 'log_%'"
end

function dump_parse_tables --argument-names file_name_tag
    for table in (ls_parse_tables)
        echo $table
        pfout postgres $table $file_name_tag
    end
end

function ls_summary_tables
    pcoms distil_summary "Select table_name from information_schema.tables where table_schema = 'summary' and table_name not like '%_2%'"
end

function dump_summary_tables --argument-names file_name_tag
    for table in (ls_summary_tables)
        echo $table
        pfout distil_summary "summary.$table" $file_name_tag
    end
end

function ls_reporting_tables
    pcoms distil_reporting "Select table_name from information_schema.tables where table_schema = 'reporting' and table_name not like '%_2%' and table_name not like 'counters'"
end

function dump_reporting_tables --argument-names file_name_tag
    for table in (ls_reporting_tables)
        echo $table
        pfout distil_reporting "reporting.$table" $file_name_tag
    end
end

function sdiff --argument-names f1 f2
    icdiff (sort $f1 | psub) (sort $f2 | psub)
end

function sdiffv --argument-names f1 f2
    vimdiff (sort $f1 | psub) (sort $f2 | psub)
end

function sudiff --argument-names f1 f2
    diff (sort $f1 | uniq | psub) (sort $f2 | uniq | psub)
end

complete --command pbproc --arguments '(functions | tr --delete \,)' --authoritative
function pbproc \
    --description "Process contents of pb clipboard on OS X"
    pbpaste | eval $argv | pbcopy
end
