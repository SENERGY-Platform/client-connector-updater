#!/bin/bash

task_file=gupfile

log() {
    first=1
    while read -r line; do
        if [ "$first" -eq "1" ]; then
            echo "[$(date +"%Y.%m.%d - %H:%M:%S")] $line" >> gup.log 2>&1
            first=0
        else
            echo "$line" >> gup.log 2>&1
        fi
    done
}

echo "************* starting auto update *************" | log
echo "scanning for gateways ..." | log

for dir in $(cd .. && ls -d */); do
    path=$(dirname "$(pwd)")/${dir%/}
    if [ -e "$path/$task_file" ]; then
        echo "(${dir%/}) checking for updates ..." | log
        update_result=$(cd "$path" && git remote update 3>&1 1>&2 2>&3 >/dev/null)
        if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
            status_result=$(cd "$path" && git status)
            if [[ $status_result = *"behind"* ]]; then
                echo "(${dir%/}) updates found!" | log
                echo "(${dir%/}) downloading updates ..." | log
                pull_result=$(cd "$path" && git pull 3>&1 1>&2 2>&3 >/dev/null)
                if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                    echo "(${dir%/}) applying updates ..." | log
                    commit_result=$(cd "$path" && git commit -a -m "update" 3>&1 1>&2 2>&3 >/dev/null)
                    if ! [[ $commit_result = *"fatal"* ]] || ! [[ $commit_result = *"error"* ]]; then
                        echo "(${dir%/}) checking dependencies ..." | log
                        if ! [ -z "$path/$task_file" ]; then
                            for dep in $(cat "$path/$task_file"); do
                                echo "$dep"
                            done
                        fi
                    else
                        echo "(${dir%/}) $commit_result" | log
                    fi
                else
                   echo "(${dir%/}) $pull_result" | log
                fi

                #echo "rebooting in 30s ..." | log
                #sleep 30
                #sudo reboot
            else
                echo "(${dir%/}) up to date" | log
            fi
        else
            echo "(${dir%/}) $update_result" | log
        fi
    fi
done
echo "auto update done!" | log