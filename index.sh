#!/bin/bash
#@description: 用于部署语音识别项目的 debian 系统初始化脚本
#@author: Fred Zhang Qi
#@datetime: 2024-02-06

#文件依赖
#⚠️import--需要引入包含函数的文件

install_python_3() {
  uninstall_old_python
  local base_url=http://ftp.cn.debian.org/debian/pool/main/p/python3.10/
  local package_name
  package_name=python3.10-minimal
  downloader $package_name $base_url
  installer $package_name
  package_name=libpython3.10-stdlib
  downloader $package_name $base_url
  installer $package_name
  package_name=python3.10_3.10.13-1_amd64.deb
  downloader $package_name $base_url
  installer $package_name
  echo "检查Python3.10是否安装成功"
  python3 --version
}

downloader() {
  package_name=$1
  $base_url=$2
  if [ -f $package_name ]; then
    echo "已下载"$package_name
  else
    echo "下载"$package_name
    wget $base_url$package_name
  fi
}

installer() {
  package_name=$1
  echo "安装"$package_name
  dpkg -i $package_name
  apt install -y
}

uninstall_old_python() {
  local version=$(python3 --version | awk '{print $2}')
  if [ -z $version ]; then
    echo "未安装python3"
    return 0
  fi
  apt purge 'python3*' -y
  echo "请清理残留（若有）"
  local lines=($(dpkg -l | grep "^ii" | grep python3 | awk '{print $2}'))
  for line in ${lines[@]}; do
    echo "删除"$line
    apt purge $line -y
  done
  apt autoremove -y
  echo "删除python的外部管理，方便安装pip"
  rm /usr/lib/python$version/EXTERNALLY-MANAGED
  echo "旧版本python已卸载"
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
}

main() {
  install_python_3
  install_pip
  install_ffmpeg
  install_pytorch
  install_openai_and_whisper
}

main
