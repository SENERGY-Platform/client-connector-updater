#!/bin/bash

log() {
    first=1
    while read -r line; do
        if [ "$first" -eq "1" ]; then
            echo "[$(date +"%m.%d.%Y %I:%M:%S %p")] $line" >> gup.log 2>&1
            first=0
        else
            echo "$line" >> gup.log 2>&1
        fi
    done
}

wget -q --tries=3 --timeout=20 --spider https://www.google.com/  > /dev/null
if [[ $? -eq 0 ]]; then
    update_result=$(git remote update 3>&1 1>&2 2>&3 >/dev/null)
    if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
        status_result=$(&& git status)
        if [[ $status_result = *"behind"* ]]; then
            echo "(gateway-updater) downloading and applying updates ..." | log
            pull_result=$(git pull 3>&1 1>&2 2>&3 >/dev/null)
            if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                echo "(gateway-updater) update success" | log
                sleep 5
                ./updater.sh &
                exit 0
            else
               echo "(gateway-updater) $pull_result" | log
            fi
        fi
    else
        echo "(gateway-updater) $update_result" | log
    fi
else
    echo "no internet access - can't update" | log
    exit 1
fi