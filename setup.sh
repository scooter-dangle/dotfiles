#!/usr/bin/env bash

# apt tool installs
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update --yes
# start with fish so it's available faster when we ssh in
sudo apt install --yes fish

# use fish!
sudo chsh --shell $(which fish) codespace

# symlinks
if [ ! -e ~/dotfiles ]
then
  ln --symbolic --directory $PWD ~/dotfiles
fi
mkdir --parents ~/.config/fish
ln --symbolic --force ~/dotfiles/config.fish  ~/.config/fish/config.fish
ln --symbolic --force ~/dotfiles/aliases.fish ~/.config/fish/aliases.fish

mkdir --parents ~/.config/bat
ln --symbolic ~/dotfiles/bat.conf ~/.config/bat/config

mkdir --parents ~/.config/htop
ln --symbolic ~/dotfiles/htoprc ~/.config/htop/htoprc

ln --symbolic ~/dotfiles/starship.toml ~/.config/starship.toml

for file in .bash* .gitconfig .tmux.conf .gitignore_global .tmux.conf
do
  ln --symbolic --force ~/dotfiles/$file  ~/$file
done

if [ -d /workspaces ]
then
  mkdir --parents /workspaces/.local/share/fish
  mkdir --parents ~/.local/share/fish
  touch /workspaces/.local/share/fish/fish_history
  ln --symbolic --force /workspaces/.local/share/fish/fish_history ~/.local/share/fish/fish_history
fi

# moar of the login prompt
sh <(\
  curl --silent --show-error https://starship.rs/install.sh \
) --yes &


sudo apt install --yes build-essential

(
# the rest of the tools
sudo apt install --yes \
  git \
  ripgrep \
  fd-find \
  bat \
  tmux \
  jq \
  icdiff \
  neovim

sudo ln --symbolic --force $(which fdfind) /usr/local/bin/fd
sudo ln --symbolic --force $(which batcat) /usr/local/bin/bat
) &

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

sh <( \
  curl --proto '=https' \
    --tlsv1.2 \
    --silent \
    --show-error \
    --fail \
    https://sh.rustup.rs \
) -y

rustup default stable
rustup install $(rustc --version | cut --delimiter ' ' --fields 2) &

# Rust tools
cargo install \
  cargo-expand &

wait
