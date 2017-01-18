#!/bin/bash

VIRTUOSO_VERSION=7.2.4.2
VIRTUOSO_SOURCE=https://github.com/openlink/virtuoso-opensource/releases/download/v$VIRTUOSO_VERSION/virtuoso-opensource-$VIRTUOSO_VERSION.tar.gz

BUILD_DIR=/tmp/build
VIRTUOSO_DEB_PKG_DIR=/virtuoso_deb
BUILD_ARGS=""

export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LANGUAGE="en_US"

# remember installed packages for later cleanup
    dpkg --get-selections > /inst_packages.dpkg

    # install build essentials
    apt-get update && apt-get install -y \
        build-essential \
        devscripts \
        wget &&

    # download and extract virtuoso source
    mkdir -p "$BUILD_DIR" 
    cd "$BUILD_DIR" &&
    echo -n "downloading..." &&
    wget "$VIRTUOSO_SOURCE" &&
    echo " done." &&
    echo -n "extracting..." &&
    tar -xaf virtuoso*.tar* &&
    echo -n "1" &&
    rm virtuoso*.tar* &&
    echo " done." || (printf "1" && exit 1)

    # build debian packages for virtuoso
    cd "$BUILD_DIR"/virtuoso-opensource*/ &&
    mk-build-deps -irt'apt-get --no-install-recommends -yV' &&
    dpkg-checkbuilddeps &&
    ln -s /usr/bin/aclocal /usr/bin/automake-1.14 &&
    ln -s /usr/bin/aclocal /usr/bin/aclocal-1.14 &&
    autoreconf -vfi &&
    dpkg-buildpackage -us -uc $BUILD_ARGS || (printf "buildpackage" && exit 1)
	
exit 1

    # additionally build dbpedia vad file
    ./configure --with-layout=debian --enable-dbpedia-vad &&
    cd binsrc &&
    make $BUILD_ARGS &&
    cp dbpedia/dbpedia_dav.vad ../../ || (printf "dbpedia" && exit 1)

    # make virtuoso packages available for apt
    cd "$BUILD_DIR" &&
    rm -r virtuoso-opensource*/ &&
    (dpkg-scanpackages ./ | gzip > Packages.gz) &&
    echo "deb file:$BUILD_DIR ./" >> /etc/apt/sources.list.d/virtuoso.list || (printf "make virtuoso packages available for apt" && exit 1)

     # cleanup packages and caches for  building virtuoso (reduce container size)
    dpkg --clear-selections &&
    dpkg --set-selections < /inst_packages.dpkg &&
    rm /inst_packages.dpkg &&
    rm -rf /var/lib/apt/lists/* &&
    apt-get -y dselect-upgrade || (printf "error cleanup packages and caches for  building virtuoso (reduce container size)" && exit 1)

    # install virtuoso with runtime dependencies via apt and
    # move dbpedia vad file into shared location
    apt-get update && apt-get install -y --force-yes &&
        virtuoso-server &&
        virtuoso-vad-bpel &&
        virtuoso-vad-conductor &&
        virtuoso-vad-demo &&
        virtuoso-vad-doc &&
        virtuoso-vad-isparql &&
        virtuoso-vad-ods &&
        virtuoso-vad-rdfmappers &&
        virtuoso-vad-sparqldemo &&
        virtuoso-vad-syncml &&
        virtuoso-vad-tutorial &&
    mv $BUILD_DIR/dbpedia_dav.vad /usr/share/virtuoso-opensource-7/vad/ || (printf "Error installing virtuoso packages" && exit 1)

    # remove virtuoso packages and apt cache (small container size)
    rm -rf $BUILD_DIR &&
    rm /etc/apt/sources.list.d/virtuoso.list &&
    rm -rf /var/lib/apt/lists/* ||( printf "Error cleaning cache" && exit 1)

    # allow virtuoso to access the /import DIR in container
    sed -i '/^DirsAllowed&&s*=/ s_&&s*$_, /import_' /etc/virtuoso-opensource-7/virtuoso.ini || (printf "Unable to allow access" && exit 1)

    # init db folder
    /etc/init.d/virtuoso-opensource-7 start &&
    /etc/init.d/virtuoso-opensource-7 stop || (printf "Unable to stop virtuoso" && exit 1)

    # back init state up to init empty mounted DB volume in start.sh
    cp -a /var/lib/virtuoso-opensource-7 /var/lib/virtuoso-opensource-7.orig || (printf "Unable to back init state" && exit 1)

