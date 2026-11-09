#!/bin/fish

set EMAIL $(read -z)

echo $EMAIL

set RECIPIENTS "$argv"

echo "$EMAIL" | /usr/bin/mutt -s "" -- $RECIPIENTS