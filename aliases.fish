set --universal aliases ~/dotfiles/aliases.fish

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

function __fish_print_cmd_args
    commandline --current-process --tokenize --cut-at-cursor
end

function __fish_print_cmd_args_without_options
    __fish_print_cmd_args | grep '^[^-]'
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
    while [ $n -le $total_functions -a $i -le $total_matches ]
        if [ $argv[$i] -ge $func_start_lines[$n] -a $argv[$i] -lt $func_end_lines[$n] ]
            set next_index (math (count $out_start_lines)" + 1")
            set out_start_lines[$next_index] $func_start_lines[$n]
            set out_end_lines[$next_index]   $func_end_lines[$n]
            set i (math "$i + 1")

            # Eat up additional grep matches for $target
            # from the current function block (i.e., move on
            # from any further grepped matches in this current
            # function...we already marked this block for output)
            # while [ $i -le $total_matches -a $argv[$i] -ge $out_start_lines[-1] -a $argv[$i] -lt $out_end_lines[-1] ]
            while begin; [ $i -le $total_matches ]
                     and [ $argv[$i] -ge $out_start_lines[-1] ]
                     and [ $argv[$i] -lt $out_end_lines[-1] ]
                  end
                set i (math "$i + 1")
            end
        end
        set n (math "$n + 1")
    end

    set total_results (count $out_start_lines)
    set m 1
    while [ $m -le $total_results ]
        cat $aliases \
        |   head --lines $out_end_lines[$m] \
        |   tail --lines (math "$out_end_lines[$m] - $out_start_lines[$m] + 1")
        set m (math "$m + 1")
    end
    return 0
end

function bpac
    ~/stuffs/baltimore_public_art_commons
end

# function func_blocks \
#   --description "Output surrounding function blocks from "$aliases" from line numbers in argv"
#     set func_start_lines (line_number_matches '^function ' $aliases)
#     set func_end_lines   (line_number_matches '^end'       $aliases)

#     set out_start_lines
#     set out_end_lines

#     set total_matches (count $argv)
#     set i 1
#     set total_functions (count $func_start_lines)
#     set n 1
#     while begin; ≤ $n $total_functions
#              and ≤ $i $total_matches
#       end
#         if  begin; ≥ $argv[$i] $func_start_lines[$n]
#                and « $argv[$i] $func_end_lines[$n]
#             end
#             set next_index (++ (count $out_start_lines))
#             set out_start_lines[$next_index] $func_start_lines[$n]
#             set out_end_lines[$next_index]   $func_end_lines[$n]
#             set i (++ $i)

#             # Eat up additional grep matches for $target
#             # from the current function block (i.e., move on
#             # from any further grepped matches in this current
#             # function...we already marked this block for output)
#             while begin; ≤ $i $total_matches
#                      and ≥ $argv[$i] $out_start_lines[-1]
#                      and « $argv[$i] $out_end_lines[-1]
#                   end
#                 set i (++ $i)
#             end
#         end
#         set n (++ $n)
#     end

#     set total_results (count $out_start_lines)
#     set m 1
#     while ≤ $m $total_results
#         cat $aliases \
#         |   head -n $out_end_lines[$m] \
#         |   tail -n (++ (— $out_end_lines[$m] $out_start_lines[$m]))
#         set m (++ $m)
#     end
#     return 0
# end

function amath \
  --description "'Advanced' math (bc with math library option)"
    echo $argv | bc --mathlib
end

complete --command secrify --arguments "(complete --do-complete='gpg --recipient ')" --authoritative --exclusive
function secrify --argument-names recipient
    set text_filename ~/Downloads/text.txt
    set encrypted_filename "$text_filename.gpg"
    if [ -e $encrypted_filename ]
        rm  $encrypted_filename
    end
    vim $text_filename
    and gpg --recipient $recipient --encrypt $text_filename
    and echo > $text_filename
    echo $encrypted_filename
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
    test $left_side -lt $right_side
end

function ≤ --argument-names left_side right_side
    test $left_side -le $right_side
end

function » --argument-names left_side right_side
    test $left_side -gt $right_side
end

function ≥ --argument-names left_side right_side
    test $left_side -ge $right_side
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
    sed --unbuffered --expression "s/\([^)]\);\s*/\1\n/g" $target \
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
    cat $target
    # if test (which pygmentize)
    #     pygmentize -lbash $target
    # else
    #     cat $target
    # end
end

function __grep_highlight --argument-names target
    # helper
    while read line
        if test (echo $line | grep -l $target ^ /dev/null)
            echo $line | grep $target
        else
            echo $line
        end
    end
    return 0
end

function up
    ..
end

function bk
    prevd $argv
end

function fd
    nextd $argv
end

function hm
    ~
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

abbr --add bx "bundle exec"
complete --command bundle --condition "[ (commandline | tr --squeeze-repeats ' ' | sed 's/^ //g' | grep ' ' --only-matching | wc --lines) -ge 2 -a (commandline | cut --fields 2 --delimiter ' ') = exec ]" --arguments "(__fish_complete_subcommand -- -u --unset)"
complete --command bundle --condition "[ (commandline | tr --squeeze-repeats ' ' | sed 's/^ //g' | grep ' ' --only-matching | wc --lines) -ge 3 -a (commandline | cut --fields 2 --delimiter ' ') = exec ]" --arguments "(complete --do-complete=(commandline | sed 's/^ *bundle *exec *//'))" --authoritative
complete --command bx --arguments "(complete --do-complete=(commandline | sed 's/^bx //'))"
function bx
    bundle exec $argv
end

complete --command boot2docker --arguments "(boot2docker ^| sed 's/^.*{\(.*\)}.*\$/\1/' | tr '|' '\n')" --authoritative --exclusive

function pru
    rvm 2.2.0 exec pru $argv
end

function boot2docker_local_ip
    boot2docker config | grep Lower | sed 's/^.*"\(.*\)"$/\1/'
end

