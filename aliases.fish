set --universal aliases ~/.config/fish/aliases.fish

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

# easy fix
function uname \
  --description "The full documentation for Linux is maintained as a Wikipedia article. If the google-chrome program is properly installed at your site, the command 'google-chrome http://en.wikipedia.org/wiki/Linux' should give you access to the complete article."
    command uname $argv \
    | sed 's/GNU\/Linux/Linux/g'
end

# the short-opt annoyingly varies by OS
switch (uname)
case "Darwin"
    set sed_regex_flag "-E"
case "Linux"
    set sed_regex_flag "-r"
end

function set_hasher
    if not set --query --universal HASHER
        if which md5 >/dev/null 2>/dev/null
            set --universal HASHER md5
        else if which md5sum >/dev/null 2>/dev/null
            set --universal HASHER md5sum
        else
            echo "no hasher found (md5 or md5sum)" >&2
            return 1
        end
    end
end


function amath \
  --description "'Advanced' math (bc with math library option)"
    echo $argv | bc --mathlib
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

function __trash \
  --description "Worker function behind trash function...use trash instead." \
  --argument-names item __trash_base_dir
    # $__trash_base_dir must either be nil or an immediate subdirectory
    # of $TRASH where the final directory name is a number
    set TRASH ~/Trash

    # echo "item: $item"\t"__trash_base_dir: $__trash_base_dir" >&2

    if « (count $argv) 2
        set __trash_base_dir $TRASH
        set trash_count 0
    else
        set trash_count (++ (basename $__trash_base_dir))
    end

    # echo "trash_count: $trash_count"\t"__trash_base_dir: $__trash_base_dir" >&2

    set orig_item $item
    set item (pwd)"/"$item
    set parent_dir (dirname $item)
    set trash_parent $__trash_base_dir$parent_dir
    set trash_item $__trash_base_dir$item

    # echo "trash_parent: $trash_parent"\t"trash_item: $trash_item" >&2

    if test -e $trash_item
        # echo "TRUE: test -e $trash_item" >&2

        set_hasher

        if [ -f $trash_item ] && [ -f $item ] && [ (cat $item | $HASHER) = (cat $trash_item | $HASHER) ]
            # end
            # echo "TRUE: begin" >&2

            # Current target already exists and is same as file
            # already in trash...just remove the current file
            rm $item
            echo $trash_item
            return 0
        else
            # echo "FALSE: begin" >&2

            __trash ''$orig_item'' ''$TRASH/$trash_count''
            return $status
        end
    else
        # echo "FALSE: test -e $trash_item" >&2

        if test -e $trash_parent
            # echo "TRUE: test -e $trash_parent" >&2

            if not test -d $trash_parent
                # echo "TRUE: not test -d $trash_parent" >&2

                __trash ''$orig_item'' ''$TRASH/$trash_count''
                return $status
            end
        else
            # echo "FALSE: test -e $trash_parent" >&2

            if not mkdir --parents $trash_parent 2> /dev/null
                # echo "FALSE: not mkdir --parents $trash_parent 2> /dev/null" >&2

                __trash ''$orig_item'' ''$TRASH/$trash_count''
                return $status
            end
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

# function fact --argument-names n
#     × (… $n)
# end

function == --argument-names leftside rightside
    return (test $leftside = $rightside)
end

function != --argument-names leftside rightside
    return (test $leftside != $rightside)
end

# function range
#     … $argv
# end

# function … \
#   --description "Numeric or alphabetic range with optional step"
#     set compare ≤
#     switch (count $argv)
#     case 1
#         set i 1
#         set n $argv[1]
#         set incr 1
#     case 2
#         set i $argv[1]
#         set n $argv[2]
#         set incr 1
#     case 3
#         set i $argv[1]
#         set n $argv[2]
#         set incr $argv[3]
#         if « $incr 0
#             set compare ≥
#         end
#     case '*'
#         return 1
#     end
#     if contains -- $n $alphabet
#         if == 1 $i
#             set i $alphabet[$i]
#         end
#         set source_size (count $alphabet)
#         at_all $source_size $alphabet (… (contains --index $i $alphabet) (contains --index $n $alphabet) $incr)
#         return 0
#     else if contains -- $n $Alphabet
#         if == 1 $i
#             set i $Alphabet[$i]
#         end
#         set source_size (count $Alphabet)
#         at_all $source_size $Alphabet (… (contains --index $i $Alphabet) (contains --index $n $Alphabet) $incr)
#         return 0
#     end
#     while eval $compare $i $n
#         echo $i
#         set i (+ $i $incr)
#     end
#     return 0
# end

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

