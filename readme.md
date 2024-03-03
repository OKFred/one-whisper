### @description: 用于部署语音识别项目的 debian 系统初始化脚本

### @author: Fred Zhang Qi

### @datetime: 2024-02-06

## 运行方法

`cd $HOME && git clone https://github.com/OKFred/one-whisper`

`cd $HOME/one-whisper && git reset --hard HEAD && git pull && chmod +x menu.sh && ./menu.sh`

#### 菜单预览
1. NVIDIA显卡驱动安装
2. LXC容器显卡直通
3. 语音转文字whisper安装
4. 语音转换