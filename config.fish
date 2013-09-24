# vim: filetype=sh

if status --is-interactive
    . ~/.config/fish/aliases.fish
end

set -x NODE_PATH /usr/local/lib/node /usr/local/lib/node_modules /usr/lib/node /usr/lib/node_modules

set -x PATH ~/erlang/rebar $PATH
set -x PATH ~/.cabal/bin $PATH
set -x PATH ~/node_modules/.bin $PATH
set -x PATH $HOME/.rbenv/bin $PATH
set -x PATH $HOME/.rbenv/shims $PATH

set -x GEM_HOME $HOME/.gems
set -x PATH .bundle/bin $GEM_HOME/bin $PATH

rbenv init - | bash

# Can't get this to work
#if test -f ~/.LOW-COLOR-TERM -o -f ~/dotfiles/.LOW-COLOR-TERM
#    set -x LESS_TERMCAP_mb '$\E[01;31m'       # begin blinking
#    set -x LESS_TERMCAP_md '$\E[01;31m'       # begin bold
#    set -x LESS_TERMCAP_me '$\E[0m'           # end mode
#    set -x LESS_TERMCAP_se '$\E[0m'           # end standout-mode
#    set -x LESS_TERMCAP_so '$\E[01;44m'       # begin standout-mode - info box
#    set -x LESS_TERMCAP_ue '$\E[0m'           # end underline
#    set -x LESS_TERMCAP_us '$\E[32m'          # begin underline
#else
#    set -x LESS_TERMCAP_mb '$\E[01;31m'       # begin blinking
#    set -x LESS_TERMCAP_md '$\E[01;38;5;74m'  # begin bold
#    set -x LESS_TERMCAP_me '$\E[0m'           # end mode
#    set -x LESS_TERMCAP_se '$\E[0m'           # end standout-mode
#    set -x LESS_TERMCAP_so '$\E[38;5;246m'    # begin standout-mode - info box
#    set -x LESS_TERMCAP_ue '$\E[0m'           # end underline
#    set -x LESS_TERMCAP_us '$\E[04;38;5;146m' # begin underline
#end

# At least the following will work for manpages
function man
    bash -lc "man $argv"
end

# tmux looks at $EDITOR to determine whether to use vi keys
set -x EDITOR vi

function bundle-bootstrap
    bundle install --binstubs=.bundle/bin path=.bundle/gems
end
