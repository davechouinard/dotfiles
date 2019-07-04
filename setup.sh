#!/bin/bash
# Run this script from the dotfiles directory:
# ./setup.sh

pip_command='pip'
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    *)          machine="UNKNOWN:${unameOut}"
esac
if [[ "${machine}" == "Cygwin" ]]; then
  pip_command='pip2'
fi

mkdir -p ~/.config/powerline
cp powerline-config.json ~/.config/powerline/config.json
$pip_command install --user powerline-status
powerline_location=$($pip_command show powerline-status|grep Location|sed 's/Location: //')
if [[ "x$powerline_location" == "x" ]]; then
  echo 'Fatal error:'
  echo 'Could not detect powerline location'
  exit 1
fi

sed "s@POWERLINE_LOCATION@$powerline_location@" .bashrc.powerline > ~/.bashrc
sed "s@POWERLINE_LOCATION@$powerline_location@" .tmux.conf.powerline > ~/.tmux.conf
sed "s@POWERLINE_LOCATION@$powerline_location@" .vimrc.powerline > ~/.vimrc
sed "s@POWERLINE_LOCATION@$powerline_location@" .zshrc.powerline > ~/.zshrc
cp .local.environment ~/

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

sed -e "s/AUTHORNAME/$USER/g" -e "s/AUTHOREMAIL/root@localhost/g" .gitconfig > ~/.gitconfig

if [[ "${machine}" == "Mac" ]]; then
  mkdir -p ~/Library/KeyBindings
  cp DefaultKeyBinding.dict ~/Library/KeyBindings/
  mkdir -p ~/Library/Application\ Support/Code/User/snippets
  cp vscode/settings.json ~/Library/Application\ Support/Code/User/
  cp vscode/snippets/* ~/Library/Application\ Support/Code/User/snippets/
  echo 'export PATH="$PATH:$HOME/.local/bin:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin"' >> ~/.bashrc
elif [[ "${machine}" == "Cygwin" ]]; then
  pip_command='pip2'
  mkdir -p /cygdrive/c/Users/$USER/AppData/Roaming/Code/User/snippets
  cp vscode/settings.json /cygdrive/c/Users/$USER/AppData/Roaming/Code/User/
  cp vscode/snippets/* /cygdrive/c/Users/$USER/AppData/Roaming/Code/User/snippets/
  cp -a .mintty ~/
  cp .minttyrc ~/
  echo 'export PATH="$PATH:$HOME/.local/bin:/cygdrive/c/Users/$USER/VSCode-win32-x64/bin"' >> ~/.bashrc
else
  mkdir -p ~/.config/Code/User/snippets
  cp vscode/settings.json ~/.config/Code/User/
  cp vscode/snippets/* ~/.config/Code/User/snippets/
  cp Desktop/* ~/Desktop/
  cp Pictures/* ~/Pictures/
  echo 'export PATH="$PATH:$HOME/.local/bin:$HOME/VSCode-linux-x64"' >> ~/.bashrc
fi

exit 0
