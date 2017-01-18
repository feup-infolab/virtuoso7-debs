#!/bin/sh

sudo apt-get -y -f -qq install unzip devscripts autoconf automake libtool flex bison gperf gawk m4 make libssl-dev

sudo apt-get -y update
apt-get install checkinstall build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev

sudo rm -rf virtuoso-opensource

sudo git clone https://github.com/openlink/virtuoso-opensource.git virtuoso-opensource &&
cd virtuoso-opensource &&
sudo git branch remotes/origin/develop/7 &&
sudo ./autogen.sh &&
CFLAGS="-O2 -m64" &&
export CFLAGS &&
sudo ./configure && #> /dev/null 2>&1
sudo make --silent && #> /dev/null 
sudo checkinstall
