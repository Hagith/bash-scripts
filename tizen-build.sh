#!/bin/bash

# tizen-build - Build, sign, push, install, run or debug web application to Tizen device or emulator

ARGS=$(getopt -l 'install,run,debug,device:,profile:' -o 'i,r,d,D:,p:' -- "$@" 2> /dev/null)
eval set -- "$ARGS"

build=1
install=0
run=0
debug=0
device=""
profile="develop"

while true
do
    case "$1" in
    --install | -i)
        install=1
        ;;
    --run | -r)
        install=1
        run=1
        debug=0
        ;;
    --debug | -d)
        install=1
        debug=1
        run=0
        ;;
    --device | -D)
        device=$2
        shift;;
    --profile | -p)
        profile=$2
        shift;;
    --)
        shift
        break
        ;;
    esac
    shift
done

if [ ! -z "$device" ]; then
    device="-d ${device}"
fi

NAME=$(basename `pwd`)

if [ $build = 1 ]; then
    web-build ./ --output dist/${NAME}/
fi

pushd .
cd dist/${NAME}/

config=`cat config.xml`
appid=`expr match "$config" ".*id=\"\([a-zA-Z0-9]*\.[a-zA-Z0-9]*\)\""`

if [ $build = 1 ]; then
    rm -rf .[^.] .??** *.wgt *.tmp *signature*
    echo -ne 'y\n' | web-signing -p $profile
    echo -ne 'y\n' | web-packaging
fi

if [[ $install = 1 ]]; then
    web-uninstall ${device} -i ${appid}
    echo "Installing ${NAME}.wgt ..."
    web-install ${device} -w ${NAME}.wgt
fi
if [[ $run = 1 && ! -z "$appid" ]]; then
    web-run ${device} -i ${appid}
fi
if [[ $debug = 1 && ! -z "$appid" ]]; then
    out=$(web-debug ${device} -i ${appid})
    url=`expr match "$out" ".*DEBUG URL: \(.*\)"`
    if [ ! -z "$url" ]; then
        chromium-browser $url 2>&1
    fi
fi

popd
