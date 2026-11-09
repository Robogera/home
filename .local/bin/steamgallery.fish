#!/bin/fish

swayimg --from-file (find $HOME/.isolate/steam/.local/share/Steam/userdata/ -name "screenshots" -type d | psub)
