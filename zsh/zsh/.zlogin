if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && command -v startx; then
  exec startx
fi