function __grep_highlight --argument-names target
    # helper
    while read line
        if test (echo $line | grep -l $target 2> /dev/null)
            echo $line \
            | grep $target
        else
            echo $line
        end
    end
    return 0
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

function git-branch-activity
    # From
    # http://stackoverflow.com/questions/11135052/how-to-list-only-active-recently-changed-branches-in-git
    git for-each-ref --format='%(committerdate:short) %(refname)' refs/heads refs/remotes | sort
end

function git-recent --description "Show recent activity on all branches"
    git-branch-activity | tail --lines 20
end

complete --command git-branch-delete \
         --condition "[ -d ./.git ]" \
         --arguments "(
           complete --do-complete='git branch -d ' | remove_if_in_commandline
         )" \
         --exclusive \
         --authoritative

function git-branch-delete \
    --argument-names branch \
    --description "Delete branch locally and at origin"
    git push origin --delete $branch
    and git branch --delete $branch
end

abbr --add lolwut "watch --no-title --precise --color --interval 1 -- bash (echo 'redis-cli lolwut version 6 \$COLUMNS \$LINES | head --lines \"-2\"' | psub)"
abbr --add bk prevd
abbr --add fw nextd
abbr --add up 'cd ..'
abbr --add hm 'cd ~'
# abbr --add enw 'env (cat ../configs/test.env | tr --squeeze-repeats \n)'
abbr --add enf 'enw --file'

abbr --add xx 'env (cat .env) rbenv exec bundle exec'

abbr --add gd  "git diff --ignore-space-change --relative --color --indent-heuristic"
abbr --add gdf 'git diff --ignore-space-change --relative --indent-heuristic --name-only'
abbr --add gds "git diff --ignore-space-change --relative --color --indent-heuristic --stat"
abbr --add gs  "git status --short ."
abbr --add gch "git checkout"
abbr --add gco "git commit"
abbr --add gl  "git log"
abbr --add gbb  "git branch"

abbr --add gf  "git fetch"
abbr --add GP  "git push"
abbr --add GPF  "git push --force-with-lease"
abbr --add gp  "git pull --rebase --autostash"
abbr --add gdb "git diff --ignore-space-change --color --indent-heuristic --relative HEAD{~,}"
abbr --add gbk "git checkout -"
abbr --add GPU "git push --set-upstream origin (git rev-parse --abbrev-ref HEAD)"
switch (uname)
case "Darwin"
    abbr --add GPUP "git push --set-upstream origin (git rev-parse --abbrev-ref HEAD); and open (git remote get-url origin | sed 's/\.git\$//')/pull/new/(git rev-parse --abbrev-ref HEAD | tr -d \n)"
case "Linux"
    abbr --add GPUP "git push --set-upstream origin (git rev-parse --abbrev-ref HEAD); and echo (git remote get-url origin | sed 's/\.git\$//')/pull/new/(git rev-parse --abbrev-ref HEAD | tr --delete \n) | xclip -selection clipboard"
end

abbr --add gst "git stash"
abbr --add gsp "git stash pop"
abbr --add git-current-branch "git rev-parse --abbrev-ref HEAD"
if [ (uname) = "Darwin" ]
    abbr --add gcb "git rev-parse --abbrev-ref HEAD | tr -d \n"
    abbr --add gcur "git rev-parse --abbrev-ref HEAD | tr -d \n"
else
    abbr --add gcb "git rev-parse --abbrev-ref HEAD | tr --delete \n"
    abbr --add gcur "git rev-parse --abbrev-ref HEAD | tr --delete \n"
