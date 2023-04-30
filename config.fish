if status is-interactive
  source ~/.config/fish/aliases.fish
  if [ -e ~/dotfiles-extra/auth.fish ]
    source ~/dotfiles-extra/auth.fish
  end
  source ~/dotfiles/__fish_complete_cd.fish
  source ~/dotfiles/z.fish
  complete --command blarp --no-files --arguments '(__fish_complete_j)'
end

if test -e ~/dotfiles/git-custom-commands
  set --export PATH ~/dotfiles/git-custom-commands $PATH
end

set --export PATH /usr/local/opt/coreutils/libexec/gnubin $PATH
# set --export NODE_PATH /usr/local/lib/node /usr/local/lib/node_modules /usr/lib/node /usr/lib/node_modules
if test -e ~/.asdf/asdf.fish
  source ~/.asdf/asdf.fish
end

# set --export PATH ~/erlang/rebar $PATH
# set --export PATH ~/erlang/concrete $PATH
# set --export PATH ~/.cabal/bin $PATH
# set --export PATH ~/node_modules/.bin $PATH
# set --export PATH $HOME/.rbenv/bin $PATH
# set --export PATH $HOME/.rbenv/shims $PATH
# set --export PATH $HOME/ruby/mruby/bin $PATH
# set --export PATH $HOME/.topaz/bin $PATH

if which rbenv >/dev/null 2>/dev/null
  rbenv init - | source
end

# set --export GEM_HOME $HOME/.gems
# set --export PATH .bundle/bin $GEM_HOME/bin $PATH

# set --export GOPATH $HOME/go
# set --export GOBIN $HOME/go/bin
# set --export PATH /usr/local/go/bin $PATH

# set --export PATH $GOBIN $PATH

# set --export PATH $HOME/.luarocks/bin $PATH

set --export SEARCH_OPEN_LIMIT 80

set --export PATH /usr/local/go/bin $PATH


if which brew > /dev/null
  set --export PATH $PATH /usr/local/opt/coreutils/libexec/gnubin
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
#    set --export LESS_TERMCAP_mb '$\E[01;31m'       # begin blinking
#    set --export LESS_TERMCAP_md '$\E[01;31m'       # begin bold
#    set --export LESS_TERMCAP_me '$\E[0m'           # end mode
#    set --export LESS_TERMCAP_se '$\E[0m'           # end standout-mode
#    set --export LESS_TERMCAP_so '$\E[01;44m'       # begin standout-mode - info box
#    set --export LESS_TERMCAP_ue '$\E[0m'           # end underline
#    set --export LESS_TERMCAP_us '$\E[32m'          # begin underline
#else
#    set --export LESS_TERMCAP_mb '$\E[01;31m'       # begin blinking
#    set --export LESS_TERMCAP_md '$\E[01;38;5;74m'  # begin bold
#    set --export LESS_TERMCAP_me '$\E[0m'           # end mode
#    set --export LESS_TERMCAP_se '$\E[0m'           # end standout-mode
#    set --export LESS_TERMCAP_so '$\E[38;5;246m'    # begin standout-mode - info box
#    set --export LESS_TERMCAP_ue '$\E[0m'           # end underline
#    set --export LESS_TERMCAP_us '$\E[04;38;5;146m' # begin underline
#end

# At least the following will work for manpages
function man
    bash -lc "man $argv"
end

# tmux looks at $EDITOR to determine whether to use vi keys
set --export EDITOR vim

function bundle-bootstrap
    bundle install --binstubs=.bundle/bin path=.bundle/gems
end

# Rake completion helper
# TODO - This shouldn't be is complicated.
function test_for_rake
  begin
    test -f Rakefile
    or test -f rakefile
    or test -f Rakefile.rb
    or test -f rakefile.rb
  end
end

# TODO - fix-me-up
function __rake_checksum
  md5sum Rakefile | sed --regexp-extended 's/^\b(.+)\b +Rakefile$/\1/'
end

# Rake completion helper
function rake_args
  set checksum (__rake_checksum)
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



function __fish_terraform_prompt
  if begin; which terraform >/dev/null ^/dev/null; and [ -e "terraform.tfstate" -o -d ".terraform" -o -d "terraform.tfstate.d" ]; end
    printf "["
    if [ -e ".terraform/environment" ]
      set workspace (cat .terraform/environment)
      printf "%s" $workspace
    else if [ -e "terraform.tfstate.d/environment" ]
      set workspace (cat terraform.tfstate.d/environment)
      printf "%s" $workspace
    else
      set workspace (terraform workspace show)
      printf "%s" $workspace
    end
    printf "]"
  end
