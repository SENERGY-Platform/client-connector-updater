#!/bin/bash

arg=$1

gup_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $gup_dir/logger.sh

duration=$(( ( RANDOM % 120 )  + 10 ))

if ! [ -z "$arg" ]; then
    if [[ $arg = "now" ]]; then
        duration=0
    else
        echo "unknown argument '$arg'"
        exit 1
    fi
fi

sleep $duration

wget -q --tries=3 --timeout=20 --spider https://www.google.com/  > /dev/null
if [[ $? -eq 0 ]]; then
    update_result=$(cd $gup_dir && git remote update 3>&1 1>&2 2>&3 >/dev/null)
    if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
        status_result=$(cd $gup_dir && git status)
        if [[ $status_result = *"behind"* ]]; then
            echo "------------------------------------------------------" | log
            echo "(gateway-updater) downloading and applying updates ..." | log
            pull_result=$(cd $gup_dir && git pull 3>&1 1>&2 2>&3 >/dev/null)
            if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                echo "(gateway-updater) update success" | log
            else
               echo "(gateway-updater) $pull_result - exit" | log
               exit 1
            fi
        fi
    else
        echo "(gateway-updater) $update_result - exit" | log
        exit 1
    fi
else
    echo "no internet access - exit" | log
    exit 1
fi
sleep 5
bash $gup_dir/updater.sh &
exit 0