#!/bin/bash
#@description: 用于部署语音识别项目的 debian 系统初始化脚本
#@author: Fred Zhang Qi
#@datetime: 2024-02-06

#文件依赖
#⚠️import--需要引入包含函数的文件

install_python_3() {
  wget http://ftp.cn.debian.org/debian/pool/main/p/python3.10/python3.10_3.10.13-1_amd64.deb
  sudo dpkg -i python3.10_3.10.13-1_amd64.deb
  sudo apt install -f -y
  #检查是否安装成功
  python --version
  echo "Python3.10.10已安装"
}

install_pip() {
  sudo apt install -y python3-pip
  echo "pip已安装"
}

install_ffmpeg() {
  sudo apt install -y ffmpeg
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
