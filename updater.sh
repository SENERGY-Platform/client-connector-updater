#!/bin/bash

task_file=gupfile

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

reboot_flag=0

echo "*********** starting gateway-updater 0.8.1 ***********" | log

for dir in $(cd .. && ls -d */); do
    path=$(dirname "$(pwd)")/${dir%/}
    if [ -e "$path/$task_file" ]; then
        echo "(${dir%/}) checking for updates ..." | log
        update_result=$(cd "$path" && git remote update 3>&1 1>&2 2>&3 >/dev/null)
        if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
            status_result=$(cd "$path" && git status)
            if [[ $status_result = *"behind"* ]]; then
                echo "(${dir%/}) downloading and applying updates ..." | log
                pull_result=$(cd "$path" && git pull 3>&1 1>&2 2>&3 >/dev/null)
                if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                    echo "(${dir%/}) update success" | log
                    reboot_flag=1
                else
                   echo "(${dir%/}) $pull_result" | log
                fi
            fi
        else
            echo "(${dir%/}) $update_result" | log
        fi
        echo "(${dir%/}) checking dependencies ..." | log
        pip_upgrade=$(~/.pyenv/versions/${dir%/}/bin/python -m pip install --upgrade pip)
        if [[ $pip_upgrade = *"Success"* ]]; then
            echo "(${dir%/}) 'pip' update success" | log
        fi
        if ! [ -z "$path/$task_file" ]; then
            while IFS="," read -r pkg new_ver; do
                cur_ver=$(~/.pyenv/versions/${dir%/}/bin/python -m pip show $pkg | grep Version)
                if ! [[ $cur_ver = *"$new_ver"* ]]; then
                    echo "(${dir%/}) '$pkg' -> $new_ver" | log
                    if [[ $pkg = *"sepl-connector-client"* ]]; then
                        rm_result=$(~/.pyenv/versions/${dir%/}/bin/python -m pip uninstall -y $pkg)
                        inst_result=$(~/.pyenv/versions/${dir%/}/bin/python -m pip install git+ssh://git@gitlab.wifa.uni-leipzig.de/fg-seits/connector-client.git)
                    else
                        inst_result=$(~/.pyenv/versions/${dir%/}/bin/python -m pip install --upgrade $pkg==$new_ver)
                    fi
                    if [[ $inst_result = *"Success"* ]]; then
                        echo "(${dir%/}) '$pkg' update success" | log
                        reboot_flag=1
                    else
                        echo "(${dir%/}) $inst_result" | log
                    fi
                fi
            done < $path/$task_file
        fi
    fi
done
if [ "$reboot_flag" -eq "1" ]; then
    echo "gateways updated - reboot required" | log
    echo "rebooting in 30s ..." | log
    #sleep 30
    #sudo reboot
else
    echo "all gateways up to date - exit" | log
    exit 0
fi