#!/bin/bash
#@description: 菜单化显示工具箱列表
#@author: Fred Zhang Qi
#@datetime: 2023-12-24

#文件依赖
#⚠️import--需要引入包含函数的文件
source ./components/the_nvidia_installer.sh
source ./components/the_lxc_gpu_passthrough.sh
source ./components/the_whisper_installer.sh

menu_title() {
  date
  echo "Root Required--执行需要管理员权限。请注意"
  echo "*********************"
  echo "*****   工具箱Tool   *****"
}

menu_back() {
  echo
  echo -n "press any key--按任意键返回."
  read
  clear
}

main() {
  while (true); do
    menu_title
    echo "01. nvidia installer--NVIDIA显卡驱动安装"
    echo "02. lxc gpu passthrough--LXC容器显卡直通"
    echo "03. whisper installer--语音转文字whisper安装"
    echo "04. transcribe audio--语音转换"
    echo "05. uninstall nvidia driver--卸载NVIDIA显卡驱动"
    echo "08. more--更多"
    echo "09. about--关于"
    echo "00. exit--退出"
    echo
    echo -n "your choice--请输入你的选择："
    read the_user_choice
    case "$the_user_choice" in
    01 | 1) the_nvidia_installer ;;
    02 | 2) the_lxc_gpu_passthrough ;;
    03 | 3) the_whisper_installer ;;
    04 | 4) python3 main.py ;;
    05 | 5) unistall_nvidia_driver ;;
    08 | 8) echo 'wait and see--敬请期待' ;;
    09 | 9) nano readme.md ;;
    00 | 0 | "") exit 1 ;;
    u) echo "???" ;;
    *) echo "error input--输入有误，请重新输入！" && menu_back ;;
    esac
    echo
  done
}

clear
main
