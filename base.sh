#!/bin/bash

AUTH_PASSWD=""

function init_seq {
    if $(whoami) = "root";
    then
        echo "You shouldn't execute the script with the root privilege"
        echo "Exiting now..."
        exit -1
    fi

    read -p "Authentication Required(User must be in sudoers list): " -r AUTH_PASSWD
    
}

function base {
    sudo apt update && sudo apt -y upgrade 
}

function change_apt_srcs {
    sed -i.backup -r 's/(deb|security)\.debian\.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
}

function install_base_tools {
    apt install -y  vim-gtk3 \
                    tmux \
                    git \
                    openssh-server \
                    openssl-dev
                    python3-pip \
                    curl \
                    wget \
}


function deploy_bin_analy_env {
    apt install -y  binutils \
                    gcc-multilib \
                    gdb \
                    openjdk-17-jdk \
                    autotools-dev \
                    autoconf \
                    m4 \
                    cmake \
                    patchelf \
}
