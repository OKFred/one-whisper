#!/bin/bash
#@description: 安装英伟达显卡驱动和CUDA工具包
#@author: Fred Zhang Qi
#@datetime: 2024-02-29

#文件依赖
#⚠️import--需要引入包含函数的文件
#none

check_hardware() {
  #检查硬件
  local has_pciutils=$(which lspci)
  if [ $has_pciutils == "" ]; then
    apt install pciutils -y
  fi
  lspci | grep -i nvidia
  echo "检查完成"
}

check_nvidia_module() {
  echo "检查nvidia模块"
  lsmod | grep nvidia
  lsof | grep nvidia
}

install_nvidia_driver() {
  #安装英伟达显卡驱动
  local file_name="NVIDIA-Linux-x86_64-550.54.14.run" #发布日期:	2024.2.23
  wget https://cn.download.nvidia.com/XFree86/Linux-x86_64/550.54.14/$file_name
  chmod +x $file_name
  read -p "是否需要核心模块？(y/n) (LXC一般不需要)" need_kernel_module
  if [ $need_kernel_module == "y" ]; then
    ./$file_name
  else
    ./$file_name --no-kernel-module
  fi
  echo "安装完成，检查命令是否可用"
  nvidia-smi
}

unistall_nvidia_driver() {
  #卸载英伟达显卡驱动
  local file_name="NVIDIA-Linux-x86_64-550.54.14.run" #发布日期:	2024.2.23
  ./$file_name --uninstall
  apt remove nvidia-driver
  apt --purge remove "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" "*nvvm*"
  apt --purge remove "*nvidia*" "libxnvctrl*"
  apt autoremove
  echo "卸载完成"
}

install_cuda() {
  apt install nvidia-modprobe -y
  apt install nvidia-cuda-toolkit -y
}

the_nvidia_installer() {
  check_hardware
  check_nvidia_module
  install_nvidia_driver
}