end
abbr --add gbc "git merge-base HEAD"
abbr --add glg "git log --graph --oneline --all --decorate --color"
# abbr --add glw "watch --color --differences --no-title --interval=0.1 'git log --graph --oneline --all --decorate --color | head --lines \$LINES | sed --regexp-extended \"s/(^((\x1B\[[0-9;]*m)*[^\x1B]){0,\$COLUMNS}).*\$/\1\x1B[m/\"'"
if [ (uname) = "Darwin" ]
    abbr --add glw "watch --color --no-title --interval=0.1 'git log --graph --oneline --all --decorate --color | head -n \$LINES | sed -E \"s/(^((\x1B\[[0-9;]*m)*[^\x1B]){0,\$COLUMNS}).*\$/\1\x1B[m/\"'"
else
    abbr --add glw "watch --color --no-title --interval=0.1 'git log --graph --oneline --all --decorate --color | head --lines \$LINES | sed --regexp-extended \"s/(^((\x1B\[[0-9;]*m)*[^\x1B]){0,\$COLUMNS}).*\$/\1\x1B[m/\"'"
end
abbr --add gla "git log --graph --all --decorate --color"
abbr --add gsmod "git ls-files --modified"
abbr --add gsdel "git ls-files --deleted"
abbr --add gsnew "git status --short | sed --silent 's/^?? //p'"
switch (uname)
case "Darwin"
    abbr --add gsconfl "git status --short | sed -n       -E                's/^(UA|UU|AU|AA) //p'"
case "Linux"
    abbr --add gsconfl "git status --short | sed --silent --regexp-extended 's/^(UA|UU|AU|AA) //p'"
end
abbr --add grpo "git remote prune origin"
abbr --add gmb  "git merge-base HEAD master"
abbr --add gother "git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- '*'"
abbr --add gmenv "env (git log --max-count=1 --format=GIT_AUTHOR_NAME=\"'%an'\"\nGIT_AUTHOR_EMAIL=\"'%ae'\"\nGIT_AUTHOR_DATE=\"'%ad'\"\nGIT_COMMITTER_NAME=\"'%cn'\"\nGIT_COMMITTER_EMAIL=\"'%ce'\"\nGIT_COMMITTER_DATE=\"'%cd'\")"

abbr --add gsubdir "string replace (git rev-parse --show-toplevel)/ '' \$PWD/"

abbr --add sshas "ssh-agent -s | sed 's/; /\n/' | tr --delete ';' | rg --invert-match 'export|echo' | sed --regexp-extended 's/^(.*)\=(.*)\$/set --export \1 \2/' | source"

abbr --add iso8601 "date +'%FT%T%z' --utc"
abbr --add wordlet "pst | sed 's/🟩/🌄/g' | sed 's/🟨/💡/g' | sed 's/⬛/🌃/g' | cpy"

# V.P.N. C.onnect
abbr --add vpnc "openvpn3 session-start --config="
# V.P.N. D.isconnect
abbr --add vpnd "openvpn3 session-manage --disconnect --path=/net/openvpn/v3/sessions/"

# Common usage of terraform init
abbr --add tinit "terraform init -backend-config=../backend-config.tfvars"

function ghc --argument-names user repo
    git clone "https://github.com/$user/$repo.git"
end

function ghcd \
  --argument-names user repo
    git clone --recurse-submodule \
        "https://github.com/$user/$repo.git"
    and cd $repo
end

function ta --argument idx \
  --description "Shortcut for commonly used cut functionality"
  cut -d ' ' -f $idx
end

function l \
  --description "Grab a particular line from file or pipe" \
  --argument-names target
    sed (+ $target '-1')"p" --quiet
end

### BEGIN SEARCH SECTION
# Note: Largely from
# http://robots.thoughtbot.com/silver-searcher-tab-completion-with-exuberant-ctags

function __s_tag_files
    set tag_files

    if [ -f tags ]
        set tag_files tags
    end

    if bash -c 'compgen -G */tags > /dev/null'
        set tag_files $tag_files (ls -1 */tags | sort)
    end

    echo -ns $tag_files\n
end

