#!/bin/fish

set in (mktemp)
set out (mktemp)
cat > $in

foot --app-id=select fish -c "fzf --style=minimal --prompt='Share > ' < $in > $out"
set rc $status

cat $out
rm -f $in $out
exit $rc
