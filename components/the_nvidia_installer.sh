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

check_nouveau_and_block() {
  echo "blacklist nouveau
options nouveau modeset=0
" >/etc/modprobe.d/blacklist-nouveau.conf
  lsmod | grep nouveau
  dpkg -l | grep nouveau
  # 检查是否加载了 nouveau 模块
  if lsmod | grep -q nouveau; then
    echo "nouveau 模块已加载。需要重启系统以应用更改。"
    read -p "现在重启系统吗？ (y/n): " choice
    case "$choice" in
    y | Y)
      echo "重启系统..."
      sudo update-initramfs -u
      sudo reboot
      ;;
    *)
      echo "请记得手动重启系统以应用更改。"
      ;;
    esac
  else
    echo "nouveau 模块未加载。不需要重启。"
  fi
}

get_latest_version() {
  #获取最新版本
  local latest_version_str=$(curl -s $nvidia_server/latest.txt)
  local latest_version=$(echo $latest_version_str | awk '{print $2}')
  echo $latest_version
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

install_driver_and_cuda() {
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
  check_nouveau_and_block
  install_driver_and_cuda
  check_nvidia_module
  # unistall_nvidia_driver
}
