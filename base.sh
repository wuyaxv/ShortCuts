#!/bin/bash

AUTH_PASSWD=""
ARSENAL="${HOME}/Arsenal"

TIMESTAMP="date +%Y-%m-%d_%H:%M:%S.%N"
IFS_STORED=$IFS

#  Verbose.
DEBUG=true
ERROR=true

VERBOSE_DEBUG=/tmp/debug_$(${TIMESTAMP})
VERBOSE_ERROR=/tmp/error_$(${TIMESTAMP})
VERBOSE_INFO=/tmp/info_$(${TIMESTAMP})

# 设置verbose标准输出用于排查
if [ -e ${VERBOSE_DEBUG} ]
then
    rm ${VERBOSE_DEBUG}
fi

mkfifo ${VERBOSE_DEBUG}
exec 6<> ${VERBOSE_DEBUG}
rm -f ${VERBOSE_DEBUG}

function verbose_debug {
    if $DEBUG
    then
        while read line <&6
        do
            echo -e "\033[1;34m[-]\033[0m $line"
        done
    fi
}

# 设置verbose标准错误输出用于分析错误原因
if [ -e ${VERBOSE_ERROR} ]
then
    rm ${VERBOSE_ERROR}
fi

mkfifo ${VERBOSE_ERROR}
exec 7<> ${VERBOSE_ERROR}
rm -f ${VERBOSE_ERROR}

function verbose_error {
    if $ERROR
    then
        while read line <&7
        do
            echo -e "\033[1;31m[!]\033[0m $line"
        done
    fi
}

if [ -e ${VERBOSE_INFO} ]
then
    rm ${VERBOSE_INFO}
fi

mkfifo ${VERBOSE_INFO}
exec 8<> ${VERBOSE_INFO}
rm -f ${VERBOSE_INFO}

function verbose_info {
    if $ERROR
    then
        while read line <&8
        do
            echo -e "\033[1;32m[*]\033[0m $line"
        done
    fi
}

verbose_debug &
verbose_error &
verbose_info &

function error {
    # echo -e "\033[1;31m[!]\033[0m $*"
    echo -e "$*" >&2
}

function info {
    # echo -e "\033[1;32m[*]\033[0m $*"
    echo -e "$*" >&8
}

function init_seq {
    if [ $(whoami) = "root" ]
    then
        echo "You shouldn't execute the script with the root privilege"
        echo "Exiting now..."
        exit -1
    fi

    read -s -p "Authentication Required(User must be in sudoers list): " -r AUTH_PASSWD
}

function change_apt_srcs {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        sed -i.backup -r 's/(deb|security)\.debian\.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
}

function base {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt update && sudo apt -y upgrade 
}

function deploy_network_infra {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt install -y
            openvpn \
            network-manager-openvpn \
            network-manager-openvpn-gnome \
            wireguard \
            wireguard-dkms \
            gpg
}

function install_base_tools {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt install -y  \
            vim-gtk3 \
            tmux \
            git \
            openssh-server \
            libssl-dev \
            python3-pip \
            curl \
            wget 
}

function deploy_bin_analy_env {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt install -y  \
                    binutils \
                    gcc-multilib \
                    gdb \
                    openjdk-17-jdk \
                    autotools-dev \
                    autoconf \
                    m4 \
                    cmake \
                    patchelf \
                    python3-pip \
                    jq 

    # Get gef(GDB Enhanced Features)
    bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

    # Get the latest Ghidra.
    GHIDRA_LATEST_DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest  | jq '.assets[] | .browser_download_url' | tr -d \" )
    GHIDRA_DIR=$(curl -sL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest  | jq '.assets[] | .name' | tr -d \"  | sed -r 's/(.*)[0-9]{8}\.zip/\1/g')

    echo -n Ghidra download url ${GHIDRA_LATEST_DOWNLOAD_URL} >&2
    echo -n Ghidra extract directory url ${GHIDRA_DIR} >&2

    mkdir -p ${ARSENAL} && \
        curl -fSL -# -o ${ARSENAL}/ghidra_latest.zip ${GHIDRA_LATEST_DOWNLOAD_URL}  && \
        unzip ${ARSENAL}/ghidra_latest.zip -d ${ARSENAL} && \
        rm ${ARSENAL}/ghidra_latest.zip

    # adding ghidra to /usr/local/bin/ghidra
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        ln -s ${ARSENAL}/${GHIDRA_DIR}/ghidraRun /usr/local/bin/ghidra

}

#( init_seq && change_apt_srcs && base && deploy_bin_analy_env ) >&6

