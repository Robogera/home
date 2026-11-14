#!/usr/bin/env fish

argparse -x 'a,d' \
    'a/add' \
    'd/del' \
    'i/dev=' \
    -- $argv
or exit 1

set -ql _flag_dev; or set -l _flag_dev tun0

if set -ql _flag_add
    echo "add route via $_flag_dev"
    sudo ip route replace 0.0.0.0/0 dev $_flag_dev
else if set -ql _flag_del
    echo "del route via $_flag_dev"
    sudo ip route del 0.0.0.0/0 dev $_flag_dev
end
