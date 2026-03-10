#! /bin/bash

# Determine default src_directory relative to this script:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../../../" && pwd)"   #base dir of the project
src_PATH="${BASE_DIR}/build/tmp/deploy/images/dlp"
src_PATH_sources="${BASE_DIR}/sources/meta-bsp-dlp"

dst_PATH="${BASE_DIR}/Package"

#src_PATH="/media/superuser/GlobalStorage/Projects/3043-50/users/oleg_s/dlp_next_update/build/tmp/deploy/images/dlp"
#src_PATH_sources="/media/superuser/GlobalStorage/Projects/3043-50/users/oleg_s/dlp_next_update/sources/meta-bsp-dlp"

# Create directory
mkdir -p "${dst_PATH}"
mkdir -p "${dst_PATH}/tar"

#cp -L $src_PATH/Image $dst_PATH/Image
#cp -L $src_PATH/decoder.dtb $dst_PATH/decoder.dtb
#cp -L $src_PATH/basearm1.dtb $dst_PATH/basearm1.dtb
#cp -L $src_PATH/basearm2.dtb $dst_PATH/basearm2.dtb
#cp -L $src_PATH/core-image-base-dlp.cpio.gz $dst_PATH/core-image-base-dlp.cpio.gz
#cp -L $src_PATH/core-image-minimal-dlp.cpio.gz $dst_PATH/core-image-minimal-dlp.cpio.gz
cp -L $src_PATH/fitImage-core-image-minimal-dlp-dlp $dst_PATH/fitImage-core-image-minimal-dlp-dlp
cp -L $src_PATH/imx-boot $dst_PATH/OTP.bin
cp -L $src_PATH_sources/DLP.txt  $dst_PATH/DLP.txt
cd $dst_PATH
cd tar
tar -czf test_version.tar.gz -C $dst_PATH .



