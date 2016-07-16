# This maintains a jump-list of the directories you actually use.
#
# First, cd around for a while to build up the database of directories.
#
# USAGE:
#   * z foo     # goes to most frecent dir matching foo
#   * z foo bar # goes to most frecent dir matching foo and bar
#   * z -r foo  # goes to highest ranked dir matching foo
#   * z -t foo  # goes to most recently accessed dir matching foo
#   * z -l foo  # list all dirs matching foo (by frecency)
#
# Originally from: https://github.com/sjl/z-fish

function addzhist --on-variable PWD
    z --add "$PWD"
end

function __unique_z_words --argument-names num_directories
    if [ "$num_directories" = "" ]
        set num_directories 1000
    end

    z -l \
    | tail --lines $num_directories \
    | awk '{ print $2 }' \
    | tr / \n \
    | sort --parallel 4 --unique \
    | tail --lines +2
end

function grep_commandline_filter
    set --local num_cmd_words  (commandline | wc --words)
    set --local current_token  (commandline --current-token)
    set --local last_token     (commandline | awk "{ print \$$num_cmd_words; }")
    # if begin; [ $num_cmd_words = 1 ]; or [ $num_cmd_words = 2 -a "$current_token" = "$last_token" ]; end  # orig
    if [ $num_cmd_words = 1 -o \( $num_cmd_words = 2 -a "$current_token" = "$last_token" \) ]
        cat
    else
        # if [ "$current_cmd_token" = "" ]
            set filter_words (commandline --tokenize | tail --lines +2 | awk '{ print "--regexp" "\n" $1; }')
        # else
            # set filter_words (commandline --tokenize | grep --line-regexp --invert-match --fixed-strings "$current_cmd_token" | awk '{ print "--regexp" "\n" $1; }')
            # set filter_words (commandline --tokenize | grep --line-regexp --invert-match --fixed-strings "$current_cmd_token" | tail --lines +2 | awk '{ print "--regexp" "\n" $1; }')
        # end
        grep --line-regexp --invert-match --fixed-strings $filter_words
    end
end

function __fish_complete_j
    set --local unique_z_words     (__unique_z_words)
    set --local num_cmd_words      (commandline | wc --words)
    set --local last_token         (commandline | awk "{ print \$$num_cmd_words }")
    set --local current_token      (commandline --current-token)
    # set --local current_token_size (commandline --current-token | wc --bytes)
    # set --local last_cmd_char      (commandline | tail --bytes 2 | head --bytes 1)

    # echo > /tmp/watchfile.txt
    # echo commandline        "<<"(commandline)">>"     >> /tmp/watchfile.txt
    # echo num_cmd_words      "<<$num_cmd_words>>"      >> /tmp/watchfile.txt
    # echo last_token         "<<$last_token>>"         >> /tmp/watchfile.txt
    # echo current_token      "<<$current_token>>"      >> /tmp/watchfile.txt
    # # echo current_token_size "<<$current_token_size>>" >> /tmp/watchfile.txt
    # # echo last_cmd_char      "<<$last_cmd_char>>"      >> /tmp/watchfile.txt

    begin
        if [ $num_cmd_words = 1 -o \( $num_cmd_words = 2 -a "$last_token" = "$current_token" \) ]
            __fish_complete_cd
            echo -n (z --complete "")/\n
        end
        echo -ns $unique_z_words\n
    # end | sed 's/^ //' | grep_commandline_filter # orig
    end | grep_commandline_filter
end

# complete --command j \
#          --condition 'begin
#              [ (commandline | wc --words) = 1 ]
#              or [ (commandline | wc --words) = 2 -a ""(commandline --cut-at-cursor | tail --bytes 2)"" != " " ]
#          end' \
#          --arguments "(__fish_complete_cd)" \
#          --authoritative \
#          --exclusive
# complete --command j \
#          --condition 'begin
#              [ (commandline | wc --words) = 1 ]
#              or [ (commandline | wc --words) = 2 -a ""(commandline --cut-at-cursor | tail --bytes 2)"" != " " ]
#          end' \
#          --arguments '(z --complete "")' \
#          --authoritative \
#          --exclusive
# complete --command j \
#          --arguments '(z -l | tail --lines 20 | awk \'{print $2;}\' | tr / \n | sort --unique | tail --lines +2)' \
#          --authoritative \
#          --exclusive

complete --command j \
         --arguments '(__fish_complete_j)' \
         --authoritative \
         --exclusive
function j
    if [ (count $argv) = 1 -a -d "$argv[1]" ]
        cd $argv
    else
        z $argv
    end
end

