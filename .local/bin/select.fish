#!/bin/fish

mmsg get all-clients \
  | jq --raw-output0 '
    .clients[]
    | select(.appid != "launcher")
    | "\(.id)\t\(.appid):\n  \(.title)"' \
  | fzf --read0 --print0 --style=minimal --delimiter=\t --with-nth=2.. \
  | read -z id title

if string match -qr '[^0]' $pipestatus
    exit 1
end

mmsg dispatch focusid client,$id