function copy_github_password
    lpass show --notes --clip 4904780006
end

set __cucumber_formatters debug\tFor developing formatters - prints the calls made to the listeners.\nhtml\tGenerates a nice looking HTML report.\njson\tPrints the feature as JSON\njson_pretty\tPrints the feature as prettified JSON\njunit\tGenerates a report similar to Ant+JUnit.\npretty\tPrints the feature as is - in colours.\nprogress\tPrints one character per scenario.\nrerun\tPrints failing files with line numbers.\nstepdefs\tPrints All step definitions with their locations.\nusage\tPrints where step definitions are used.\nCucumberNc\tUse OS X notifications.

function __cucumber_formatters
    echo "debug:For developing formatters - prints the calls made to the listeners.
html:Generates a nice looking HTML report.
json:Prints the feature as JSON
json_pretty:Prints the feature as prettified JSON
junit:Generates a report similar to Ant+JUnit.
pretty:Prints the feature as is - in colours.
progress:Prints one character per scenario.
rerun:Prints failing files with line numbers.
stepdefs:Prints All step definitions with their locations.
usage:Prints where step definitions are used.
CucumberNc:Use OS X notifications."
end


complete --command cucumber --short-opt r --long-opt require --description "Require files before executing the features." --require-parameter
complete --command cucumber --long-opt i18n --description "List keywords for in a particular language." --arguments "(bundle exec cucumber --i18n help | sed 's/\s*|\s*/|/g' | sed --regexp-extended 's/^\|([^|]+)\|([^|]+)\|.+\$/\1\t\2/g')" --exclusive --authoritative --no-files
# complete --command cucumber --short-opt f --long-opt format --arguments "(echo -n $__cucumber_formatters)" --description "How to format features (Default: pretty)." --no-files --require-parameter
complete --command cucumber --short-opt f --long-opt format --arguments "(__cucumber_formatters | tr ':' '\t')" --description "How to format features (Default: pretty)." --no-files --require-parameter
complete --command cucumber --short-opt o --long-opt out --description "Write output to a file/directory instead of STDOUT." --require-parameter

function __cucumber_tags
    bundle exec cucumber --dry-run --require ~/dotfiles/list_tags.rb --format Cucumber::Formatter::ListTags | sed 's/^\(.*\)$/\1\n~\1/g'
end

complete --command cucumber --short-opt t --long-opt tags --arguments "(__cucumber_tags)" --description "Only execute the features or scenarios with tags matching TAG_EXPRESSION." --require-parameter
complete --command cucumber --short-opt n --long-opt name --description "Only execute the feature elements which match part of the given name." --require-parameter
complete --command cucumber --short-opt e --long-opt exclude --description "Don't run feature files or require ruby files matching PATTERN." --require-parameter
complete --command cucumber --short-opt p --long-opt profile --description "Pull commandline arguments from cucumber.yml."
complete --command cucumber --short-opt P --long-opt no-profile --description "Disables all profile loading to avoid using the 'default' profile."
complete --command cucumber --short-opt c --long-opt color --description "Use ANSI color in the output."
complete --command cucumber --long-opt no-color --description "Don't use ANSI color in the output."
complete --command cucumber --short-opt d --long-opt dry-run --description "Invokes formatters without executing the steps."
complete --command cucumber --short-opt a --long-opt autoformat --description "Reformats (pretty prints) feature files and write them to DIRECTORY." --require-parameter
complete --command cucumber --short-opt m --long-opt no-multiline --description "Don't print multiline strings and tables under steps."
complete --command cucumber --short-opt s --long-opt no-source --description "Don't print the file and line of the step definition with the steps."
complete --command cucumber --short-opt i --long-opt no-snippets --description "Don't print snippets for pending steps."
complete --command cucumber --short-opt I --long-opt snippet-type --description "Use different snippet type (Default: regexp)." --require-parameter --no-files

function __cucumber_snippet_types
    # TODO
    echo "
     classic: Snippets without parentheses. Note that these cause a warning from modern versions of Ruby. e.g. Given /^missing step\$/
     percent: Snippets with percent regexp e.g. Given %r{^missing step\$}
     regexp : Snippets with parentheses    e.g. Given(/^missing step\$/)
     "
 end

complete --command cucumber --short-opt q --long-opt quiet --description "Alias for --no-snippets --no-source."
complete --command cucumber --short-opt b --long-opt backtrace --description "Show full backtrace for all errors."
complete --command cucumber --short-opt S --long-opt strict --description "Fail if there are any undefined or pending steps."
complete --command cucumber --short-opt w --long-opt wip --description "Fail if there are any passing scenarios."
complete --command cucumber --short-opt v --long-opt verbose --description "Show the files and features loaded."
complete --command cucumber --short-opt g --long-opt guess --description "Guess best match for Ambiguous steps."
complete --command cucumber --short-opt l --long-opt lines --description "Run given line numbers. Equivalent to FILE:LINE syntax" --require-parameter
complete --command cucumber --short-opt x --long-opt expand --description "Expand Scenario Outline Tables in output."
complete --command cucumber --long-opt drb --description "Run features against a DRb server. (i.e. with the spork gem)"
complete --command cucumber --long-opt no-drb --description "Don't run features against a DRb server. (i.e. with the spork gem)"
complete --command cucumber --long-opt port --description "Specify DRb port. Ignored without --drb" --require-parameter
complete --command cucumber --long-opt dotcucumber --description "Write metadata to DIR" --require-parameter
complete --command cucumber --long-opt version --description "Show version."
complete --command cucumber --short-opt h --long-opt help --description "You're looking at it."

function rsh
    pry --require rake
end

function in_git_repo
    gs ^ /dev/null
end

function git-branch-activity
    # From
    # http://stackoverflow.com/questions/11135052/how-to-list-only-active-recently-changed-branches-in-git
    git for-each-ref --format='%(committerdate:short) %(refname)' refs/heads refs/remotes | sort
end

