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
  echo "是否存在英伟达显卡？"
  lspci | grep -i nvidia
  echo "显卡是否被识别？"
  local result=$(ls -l /dev/nvidia* /dev/dri/* /dev/fb0)
  echo $result
  local error_case=$(echo $result | grep "No such file or directory")
  if [ $error_case != "" ]; then
    echo "显卡未被识别"
    return 1
  fi
}

check_nvidia_module() {
  echo "检查nvidia模块"
  lsmod | grep nvidia
  lsof | grep nvidia
}

install_nvidia_driver() {
  #安装英伟达显卡驱动
  local file_name="NVIDIA-Linux-x86_64-550.54.14.run" #发布日期:	2024.2.23
  if [ ! -f $file_name ]; then
    wget https://cn.download.nvidia.com/XFree86/Linux-x86_64/550.54.14/$file_name
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
  local file_name="NVIDIA-Linux-x86_64-550.54.14.run" #发布日期:	2024.2.23
  ./$file_name --uninstall
  apt remove nvidia-driver -y
  apt --purge remove "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" "*nvvm*" -y
  apt --purge remove "*nvidia*" "libxnvctrl*" -y
  apt autoremove -y
  echo "卸载完成"
}

install_cuda() {
  # apt install nvidia-driver -y
  # apt install nvidia-modprobe -y
  apt install nvidia-cuda-toolkit -y
  echo "安装完成，检查命令是否可用"
  nvidia-smi
}

the_nvidia_installer() {
  check_hardware
  if [ $? -eq 1 ]; then
    echo "未检测到英伟达显卡，退出安装"
    return 1
  fi
  check_nvidia_module
  install_nvidia_driver
  install_cuda
}
