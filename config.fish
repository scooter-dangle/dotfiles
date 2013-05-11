# vim: filetype=sh

if status --is-interactive
    . ~/.config/fish/aliases.fish
end

set NODE_PATH /usr/local/lib/node /usr/local/lib/node_modules /usr/lib/node /usr/lib/node_modules

set PATH ~/erlang/rebar $PATH
set PATH ~/.cabal/bin $PATH

set GEM_HOME $HOME/.gems
set PATH .bundle/bin $GEM_HOME/bin $PATH

function bundle-bootstrap
    bundle install --binstubs=.bundle/bin path=.bundle/gems
end
