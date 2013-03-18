# ~/.bash_aliases

# Tip from M Subelsky:
alias ea='vim ~/.bash_aliases && source ~/.bash_aliases'

function ag { grep $1 ~/.bash_aliases; }


alias  up='cd ..'
alias  bk='cd -'
alias  hm='cd ~'
alias  bx='bundle exec'
alias   d=date
alias  ct='ctags -R'
alias  pi='ping www.google.com'
alias rsh='pry --require rake'
# Be super careful with this little feller...
# Don't use him twice in a row or he will
# buh-rake all of your things :(
alias  mo='fc -s | more'

function dl { rm -i $1; }

alias ll='ls -alF'
alias la='ls -A'
alias  l='ls -CF'
function ld { cd $1 && ls; }
alias lu='cd .. && ls'

alias ruby='ruby1.9.3'
alias  irb='irb1.9.3'
alias rakes='rake -T'

alias gm='w3m "https://mail.google.com/mail/you/0/?ui=html&zy=s"'
alias th='~/Downloads/Thunderbird/thunderbird &'

alias co='setxkbmap -option "compose:menu" && xmodmap ~/.Xmodmap'

function blerg { echo blerg $1 ferg snerg; }

# Specific to Jeevsy
function cn { sudo chown ubuntu:ubuntu $1; }

# git
alias gs='git status -s'
alias gd='git diff -b --color'
alias gl='git log'
alias gb='git branch'
alias gp='git pull'
alias GP='git push'
function gc { git commit -am $1; }
function gco { git co $1; }

# pman auto-completion
alias pm='source ~/.pman.sh'

# test 256 colors (from commandlinefu.com)
function tt256 {(
    function tt256_helper { m=`tput cols` n=`printf %$(($m-4))s`; echo ${n// /=}; }
    h=${1:-1} x=`tput op`;
    for (( g = 0; g < $h; g++ ));
    do
        for i in {0..256};
        do
            y=`tt256_helper`;
            o=00$i;
            echo -e ${o:${#o}-3:3} `tput setaf $i;tput setab $i`$y$x;
        done;
    done;
)}

# faster version of previous function
function tt256f {(
    function tt256_helper { m=`tput cols` n=`printf %$(($m-4))s`; echo ${n// /=}; }
    h=${1:-1};
    x=`tput op`;
    y=`tt256_helper`;
    for (( g = 0; g < $h; g++ ));
    do
        for i in {0..256};
        do
            o=00$i;
            echo -e ${o:${#o}-3:3} `tput setaf $i;tput setab $i`$y$x;
        done;
    done;
)}

# screensaver version of previous function
function tt256s {(
    function reseter {(
        if [[ $(($1 + 2)) -gt `tput lines` ]]
        then
            clear;
            return $((0));
        else
            echo $1;
        fi;
    )}
    function tt256_helper { m=`tput cols` n=`printf %${m}s`; echo ${n// /=}; }
    x=`tput op`;
    l=0;
    sleepy_time="0.0$((45 + ($RANDOM % 45)))";
    clear;
    lister=(1 6 36);
    stepper=${lister[$(($RANDOM % 3))]};
    modder=$((231-17));
    while true;
    do
        for h in {1..214};
        do
            sleep $sleepy_time;
            if [[ $(($l + 3)) -gt `tput lines` ]]
            then
                clear;
                l=0;
            else
                l=$(($l + 1));
            fi;
            i=$((17 + ((h * stepper) % $modder)));
            y=`tt256_helper`;
            echo -e `tput setaf $i;tput setab $i`$y$x;
        done;
    done;
)}

# I use asky to check whether the current terminal is rendering all the
# ascii glyphs correctly.
alias asky="echo \"abcdefghijklmnopqrstuvwxyz\\\`1234567890-=[]\;',./ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:\\\"<>?\""

function s { grep $1 -Rn . | less; }

function le { ls -al $1 | less; }

function md { mkdir $1 && cd $1; }

function foo { bash ~/bash/push_live.sh $1; }

# vim: set filetype=sh:
