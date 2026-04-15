#! /bin/bash

# Determine default src_directory relative to this script:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../../../" && pwd)"   #base dir of the project
src_PATH="${BASE_DIR}/build/tmp/deploy/images/dlp"
src_PATH_sources="${BASE_DIR}/sources/meta-bsp-dlp"

dst_PATH="${BASE_DIR}/Package"

# Create directory
mkdir -p "${dst_PATH}"
mkdir -p "${dst_PATH}/tar"


cp -L $src_PATH/fitImage-core-image-minimal-dlp-dlp $dst_PATH/fitImage-core-image-minimal-dlp-dlp
cp -L $src_PATH/imx-boot $dst_PATH/OTP.bin
cp -L $src_PATH_sources/DLP.txt  $dst_PATH/DLP.txt
cd $dst_PATH
cd tar
tar -czf test_version.tar.gz -C $dst_PATH .



