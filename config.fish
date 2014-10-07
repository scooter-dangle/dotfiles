status --is-interactive; and . ~/.config/fish/aliases.fish

set -x NODE_PATH /usr/local/lib/node /usr/local/lib/node_modules /usr/lib/node /usr/lib/node_modules

set -x PATH ~/erlang/rebar $PATH
set -x PATH ~/erlang/concrete $PATH
set -x PATH ~/.cabal/bin $PATH
set -x PATH ~/node_modules/.bin $PATH
set -x PATH $HOME/.rbenv/bin $PATH
set -x PATH $HOME/.rbenv/shims $PATH
set -x PATH $HOME/ruby/mruby/bin $PATH
set -x PATH $HOME/.topaz/bin $PATH

set -x GEM_HOME $HOME/.gems
set -x PATH .bundle/bin $GEM_HOME/bin $PATH

set -x GOPATH $HOME/go
set -x GOBIN $HOME/go/bin
set -x PATH /usr/local/go/bin $PATH

set -x PATH $GOBIN $PATH

set -x PATH $HOME/.luarocks/bin $PATH

set --export SEARCH_OPEN_LIMIT 15

if which brew > /dev/null
  set -x PATH $PATH /usr/local/opt/coreutils/libexec/gnubin
end

if test -e ~/.rvm
  function rvm --description='Ruby enVironment Manager'
    # run RVM and capture the resulting environment
    set --local env_file (mktemp -t rvm.fish.XXXXXXXXXX)
    bash -c 'source ~/.rvm/scripts/rvm; rvm "$@"; status=$?; env > "$0"; exit $status' $env_file $argv

    # apply rvm_* and *PATH variables from the captured environment
    and eval (grep '^rvm\|^[^=]*PATH\|^GEM_HOME' $env_file | grep -v '_clr=' | sed '/^[^=]*PATH/s/:/" "/g; s/^/set -xg /; s/=/ "/; s/$/" ;/; s/(//; s/)//')
    # clean up
    rm -f $env_file
  end

  function __handle_rvmrc_stuff --on-variable PWD
    # Source a .rvmrc file in a directory after changing to it, if it exists.
    # To disable this fature, set rvm_project_rvmrc=0 in $HOME/.rvmrc
    if test "$rvm_project_rvmrc" != 0
      set -l cwd $PWD
      while true
        if contains $cwd "" $HOME "/"
          if test "$rvm_project_rvmrc_default" = 1
            rvm default 1>/dev/null 2>&1
          end
          break
        else
          if test -e .rvmrc -o -e .ruby-version -o -e .ruby-gemset
            eval "rvm reload" > /dev/null
            eval "rvm rvmrc load" >/dev/null
            break
          else
            set cwd (dirname "$cwd")
          end
        end
      end

      set -e cwd
    end
  end

  # set -x PATH $HOME/.gems/bin $PATH
  if begin
      not which rvm > /dev/null
      and ls -A | \
      grep --extended-regexp '(\.rb$)|rakefile|gemfile|\.ruby-(gemset|version)' --ignore-case --silent
    end
    echo 'Ruby files found...loading rvm'
    rvm reload > /dev/null
  end
  cd .
end

# Vim mode doesn't feel ready yet :(
# function fish_prompt
#   fish_vi_prompt
# end
# set fish_key_bindings fish_vi_key_bindings

function install_rbenv
  if test ! -d ~/.rbenv
      set orig_dir (pwd)
      cd ~
      git clone https://github.com/sstephenson/rbenv.git
      mv rbenv .rbenv
      cd .rbenv
      mkdir plugins
      cd plugins
      git clone https://github.com/sstephenson/ruby-build.git
      cd $orig_dir
      # Still need to do more things here
  else
      echo ~/.rbenv already exists!
  end
end

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

# Rake completion helper
function test_for_rake
  begin
    test -f Rakefile
    or test -f rakefile
  end
end

# Rake completion helper
function rake_args
  set checksum (md5sum Rakefile | sed --regexp-extended 's/^\b(.+)\b +Rakefile$/\1/')
  set task_full  /tmp/Rakefile.tasks.full.$checksum
  set task_names /tmp/Rakefile.tasks.names.$checksum
  set task_desc  /tmp/Rakefile.tasks.desc.$checksum
  if not test -f $task_names
    if test -f Gemfile
      set rake_prefix 'bundle exec'
    end

    eval $rake_prefix rake -T \
    | sed --regexp-extended   's/^rake (((\w|\[|\]|-|\,)+)(\:(\w|\[|\]|-|\,)+)*) +# (.+)$/\1 # \6/' \
    > $task_full

    cat $task_full \
    | sed --regexp-extended   's/^([^#]+) # (.+)$/\1/' \
    > $task_names

    cat $task_full \
    | sed --regexp-extended   's/^([^#]+) # (.+)$/\2/' \
    > $task_desc

  end
  cat $task_names
end

# Rake completion helper
# Doesn't work  :(
function rake_desc
  set checksum (md5sum Rakefile | sed --regexp-extended 's/^\b(.+)\b +Rakefile$/\1/')
  set task_desc  /tmp/Rakefile.tasks.desc.$checksum
  if test -f $task_desc
    cat $task_desc
  else
    echo rake task
  end
end

complete --command rake --condition 'test_for_rake' --arguments '(rake_args)' --description '(rake_desc)' --no-files

complete --command lolcat --long-option spread    --short-option p --exclusive --description "Rainbow spread (default: 3.0)"
complete --command lolcat --long-option freq      --short-option F --exclusive --description "Rainbow frequency (default: 0.1)"
complete --command lolcat --long-option seed      --short-option S --exclusive --description "Rainbow seed, 0 = random (default: 0)"
complete --command lolcat --long-option animate   --short-option a             --description "Enable psychedelics"
complete --command lolcat --long-option duration  --short-option d --exclusive --description "Animation duration (default: 12)"
complete --command lolcat --long-option speed     --short-option s --exclusive --description "Animation speed (default: 20.0)"
complete --command lolcat --long-option force     --short-option f             --description "Force color even when stdout is not a tty"
complete --command lolcat --long-option version   --short-option v             --description "Print version and exit"
complete --command lolcat --long-option help      --short-option h             --description "Show help message"

# Note: Modified version of 'Informative Git Prompt'
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_hide_untrackedfiles 1

set -g __fish_git_prompt_color_branch magenta --bold
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""

set -g __fish_git_prompt_char_stagedstate "●"
set -g __fish_git_prompt_char_dirtystate "✚"
set -g __fish_git_prompt_char_untrackedfiles "…"
set -g __fish_git_prompt_char_conflictedstate "✖"
set -g __fish_git_prompt_char_cleanstate "✔"

set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
set -g __fish_git_prompt_color_cleanstate green --bold


function fish_prompt --description 'Write out the prompt'

  set -l last_status $status

  if not set -q __fish_prompt_normal
    set -g __fish_prompt_normal (set_color normal)
  end

  # PWD
  set_color $fish_color_cwd
  echo -n (prompt_pwd)
  set_color normal

  printf '%s' (__fish_git_prompt)

  if not test $last_status -eq 0
      set_color $fish_color_error
  end

  echo -n '> '

end

# Load rbenv automatically by adding
# the following to ~/.config/fish/config.fish:

status --is-interactive; and which rbenv > /dev/null; and . (rbenv init -|psub)
