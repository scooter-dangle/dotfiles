#!/usr/bin/env bash

# apt tool installs
sudo apt update --yes
# start with fish so it's available faster when we ssh in
sudo apt install --yes fish

# use fish!
sudo chsh --shell $(which fish) codespace

# symlinks
mkdir --parents ~/.config/fish
ln --symbolic --force $PWD/config.fish  ~/.config/fish/config.fish
ln --symbolic --force $PWD/aliases.fish ~/.config/fish/aliases.fish

mkdir --parents ~/.config/bat
ln --symbolic $PWD/bat.conf ~/.config/bat/config

ln --symbolic $PWD/starship.toml ~/.config/starship.toml

for file in .bash* .gitconfig .tmux.conf .gitignore_global .tmux.conf
do
  ln --symbolic --force $PWD/$file  ~/$file
done

if [ -d /workspaces ]
then
  mkdir --parents /workspaces/.local/share/fish
  mkdir --parents ~/.local/share/fish
  touch /workspaces/.local/share/fish/fish_history
  ln --symbolic --force /workspaces/.local/share/fish/fish_history ~/.local/share/fish/fish_history
fi

# moar of the login prompt
curl --silent --show-error https://starship.rs/install.sh | sh

# the rest of the tools
sudo apt install --yes \
  curl \
  git \
  ripgrep \
  fd-find \
  bat \
  tmux \
  jq \
  icdiff \
  neovim \
  build-essential

sudo ln --symbolic --force $(which fdfind) /usr/local/bin/fd
sudo ln --symbolic --force $(which batcat) /usr/local/bin/bat

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

bash <( \
  curl --proto '=https' \
    --tlsv1.2 \
    --silent \
    --show-error \
    --fail \
    https://sh.rustup.rs \
) -y

# Rust tools
cargo install \
  cargo-expand