function git-recent --description "Show recent activity on all branches"
    git-branch-activity | tail --lines 6
end

function gdb --argument-names commit_number
    if [ (count $argv) -gt 1 ]
        set more_args $argv[2..-1]
    end

    git diff --compaction-heuristic --ignore-space-change HEAD~$commit_number HEAD~(math "$commit_number - 1") $more_args
end

complete --command git-branch-delete \
         --condition "[ -d ./.git ]" \
         --arguments "(
           complete --do-complete='git branch -d '
         )" \
         --exclusive \
         --authoritative

function git-branch-delete \
    --argument-names branch \
    --description "Delete branch locally and at origin"
    git push origin :$branch
    and git branch -d $branch
end

abbr --add gd  "git diff --ignore-space-change --color --compaction-heuristic"
abbr --add gs  "git status --short"
abbr --add gch "git checkout"
abbr --add gbk "git checkout -"
abbr --add gl  "git log"
abbr --add gbb  "git branch"
abbr --add gds "git diff --stat"
abbr --add gp  "git pull --rebase=preserve"
abbr --add gf  "git fetch"
abbr --add GP  "git push"
abbr --add GPF  "git push --force"
abbr --add GPU "git push --set-upstream origin (git rev-parse --abbrev-ref HEAD)"
abbr --add gst "git stash"
abbr --add gsp "git stash pop"
abbr --add git-current-branch "git rev-parse --abbrev-ref HEAD"
abbr --add gcb "git rev-parse --abbrev-ref HEAD"
abbr --add gcur "git rev-parse --abbrev-ref HEAD"
abbr --add glg "git log --graph --oneline --all --decorate --color"
abbr --add glw "watch --color --differences --no-title --interval=0.1 'git log --graph --oneline --all --decorate --color | head --lines \$LINES | sed --regexp-extended \"s/(^((\x1B\[[0-9;]*m)*[^\x1B]){0,\$COLUMNS}).*\$/\1\x1B[m/\"'"
abbr --add gla "git log --graph --all --decorate --color"
abbr --add gsmod "git ls-files --modified"
abbr --add gsdel "git ls-files --deleted"
abbr --add gsnew "git status --short | sed --silent 's/^?? //p'"

abbr --add vsp "rvm 2.2 @global do /usr/local/bin/vim --cmd 'let g:sonicpi_enabled = 1'"

abbr --add dkr 'docker (docker-machine config)'


complete --command gfwd \
         --condition "[ -d ./.git ]" \
         --arguments "(
           complete --do-complete='git checkout '
         )" \
         --exclusive \
         --authoritative
function gfwd --argument-names target_commit --description "Go forward toward <target-commit> in git"
    git checkout (git rev-list --topo-order HEAD.."$target_commit" | tail --lines 1)
end

function jira-link-md
    set --local jira_ticket_num (git-current-branch | cut --fields 1 --delimiter _ | cut --fields 1,2 --delimiter '-')
    echo -n "[$jira_ticket_num](https://distil.atlassian.net/browse/$jira_ticket_num)"
end

function gme \
    --description "Edit files with merge conflicts"
    vim (git status --porcelain | sed --regexp-extended --quiet "/^UU /s/^UU //p")
end

function jira-name-to-branch-name
    if [ -z "$argv" ]
        echo (pbpaste)
    else
        echo $argv
    end | tr '._ ' '-' | tr 'A-Z' 'a-z'
end

function __fish_rust_error_diagnostics_file
    if not set --query RUST_SRC_PATH
        set RUST_SRC_PATH ~/stuffs/rust/rust/src
    end

    echo $RUST_SRC_PATH/librustc_typeck/diagnostics.rs
end

function __fish_rust_error_diagnostics
    cat (__fish_rust_error_diagnostics_file) | gawk '
        BEGIN { msg = "" }

        !!(err) && match($0, /^([^.]+)\./, ary) {
            out = err "'\t'" msg ary[1]
            print out
            err = ""
            msg = ""
        }

        !!(err) && msg != "" { msg = msg $0 " " }
        !!(err) && msg == "" { msg = $0 " " }

        match($0, /^(E[0-9]{4}): r#+"$/, ary) {
            err = ary[1]
        }
    '
end

complete --command rustc \
         --long-opt explain \
         --description "Provide a detailed description of an error message" \
         --condition "[ -e (__fish_rust_error_diagnostics_file) ]" \
         --arguments "(__fish_rust_error_diagnostics)" \
         --authoritative \
         --exclusive

function gsolt \
  --description "Default git push for minor tweak for soluteandsolvent.com subdomain"
    git commit --all --message $argv
    and git push origin master
    and git push dokku master
end

abbr --add cne "crontab -e"

function where --argument-names target \
  --description "Get the directory of an executable"
    dirname (which $target)
end

function toggle-nvim
    set app_idx           (contains --index /Users/scott/apps $PATH)
    set usr_local_bin_idx (contains --index /usr/local/bin $PATH)

    set PATH[ $app_idx ]           /usr/local/bin
    set PATH[ $usr_local_bin_idx ] /Users/scott/apps

    readlink --canonicalize (which vim)
end

function gh --argument-names user repo
    git clone "git@github.com:$user/$repo.git"
end

function ghcd \
  --argument-names user repo
    # git clone "git@github.com:$user/$repo.git"
    git clone "https://github.com/$user/$repo"
    and cd $repo
end

abbr --add pp "pygmentize"

# Note: Largely from
# http://robots.thoughtbot.com/silver-searcher-tab-completion-with-exuberant-ctags
function __s_complete_gen
    cut --fields 1 local.tags ^/dev/null \
    | grep --invert-match '!_TAG' \
    | uniq
end

function __s_complete_test
    [ -e local.tags ]
end

function __s_cleanup --argument-names dir_hash suffix
    for stale_file in (ls /tmp/ | grep $dir_hash)
        rm /tmp/$stale_file
    end
end

