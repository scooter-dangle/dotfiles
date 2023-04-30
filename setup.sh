#!/usr/bin/env bash

# apt tool installs
sudo apt update --yes
sudo apt install --yes \
  curl \
  fish \
  git \
  ripgrep \
  fd-find \
  bat \
  tmux \
  jq \
  icdiff \
  neovim \
  build-essential

# Rust
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

# symlinks

mkdir --parents ~/.config/fish
ln --symbolic --force ~/dotfiles/fish/config.fish  ~/.config/fish/config.fish
ln --symbolic --force ~/dotfiles/fish/aliases.fish ~/.config/fish/aliases.fish

for file in .bash* .gitconfig .tmux.conf .gitignore_global .tmux.conf
do
  ln --symbolic --force ~/dotfiles/$file  ~/$file
done

# use fish!
chsh --shell $(which fish)
