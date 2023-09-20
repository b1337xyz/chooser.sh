#!/usr/bin/env bash
# shellcheck disable=SC2162
#   read without -r will mangle backslashes. [SC2162]

usage() { printf 'Usage: %s [choices...]\n' "${0##*/}"; exit 0; }
cursor_up(){ printf '\e[A'; }
cursor_down(){ printf '\e[B'; }
goto_row() { printf '\e[%d;1H' "$1"; }
set_offset() { IFS='[;' read -p $'\e[6n' -d R -rs _ offset _ _ </dev/tty; }

init_term() {
    shopt -s checkwinsize; (:;:)
    # printf '\e[?1000h'  # enable mouse support
    exec 3>&1  # send stdout to fd 3
    exec >&2   # send stdout to stderr
    stty -echo </dev/tty
}

cleanup() {
    goto_row "$offset"
    for ((i=0;i<=ROWS;i++));do printf '\e[2K'; cursor_down ;done
    goto_row "$offset"

    stty echo </dev/tty
    exec 1>&3 3>&-  # restore stdout and close fd #3
    [ -n "$sel" ] && printf '%s\n' "$sel"
}

read_keys(){
    read -sN1 KEY </dev/tty
    case "$KEY" in
        [a-z]|'') return ;;
    esac
    read -sN2 -t 0.0001 </dev/tty
    KEY=$KEY$REPLY
}

list_choices() {
    goto_row "$offset"  # go back to the start position
    printf ' %-'${COLUMNS}'s\n' "${choices[@]:pos:$ROWS}" | cut -c -$((COLUMNS - 2)) # trim
    goto_row "$cursor"  # go back to the cursor position
}

move_up() {
    if (( cursor == offset )) && (( pos > 0 ));then
        ((pos--))  # if doing this, do not use `set -e`
    elif (( cursor > offset ));then
        ((cursor--))
        cursor_up
    fi
}

move_down() {
    (( actual_pos == (total_choices - 1) )) && return
    if (( cursor == (ROWS + offset - 1) )) && (( (total_choices - pos) != ROWS )); then
        ((pos++))
    elif (( cursor < (ROWS + offset - 1) )); then
        ((cursor++))
        cursor_down
    fi
}

[ -z "$1" ] && usage

declare -a choices=()
if [ "$1" = - ];then
    while read -r i; do choices+=("$i"); done
else 
    choices=("$@")
fi

init_term
trap cleanup EXIT

pos=0
prev=1
total_choices=${#choices[@]}
((ROWS = (LINES / 2) + 1))
set_offset
if (( (offset + ROWS) > LINES )) && (( total_choices >= ROWS ));then # TODO: improve this
    if (( offset == LINES ));then
        goto_row "$((offset - ROWS))"  # if added 1 this will break the script
    else
        goto_row "$((offset - ROWS + 1))"
    fi
    set_offset
fi
cursor=$offset

(( total_choices > ROWS )) && { goto_row "$((ROWS + offset))"; printf ▼; }
while :;do
    ((actual_pos = cursor - offset + pos))
    (( pos != prev )) && { prev=$pos; list_choices; }
    read_keys
    case "$KEY" in
        k|$'\E[A') move_up ;;
        j|$'\E[B') move_down ;;
        $'\E') exit ;; # Esc
        $'\n') sel=${choices[actual_pos]} ; exit ;;
    esac
done