function __s_complete
    set dir_hash (readlink --canonicalize local.tags | md5sum | cut --fields 1 --delimiter ' ')
    set stat_hash (stat --format '%z' local.tags | md5sum | cut --fields 1 --delimiter ' ')
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
    search_remember $argv
end

function _s
    ag $argv | sed --regexp-extended 's/^([^:]+):([0-9]+):/\1 \2/'
end

function ta --argument idx \
  --description "Shortcut for commonly used cut functionality"
  cut --delimiter ' ' --fields $idx
end

function sf \
  --description "Print out filenames where pattern occurs"
    s $argv | cut --fields 3 --delimiter ' ' | sort --unique
end

function vsf \
  --description 'Because vim (sf $argv) takes too long'
    vim (sf $argv) +/$argv[1]
end

function l \
  --description "Grab a range of lines from file or pipe" \
  --argument-names range_start range_stop
    if [ -z "$range_stop" ]
        set range_stop $range_start
    end
    sed $range_start,$range_stop'p;'$range_stop'q' --silent
end

function paj \
  --description "Paginate result chunk" \
  --argument-names increment chunk
    set startIndex (× (++ $chunk) $increment)
    head --lines $startIndex \
    | tail --lines $increment
end

function md
    mkdir --parents $argv
    and cd $argv
end

function psfind \
  --description "Search for processes with a given string."
    # Usually better to just use process expansion (with the percent
    # sign) instead of this
    ps -A \
    | grep $argv \
    | grep grep --invert-match
end

function bundle-bootstrap
    bundle install --shebang (which ruby) --binstubs=.bundle/bin --path .bundle/gems
end

function yaml
    ~/dotfiles/yaml_runner.rb $argv
end

function remove_dangling_docker_images
    set dangling_images (docker (docker-machine config) images --quiet --filter "dangling=true")
    if count $dangling_images > /dev/null
        docker (docker-machine config) rmi $dangling_images
    end
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
    if not [ -d $origin ]
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

function factor_roots
    set roots (cat ~/.factor-roots)
    if [ (basename $PWD) = factor ]
        set roots $roots $PWD
    end
    if [ -d ./factor ]
        set roots $roots $PWD/factor
    end
    echo -ns :$roots | tail --bytes +2
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

# TODO—Use different behavior if `isatty 1` returns true...can pipe things
# straight through if we're not printing to the shell
function search_remember
    if not set --query SEARCH_OPEN_LIMIT
        set SEARCH_OPEN_LIMIT 20
    end
    set --local search_term $argv[1]

    set --local tmpfile (mktemp --suffix _last_searched_files)

    if == $_ s
        set --local s_opts --ignore tags --ignore log --ignore local.tags --ignore .min.js --ignore '*.dump' --ignore docs --ignore doc --smart-case --skip-vcs-ignores --silent
        ag --max-count 5 --{color,head,break,group} --context=1 --before=1 $s_opts $argv | numberer | less -R
        __search_remember_completer_s $argv &
    else if == $_ f
        ag --color --skip-vcs-ignores -g $argv | numberer_simple
        __search_remember_completer_f $argv &
    end
end

function __search_remember_completer_s \
  --no-scope-shadowing
    ag --max-count 1 $s_opts $argv | sed --regexp-extended 's/^([^:]+):([0-9]+):/\1 \2/' | head --lines $SEARCH_OPEN_LIMIT > $tmpfile
    __search_remember_close_out &
end

function __search_remember_completer_f \
  --no-scope-shadowing
    ag --skip-vcs-ignores -g $argv | head --lines $SEARCH_OPEN_LIMIT > $tmpfile
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

function load-thor-completions --argument-names thor_app
    if [ -f "$thor_app" ]
        set thor_app "./$thor_app"
    end

    eval (eval $thor_app completions --format fish)
end

function _gen_vf_completions
    complete --command vf --erase
    set --local counterer 1
    for file in (cat $LAST_SEARCHED_FILES | cut --fields 1 --delimiter ' ')
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
    cat $LAST_SEARCHED_FILES | cut --fields 1 --delimiter ' ' | uniq
end

function blerg --argument-names the_royal_nergin
    if [ -z "$the_royal_nergin" ]
        echo blerg ferg snerg
    else
        echo blerg $the_royal_nergin ferg snerg
    end
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
    set --universal teh_bots ~/codes/bots

    tmux new-window -c $teh_bots/reporting-bot
    tmux split-window -h -c $teh_bots/queue-bot
    tmux split-window -h -c $teh_bots/parse-bot
    tmux select-layout even-horizontal
    tmux select-pane -L
    tmux select-pane -L
    tmux split-window -v -c $teh_bots/summary-bot
    tmux select-pane -R
    tmux split-window -v -c $teh_bots/retention-bot
    tmux select-pane -R
    tmux split-window -v -c $teh_bots/cleanup-bot
    tmux select-pane -L
    tmux select-pane -L
    tmux set-option synchronize-panes on

    set --erase teh_bots
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
    tmux new-session -c ~/codes/bots -s Alp -d
    open_bot_windows
    tmux send-keys t a i l Space '-' '-' f o l l o w Space l o g '/' '*' '-'  b o t '.' l o g Enter
    all_bots_skiq $argv
    tmux -2 -q attach -t Alp
end

function fancy_foreman \
  --description "foreman with RubyMine Ruby args"
    # Attempt to mimic RubyMine foreman setup
    # How to use tail came from coderwall.com/p/6qdp5a
    ruby -e '$stdout.sync=true;$stderr.sync=true;load($0=ARGV.shift)' (which foreman) \
        $argv \
        --procfile=(cat "$PWD/Procfile" (echo \n"log: tail --follow $PWD/log/development.log"\n"sidekiq: tail --follow $PWD/log/sidekiq.log" | psub) | psub) \
        --root=$PWD
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

