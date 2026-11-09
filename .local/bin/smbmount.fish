#!/bin/fish

argparse 'c/credentials=' 'u/url=' -- $argv or exit 1

set data "$(pass show $_flag_credentials)"

function get_field
  echo $argv[1] | grep $argv[2] | head -n1 | sed -nre 's/.*=(.*)/\1/p'
end

echo -e "$(get_field $data user)\n$(get_field $data domain)\n$(get_field $data password)\n" \
  | gio mount "$_flag_url"
