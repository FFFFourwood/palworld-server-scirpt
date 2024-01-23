#!/bin/bash

# The complete path of PalServer.sh
PAL_SERVER_SCRIPT_PATH="/home/steam/Steam/steamapps/common/PalServer/PalServer.sh"

# URL to send a request
WECOM_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key={wecomkey}"
IPHONE_URL="https://api.day.app/{barkkey}/PalWorld/"

# Available memory limit (unit: MB), here is 0.5GB.
MEM_LIMIT=500

# PID of the script
PAL_SERVER_PID=""


# The function to start the PalServer.sh script.
start_pal_server() {
    # Run PalServer.sh in the background as a steam user.
    sudo -u steam bash "$PAL_SERVER_SCRIPT_PATH" &
    # Get the PID of the last process put into the background.
    PAL_SERVER_PID=$!
    echo "PalServer.sh started with PID: $PAL_SERVER_PID"
}

# Function to send messages to WeCom
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

# Function to check memory and restart
check_and_restart() {
    # Get the available memory of the entire system (unit: MB)
    AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
    echo "Available Memory - ${AVAILABLE_MEM}MB..."
    # If the available memory is below the limit, restart PalServer.sh.
    if [ "$AVAILABLE_MEM" -lt "$MEM_LIMIT" ]; then
        echo "Memory limit exceeded: Available - ${AVAILABLE_MEM}MB, Limit - ${MEM_LIMIT}MB. Restarting PalServer.sh..."
        sudo kill "$PAL_SERVER_PID" 2>/dev/null
        start_pal_server
        # Send message
        send_wechat_message "Memory limit exceeded, restarting PalServer"
        send_iphone_message "Memory%20limit%20exceeded,%20restarting%20PalServer"
    fi
}


# First start PalServer.sh
start_pal_server
echo "PalServer started"
send_wechat_message "Start PalServer"
send_iphone_message "Start%20PalServer"

# Set up an infinite loop.
while true; do
    # Check the memory every minute.
    check_and_restart
    sleep 60
    echo "time interval running..."
    # Restart PalServer.sh every four hours.
    if ((SECONDS >= 14400)); then
        echo "Four hours passed. Restarting PalServer.sh..."
        sudo kill "$PAL_SERVER_PID" 2>/dev/null
        start_pal_server
        # Send message.
        send_wechat_message "Four hours passed, restarting PalServer"
        send_iphone_message "Four%20hours%20passed,%20restarting%20PalServer"
        # Reset stopwatch.
        SECONDS=0
    fi
done