function __s_complete_gen \
    --inherit-variable sed_regex_flag
    set pwd_length (echo -ns "$PWD" | wc -c)
    set follow_on_dir_start (math "$pwd_length + 2")

    set tag_files (__s_tag_files)

    if [ -z "$tag_files" ]
        return 1
    end

    # print non meta lines that are for files in the current directory (either
    # include PWD as substring in path or are local relative paths)
    # This one prints the filepath as the description
    # sed '/^!_TAG/d' $tag_files \
    # | awk -F \t 'substr($2, 0, '$pwd_length') == "'$PWD'" || $2 ~ /^[^\/]/ { print $1 "\t" substr($2, '$follow_on_dir_start') }'
    # This one prints the code snippet as the description
    # sed '/^!_TAG/d' $tag_files \
    # | awk -F \t 'substr($2, 0, '$pwd_length') == "'$PWD'" || $2 ~ /^[^\/]/ { print $1 "\t" $3 }' \
    # | sed $sed_regex_flag 's#\t/\^ *#\t#' \
    # | sed $sed_regex_flag 's# *\$/;?"?$##'
    # This one prints the file AND code snippet as the description
    sed '/^!_TAG/d' $tag_files \
    | awk -F \t 'substr($2, 0, '$pwd_length') == "'$PWD'" || $2 ~ /^[^\/]/ { print $1 "\t" substr($2, '$follow_on_dir_start') "\t" $3 }' \
    | sed $sed_regex_flag 's#\t/\^ *#\t\# #g' \
    | sed $sed_regex_flag 's# *\$/;?"?$##'

    # cat tags \
    # | grep -F $PWD 2>/dev/null \
    # | cut -f 1 2>/dev/null \
    # | grep -v '!_TAG' \
    # | uniq
end

function __s_complete_test
    # [ -e local.tags ]
    [ -e tags ] || bash -c 'compgen -G */tags > /dev/null'
end

function __s_cleanup --argument-names dir_hash suffix
    # for stale_file in (ls /tmp/ | grep $dir_hash)
    #     rm /tmp/$stale_file
    # end
    rm -f (ls /tmp/ | grep $dir_hash | grep tag_search_completion)
end

switch (uname)
case "Darwin"
    set stat_fmt_flag "-f" "%z"
case "Linux"
    set stat_fmt_flag "-c" "%c"
end

function __s_complete
    set tag_files (__s_tag_files)

    set_hasher

    # set dir_hash (readlink --canonicalize local.tags | md5sum | cut --fields 1 --delimiter ' ')
    # set dir_hash (readlink -f $tag_files | md5sum | cut -f 1 -d ' ')
    set dir_hash (echo -ns "$PWD" | $HASHER | cut -f 1 -d ' ')

    # set stat_hash (stat --format '%z' local.tags | md5sum | cut --fields 1 --delimiter ' ')
    # TODO: Not sure how to use `stat` in a Gnu vs BSD neutral way
    # set stat_hash (stat --format '%z' local.tags | md5sum | cut -f 1 -d ' ')
    # set stat_hash (stat -c '%z' $tag_files | md5sum | cut -f 1 -d ' ')
    set stat_hash (stat $stat_fmt_flag $tag_files | $HASHER | cut -f 1 -d ' ')
    set suffix tag_search_completion
    set filename "/tmp/$dir_hash.$stat_hash.$suffix"

    if [ -e $filename ]
        cat $filename
        return 0
    end

    __s_cleanup $dir_hash $suffix

    __s_complete_gen | tee $filename
end

complete --command s --exclusive --condition "__s_complete_test" --arguments "(__s_complete)" --authoritative
function s \
  --description "Find the given argument in any file within the current directory or its subdirectories"
    echo "argv: $argv" >> /tmp/search.log
    search_remember s $argv
end

function _s
    ag $argv | sed --regexp-extended 's/^([^:]+):([0-9]+):/\1 \2/'
end

function l \
  --description "Grab a range of lines from file or pipe" \
  --argument-names range_start range_stop
    if [ -z "$range_stop" ]
        set range_stop $range_start
    end
    sed $range_start,$range_stop'p;'$range_stop'q' --silent
end

