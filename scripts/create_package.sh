#!/bin/bash
# Package the DLP release artifacts for factory flashing.
#
# With the multi-DTB U-Boot refactor there is a SINGLE imx-boot that works on
# all three DLP board variants (Base ARM#1, Base ARM#2, Decoder).  SPL picks
# the correct DTB at runtime via read_boot_gpios() -> board_fit_config_name_match().
#
# Factory flow:
#   sudo uuu -b qspi imx-boot               # flashes the universal bootloader
# then flash the fitImage using DLP.txt.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../../../" && pwd)"
src_PATH="${BASE_DIR}/build/tmp/deploy/images/dlp"
src_PATH_sources="${BASE_DIR}/sources/meta-bsp-dlp"
dst_PATH="${BASE_DIR}/Package"

mkdir -p "${dst_PATH}"
mkdir -p "${dst_PATH}/tar"

cp -L "${src_PATH}/fitImage-core-image-minimal-dlp-dlp" "${dst_PATH}/fitImage-core-image-minimal-dlp-dlp"
cp -L "${src_PATH}/imx-boot"                            "${dst_PATH}/OTP.bin"
cp -L "${src_PATH_sources}/DLP.txt"                     "${dst_PATH}/DLP.txt"

cd "${dst_PATH}/tar"
tar -czf test_version.tar.gz -C "${dst_PATH}" .
