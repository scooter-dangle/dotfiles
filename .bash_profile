[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
PS1="\$(~/.rvm/bin/rvm-prompt u) $PS1" # To display to current ruby selection string in my prompt
source ~/.bashrc

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
if [ -e /home/scott/.nix-profile/etc/profile.d/nix.sh ]; then . /home/scott/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