# complete --command f --arguments  "(ag -g '.*'  | tr '/.' \"\n\" | sort --unique)" --exclusive --authoritative
complete --command f --arguments  "(fd --strip-cwd-prefix --max-depth 7 '.*' 2>/dev/null | tr '/.' \"\n\" | sort -u)" --exclusive --authoritative
function f \
  --description "Find files with the given argument in their name in the current directory or its subdirectories"
    search_remember f $argv
end

# TODO—Use different behavior if `isatty 1` returns true...can pipe things
# straight through if we're not printing to the shell
function search_remember
    if [ (uname) = "Darwin" ]
        set tee_append "-a"
    else
        set tee_append "--append"
    end

    echo "search_remember argv: $argv"  >> /tmp/search.log
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 80
    end
    set --local mode $argv[1]
    set --local search_term $argv[2]

    # set --local tmpfile (mktemp --suffix _last_searched_files)
    set --local tmpfile (mktemp -t last_searched_files__XXXXXXXXXXXX)

    echo "tmpfile: $tmpfile"  >> /tmp/search.log

    switch (uname)
    case "Darwin"
        set more_opts more "-R"
    case "Linux"
        set more_opts less \
            --no-init \
            --quit-on-intr \
            --quit-at-eof \
            --quit-if-one-screen \
            --raw-control-chars
    end

    echo "more_opts: $more_opts"  >> /tmp/search.log

    if [ "$mode" = s ]
        rg \
            --max-count 5 \
            --color always \
            --heading \
            --line-number \
            --before-context 1 \
            --after-context 1 \
            --smart-case \
            --iglob=!(__s_tag_files) \
            $argv[2..-1] \
        | tee $tee_append /tmp/search.log \
        | numberer \
        $more_opts
        # | command $more_opts
        __search_remember_completer_s $argv[2..-1] &
    else if [ "$mode" = f ]
        fd \
            --strip-cwd-prefix \
            --color always \
            $argv[2..-1] \
        | numberer_simple \
        $more_opts
        # | command $more_opts
        __search_remember_completer_f $argv[2..-1] &
    end
end

function __search_remember_completer_s \
  --no-scope-shadowing \
  --inherit-variable sed_regex_flag
    rg \
        --smart-case --max-count 1 \
        --line-number $argv \
        --iglob=!(__s_tag_files) \
    | sed $sed_regex_flag 's/^([^:]+):([0-9]+):? *(.*)$/\1 +\2 \3/' \
    | head -n $SEARCH_OPEN_LIMIT \
    > $tmpfile
    __search_remember_close_out &
end

function __search_remember_completer_f \
  --no-scope-shadowing
    fd --strip-cwd-prefix $argv \
    | head -n $SEARCH_OPEN_LIMIT \
    > $tmpfile
    __search_remember_close_out &
end

function __search_remember_close_out \
  --no-scope-shadowing
    if test -s $tmpfile
        set --global LAST_SEARCH_TERM $search_term
        if [ -f "$LAST_SEARCHED_FILES" ]
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
    if [ "$target" = "$element" ]
        return (false)
    end

    # if begin; echo $target | grep --quiet ,; end
    if begin; echo $target | grep -q ,; end
        # set --local lower (echo $target | cut --fields 1 --delimiter ',')
        set --local lower (echo $target | cut -f 1 -d ',')
        # set --local upper (echo $target | cut --fields 2 --delimiter ',')
        set --local upper (echo $target | cut -f 2 -d ',')

        if [ "$lower" = '.' ]
            set lower 0
        end

        if [ "$upper" = \$ ]
            set upper (math "1 + $element")
        end

        # if begin; echo $upper | grep --quiet +; end
        if begin; echo $upper | grep -q +; end
            # set --local tmp_upper (echo $upper | cut --fields 2 --delimiter +)
            set --local tmp_upper (echo $upper | cut -f 2 -d +)
            if test -z $tmp_upper
                set tmp_upper 0
            end
            set upper (math "$lower + $tmp_upper")
        end

        if [ \( "$element" -ge "$lower" \) -a \( "$element" -le "$upper" \) ]
            return (false)
        end
    end

    return (true)
