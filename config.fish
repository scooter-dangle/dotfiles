# vim: filetype=sh

if status --is-interactive
    . ~/.config/fish/aliases.fish
end

set -x NODE_PATH /usr/local/lib/node /usr/local/lib/node_modules /usr/lib/node /usr/lib/node_modules

set -x PATH ~/erlang/rebar $PATH
set -x PATH ~/.cabal/bin $PATH
set -x PATH $HOME/.rbenv/bin $PATH

set -x GEM_HOME $HOME/.gems
set -x PATH .bundle/bin $GEM_HOME/bin $PATH

function bundle-bootstrap
    bundle install --binstubs=.bundle/bin path=.bundle/gems
end