end

function __fish_aws_creds_prompt
  if set --query AWS_ENV
    if string match --ignore-case --quiet --regex 'pro?d' "$AWS_ENV"
      set aws_name_color brred
    else
      set aws_name_color bryellow
    end

    set_color brwhite
    printf "["
    set_color $aws_name_color
    printf "aws:$AWS_ENV"
    set_color brwhite
    printf "]"
    set_color normal
  end
end

# # Original
# function fish_prompt --description 'Write out the prompt'
#   set --local last_status $status

#   if not set --query __fish_prompt_normal
#     set --global __fish_prompt_normal (set_color normal)
#   end

#   # PWD
#   set_color $fish_color_cwd
#   echo -n (prompt_pwd)
#   set_color normal

#   printf '%s' (__fish_git_prompt)
#   __fish_terraform_prompt

#   __fish_aws_creds_prompt

#   if not [ $last_status -eq 0 ]
#       set_color $fish_color_error
#       printf '(%d)' $last_status
#   end

#   echo -n '> '
# end

# Load rbenv automatically by adding
# the following to ~/.config/fish/config.fish:

# function bind_bang
#   switch (commandline -t)
#   case "!"
#     commandline -t $history[1]; commandline -f repaint
#   case "*"
#     commandline -i !
#   end
# end
#
# function bind_dollar
#   switch (commandline -t)
#   case "!"
#     commandline -t ""
#     commandline -f history-token-search-backward
#   # case "*!"
#   #     # Without the `--`, the functionality will break when completing
#   #     # flags used in the history (since `commandline` will assume
#   #     # that it should try to interpret the flag)
#   #     commandline --current-token -- (echo -ns (commandline --current-token)[-1] | head -c '-1')
#   #     commandline --function history-token-search-backward
#   case "*"
#     commandline -i '$'
#   end
# end

function fish_user_key_bindings
  bind ! bind_bang
  bind @ bind_at
  bind '#' bind_num
  bind '$' bind_dollar
  bind '%' bind_percent
end

# function bind_percent
#   switch (commandline --current-token)
#   case '*!'
#     commandline --function backward-delete-char
#
#     bind --mode search a search_step
#     bind --mode search b search_step
#     bind --mode search c search_step
#     bind --mode search d search_step
#     bind --mode search e search_step
#     bind --mode search f search_step
#     bind --mode search g search_step
#     bind --mode search h search_step
#     bind --mode search i search_step
#     bind --mode search j search_step
#     bind --mode search k search_step
#     bind --mode search l search_step
#     bind --mode search m search_step
#     bind --mode search n search_step
#     bind --mode search o search_step
#     bind --mode search p search_step
#     bind --mode search q search_step
#     bind --mode search r search_step
#     bind --mode search s search_step
#     bind --mode search t search_step
#     bind --mode search u search_step
#     bind --mode search v search_step
#     bind --mode search w search_step
#     bind --mode search x search_step
#     bind --mode search y search_step
#     bind --mode search z search_step
#
#     bind --mode search \e _search_exit
#     bind --mode search enter search_enter
#
#     # TODO make every key trigger a re-search
#     set fish_bind_mode search
#   case '*'
#     commandline --insert %
#   end
# end
#
# function search_step
#   commandline --function self-insert
#   # TODO
#   s (commandline --current-token) | head -n (math "$LINES - 1")
# end
#
# function search_enter
#   commandline --function backward-delete-char
#   set --local tmpfile (mktemp -t last_searched_files__XXXXXXXXXXXX)
#   set --local current_token (commandline --current-token | head -c '-2')
#   __search_remember_completer_s "$current_token"
#   complete_single_run_wrapper (commandline --current-process | cut -f 1 -d ' ')
#   commandline --function complete-and-search pager-toggle-search
# end
#
# function _search_exit
#   set fish_bind_mode default
# end

# TODO: Close but too much confusion with original completions for the
# command that we're wrapping

set --universal COMPLETE_SINGLE_RUN_WRAPPER_PREFIX ___fish_completion_wrapper___