end

function __vs_complete_arg_filter_gen --argument-names counter
    # source (echo 'function __vs_complete_arg_filter_'$counter'; set current_args (__fish_print_cmd_args) ; if ≥ (count $current_args) 2 ; for arg in $current_args[2..-1] ; if not __vs_complete_allows $arg '$counter' ; return (false) ; end ; end ; end ; return (true) ; end' | psub)
    eval '
        function __vs_complete_arg_filter_'$counter'
            set current_args (__fish_print_cmd_args)
            if [ (count $current_args) -ge 2 ]
                for arg in $current_args[2..-1]
                    if not __vs_complete_allows $arg '$counter'
                        return (false)
                    end
                end
            end
            return (true)
        end
    '
    echo __vs_complete_arg_filter_$counter
end

function __vf_complete_arg_filter_gen --argument-names counter path
    set --local escaped_path (string escape "$path")
    eval '
        function __vf_complete_arg_filter_'$counter'
            not contains '$escaped_path' (__fish_print_cmd_args | tail -n +2)
        end
    '
    echo __vf_complete_arg_filter_$counter
end

function vs
    if [ '0' = (count $argv) ]
        set files (recently_searched_files)
    else
        set files (recently_searched_files | get_lines $argv)
    end
    # vim $files +"Ag $LAST_SEARCH_TERM $files" +"let @/ = '$LAST_SEARCH_TERM'" +"set hlsearch"
    vim $files +"let @/ = '$LAST_SEARCH_TERM'" +"set hlsearch"
end

# why not include both vs and vf? vs for select and vf for file?
function vf
    vim $argv +"let @/ = '$LAST_SEARCH_TERM'" +"set hlsearch"
end

function _gen_vs_completions
    complete --command vs --erase
    set --local counterer 1
    for match in (cat $LAST_SEARCHED_FILES)
        complete \
            --command vs \
            --condition (__vs_complete_arg_filter_gen $counterer) \
            --argument $counterer \
            --description ''$match'' \
            --no-files \
            --authoritative
        set counterer (math "1 + $counterer")
    end
end

# Orig
#
# Didn't include the 'description' of the search findings like the
# modified version does.
#
# function _gen_vf_completions
#     complete --command vf --erase
#     set --local counterer 1
#     # for file in (cat $LAST_SEARCHED_FILES | cut --fields 1 --delimiter ' ')
#     for file in (cat $LAST_SEARCHED_FILES | cut -f 1 -d ' ')
#         complete --command vf --condition ( \
#             __vf_complete_arg_filter_gen $counterer $file \
#         ) --argument (string escape $file) --description (basename $file) --no-files --authoritative
#         set counterer (math "1 + $counterer")
#     end
# end

function _gen_vf_completions
    complete --command vf --erase
    set --local counterer 1
    # for file in (cat $LAST_SEARCHED_FILES | cut --fields 1 --delimiter ' ')
    for match in (cat $LAST_SEARCHED_FILES)
        echo -ns $match | read --local --delimiter=' ' file desc
        complete --command vf --condition ( \
            __vf_complete_arg_filter_gen $counterer $file \
        ) --argument (string escape $file) --description "$desc" --no-files
        set counterer (math "1 + $counterer")
    end
end

function numberer_simple
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 80
    end

    # set --local counter_padded_size (amath "length($SEARCH_OPEN_LIMIT)")
    set --local counter_padded_size (echo "length($SEARCH_OPEN_LIMIT)" | bc -l)
    set --local counter_finished (echo $SEARCH_OPEN_LIMIT | tr '01234567890' ' ')

    set --local counter 1

    while read line
        if [ "$counter" -le "$SEARCH_OPEN_LIMIT" ]
            set counter_string (printf '%-'$counter_padded_size'i ' $counter)
            set counter (math "1 + $counter")
        else
            set counter_string "$counter_finished "
        end
        echo $counter_string$line
    end
end

