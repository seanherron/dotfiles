#!/bin/zsh

setopt EXTENDED_GLOB


echo "zprezto: checking to see if present"
if [ !  -d .zprezto ]; then
  echo "zprezto: not present...downloading..."
  git clone --recursive git@github.com:seanherron/prezto.git .zprezto > /dev/null 2>&1
  echo "zprezto: downloaded!"
fi

if [ ! -L ~/.zprezto ]; then
  ln -s ~/.dotfiles/.zprezto ~/.zprezto > /dev/null 2>&1
fi

for rcfile in .zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" > /dev/null 2>&1
done

if dscl . -read ~/ UserShell | sed 's/UserShell: //' | grep -q '/bin/zsh'; then
   echo "zprezto: zsh already set as default shell"
else
  chsh -s /bin/zsh
fi

if [ ! -f /usr/local/bin/brew ]; then
  arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew bundle

for rcfile in ~/.dotfiles/.[^.]*; do
  ln -s "$rcfile" ~/"${rcfile:t}" > /dev/null 2>&1
done