function complete_single_run_wrapper --argument-names completer_cmd cmd
    # echo in complete_single_run_wrapper >> current-process.txt
    # echo pre-read version: >> current-process.txt
    # commandline --current-process --tokenize | tail -n '+2' >> current-process.txt
    # echo pre-read version done: >> current-process.txt
    # commandline --current-process --tokenize | tail -n '+2' | read --local current_commandline
    set current_commandline (commandline --current-process --tokenize | tail -n '+2' | head -n '-1')
    # echo read version: >> current-process.txt
    # echo "$current_commandline" >> current-process.txt
    # echo read version done >> current-process.txt
    # Note: It's impossible to erase this without erasing all of cmd's
    # completions
    complete --command "$cmd" --wraps "$COMPLETE_SINGLE_RUN_WRAPPER_PREFIX$cmd"
    # complete --command "$COMPLETE_SINGLE_RUN_WRAPPER_PREFIX$cmd" \
    #     --arguments "(
    #       complete --erase --command $COMPLETE_SINGLE_RUN_WRAPPER_PREFIX$cmd \
    #       && complete --command $cmd --erase --wraps $COMPLETE_SINGLE_RUN_WRAPPER_PREFIX$cmd \
    #       && complete --do-complete='vf $current_commandline ' \
    #     )" \
    #     --no-files
    complete --command "$COMPLETE_SINGLE_RUN_WRAPPER_PREFIX$cmd" \
        --arguments "(
          complete --erase --command $COMPLETE_SINGLE_RUN_WRAPPER_PREFIX$cmd \
          && complete --do-complete='$completer_cmd $current_commandline ' \
        )" \
        --no-files
end

# TODO: Want to make !@ trigger an auto-complete of filenames
# from the latest `s` search
function bind_at
    # commandline --current-token >> current-token.txt
    # commandline --current-job >> current-job.txt
    # commandline --current-process >> current-process.txt
    switch (commandline --current-token)[1]
    # This case lets us still type a literal `!@` if we need to (by
    # typing `!\$`). Probably overkill.
    case "*!\\"
        # Without the `--`, the functionality can break when completing
        # flags used in the history (since, in certain edge cases
        # `commandline` will assume that *it* should try to interpret
        # the flag)
        commandline --current-token -- (commandline --current-token | head -c '-2')@
    case "*!"
        # Without the `--`, the functionality can break when completing
        # flags used in the history (since, in certain edge cases
        # `commandline` will assume that *it* should try to interpret
        # the flag)
        commandline --function backward-delete-char
        complete_single_run_wrapper vf (commandline --current-process | cut -f 1 -d ' ')
        # commandline --current-token >> current-token.txt
        # commandline --current-job >> current-job.txt
        # commandline --current-process >> current-process.txt
        commandline --function complete-and-search pager-toggle-search
    case "*"
        commandline --insert @
    end
end

# TODO: Want to make !# trigger an auto-complete of filenames
# by searching what's at the current token
function bind_num
  switch (commandline --current-token)[1]
  # This case lets us still type a literal `!#` if we need to (by
  # typing `!\#`). Probably overkill.
  case "*!\\"
    # Without the `--`, the functionality can break when completing
    # flags used in the history (since, in certain edge cases
    # `commandline` will assume that *it* should try to interpret
    # the flag)
    commandline --current-token -- (commandline --current-token | head -c '-2')\#
  case "!"
    # If you don't have a search term, don't try to search
    commandline --insert \#
  case "*!"
    commandline --function backward-delete-char
    set --local tmpfile (mktemp -t last_searched_files__XXXXXXXXXXXX)
    set --local current_token (commandline --current-token | head -c '-2')
    # Without the `--`, the functionality can break when completing
    # flags used in the history (since, in certain edge cases
    # `commandline` will assume that *it* should try to interpret
    # the flag)
    __search_remember_completer_s -- "$current_token"
    complete_single_run_wrapper vf (commandline --current-process | cut -f 1 -d ' ')
    commandline --function complete-and-search pager-toggle-search
  case "*"
    commandline --insert \#
  end
end

# This isn't a real command. It's just here to provide the shim for
# bind_percent.
complete --command nested_file_list \
  --condition '[ "$PWD" != "$HOME" ]' \
  --authoritative \
  --argument '(fd --max-depth 7 \'.*\' 2>/dev/null | remove_if_in_commandline)'

function bind_percent
  switch (commandline --current-token)[1]
  # This case lets us still type a literal `!%` if we need to (by
  # typing `!\%`). Probably overkill.
  case "*!\\"
    # Without the `--`, the functionality can break when completing
    # flags used in the history (since, in certain edge cases
    # `commandline` will assume that *it* should try to interpret
    # the flag)
    commandline --current-token -- (commandline --current-token | head -c '-2')%
  case "!"
    # If you don't have a search term, don't try to search
    commandline --insert %
  case "*!"
    commandline --function backward-delete-char
    # Without the `--`, the functionality can break when completing
    # flags used in the history (since, in certain edge cases
    # `commandline` will assume that *it* should try to interpret
    # the flag)
    complete_single_run_wrapper nested_file_list (commandline --current-process | cut -f 1 -d ' ')
    commandline --function complete-and-search pager-toggle-search
  case "*"
    commandline --insert %
  end
