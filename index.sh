#!/bin/bash

install_python_3() {
  sudo apt-get update
  sudo apt-get install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget
  wget https://www.python.org/ftp/python/3.10.10/Python-3.10.10.tgz
  tar -xf Python-3.10.10.tgz
  cd Python-3.10.10
  ./configure --enable-optimizations
  make
  sudo make install
  cd ..
  sudo rm -rf Python-3.10.10
  echo "Python3.10.10已安装"
}

install_pip() {
  sudo apt-get install python3-pip
  echo "pip已安装"
}

install_ffmpeg() {
  sudo apt-get install ffmpeg
  echo "ffmpeg已安装"
}

install_pytorch() {
  read -p "是否使用英伟达显卡计算？(y/n)" use_gpu
  if [ $use_gpu = "y" ]; then
    pip3 install torch torchvision torchaudio
  else
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
  fi
  echo "pytorch已安装"
}

install_openai_and_whisper() {
  pip3 install openai
  pip3 install whisper
  echo "openai和whisper已安装"
}

main() {
  install_python_3
  install_pip
  install_ffmpeg
  install_pytorch
  install_openai_and_whisper
}

main
