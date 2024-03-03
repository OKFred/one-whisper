#!/bin/bash
#@description: LXC环境下，允许设备访问和挂载点的设置
#@author: Fred Zhang Qi
#@datetime: 2024-03-03

#文件依赖
#⚠️import--需要引入包含函数的文件
#none

the_lxc_gpu_passthrough() {
  echo "Available LXC Containers / 可用的 LXC 容器列表:"
  ls /etc/pve/lxc/
  read -p "LXC container name (e.g., 100) / 输入 LXC 容器名称（例如，100）: " container_name
  container_conf="/etc/pve/lxc/${container_name}.conf"
  #先备份配置文件
  cp $container_conf $container_conf.bak
  if [ ! -f "$container_conf" ]; then
    echo "Error: Container $container_name does not exist / 错误：容器 $container_name 不存在."
  else
    echo "Configuring LXC container: $container_name / 正在配置 LXC 容器: $container_name"
    echo "检查是否开启嵌套虚拟化"
    if [ ! -n "$(grep "nesting=1" $container_conf)" ]; then
      echo "features: nesting=1" >>$container_conf
    fi
    echo "Available Devices / 可用的设备:"
    ls -l /dev/nvidia* /dev/dri/* /dev/fb0
    echo "lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop: 
lxc.cgroup2.devices.allow: c 195:* rwm
lxc.cgroup2.devices.allow: c 511:* rwm
lxc.cgroup2.devices.allow: c 236:* rwm
lxc.cgroup2.devices.allow: c 226:* rwm
lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-modeset dev/nvidia-modeset none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
lxc.mount.entry: /dev/dri/card0 dev/dri/card0 none bind,optional,create=file
lxc.mount.entry: /dev/dri/card1 dev/dri/card1 none bind,optional,create=file
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file
" >>$container_conf
    if [ ! -n "$(grep "tags" $container_conf)" ]; then
      echo "tags: nvidia" >>$container_conf
    fi
    echo "Configuration completed / 配置完成，重启容器以生效"
    echo "如需恢复之前的配置文件，请执行：cp $container_conf.bak $container_conf"
  fi
}
