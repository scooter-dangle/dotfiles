#!/usr/bin/env bash
# build_env.sh

sudo apt-get install -y vim-common tmux fish git htop exuberant-ctags build-essential rbenv
cd ~
git clone https://github.com/scooter-dangle/dotfiles.git
git clone https://github.com/scooter-dangle/dotvim.git
mv dotvim .vim
mkdir --parents .config/fish
ln --symbolic ~/dotfiles/config.fish  ~/.config/fish/config.fish
ln --symbolic ~/dotfiles/aliases.fish ~/.config/fish/aliases.fish
ln --symbolic ~/dotfiles/.tmux.conf   ~/.tmux.conf
ln --symbolic ~/.vim/vimrc ~/.vimrc
fish --command=install_rbenv
fish --command=fish_update_completions
cd ~/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git
vim +PluginInstall +qall
cd ~