function numberer
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 80
    end
    echo "SEARCH_OPEN_LIMIT: $SEARCH_OPEN_LIMIT" >> /tmp/search.log

    # set --local counter_padded_size (amath "length($SEARCH_OPEN_LIMIT)")
    set --local counter_padded_size (echo "length($SEARCH_OPEN_LIMIT)" | bc -l)
    echo "counter_padded_size: $counter_padded_size" >> /tmp/search.log
    set --local counter_finished (echo $SEARCH_OPEN_LIMIT | tr '01234567890' ' ')
    echo "counter_finished: $counter_finished" >> /tmp/search.log

    set --local blank true
    set --local counter 1

    echo "counter: $counter" >> /tmp/search.log

    while read line
        echo "line: $line" >> /tmp/search.log
        if [ "$counter" -le "$SEARCH_OPEN_LIMIT" ]
            if eval $blank
                if not test -z $line
                    set counter_string (printf '%-'$counter_padded_size'i ' $counter)
                    set counter (math "1 + $counter")
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
    if [ 1 = (count $argv) ]
        # sed --quiet ''$argv[1]'p'
        sed -n ''$argv[1]'p'
    else
        # set --local get_lines_file (mktemp --suffix _get_lines_helper)
        set --local get_lines_file (mktemp -t get_lines_helper__XXXXXXXXXXXX)

        while read line
            echo $line >> $get_lines_file
        end

        for specifier in $argv
            # cat $get_lines_file | sed --quiet ''$specifier'p'
            cat $get_lines_file | sed -n ''$specifier'p'
        end
        rm $get_lines_file
    end
end

function recently_searched_files
    if not set --query LAST_SEARCHED_FILES
        echo \n
    end
    # cat $LAST_SEARCHED_FILES | cut --fields 1 --delimiter ' ' | uniq
    cat $LAST_SEARCHED_FILES \
    | cut -f 1 -d ' ' \
    | uniq
end
### END SEARCH SECTION

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

function bundle-bootstrap
    bundle install --shebang (which ruby) --binstubs=.bundle/bin --path .bundle/gems
end

abbr --add rx "rbenv exec"
abbr --add rxb "rbenv exec bundle exec"

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

function blerg --argument-names the_royal_nergin
    echo blerg $the_royal_nergin ferg snerg
end

function lsusers \
  --description "List all users"
    cat /etc/passwd
end

function xcape_defaults \
  --description "Run xcape keymappings"
    # # For faster tmux use
    # xcape -e 'Alt_L=Control_L|S'
    # # For vim happiness
    # xcape -e 'Control_L=Escape'
    # # For fast parens
    # xcape -e 'Shift_L=Shift_L|9'
    # xcape -e 'Shift_R=Shift_R|0'

    pkill xcape

    xcape -e 'Alt_L=Control_R|S;Control_L=Escape;Shift_L=Shift_L|9;Shift_R=Shift_R|0'
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

# function rtags \
#   --description "Generate ctags for a ruby project in a separate tmux session"
#     set --export TMUX (tmux new-session -s "rtags "(basename (pwd)) -P -d -c "#{pane_current_path}" __rtags)
# end

function rtags \
  --description "Generate ctags for a ruby project"
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
    prevd
end

# function less
#     command less --RAW-CONTROL-CHARS $argv
# end

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

    fish --interactive --debug 3 --profile $pro_file 2>$log_file
end

function remove_if_in_commandline
    set current (commandline --tokenize)

    while read line
        if not contains $line $current
            echo -s $line
        end
    end
end

# TODO: Add version switch for fd-find to exclude --strip-cwd-prefix if
# version is less than 8.0
complete \
    --command vim \
    --condition '[ "$PWD" != "$HOME" ]' \
    --argument '(fd --strip-cwd-prefix --max-depth 7 2>/dev/null | remove_if_in_commandline)'
    # --argument '(fd --max-depth 7 2>/dev/null | remove_if_in_commandline)'
# complete --command vim --condition '[ "$PWD" != "$HOME" ]' --argument '(fd --max-depth 7 \'.*\' 2>/dev/null | remove_if_in_commandline)'
# complete --command vim --authoritative --argument '(ag --depth 7 --max-count 250 -g \'.*\' 2>/dev/null)'

