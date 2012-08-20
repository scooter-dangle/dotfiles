# ~/.bash_aliases

# Tip from M Subelsky:
alias ea='vim ~/.bash_aliases && source ~/.bash_aliases'

function ag { grep $1 ~/.bash_aliases; }


alias  up='cd ..'
alias  bk='cd -'
alias  bx='bundle exec'
alias   d=date
alias rbc='cd ~/.rvm/src/ruby-1.9.3-p0'
alias  ct='ctags -R'
alias  pi='ping www.google.com'

alias ll='ls -alF'
alias la='ls -A'
alias  l='ls -CF'
function ld { cd $1 && ls; }
alias lu='cd .. && ls'

alias gm='w3m "https://mail.google.com/mail/you/0/?ui=html&zy=s"'
alias th='~/Downloads/Thunderbird/thunderbird &'

alias co='setxkbmap -option "compose:menu" && xmodmap ~/.Xmodmap'

function blerg { echo blerg $1 ferg snerg; }

# Specific to Jeevsy
function cn { sudo chown ubuntu:ubuntu $1; }

# git
alias gs='git status -s'
alias gd='git diff -b --color'
alias gb='git branch'
alias gp='git pull'
alias GP='git push'
function gc { git commit -am $1; }
function gco { git co $1; }

# pman auto-completion
alias pm='source ~/.pman.sh'

# I use asky to check whether the current terminal is rendering all the
# ascii glyphs correctly.
alias asky="echo \"abcdefghijklmnopqrstuvwxyz\\\`1234567890-=[]\;',./ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:\\\"<>?\""

function s { grep $1 -Rn . | less; }

function le { ls -al $1 | less; }

function md { mkdir $1 && cd $1; }

function foo { bash ~/bash/push_live.sh $1; }