abbr --add rgd "rvm 2.2 @global do"

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
    ctags -R --exclude=doc{,s} --exclude=\*.tags --exclude=prototype . $gemdir
    rdoc --format=tags --ctags-merge --exclude=.log --exclude=doc{,s} --exclude=tags --exclude=prototype --exclude=.tags .

    # So hacky  :(
    # Can't figure out how to tell rdoc to use a different file
    mv tags .global.tags

    echo 'Generating local ctags...'
    # rvm 2.2 @global do starscope --export=ctags,tags --exclude .js --exclude .coffee --exclude tags --exclude local.tags --exclude tmp/ --exclude log/
    ctags -R --exclude=doc{,s} --exclude=\*.tags --exclude=prototype .
    rdoc --format=tags --ctags-merge --exclude=.log --exclude=doc{,s} --exclude=tags --exclude=prototype --force-update --exclude=.tags .

    # completion of gross hack
    mv tags local.tags
    mv .global.tags tags

    # Disabling for now due to so slow...need to cache
    # or something
    # echo 'Generating ri-tags...'
    # gmd --local

    return 0
end

    # function skiq \
    #   --description "Startup sidekiq worker"
    # env REDIS_PORT_6379_TCP_ADDR=127.0.0.1 POSTGRES_PORT_5432_TCP_ADDR=localhost rerun --background --no-growl --pattern '{**/*.rb}' -- bundle exec sidekiq -r ./main.rb -e development -C ./config/sidekiq.yml --verbose
abbr --add skiq "rerun --background --no-growl --pattern '{**/*.rb}' -- bundle exec sidekiq --require ./main.rb --environment development --config ./config/sidekiq.yml --verbose"
    # end

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

complete --command vim --condition '[ (pwd) != "$HOME" ]' --authoritative --argument '(ag --depth 7 --max-count 250 -g \'.*\' ^/dev/null)'
complete --command nvim --wraps vim
# complete --command vim --condition 'test -e .gitignore' --authoritative --argument '(ag --depth 8 --max-count 40 -g \'.*\')'

# What does this even do?
# complete --command vim --condition 'true' --authoritative --argument '(ag --depth 8 --max-count 40 -g ""(__fish_print_cmd_args | cut --delimiter \' \' --fields (count __fish_print_cmd_args))"" ^/dev/null)'

    if [ (uname) -a Darwin ]
function postgres_start_server
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
end
    end

