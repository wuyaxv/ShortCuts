#!/bin/bash

AUTH_PASSWD=""
ARSENAL="${HOME}/Arsenal"

function init_seq {
    if [ $(whoami) = "root" ]
    then
        echo "You shouldn't execute the script with the root privilege"
        echo "Exiting now..."
        exit -1
    fi

    read -s -p "Authentication Required(User must be in sudoers list): " -r AUTH_PASSWD
}

function base {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt update && sudo apt -y upgrade 
}

function change_apt_srcs {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        sed -i.backup -r 's/(deb|security)\.debian\.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
}

function install_base_tools {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt install -y  vim-gtk3 \
                    tmux \
                    git \
                    openssh-server \
                    openssl-dev
                    python3-pip \
                    curl \
                    wget 
}


function deploy_bin_analy_env {
    echo -n $AUTH_PASSWD | sudo -S -p "" \
        apt install -y  binutils \
                    gcc-multilib \
                    gdb \
                    openjdk-17-jdk \
                    autotools-dev \
                    autoconf \
                    m4 \
                    cmake \
                    patchelf \
                    jq 

    # Get gef(GDB Enhanced Features)
    bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

    # Get the latest Ghidra.
    GHIDRA_LATEST_DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest  | jq '.assets[] | .browser_download_url' | tr -d \" )

    mkdir -p ${ARSENAL} && \
        curl -fsSL -o ${ARSENAL}/ghidra_latest.zip ${GHIDRA_LATEST_DOWNLOAD_URL}  && \
        unzip ${ARSENAL}/ghidra_latest.zip && \
        rm ${ARSENAL}/ghidra_latest.zip
}

