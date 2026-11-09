#!/bin/fish

set COOKIES "/tmp/cookies.txt"

curl -c $COOKIES -L -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
     https://archive.org/account/login > /dev/null

curl -c $COOKIES -b $COOKIES -L \
     -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
     -e "https://archive.org/account/login" \
     -d "username=g.cherdakly@int-sys.ru&password=comfortablynumb1" \
     https://archive.org/account/login

aria2c --load-cookies=$COOKIES \
       --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
       -x16 -s16 \
       "$argv[1]"