# complete --command vim --condition 'test -e .gitignore' --authoritative --argument '(ag --depth 8 --max-count 40 -g \'.*\')'
# complete --command vim --condition 'true' --authoritative --argument '(ag --depth 8 --max-count 40 -g ""(__fish_print_cmd_args | ta (count __fish_print_cmd_args))"" 2>/dev/null)'

if == (uname) Darwin
    function postgres_start_server
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
    end
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

complete --command aws_env --arguments "(ls ~/.aws/profiles/ | remove_if_in_commandline)" --authoritative --exclusive
function aws_env
    if [ (uname) = "Darwin" ]
        set suffix_arg "-s"
    else
        set suffix_arg "--suffix"
    end

    for arg in $argv
        set AWS_VAULT (basename $suffix_arg .gpg $arg)
        set env_args $env_args AWS_VAULT="$AWS_VAULT"
        set env_args $env_args AWS_ENV="$AWS_VAULT"
        if string match --quiet --regex '\.gpg$' "$arg"
            set env_args $env_args (gpg --decrypt ~/.aws/profiles/"$arg")
        else
            set env_args $env_args (cat ~/.aws/profiles/"$arg")
        end
    end

    env $env_args fish
end

function title_case --argument-names word
    while read word
        echo -n (string sub --start 1 --length 1 $word | string upper)(string sub --start 2 $word | string lower)\n
    end
end

function screaming_snake_to_cap_camel
    while read input
        string split '_' $input | title_case | string join ''
    end
end

function aws_load_role2 \
    --argument-names role_file

    for prop in ACCESS_KEY_ID SECRET_ACCESS_KEY SESSION_TOKEN
        set --export AWS_$prop (\
            cat $role_file \
            | jq \
                .Credentials.(echo $prop | screaming_snake_to_cap_camel) \
                --raw-output \
        )
    end

    set --export AWS_ENV (\
        cat $role_file \
        | jq .AssumedRoleUser.Arn --raw-output \
    )

    fish
end

function aws_assume_role --argument-names \
    account_id \
    role_name \
    session_name \
    external_id

    set aws_args \
    --role-arn arn:aws:iam::$account_id:role/$role_name \
    --role-session-name $session_name

    if [ -n "$external_id" ]
        set aws_args --external-id $external_id $aws_args
    end

    aws_load_role (aws sts assume-role $aws_args | psub)
end

function aws_load_role \
    --argument-names role_file

    set jq_template (string join \\n \
        '"AWS_SESSION_TOKEN=\(.Credentials.SessionToken)' \
        'AWS_ACCESS_KEY_ID=\(.Credentials.AccessKeyId)' \
        'AWS_SECRET_ACCESS_KEY=\(.Credentials.SecretAccessKey)' \
        'AWS_ENV=\(.AssumedRoleUser.Arn)"' \
    )

    env (cat $role_file | jq --raw-output $jq_template) fish
end

function aws_docker
    # --tty \
    sudo -E docker run \
    --interactive \
    --rm \
    --env=AWS_{ACCESS_KEY_ID,DEFAULT_REGION,SECRET_ACCESS_KEY} \
    --volume $PWD:/aws \
    amazon/aws-cli \
    --no-paginate \
    --color=off \
    $argv
end

# abbr --add pst  "xclip -out -selection clipboard"
# abbr --add cpy  system_clipboard

function pst
    if which xclip >/dev/null 2>/dev/null
        xclip -out -selection clipboard
    else if which pbpaste >/dev/null 2>/dev/null
        pbpaste
    else
        cat >/dev/null
    end
end

function system_clipboard
    if which xclip >/dev/null 2>/dev/null
        xclip -in -selection clipboard
    else if which pbcopy >/dev/null 2>/dev/null
        pbcopy
    else
        cat >/dev/null
    end
end

# want a dedicated function rather than an expansion
function cpy
    system_clipboard
end

function clear_system_clipboard
    echo -ns | system_clipboard
end

function record --argument-names file_name
    if [ -z "$file_name" ]
        set file_name recording
    end

    asciinema rec --idle-time-limit 0.25 "$file_name.cast" \
    && cast2gif "$file_name.cast" "$file_name.gif"
end
