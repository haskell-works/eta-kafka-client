#!/usr/bin/env bash
if [ ! -d "${HOME}/eta" ]; then
  echo "Installing ETA"
  cd ${HOME}
  git clone --recursive https://github.com/typelead/eta
  cd eta
  ./install.sh
else
  echo "Updating ETA"
  cd ${HOME}/eta
  ./update.sh
fi
