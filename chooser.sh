#!/usr/bin/env bash
set -e

# Resources:
#   https://espterm.github.io/docs/VT100%20escape%20codes.html
#   https://github.com/wick3dr0se/bashin/blob/main/lib/std/ansi.sh
#   https://github.com/wick3dr0se/bashin/blob/main/lib/std/tui.sh
#   https://github.com/wick3dr0se/fml/blob/main/fml
#   https://invisible-island.net/xterm/ctlseqs/ctlseqs.html
#   https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
#   https://stackoverflow.com/questions/2612274/bash-shell-scripting-detect-the-enter-key

shopt -s checkwinsize; (:;:)
# printf '\e[?1000h'  # enable mouse support

usage() { printf 'Usage: %s [choices...]\n' "${0##*/}"; exit 0; }
cursor_up(){ printf '\e[A'; }
cursor_down(){ printf '\e[B'; }
cursor_save(){ printf '\e7'; }
cursor_restore(){ printf '\e8'; }
read_keys(){ read -rsn1 KEY </dev/tty; }
set_offset() { IFS='[;' read -p $'\e[6n' -d R -rs _ offset _ _ </dev/tty; }
cleanup() {
    printf '\e[%d;1H' "$offset"
    for ((i=0;i<=ROWS;i++));do printf '\e[2K'; cursor_down ;done
    printf '\e[%d;1H' "$offset"
    stty echo </dev/tty
    exec 1>&3 3>&-  # restore stdout and close fd #3
    [ -n "$sel" ] && printf '%s\n' "$sel"
}
list_choices() {
    printf '\e[%d;1H' "$offset"  # go back to the start position
    printf ' %-80s\n' "${choices[@]:pos:$ROWS}"
    printf '\e[%d;1H' "$cursor"  # go back to the cursor position
}

[ -z "$1" ] && usage

declare -a choices=()
if [ "$1" = - ];then
    while read -r i;do choices+=("$i") ;done
else 
    choices=("$@")
fi

exec 3>&1  # send stdout to fd 3
exec >&2   # send stdout to stderr
stty -echo </dev/tty
pos=0
total_choices=${#choices[@]}
((ROWS = (LINES / 2) + 1))
set_offset
if (( (offset + ROWS) > LINES )) && (( total_choices >= ROWS ));then # TODO: don't do this
    # if there is not enough rows clear the screen and reset the offset
    printf '\e[2J\e[1;1H';
    set_offset
fi
cursor=$offset

(( (total_choices - pos) >= ROWS )) && printf '\e[%d;1H▼' "$((ROWS + offset))"
trap cleanup EXIT
while :;do
    actual_pos=$((cursor - offset + pos))
    list_choices
    read_keys
    case "${KEY}" in
        k)
            if (( cursor == offset )) && (( pos > 0 ));then
                ((pos-=1))
            elif (( cursor > offset ));then
                ((cursor-=1))
                cursor_up
            fi
            ;;
        j)
            (( actual_pos == (total_choices - 1) )) && continue # TODO: fix this, unecessary logic?
            if (( cursor == (ROWS + offset - 1) )) && (( (total_choices - pos) != ROWS ))
            then
                ((pos+=1))
            elif (( cursor < (ROWS + offset - 1) ))
            then
                ((cursor+=1))
                cursor_down
            fi
            ;;
        "") # TODO: fix this, pressing ctrl+j and some other keys triggers this case 
            sel=${choices[actual_pos]} ; exit 0 ;;
    esac
done
