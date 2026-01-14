#!/bin/bash

set -e

echo "[1] Tải openssh-server."
apt update
# Đã thêm openssh-server vào ngay sau các gói python
apt install -y git python3-venv python3-dev libssl-dev libffi-dev build-essential **openssh-server**

echo "[2] Tải Cowrie v2.5.0."
rm -rf /opt/cowrie
cd /opt
git clone --branch v2.5.0 https://github.com/cowrie/cowrie.git

echo "[3] Tạo cowrie user."
adduser --disabled-password --gecos "" admin || true
chown -R admin:admin /opt/cowrie

echo "[4] Setting virtual environment."
sudo -u admin bash -c "
cd /opt/cowrie &&
python3 -m venv cowrie-env &&
source cowrie-env/bin/activate &&
pip install --upgrade pip &&
pip install -r requirements.txt &&
cp etc/cowrie.cfg.dist etc/cowrie.cfg
"

echo "[*] Configuring auto-start cho user admin via Crontab..."
sudo crontab -u admin -r || true
(sudo -u admin crontab -l 2>/dev/null; echo "@reboot /bin/bash -c 'cd /opt/cowrie && source cowrie-env/bin/activate && bin/cowrie start'") | sudo -u admin crontab -

echo "[*] Granting absolute ownership to admin."
# Cấp quyền sở hữu tuyệt đối để tránh lỗi Permission denied
sudo chown -R admin:admin /opt/cowrie

echo "[5] Khởi động cowrie lần đầu."
sudo -u admin bash -c "
cd /opt/cowrie &&
source cowrie-env/bin/activate &&
bin/cowrie start
"

echo "===================================================="
echo "  Cowrie đã được tải và khởi động ở cổng 2222!"
echo "  SSH Server (openssh-server) đã được tải."
echo "  Cowrie sẽ được tự động bật khi máy bật."
echo "===================================================="
