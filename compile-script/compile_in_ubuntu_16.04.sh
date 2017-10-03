#!/usr/bin/env bash

sudo apt-get -y -f -qq install unzip devscripts autoconf automake libtool flex bison gperf gawk m4 make libssl-dev

sudo apt-get -y update
apt-get install checkinstall build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev

#sudo rm -rf virtuoso-opensource*

while getopts b:f: option
do
 case "${option}"
 in
 b) BRANCH=${OPTARG};;
 f) CHECKOUT_FOLDER=${OPTARG};;
 esac
done

if [ "${BRANCH}" == "" ]; then
       echo "No branch specified for build!"
       exit 1
else
       echo "Building branch ${BRANCH}..."
fi

if [ "${CHECKOUT_FOLDER}" == "" ]; then
        echo "No CHECKOUT FOLDER  specified for build!"
        exit 1
else
        echo "CHECKING OUT TO FOLDER ${CHECKOUT_FOLDER}..."
fi

sudo rm -rf "$CHECKOUT_FOLDER"
sudo git clone https://github.com/openlink/virtuoso-opensource.git "$CHECKOUT_FOLDER"  &&
cd "$CHECKOUT_FOLDER" &&
sudo ./autogen.sh &&
CFLAGS="-O2 -m64" &&
export CFLAGS &&
sudo ./configure && #> /dev/null 2>&1
sudo make --silent && #> /dev/null 
sudo checkinstall &&
cp *.deb "../../debs-ubuntu-16-04"
