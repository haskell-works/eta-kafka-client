#!/usr/bin/env bash
if [ ! -d "~/eta" ]; then
  cd ~/
  git clone --recursive https://github.com/typelead/eta
  cd eta
  ./install.sh
else
  cd ~/eta
  ./update.sh
fi
