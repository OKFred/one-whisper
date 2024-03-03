#!/bin/bash
#@description: 用于部署语音识别项目的 debian 系统初始化脚本
#@author: Fred Zhang Qi
#@datetime: 2024-02-06

#文件依赖
#⚠️import--需要引入包含函数的文件
#none

install_python_3() {
  # 获取Python版本，并提取主要版本号
  local version=$(python3 --version | awk '{print $2}' | awk -v FS="." '{print $1$2}')
  # 检查主要版本号是否大于311
  if [ "$version" -gt 311 ]; then
    echo "版本大于3.11，可能不兼容openAI-whisper，敬请留意"
    echo "https://github.com/openai/whisper?tab=readme-ov-file#setup"
  fi
  apt install -y python3
  echo "删除python的外部管理，方便安装pip"
  rm /usr/lib/python$version/EXTERNALLY-MANAGED
}

install_pip() {
  apt install -y python3-pip
  echo "pip已安装"
}

install_ffmpeg() {
  apt install -y ffmpeg
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
  pip3 install openai-whisper
  echo "openai和whisper已安装"
  echo "下一步：可以运行 python3 main.py 进行测试"
  read -p "下载测试音频？(y/n)" download_audio
  if [ $download_audio = "y" ]; then
    wget https://cdn.openai.com/whisper/draft-20220913a/younha.wav
  fi
}

the_whisper_installer() {
  install_python_3
  install_pip
  install_ffmpeg
  install_pytorch
  install_openai_and_whisper
}