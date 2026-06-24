#!/usr/bin/env bash
set -ex

START_COMMAND="zed"
PGREP="zed"
DEFAULT_ARGS="--foreground"
ARGS="${DEFAULT_ARGS} ${APP_ARGS:-}"

options=$(getopt -o gau: -l go,assign,url: -n "$0" -- "$@") || exit
eval set -- "$options"

while [[ $1 != -- ]]; do
    case $1 in
        -g|--go) GO='true'; shift 1;;
        -a|--assign) ASSIGN='true'; shift 1;;
        -u|--url) OPT_URL=$2; shift 2;;
        *) echo "bad option: $1" >&2; exit 1;;
    esac
done
shift

for arg; do
    echo "arg! $arg"
done

FORCE=$2

zed_target() {
    if [ -n "$OPT_URL" ]; then
        echo "$OPT_URL"
    elif [ -n "$1" ]; then
        echo "$1"
    else
        mkdir -p "${ZED_WORKSPACE:-$HOME/workspace}"
        echo "${ZED_WORKSPACE:-$HOME/workspace}"
    fi
}

kasm_exec() {
    TARGET=$(zed_target "$1")
    /usr/bin/filter_ready
    /usr/bin/desktop_ready
    $START_COMMAND $ARGS "$TARGET"
}

kasm_startup() {
    if [ -n "$KASM_URL" ]; then
        URL=$KASM_URL
    elif [ -z "$URL" ]; then
        URL=$LAUNCH_URL
    fi

    if [ -z "$DISABLE_CUSTOM_STARTUP" ] || [ -n "$FORCE" ]; then
        echo "Entering process startup loop"
        set +x
        while true
        do
            if ! pgrep -x "$PGREP" > /dev/null
            then
                TARGET=$(zed_target "$URL")
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                set +e
                $START_COMMAND $ARGS "$TARGET"
                set -e
            fi
            sleep 1
        done
        set -x
    fi
}

if [ -n "$GO" ] || [ -n "$ASSIGN" ]; then
    kasm_exec "$URL"
else
    kasm_startup
fi
