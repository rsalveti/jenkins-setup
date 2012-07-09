#!/bin/bash

# install required packages

apt-get install -y --force-yes sed wget cvs subversion git bzr coreutils unzip bzip2 tar gzip cpio gawk python patch diffstat make build-essential gcc g++ desktop-file-utils chrpath autoconf automake libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev texi2html texinfo realpath

# clone repositories

git clone git://git.linaro.org/openembedded/meta-linaro.git
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
echo 'DEFAULTTUNE_qemuarmv7a = "armv7athf-neon"'		>>conf/site.conf
echo '# specify the alignment of the root file system' 	>>conf/site.conf
echo '# this is required when building for qemuarmv7a' 	>>conf/site.conf
echo 'IMAGE_ROOTFS_ALIGNMENT = "2048"' 					>>conf/site.conf
echo 'GCCVERSION = "linaro-4.7"' 						>>conf/site.conf
echo 'SDKGCCVERSION = "linaro-4.7"' 					>>conf/site.conf
echo 'INHERIT += "rm_work"' 							>>conf/site.conf
echo 'BB_GENERATE_MIRROR_TARBALLS = "True"' 			>>conf/site.conf
echo 'MACHINE = "qemuarmv7a"'							>>conf/site.conf
echo 'BB_NUMBER_THREADS = "4"'							>>conf/site.conf
echo 'PARALLEL_MAKE = "-j4"'							>>conf/site.conf

# enable source mirror

#echo 'SOURCE_MIRROR_URL = "http://snapshots.linaro.org/TO-BE-DECIDED"' >>conf/site.conf
#echo 'INHERIT += "own_mirrors"' 										>>conf/site.conf

# get rid of MACHINE setting from local.conf

sed -i -e "s/^MACHINE.*//g" conf/local.conf


# do build

bitbake linaro-image-lamp

