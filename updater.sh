#!/bin/bash

gup_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
gw_dir="$(dirname "$gup_dir")"
home_dir="$HOME"
pyenvs_dir=.pyenv

source $gup_dir/logger.sh

task_file=gupfile

reboot_flag=0

echo "*********** starting gateway-updater 0.10.1 ***********" | log

for dir in $(cd $gw_dir && ls -d */); do
    path=$gw_dir/${dir%/}
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
        if ! [ -z "$path/$task_file" ]; then
            while IFS="," read -r pkg new_ver; do
                cur_ver=$($home_dir/$pyenvs_dir/${dir%/}/bin/python -m pip show $pkg | grep Version)
                if ! [[ $cur_ver = *"$new_ver"* ]]; then
                    echo "(${dir%/}) '$pkg' -> $new_ver" | log
                    if [[ $pkg = *"sepl-connector-client"* ]]; then
                        inst_result=$($home_dir/$pyenvs_dir/${dir%/}/bin/python -m pip install --upgrade git+ssh://git@gitlab.wifa.uni-leipzig.de/fg-seits/connector-client.git@v$new_ver)
                    else
                        inst_result=$($home_dir/$pyenvs_dir/${dir%/}/bin/python -m pip install --upgrade $pkg==$new_ver)
                    fi
                    if [[ $inst_result = *"Success"* ]]; then
                        echo "(${dir%/}) '$pkg' update success" | log
                        reboot_flag=1
                    else
                        echo "(${dir%/}) '$pkg' $inst_result" | log
                    fi
                fi
            done < $path/$task_file
        fi
    fi
done
if [ "$reboot_flag" -eq "1" ]; then
    echo "gateways updated - reboot required" | log
    echo "rebooting in 15s ..." | log
    sleep 15
    sudo reboot
else
    echo "all gateways up to date - exit" | log
    exit 0
fi