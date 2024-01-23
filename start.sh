#!/bin/bash

# PalServer.sh 的完整路径
PAL_SERVER_SCRIPT_PATH="/home/steam/Steam/steamapps/common/PalServer/PalServer.sh"

# 要发送GET请求的URL
WECOM_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=企业微信的key"
IPHONE_URL="https://api.day.app/你的bark key/PalWorld/"

# 可用内存限制（单位：MB），这里是0.5GB
MEM_LIMIT=500

# 脚本的PID
PAL_SERVER_PID=""


# 启动 PalServer.sh 脚本的函数
start_pal_server() {
    # 以steam用户身份在后台运行PalServer.sh
    sudo -u steam bash "$PAL_SERVER_SCRIPT_PATH" &
    # 获取最后一个放入后台的进程的PID
    PAL_SERVER_PID=$!
    echo "PalServer.sh started with PID: $PAL_SERVER_PID"
}

# 发送消息到微信企业号的函数
send_wechat_message() {
    local message=$1
    local json_data=$(cat <<EOF
{
    "msgtype": "text",
    "text": {
        "content": "$message"
    }
}
EOF
)

    curl -s -w "\n" "$WECOM_URL" \
        -H 'Content-Type: application/json' \
        -d "$json_data"
    echo "Message sent to WeChat: $message"
}

# 发送消息到iPhone的函数
send_iphone_message() {
    local message=$1
    local icon="?icon=https://ffffourwood.cn/usr/uploads/2023/10/584a5ab299ad6a033021f2c6bd8d7b22.JPG"
    local url="${IPHONE_URL}${message}${icon}"

    curl -s -w "\n" -G "$url"
    echo "Message sent to iPhone: $message"
}

# 检查内存并重启的函数
check_and_restart() {
    # 获取整个系统的可用内存（单位：MB）
    AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
    echo "Available Memory - ${AVAILABLE_MEM}MB..."
    # 如果可用内存低于限制，则重启PalServer.sh
    if [ "$AVAILABLE_MEM" -lt "$MEM_LIMIT" ]; then
        echo "Memory limit exceeded: Available - ${AVAILABLE_MEM}MB, Limit - ${MEM_LIMIT}MB. Restarting PalServer.sh..."
        sudo kill "$PAL_SERVER_PID" 2>/dev/null
        start_pal_server
        # 发送消息
        send_wechat_message "Memory limit exceeded, restarting PalServer"
        send_iphone_message "Memory%20limit%20exceeded,%20restarting%20PalServer"
    fi
}


# 首次启动 PalServer.sh
start_pal_server
echo "PalServer started"
send_wechat_message "Start PalServer"
send_iphone_message "Start%20PalServer"

# 设置一个无限循环
while true; do
    # 每隔一分钟检查一次内存
    check_and_restart
    sleep 60
    echo "time interval running..."
    # 每四个小时重启一次PalServer.sh
    if ((SECONDS >= 14400)); then
        echo "Four hours passed. Restarting PalServer.sh..."
        sudo kill "$PAL_SERVER_PID" 2>/dev/null
        start_pal_server
        # 发送消息
        send_wechat_message "Four hours passed, restarting PalServer"
        send_iphone_message "Four%20hours%20passed,%20restarting%20PalServer"
        # 重置秒表
        SECONDS=0
    fi
done