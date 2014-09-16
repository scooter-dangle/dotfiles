set -u aliases ~/.config/fish/aliases.fish

# Tip from M Subelsky:
function ea \
  --description "Edit Aliases (and then reload them)"
    vim $aliases
    and . $aliases
end

# Further tip from B'More on Rails Meetup that was also
# the source of the preceding tip
function ag --argument-names target \
  --description "Aliases Grep"
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
    ++ (floor (log (count $argv)))
end

function trash \
  --description "Simple imitation of trash-cli"
    map __trash $argv
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
    cd -
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
    grep $argv -RIin . | sed --regexp-extended 's/^(.+):([0-9]+):/\1 \2/'
    or echo $argv[1] not found
end

function ta --argument idx \
  --description "Shortcut for commonly used awk functionality"
    awk '{print $'$idx'}'
end

function sf \
  --description "Print out filenames where pattern occurs"
    s $argv | ta 1
end

function vsf \
  --description 'Because vim (sf $argv) takes too long'
    vim (sf $argv) +/$argv
end

function vpsf \
  --description 'Because vimp (sf $argv) takes too long'
    vimp (sf $argv) +/$argv
end

function l \
  --description "Grab a particular line from file or pipe" \
  --argument-names target
    paj 1 $target
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

function justpid \
  --description "Extracts pid from psfind"
    # Unnecessary, but I can't remember the right way to do it
    sed --regexp-extended 's/^\s*([0-9]+)\s+.*$/\1/g'
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

function f \
  --description "Find files with the given argument in their name in the current directory or its subdirectories"
    find . $argv[1] ^ /dev/null \
    | grep -i $argv[1]"[^/]*\$"
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

function default_tmux
    echo "rename-session temp_session
          new-session -smusic mocp
          new-window -c~ -tmusic -d
          new-window -c~ -tmusic -d
          kill-session -ttemp_session" \
    | tmux -2 -q -C
    tmux -2 attach
end

if which foreman > /dev/null
    function fancy_foreman \
      --description "foreman with RubyMine Ruby args"
        # Attempt to mimic RubyMine foreman setup
        # How to use tail came from coderwall.com/p/6qdp5a
        ruby -e '$stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)' (which foreman) \
            $argv \
            --procfile=(cat (pwd)'/Procfile' (echo \n'log: tail --follow '(pwd)'/log/development.log' | psub) | psub) \
            --root=(pwd)
    end
end
