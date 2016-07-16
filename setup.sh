sudo apt-get install openssl libcurl4-openssl-dev libxml2 libssl-dev libxml2-dev pinentry-curses xclip
sudo apt-get update
sudo apt-get install fish tmux git
sudo apt-get install lastpass-cli
sudo apt-get install silversearcher-ag
git clone https://github.com/lastpass/lastpass-cli.git
cd lastpass-cli && make
sudo make install
cd ..
sudo apt-get install make
sudo apt-get install gcc -y
lpass login scottlsteele@gmail.com
git clone https://github.com/scooter-dangle/dotfiles.git
cd dotfiles
git checkout mac_os_x
cd ~
rm ~/.bash_aliases
ln --symbolic ~/dotfiles/.bash_aliases ~/.bash_aliases
rm ~/.bash_profile
ln --symbolic ~/dotfiles/.bash_profile ~/.bash_profile
rm ~/.gitconfig
ln --symbolic ~/dotfiles/.gitconfig ~/.gitconfig
rm ~/.gitignore
ln --symbolic ~/dotfiles/.gitignore ~/.gitignore
rm ~/.gitignore_global
ln --symbolic ~/dotfiles/.gitignore_global ~/.gitignore_global
rm ~/.rspec
ln --symbolic ~/dotfiles/.rspec ~/.rspec
rm ~/.pryrc
ln --symbolic ~/dotfiles/.pryrc ~/.pryrc
rm ~/.bashrc
ln --symbolic ~/dotfiles/.bashrc ~/.bashrc
rm ~/.irbrc
ln --symbolic ~/dotfiles/.irbrc ~/.irbrc
rm ~/.agrc
ln --symbolic ~/dotfiles/.agrc ~/.agrc
rm ~/.tmux.conf 
ln --symbolic ~/dotfiles/.tmux.conf ~/.tmux.conf 
rm ~/.tmux.conf 
ln --symbolic ~/dotfiles/.tmux.conf ~/.tmux.conf 
rm ~/.config/fish/config.fish
ln --symbolic ~/dotfiles/config.fish ~/.config/fish/config.fish
rm ~/.config/fish/aliases.fish
ln --symbolic ~/dotfiles/aliases.fish ~/.config/fish/aliases.fish
