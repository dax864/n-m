#!/bin/bash

# Lấy trạng thái hiện tại của UFW
# Lệnh grep sẽ tìm chữ 'active' trong kết quả của 'ufw status'
STATUS=$(ufw status | grep "Status: active")

if [ -z "$STATUS" ]; then
    # Nếu biến STATUS rỗng, nghĩa là firewall đang tắt (inactive)
    echo "Firewall hiện đang TẮT. Đang tiến hành BẬT và cấu hình"
    sudo ufw enable
    sudo ufw allow 22/tcp
    sudo ufw allow 2222/tcp
    sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
else
    # Nếu STATUS không rỗng, nghĩa là firewall đang bật (active)
    echo "Firewall hiện đang BẬT. Đang tiến hành TẮT"
    sudo ufw disable
    sudo ufw delete allow 22/tcp
    sudo ufw delete allow 2222/tcp
    sudo iptables -t nat -F
fi

# Hiển thị lại trạng thái cuối cùng
sudo ufw status