for project in ~/codes/{prism,portal,api,database-migrations,automation-rlw,hannibal} ~/codes/bots/* ~/go/src/github.com/distil/*
    set --local project (echo $project | sed 's#/$##')
    echo "function "(basename $project)"
        cd $project
    end" | source
    if functions --query addzhist
        z --add "$project"
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

complete --command pout --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
# complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | cut --fields 2 --delimiter " " | grep --quiet distil_summary;   end' --arguments 'summary.(ls_summary_tables)'     --exclusive --authoritative
# complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | cut --fields 2 --delimiter " " | grep --quiet distil_reporting; end' --arguments 'reporting.(ls_reporting_tables)' --exclusive --authoritative
# complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | cut --fields 2 --delimiter " " | grep --quiet postgres; end'         --arguments 'public.(ls_parse_tables)'        --exclusive --authoritative
complete --command pout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " " | tr --delete " "); end'  --arguments '(ls_psql_schema_tables (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " "))' --exclusive --authoritative
function pout --argument-names dbname schema_table
    pcoms $dbname "SELECT * FROM $schema_table"
end

complete --command pfout --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
# complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | cut --fields 2 --delimiter " " | grep --quiet distil_summary;   end' --arguments 'summary.(ls_summary_tables)'     --exclusive --authoritative
# complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | cut --fields 2 --delimiter " " | grep --quiet distil_reporting; end' --arguments 'reporting.(ls_reporting_tables)' --exclusive --authoritative
# complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __fish_print_cmd_args | cut --fields 2 --delimiter " " | grep --quiet postgres; end'         --arguments 'public.(ls_parse_tables)'        --exclusive --authoritative
complete --command pfout --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " " | tr --delete " "); end'  --arguments '(ls_psql_schema_tables (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " "))' --exclusive --authoritative
function pfout --argument-names dbname schema_table file_name_tag
    if test -z $file_name_tag
        set file_name_tag ""
    else
        set file_name_tag "__"$file_name_tag
    end
    set branch_name __(git branch --no-color | grep '\*' | cut --fields 2 --delimiter " ")
    set time_stamp __(date +'%Y-%m-%d_%I:%M:%S.%2N_%p')
    set file_name $schema_table$branch_name$file_name_tag$time_stamp".tsv"
    pout $dbname $schema_table > $file_name
end

complete --command ls_psql_schemas --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
function ls_psql_schemas --argument-names dbname
    pcoms $dbname "Select distinct table_schema from information_schema.tables where table_schema not in ('pg_catalog', 'information_schema')"
end

complete --command truncate_psql_tables --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
complete --command truncate_psql_tables --condition 'begin; ≥ (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " " | tr --delete " "); end'  --arguments '(ls_psql_schema_tables (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " "))' --exclusive --authoritative
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

function ls_psql_databases
    psql --no-align --list --tuples-only | cut --fields 1 --delimiter '|'
end

complete --command ls_psql_schema_tables --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
function ls_psql_schema_tables --argument-names dbname
    pcoms $dbname "Select distinct(table_schema || '.' || table_name) from information_schema.tables where table_schema not in ('pg_catalog', 'information_schema')"
end

complete --command ls_psql_tables --condition '≤ (count (__fish_print_cmd_args)) 1' --arguments '(__psql_all_db_names)' --exclusive --authoritative
complete --command ls_psql_tables --condition 'begin; == (count (__fish_print_cmd_args)) 2; and __psql_all_db_names | grep --quiet --line-regexp (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " " | tr --delete " "); end' --arguments '(ls_psql_schemas (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " "))' --exclusive --authoritative
# complete --command ls_psql_tables --condition '== (count (__fish_print_cmd_args)) 2' --arguments '(ls_psql_schemas (echo (__fish_print_cmd_args) | cut --fields 2 --delimiter " "))' --exclusive --authoritative
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
    pcoms distil_reporting "Select table_name from information_schema.tables where table_schema in ('reporting', 'monthly') and table_name not like '%_2%' and table_name not like 'counters'"
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

# bind --erase \cg --mode default
# bind --erase \cg --mode completion_logging
# bind --erase \e  --mode completion_logging
# bind --erase --key left  --mode completion_logging
# bind --erase --key right --mode completion_logging
# # bind --erase --all --mode completion_logging
# bind ''  --mode completion_logging __completion_logger self-insert
# bind \cg --mode default --sets-mode completion_logging false
# bind \cg --mode completion_logging --sets-mode default false
# bind \e  --mode completion_logging --sets-mode default false
# bind --key left  --mode completion_logging __completion_logger backward-char
# bind --key right --mode completion_logging __completion_logger  forward-char
# # bind --key left  --mode completion_logging __completion_logger
# # bind --key right --mode completion_logging __completion_logger

function __completion_logger
    if set --query __COMPLETION_LOGGER_SKIP
        return 0
    end

    set --local logfile /tmp/__completion_logger_watchfile.txt
    if [ (count $argv) -gt 0 -a "$argv[1]" = "--watch" ]
        if [ (count $argv) -gt 1 ]
            echo "__comp_debug_$argv[2]"
            complete --condition "__completion_logger" \
                     --command "__comp_debug_$argv[2]" \
                     --wraps "$argv[2]" \
                     --authoritative \
                     --exclusive
        else
            echo > $logfile
            echo watching $logfile
            watch --interval=0.1 cat $logfile
        end

        return 0
    end

    set --local current_job        (commandline --current-job)
    set --local current_process    (commandline --current-process)
    set --local cut_at_cursor      (commandline --cut-at-cursor)
    set --local cursor             (commandline --cursor)
    set --local num_cmd_words      (commandline | wc --words)
    set --local last_token         (commandline | awk "{ print \$$num_cmd_words; }")
    set --local current_token      (commandline --current-token)
    set --local current_token_size (commandline --current-token | wc --bytes)
    set --local last_cmd_char      (commandline | tail --bytes 2 | head --bytes 1)

    echo > $logfile
    echo commandline        "<<"(commandline)">>"     >> $logfile
    echo current_job        "<<$current_job>>"        >> $logfile
    echo current_process    "<<$current_process>>"    >> $logfile
    echo cut_at_cursor      "<<$cut_at_cursor>>"      >> $logfile
    echo cursor             "<<$cursor>>"             >> $logfile
    echo num_cmd_words      "<<$num_cmd_words>>"      >> $logfile
    echo last_token         "<<$last_token>>"         >> $logfile
    echo current_token      "<<$current_token>>"      >> $logfile
    echo current_token_size "<<$current_token_size>>" >> $logfile
    echo last_cmd_char      "<<$last_cmd_char>>"      >> $logfile
    echo completions >> $logfile
    begin
        set --export __COMPLETION_LOGGER_SKIP true
        complete --do-complete=(commandline)
        set --erase __COMPLETION_LOGGER_SKIP
    end >> $logfile

    return 0
end

function __gettys_completer
    set address Four score and seven years ago our fathers brought forth on this       \
                continent, a new nation, conceived in Liberty, and dedicated to        \
                the proposition that all men are created equal. Now we are engaged     \
                in a great civil war, testing whether that nation, or any nation       \
                so conceived and so dedicated, can long endure. We are met on a great  \
                battle-field of that war. We have come to dedicate a portion of        \
                that field, as a final resting place for those who here gave their     \
                lives that that nation might live. It is altogether fitting and        \
                proper that we should do this. But, in a larger sense, we can not      \
                dedicate -- we can not consecrate -- we can not hallow -- this ground. \
                The brave men, living and dead, who struggled here, have consecrated   \
                it, far above our poor power to add or detract. The world will little  \
                note, nor long remember what we say here, but it can never forget      \
                what they did here. It is for us the living, rather, to be dedicated   \
                here to the unfinished work which they who fought here have thus       \
                far so nobly advanced. It is rather for us to be here dedicated        \
                to the great task remaining before us -- that from these honored       \
                dead we take increased devotion to that cause for which they gave      \
                the last full measure of devotion -- that we here highly resolve       \
                that these dead shall not have died in vain -- that this nation,       \
                under God, shall have a new birth of freedom -- and that government    \
                of the people, by the people, for the people, shall not perish from    \
                the earth.

    set next_word_index (commandline --tokenize | wc --lines)

    echo $address[$next_word_index]
end

complete --command gettys \
         --no-files
complete --command gettys \
         --arguments "(__gettys_completer)" \
         --authoritative \
         --exclusive
function gettys
    echo "--"\nAbraham Lincoln\nNovember\ 19,\ 1863
end

function ls_lpass_dbs
    # begin; lpass ls --sync no 'Secure Notes'; lpass ls --sync no distil; end \
    # | sed --silent 's/^\(Secure Notes\|distil\)\/\(db-[^[ ]\+\)[ ]\+\[id: \([0-9]\+\)\]/\2'\t'\2/p'
    lpass show --expand-multi --sync no --name --basic-regexp '/db-'
end

complete --command vimdb \
         --condition "begin; [ (commandline | wc --words) = 1 ]; or [ (commandline | wc --words) = 2 -a (commandline --current-token | wc --bytes) -gt 1 ]; end" \
         --arguments "(ls_lpass_dbs)" \
         --no-files
function vimdb --argument-names db_entry file
    # set pg_pass_file ~/.pgpass
    set pg_pass_file (mktemp)

    chmod 0600 $pg_pass_file

    if [ -e ~/.pgpass ]
        cat ~/.pgpass > $pg_pass_file
    end

    # ensure lpass connection
    lpass ls --sync no __NOT_A_REAL_GROUP__

    set db_configs (lpass show --sync no --all "$db_entry")\n

    for db_var in hostname port database username password
        set $db_var (echo -n -s $db_configs | sed --silent "/^$db_var:/I {
            s/^[^:]\+: *//p
            q
        }")
    end

    echo $hostname:$port:$database:$username:$password >> $pg_pass_file

    # Some of the following is definitely overkill...was desperate to get this
    # working.
    env PGPASSFILE=$pg_pass_file /usr/local/bin/vim $file \
        --cmd "let g:dbext_default_profile_PGSQL_VimDB = 'type=pgsql:host=$hostname:port=$port:dbname=$database:user=$username:passwd='"\n"let g:dbext_default_profile = 'PGSQL_VimDB'"\n"let g:dbext_default_PGSQL_pgpass = expand('$pg_pass_file')" \
        -c "let b:dbext_profile = 'PGSQL_VimDB'"\n"let b:dbext_type='PGSQL'" \
        -S (
            echo -s "DBSetOption type=PGSQL"\n \
                    "DBSetOption host=$hostname"\n \
                    "DBSetOption user=$username"\n \
                    "DBSetOption dbname=$database"\n \
                    "DBSetOption port=$port"\n \
        | psub)

    rm $pg_pass_file

    if [ -e $pg_pass_file.bak ]
        mv $pg_pass_file{.bak,}
    end
