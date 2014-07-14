#!/usr/bin/env bash
# build_env.sh

sudo apt-get -y install vim-common tmux fish git htop exuberant-ctags build-essential autoconf bison libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev libmysqlclient-dev rbenv

cd ~
git clone https://github.com/scooter-dangle/dotfiles.git
ln --symbolic ~/dotfiles/.tmux.conf   ~/.tmux.conf

mkdir --parents .config/fish
ln --symbolic ~/dotfiles/config.fish  ~/.config/fish/config.fish
ln --symbolic ~/dotfiles/aliases.fish ~/.config/fish/aliases.fish
fish --command=install_rbenv
fish --command=fish_update_completions

git clone https://github.com/scooter-dangle/dotvim.git
mv dotvim .vim
ln --symbolic ~/.vim/vimrc ~/.vimrc
cd ~/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git
vim +PluginInstall +qall

cd ~
