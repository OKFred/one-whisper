#!/bin/bash
#@description: 安装英伟达显卡驱动和CUDA工具包
#@author: Fred Zhang Qi
#@datetime: 2024-02-29

#文件依赖
#⚠️import--需要引入包含函数的文件
#none
nvidia_server="https://download.nvidia.com/XFree86/Linux-x86_64"

check_hardware() {
  echo "显卡是否被识别？"
  local result=$(ls -l /dev/nvidia* /dev/dri/* /dev/fb0)
  echo $result
  local error_case=$(echo $result | grep "No such file or directory")
  if [[ -n $error_case ]]; then
    echo "显卡未被识别"
    return 1
  fi
}

check_nvidia_module() {
  echo "检查nvidia模块"
  lsmod | grep nvidia
  lsof | grep nvidia
}

get_latest_version() {
  #获取最新版本
  local latest_version_str=$(curl -s $nvidia_server/latest.txt)
  local latest_version=$(echo $latest_version_str | awk '{print $2}')
  echo $latest_version
}

install_nvidia_driver() {
  #安装英伟达显卡驱动
  local latest_version=$(get_latest_version)
  local file_name=$(echo $latest_version | awk -F'/' '{print $NF}')
  echo "当前最新版本为：$latest_version"
  if [ ! -f $file_name ]; then
    wget $nvidia_server/$latest_version
  fi
  chmod +x $file_name
  read -p "是否需要核心模块？(y/n) (LXC一般不需要)" need_kernel_module
  # 回车默认为n
  if [ -z "$need_kernel_module" ] || [ "$need_kernel_module" = "n" ]; then
    ./"$file_name" --no-kernel-module
  else
    ./"$file_name"
  fi
  echo "已安装驱动"
}

unistall_nvidia_driver() {
  #卸载英伟达显卡驱动
  local latest_version=$(get_latest_version)
  local file_name=$(echo $latest_version | awk -F'/' '{print $NF}')
  if [ -f $file_name ]; then
    ./$file_name --uninstall
  fi
  apt remove nvidia-driver -y
  apt --purge remove "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" "*nvvm*" -y
  apt --purge remove "*nvidia*" "libxnvctrl*" -y
  apt autoremove -y
  modprobe -r nvidia nvidia_drm nvidia_modeset nvidia_uvm
  if grep -q "Driver *\"nvidia\"" /etc/X11/xorg.conf; then
    sed -i 's/Driver *\"nvidia\"/#&/' /etc/X11/xorg.conf
  fi
  echo "卸载完成"
  echo "建议重启系统"
  read -p "是否需要重启？(y/n)" need_reboot
  if [[ $need_reboot == "y" ]]; then
    reboot
  fi
}

install_cuda() {
  apt install nvidia-driver -y
  # apt install nvidia-modprobe -y
  apt install nvidia-cuda-toolkit -y
  echo "安装完成，检查命令是否可用"
  nvidia-smi
}

the_nvidia_installer() {
  #检查硬件
  apt update
  local has_pciutils=$(which lspci)
  if [[ $has_pciutil=="" ]]; then
    apt install pciutils -y
  fi
  echo "是否存在英伟达显卡？"
  local has_nvidia=$(lspci | grep -i nvidia)
  echo $has_nvidia
  if [[ -z $has_nvidia ]]; then
    echo "不存在英伟达显卡"
    return 1
  fi
  check_hardware
  install_cuda
  check_nvidia_module
  # unistall_nvidia_driver
}