end

function bind_bang
    switch (commandline --current-token)[1]
    case "!"
        # Without the `--`, the functionality can break when completing
        # flags used in the history (since, in certain edge cases
        # `commandline` will assume that *it* should try to interpret
        # the flag)
        commandline --current-token -- $history[1]
        commandline --function repaint
    case "*"
        commandline --insert !
    end
end

function bind_dollar
    switch (commandline --current-token)[1]
    # This case lets us still type a literal `!$` if we need to (by
    # typing `!\$`). Probably overkill.
    case "*!\\"
        # Without the `--`, the functionality can break when completing
        # flags used in the history (since, in certain edge cases
        # `commandline` will assume that *it* should try to interpret
        # the flag)
        commandline --current-token -- (commandline --current-token | head -c '-2')\$

    # Main difference from referenced version is this `*!` case
    # =========================================================
    #
    # If the `!$` is preceded by an text, search backward for tokens that
    # contain that text as a substring. E.g., if we'd previously run
    #
    #   git checkout -b a_feature_branch
    #   git checkout master
    #
    # then the `fea!$` in the following would be replaced with
    # `a_feature_branch`
    #
    #   git branch -d fea!$
    #
    # and our command line would look like
    #
    #   git branch -d a_feature_branch
    #
    case "*!"
        commandline --function backward-delete-char history-token-search-backward
    case "*"
        commandline --insert '$'
    end
end

set --export PATH $HOME/apps $PATH
if which fly >/dev/null 2>/dev/null
  set --export FLYCTL_INSTALL $HOME/apps/.fly
end
set --export PATH $HOME/.cargo/bin $PATH
set --export RUST_SRC_PATH ~/stuffs/rust/src
# set --export RUSTFLAGS '-C link-args=-fuse-ld=lld'
set --export PACT_OUTPUT_DIR pact-tests

# Shouldn't be necessary after Rust 1.70 lands
set --export CARGO_REGISTRIES_CRATES_IO_PROTOCOL sparse

# not working eigh tea em
# if which sccache-wrapper.sh >/dev/null 2>/dev/null
#   set --export RUSTC_WRAPPER sccache-wrapper.sh
#   # set --export RUSTC_WORKSPACE_WRAPPER sccache-wrapper.sh
# end

if [ -e ~/.aws/profiles/sccache ]
  export (cat ~/.aws/profiles/sccache)
end

if [ (uname) = 'Darwin' ]
  # Per caveats section after running
  # `brew install llvm cmake`
  #
  # llvm is keg-only, which means it was not symlinked into /opt/homebrew,
  # because macOS already provides this software and installing another version in
  # parallel can cause all kinds of trouble.
  set --global --export LDFLAGS "-L/opt/homebrew/opt/llvm/lib/c++ -Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++" $LDFLAGS
  # Not sure if it's correct to do the following line after the one above
  # For compilers to find llvm you may need to set:
  set --global --export LDFLAGS "-L/opt/homebrew/opt/llvm/lib" $LDFLAGS
  set --global --export CPPFLAGS "-I/opt/homebrew/opt/llvm/include" $CPPFLAGS
  # If you need to have llvm first in your PATH, run:
  #   fish_add_path /opt/homebrew/opt/llvm/bin
  #
  # Per brew
  set --global --export LDFLAGS "-L/opt/homebrew/opt/openblas/lib" $LDFLAGS
  set --global --export CPPFLAGS "-I/opt/homebrew/opt/openblas/include" $CPPFLAGS
  # For pkg-config to find openblas you may need to set:
  set --global --export PKG_CONFIG_PATH "/opt/homebrew/opt/openblas/lib/pkgconfig" $PKG_CONFIG_PATH

  # Per brew
  set --global --export LDFLAGS "-L/opt/homebrew/opt/libpq/lib" $LDFLAGS
  set --global --export CPPFLAGS "-I/opt/homebrew/opt/libpq/include" $CPPFLAGS
  set --global --export PKG_CONFIG_PATH "/opt/homebrew/opt/libpq/lib/pkgconfig" $PKG_CONFIG_PATH
  set --global --export CPPFLAGS "-I/opt/homebrew/opt/openjdk/include" $CPPFLAGS

  fish_add_path /opt/homebrew/opt/openjdk/bin
end

starship init fish | source
