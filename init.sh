#!/bin/bash

# install required packages

sudo apt-get install -y --force-yes sed wget cvs subversion git bzr coreutils unzip bzip2 tar gzip cpio gawk python patch diffstat make build-essential gcc g++ desktop-file-utils chrpath autoconf automake libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texi2html texinfo realpath

# clone repositories

#git clone git://git.linaro.org/openembedded/meta-linaro.git
git clone git://github.com/rsalveti/meta-linaro.git
git clone git://git.openembedded.org/meta-openembedded

# ugly hack
rm meta-openembedded/meta-oe/recipes-extended/lighttpd -rf

git clone git://git.openembedded.org/openembedded-core
cd openembedded-core/
git clone git://git.openembedded.org/bitbake

# let's start build
. oe-init-build-env ../build

# add required layers

echo "BBLAYERS = '`realpath $PWD/../meta-openembedded/meta-oe`'" >>conf/bblayers.conf 
echo "BBLAYERS += '`realpath $PWD/../meta-openembedded/toolchain-layer`'" >>conf/bblayers.conf 
echo "BBLAYERS += '`realpath $PWD/../meta-linaro`'" >>conf/bblayers.conf
echo "BBLAYERS += '`realpath $PWD/../openembedded-core/meta`'" >>conf/bblayers.conf 

# Add some Linaro related options

echo 'SCONF_VERSION = "1"'					 			>>conf/site.conf
echo 'DEFAULTTUNE_genericarmv7a = "armv7athf-neon"'		>>conf/site.conf
echo '# specify the alignment of the root file system' 	>>conf/site.conf
echo '# this is required when building for qemuarmv7a' 	>>conf/site.conf
echo 'IMAGE_ROOTFS_ALIGNMENT = "2048"' 					>>conf/site.conf
echo 'GCCVERSION = "linaro-4.7"' 						>>conf/site.conf
echo 'SDKGCCVERSION = "linaro-4.7"' 					>>conf/site.conf
echo 'INHERIT += "rm_work"' 							>>conf/site.conf
echo 'BB_GENERATE_MIRROR_TARBALLS = "True"' 			>>conf/site.conf
echo 'MACHINE = "genericarmv7a"'						>>conf/site.conf
echo 'BB_NUMBER_THREADS = "8"'							>>conf/site.conf
echo 'PARALLEL_MAKE = "-j8"'							>>conf/site.conf
echo 'IMAGE_FSTYPES = "tar.gz"'						>>conf/site.conf

# enable source mirror

echo 'SOURCE_MIRROR_URL = "http://snapshots.linaro.org/openembedded/sources/"' >>conf/site.conf
echo 'INHERIT += "own-mirrors"' 								>>conf/site.conf

# enable sstate mirror

echo 'SSTATE_MIRRORS = "file://.* http://snapshots.linaro.org/openembedded/sstate-cache/"' >>conf/site.conf

# enable a distro feature that is compatible with the minimal goal we have

echo 'DISTRO_FEATURES = "alsa argp ext2 largefile usbgadget usbhost xattr nfs zeroconf ${DISTRO_FEATURES_LIBC}"' >>conf/site.conf

# get rid of MACHINE setting from local.conf

sed -i -e "s/^MACHINE.*//g" conf/local.conf

prepare_for_publish () {
    # some stuff to be run after build
    pushd downloads
    rm *.done
    rm -rf git2 svn cvs bzr # we publish files not SCM dirs
    popd

    pushd sstate-cache/
    rm `find . -type l`
    rm *.done
    mv */* .
    mv */*/* .
    rm -rf ?? Ubuntu-*
    popd
}