function z --description "Jump to a recent directory"
    set --local datafile "$HOME/.z"

    # add entries
    if [ "$argv[1]" = "--add" ]
        set --erase argv[1]

        # $HOME isn't worth matching
        [ "$argv" = "$HOME" ]; and return

        set --local tempfile (mktemp $datafile.XXXXXX)
        test -f $tempfile; or return

        # maintain the file
        awk -v path="$argv" -v now=(date +%s) -F"|" '
            BEGIN {
                rank[path] = 1
                time[path] = now
            }
            $2 >= 1 {
                if( $1 == path ) {
                    rank[$1] = $2 + 1
                    time[$1] = now
                } else {
                    rank[$1] = $2
                    time[$1] = $3
                }
                count += $2
            }
            END {
                if( count > 50000 ) {
                    for( i in rank ) print i "|" 0.9*rank[i] "|" time[i] # aging
                } else for( i in rank ) print i "|" rank[i] "|" time[i]
            }
        ' $datafile ^/dev/null > $tempfile

        mv -f $tempfile $datafile

    # tab completion
    else
        if [ "$argv[1]" = "--complete" ]
            awk -v q="$argv[2]" -F"|" '
                BEGIN {
                    if( q == tolower(q) ) nocase = 1
                    split(q,fnd," ")
                }
                {
                    if( system("test -d \"" $1 "\"") ) next
                    if( nocase ) {
                        for( i in fnd ) tolower($1) !~ tolower(fnd[i]) && $1 = ""
                        if( $1 ) print $1
                    } else {
                        for( i in fnd ) $1 !~ fnd[i] && $1 = ""
                        if( $1 ) print $1
                    }
                }
            ' "$datafile" 2>/dev/null

        else
            # list/go
            set --local last ''
            set --local list 0
            set --local typ ''
            set --local fnd ''

            # while [ (count $argv) -gt 0 ] # orig
            while [ ! -z "$argv" ]
                switch "$argv[1]"
                    case -- '-h'
                        echo "z [-h][-l][-r][-t] args" >&2
                        return
                    case -- '-l'
                        set list 1
                    case -- '-r'
                        set typ "rank"
                    case -- '-t'
                        set typ "recent"
                    case -- '--'
                        while [ "$argv[1]" ]
                            set --erase argv[1]
                            set fnd "$fnd $argv[1]"
                        end
                    case '*'
                        set fnd "$fnd $argv[1]"
                end
                set last $1
                set --erase argv[1]
            end

            [ "$fnd" ]; or set list 1

            # if we hit enter on a completion just go there
            [ -d "$last" ]; and cd "$last"; and return

            # no file yet
            [ -f "$datafile" ]; or return

            set --local tempfile (mktemp $datafile.XXXXXX)
            set --local tempfile2 (mktemp $datafile.XXXXXX)
            test -f $tempfile; or return
            set --local target (awk -v t=(date +%s) -v list="$list" -v typ="$typ" -v q="$fnd" -v tmpfl="$tempfile" -v tmpfl2="$tempfile2" -F"|" '
                function frecent(rank, time) {
                    dx = t-time
                    if( dx < 3600 ) return rank*4
                    if( dx < 86400 ) return rank*2
                    if( dx < 604800 ) return rank/2
                    return rank/4
                }
                function output(files, toopen, override) {
                    if( list ) {
                        if( typ == "recent" ) {
                            cmd = "sort -nr > " tmpfl2
                        } else cmd = "sort -n > " tmpfl2
                        for( i in files ) if( files[i] ) printf "%-10s %s\n", files[i], i | cmd
                        if( override ) printf "%-10s %s\n", "common:", override > "/dev/stderr"
                    } else {
                        if( override ) toopen = override
                        print toopen
                    }
                }
                function common(matches, fnd, nc) {
                    for( i in matches ) {
                        if( matches[i] && (!short || length(i) < length(short)) ) short = i
                    }
                    if( short == "/" ) return
                    for( i in matches ) if( matches[i] && i !~ short ) x = 1
                    if( x ) return
                    if( nc ) {
                        for( i in fnd ) if( tolower(short) !~ tolower(fnd[i]) ) x = 1
                    } else for( i in fnd ) if( short !~ fnd[i] ) x = 1
                    if( !x ) return short
                }
                BEGIN { split(q, a, " ") }
                {
                    if( system("test -d \"" $1 "\"") ) next
                    print $0 >> tmpfl
                    if( typ == "rank" ) {
                        f = $2
                    } else if( typ == "recent" ) {
                        f = t-$3
                    } else f = frecent($2, $3)
                    wcase[$1] = nocase[$1] = f
                    for( i in a ) {
                        if( $1 !~ a[i] ) delete wcase[$1]
                        if( tolower($1) !~ tolower(a[i]) ) delete nocase[$1]
                    }
                    if( wcase[$1] > oldf ) {
                        cx = $1
                        oldf = wcase[$1]
                    } else if( nocase[$1] > noldf ) {
                        ncx = $1
                        noldf = nocase[$1]
                    }
                }
                END {
                    if( cx ) {
                        output(wcase, cx, common(wcase, a, 0))
                    } else if( ncx ) output(nocase, ncx, common(nocase, a, 1))
                }
            ' "$datafile")

            if [ $status -gt 0 ]
                rm -f "$tempfile"
                rm -f "$tempfile2"
            else
                mv -f "$tempfile" "$datafile"
                [ "$target" ]; and cd "$target"
                cat "$tempfile2"
                rm "$tempfile2"
            end
        end
    end
end