end
# For archival in case I decide I need it
# function vimdb --argument-names db_entry file
#     if [ -e ~/.pgpass ]
#         mv ~/.pgpass{,.bak}
#     end

#     touch ~/.pgpass
#     chmod 0600 ~/.pgpass

#     # ensure lpass connection
#     lpass ls --sync no __NOT_A_REAL_GROUP__

#     set db_configs (lpass show --sync no --notes "$db_entry")\n

#     # lpass show --notes "$db_entry" | awk '
#     #     /^Hostname:/ { sub(/^Hostname:/, ""); Hostname = $0 }
#     #     /^Port:/     { sub(/^Port:/,     ""); Port     = $0 }
#     #     /^Database:/ { sub(/^Database:/, ""); Database = $0 }
#     #     /^Username:/ { sub(/^Username:/, ""); Username = $0 }
#     #     /^Password:/ { sub(/^Password:/, ""); Password = $0 }
#     #     END {
#     #         print Hostname ":" Port ":" Database ":" Username ":" Password
#     # }' > ~/.pgpass

#     for db_var in hostname port database username password
#         set $db_var (echo -n -s $db_configs | sed --silent "/^$db_var:/I {
#             s/^[^:]\+://p
#             q
#         }")
#     end

#     echo $hostname:$port:$database:$username:$password > ~/.pgpass

#     # echo -n -s $db_configs | awk '
#     #     /^Hostname:/ { sub(/^Hostname:/, ""); Hostname = $0 }
#     #     /^Port:/     { sub(/^Port:/,     ""); Port     = $0 }
#     #     /^Database:/ { sub(/^Database:/, ""); Database = $0 }
#     #     /^Username:/ { sub(/^Username:/, ""); Username = $0 }
#     #     /^Password:/ { sub(/^Password:/, ""); Password = $0 }
#     #     END {
#     #         print Hostname ":" Port ":" Database ":" Username ":" Password
#     # }' > ~/.pgpass

#     # vim $file -S (lpass show --notes "$db_entry" | awk '
#     #     /^Hostname:/ { sub(/^Hostname:/, ""); Hostname = $0 }
#     #     /^Port:/     { sub(/^Port:/,     ""); Port     = $0 }
#     #     /^Database:/ { sub(/^Database:/, ""); Database = $0 }
#     #     /^Username:/ { sub(/^Username:/, ""); Username = $0 }
#     #     END {
#     #         print "DBSetOption type=PGSQL"
#     #         print "DBSetOption host=" Hostname
#     #         print "DBSetOption user=" Username
#     #         print "DBSetOption dbname=" Database
#     #         print "DBSetOption port=" Port
#     # }' | psub)

#     vim $file \
#         --cmd "let g:dbext_default_profile_PGSQL_VimDB = 'type=pgsql:host=$hostname:port=$port:dbname=$database:user=$username:passwd='"\n"let g:dbext_default_profile = 'PGSQL_VimDB'" \
#         -c "let b:dbext_profile = 'PGSQL_VimDB'"\n"let b:dbext_type='PGSQL'" \
#         -S (
#             echo -s "DBSetOption type=PGSQL"\n \
#                     "DBSetOption host=$hostname"\n \
#                     "DBSetOption user=$username"\n \
#                     "DBSetOption dbname=$database"\n \
#                     "DBSetOption port=$port"\n \
#         | psub)

#     # set var_cmd (lpass show --notes "$db_entry" | awk '
#     #     /^Hostname:/ { sub(/^Hostname:/, ""); Hostname = $0 }
#     #     /^Port:/     { sub(/^Port:/,     ""); Port     = $0 }
#     #     /^Database:/ { sub(/^Database:/, ""); Database = $0 }
#     #     /^Username:/ { sub(/^Username:/, ""); Username = $0 }
#     #     END {
#     #         print "let g:dbext_default_profile_VimDB = \'type=pgsql:host=" Hostname ":port=" Port ":dbname=" Database ":user=" Username "\'; "     "let g:dbext_default_profile = \'VimDB\'"
#     # }')
#     # echo $var_cmd
#     # vim $file --cmd "\"$var_cmd\"" -c "\"$var_cmd\""

#     # Working!
#     # vim $file --cmd "source "(lpass show --notes "$db_entry" | awk '
#     #     /^Hostname:/ { sub(/^Hostname:/, ""); Hostname = $0 }
#     #     /^Port:/     { sub(/^Port:/,     ""); Port     = $0 }
#     #     /^Database:/ { sub(/^Database:/, ""); Database = $0 }
#     #     /^Username:/ { sub(/^Username:/, ""); Username = $0 }
#     #     END {
#     #         print "let g:dbext_default_profile_VimDB = \'type=pgsql:host=" Hostname ":port=" Port ":dbname=" Database ":user=" Username ":passwd=\'"
#     #         print "let g:dbext_default_profile = \'VimDB\'"
#     # }' | psub)

