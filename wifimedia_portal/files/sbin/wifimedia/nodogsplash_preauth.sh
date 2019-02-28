#!/bin/sh

CLIENT_MAC=${2}
GATEWAY_MAC=$(ifconfig | grep br-lan | grep HWaddr | tr -s ' ' | cut -d' ' -f5)

# Gửi thông tin lên server
# Do có nhiều clients ở trạng thái preauthenticated, gửi lên theo cách này thống kê được nhiều hơn
wget -q --spider "http://portal.nextify.vn/connect?client_mac=${CLIENT_MAC}&gateway_mac=${GATEWAY_MAC}" &

echo 0 500 500
