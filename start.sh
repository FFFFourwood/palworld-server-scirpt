#!/bin/bash

# The complete path of PalServer.sh
PAL_SERVER_SCRIPT_PATH="/home/steam/Steam/steamapps/common/PalServer/PalServer.sh"

# The URL to send the request.
WECOM_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key={wecomkey}"
IPHONE_URL="https://api.day.app/{barkkey}/PalWorld/"

# Available memory limit (unit: MB), here is 300MB.
MEM_LIMIT=300


# The function to start the PalServer.sh script.
start_pal_server() {
    # Run PalServer.sh in the background as a steam user.
    sudo -u steam bash "$PAL_SERVER_SCRIPT_PATH" &
    echo "PalServer.sh started"
    send_wechat_message "Start PalServer"
    send_iphone_message "Start%20PalServer"
}

# Function to send messages to WeCom Bot
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

# Function to send messages to iPhone
send_iphone_message() {
    local message=$1
    local icon="?icon=https://ffffourwood.cn/usr/uploads/2023/10/584a5ab299ad6a033021f2c6bd8d7b22.JPG"
    local url="${IPHONE_URL}${message}${icon}"

    curl -s -w "\n" -G "$url"
    echo "Message sent to iPhone: $message"
}

# Function to check memory and restart.
check_and_restart() {
    # Get the available memory of the entire system (unit: MB)
    AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
    echo "Available Memory - ${AVAILABLE_MEM}MB..."
    # If the available memory is below the limit, restart PalServer.sh.
    if [ "$AVAILABLE_MEM" -lt "$MEM_LIMIT" ]; then
        echo "Memory limit exceeded: Available - ${AVAILABLE_MEM}MB, Limit - ${MEM_LIMIT}MB. Restarting PalServer.sh..."
        sudo pkill -f PalServer-Linux 2>/dev/null
        # Send message.
        send_wechat_message "Memory limit exceeded, kill PalServer-Linux"
        send_iphone_message "Memory%20limit%20exceeded"
        sleep 30
        start_pal_server
    fi
}


# First start PalServer.sh
start_pal_server
echo "PalServer started"

# Set up an infinite loop.
while true; do
    # Check the memory every minute.
    check_and_restart
    sleep 60
    echo "time interval running..."
    # Restart PalServer.sh every four hours.
    # if ((SECONDS >= 14400)); then
    #     echo "Four hours passed. Restarting PalServer.sh..."
    #     sudo pkill -f PalServer-Linux 2>/dev/null
    #     # 发送消息
    #     send_wechat_message "Four hours passed, restarting PalServer"
    #     send_iphone_message "Four%20hours%20passed%20restarting%20PalServer"
    #     sleep 30
    #     start_pal_server
    #     # 重置秒表
    #     SECONDS=0
    # fi
done