#     # vim $file --cmd "let g:dbext_default_profile_VimDB = 'type=pgsql:host=$hostname:port=$port:dbname=$database:user=$username:passwd='"\n"let g:dbext_default_profile = 'VimDB'"

#     #     /^Hostname:/ { sub(/^Hostname:/, ""); Hostname = $0 }
#     #     /^Port:/     { sub(/^Port:/,     ""); Port     = $0 }
#     #     /^Database:/ { sub(/^Database:/, ""); Database = $0 }
#     #     /^Username:/ { sub(/^Username:/, ""); Username = $0 }
#     #     END {
#     #         print "let g:dbext_default_profile_VimDB = \'type=pgsql:host=" Hostname ":port=" Port ":dbname=" Database ":user=" Username ":passwd=\'"
#     #         print "let g:dbext_default_profile = \'VimDB\'"
#     # }' | psub)

#     rm ~/.pgpass

#     if [ -e ~/.pgpass.bak ]
#         mv ~/.pgpass{.bak,}
#     end
# end

function sudiff --argument-names f1 f2
    diff (sort $f1 | uniq | psub) (sort $f2 | uniq | psub)
end

complete --command pbproc --arguments '(functions | tr --delete \,)' --authoritative
function pbproc \
    --description "Process contents of pb clipboard on OS X"
    pbpaste | eval $argv | pbcopy
end

# From https://github.com/fish-shell/fish-shell/issues/159#issuecomment-37057175
complete --command pipeset --wraps set
function pipeset --no-scope-shadowing
    set --local _options
    set --local _variables
    for _item in $argv
        switch $_item
            case '-*'
                set _options $_options $_item
            case '*'
                set _variables $_variables  $_item
        end
    end
    for _variable in $_variables
        set $_variable ""
    end
    while read _line
        for _variable in $_variables
            set $_options $_variable $$_variable$_line\n
        end
    end
    return 0
end

# Docker command completion
    if which docker > /dev/null
        # complete --command "docker"
    end

complete --command lrk --condition '≥ (count (commandline --tokenize)) 2' --arguments '(begin; set --local c_tokenize (commandline --tokenize); set --local c_cbuffer (commandline --current-buffer); set --local c_cjob (commandline --current-job); set --local c_cprocess (commandline --current-process); set --local c_ctoken (commandline --current-token); set --local c_cursor (commandline --cursor); set --local c_cacursor (commandline --cut-at-cursor); set --local an_arg dummy_arg; breakpoint; echo $an_arg; end)'
function lrk --argument-names stuff things
    set --local florb $stuff
    echo $florb
end

function follow_first_line --argument-names filename
    ruby -e 'def clear!(entry); replacement = entry.gsub(/./, ?\s); print "\r#{replacement}\r"; end; begin; entry = old_entry = \'\'; loop { new_entry = IO.readlines("'$filename'").first; unless new_entry; sleep 0.05; next; end; old_entry = entry; entry = new_entry.chomp; unless entry == old_entry; clear!(old_entry); print entry; end; sleep 0.25 }; rescue Interrupt; exit; end'
end

# From oh-my-fish
function __fishy_fish
echo "                     "(set_color F00)"___
      ___======____="(set_color FF7F00)"-"(set_color FF0)"-"(set_color FF7F00)"-="(set_color F00)")
    /T            \_"(set_color FF0)"--="(set_color FF7F00)"=="(set_color F00)")
    [ \ "(set_color FF7F00)"("(set_color FF0)"0"(set_color FF7F00)")   "(set_color F00)"\~    \_"(set_color FF0)"-="(set_color FF7F00)"="(set_color F00)")
     \      / )J"(set_color FF7F00)"~~    \\"(set_color FF0)"-="(set_color F00)")
      \\\\___/  )JJ"(set_color FF7F00)"~"(set_color FF0)"~~   "(set_color F00)"\)
       \_____/JJJ"(set_color FF7F00)"~~"(set_color FF0)"~~    "(set_color F00)"\\
       "(set_color FF7F00)"/ "(set_color FF0)"\  "(set_color FF0)", \\"(set_color F00)"J"(set_color FF7F00)"~~~"(set_color FF0)"~~     "(set_color FF7F00)"\\
      (-"(set_color FF0)"\)"(set_color F00)"\="(set_color FF7F00)"|"(set_color FF0)"\\\\\\"(set_color FF7F00)"~~"(set_color FF0)"~~       "(set_color FF7F00)"L_"(set_color FF0)"_
      "(set_color FF7F00)"("(set_color F00)"\\"(set_color FF7F00)"\\)  ("(set_color FF0)"\\"(set_color FF7F00)"\\\)"(set_color F00)"_           "(set_color FF0)"\=="(set_color FF7F00)"__
       "(set_color F00)"\V    "(set_color FF7F00)"\\\\"(set_color F00)"\) =="(set_color FF7F00)"=_____   "(set_color FF0)"\\\\\\\\"(set_color FF7F00)"\\\\
              "(set_color F00)"\V)     \_) "(set_color FF7F00)"\\\\"(set_color FF0)"\\\\JJ\\"(set_color FF7F00)"J\)
                          "(set_color F00)"/"(set_color FF7F00)"J"(set_color FF0)"\\"(set_color FF7F00)"J"(set_color F00)"T\\"(set_color FF7F00)"JJJ"(set_color F00)"J)
                          (J"(set_color FF7F00)"JJ"(set_color F00)"| \UUU)\\
                           (UU)"(set_color normal)\n\n
end

  if [ (uname) -a Darwin ]
    function chrome-app --argument-names url --description "Open url in chrome's app mode"
      /opt/homebrew-cask/Caskroom/google-chrome/latest/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app="$url"
    end
  end
