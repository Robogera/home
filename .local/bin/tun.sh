#!/bin/bash
DEFAULT_IF=eth0
DEFAULT_GW=172.31.20.1
RESOLV=$(cat /etc/resolv.conf)

function cleanup {
    sudo kill "$T2S_PID"
    wait "$T2S_PID"

    sudo ip route del 185.225.203.238/32
    sudo ip route del 132.243.202.141/32
    sudo ip route del 172.19.16.20/32
    sudo ip route del default dev tun0
    sudo ip link set tun0 down
    sudo ip tuntap del mode tun dev tun0
    sudo ip route replace default via 172.31.20.1 dev eth0
    echo "$RESOLV" | sudo tee /etc/resolv.conf
    echo "DONE"
}
trap cleanup EXIT

echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf

sudo ip tuntap add mode tun dev tun0
sudo ip addr add 192.18.0.1/24 dev tun0
sudo ip link set tun0 up mtu 1500
sudo ip route replace 185.225.203.238/32 via "$DEFAULT_GW" dev "$DEFAULT_IF"
sudo ip route replace 132.243.202.141/32 via "$DEFAULT_GW" dev "$DEFAULT_IF"
sudo ip route replace 172.19.16.20/32 via "$DEFAULT_GW" dev "$DEFAULT_IF"
sudo tun2socks --device tun0 --proxy "socks5://172.19.16.20:10802" --loglevel info &
# sudo tun2socks --device tun0 --proxy "socks5://localhost:10802" --loglevel info &
T2S_PID=$!

sleep 2

sudo ip route replace default dev tun0

wait "$T2S_PID"
