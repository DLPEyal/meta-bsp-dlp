UBOOT_DTB_NAME = "u-boot.dtb"
do_compile[depends] += "u-boot:do_deploy"

# Force task signature change when SECURE_BOOT_ENABLE / UBOOT_SIGN_ENABLE
# toggle so do_compile re-runs even if nothing else changed.
do_compile[vardeps] += "SECURE_BOOT_ENABLE UBOOT_SIGN_ENABLE"

UBOOT_DTB_SIGNED = "u-boot-${MACHINE}.dtb"

#Create 3 dtbs
DLP_BOARD_DTBS = "imx8mp-dlp-basearm1 imx8mp-dlp-basearm2 imx8mp-dlp-decoder"
DLP_FIT_DEFAULT_CONFIG = "imx8mp-dlp-basearm1"

#This function extracts a key from signed common dtb and injects them to all 3 custom dtbs
dlp_inject_sign_key() {
    signed_dtb="$1"
    board_dtb="$2"

    tmpdir=$(mktemp -d)

    dtc -I dtb -O dts -f -o "${tmpdir}/signed.dts" "${signed_dtb}" 2>/dev/null
    dtc -I dtb -O dts -f -o "${tmpdir}/board.dts"  "${board_dtb}"  2>/dev/null

    if ! grep -q "rsa,r-squared" "${tmpdir}/signed.dts" 2>/dev/null; then
        bbnote "No RSA key material in ${signed_dtb}, skipping key injection"
        rm -rf "${tmpdir}"
        return 0
    fi

    # Extract the signature block
    awk '/^\tsignature \{/{found=1} found{print} found && /^\t};/{exit}' \
        "${tmpdir}/signed.dts" > "${tmpdir}/sig_block.txt"

    # Strip the old signature block
    awk '/^\tsignature \{/{skip=1;next} skip && /^\t};/{skip=0;next} skip{next} {print}' \
        "${tmpdir}/board.dts" > "${tmpdir}/board_nosig.dts"

    # Re-insert the signature block before the root closing brace
    last_brace=$(grep -n '^};' "${tmpdir}/board_nosig.dts" | tail -1 | cut -d: -f1)
    head -n $(expr $last_brace - 1) "${tmpdir}/board_nosig.dts" > "${tmpdir}/merged.dts"
    echo "" >> "${tmpdir}/merged.dts"
    cat "${tmpdir}/sig_block.txt" >> "${tmpdir}/merged.dts"
    echo "};" >> "${tmpdir}/merged.dts"

    dtc -I dts -O dtb -f -p 2000 -o "${board_dtb}" "${tmpdir}/merged.dts" 2>/dev/null

    bbnote "Injected signing keys into $(basename ${board_dtb})"
    rm -rf "${tmpdir}"
}

# Generate a multi-DTB u-boot.its using the stock imx-mkimage script
dlp_gen_multi_dtb_its() {
    out="$1"

    dtb_files=""
    for dt in ${DLP_BOARD_DTBS}; do
        dtb_files="${dtb_files} ${dt}.dtb"
    done

    if [ ! -x "${BOOT_STAGING}/mkimage_fit_atf.sh" ]; then
        bbfatal "Stock mkimage_fit_atf.sh not found in ${BOOT_STAGING}"
    fi

    ( cd "${BOOT_STAGING}" && \
      BL32=tee.bin \
      DEK_BLOB_LOAD_ADDR=0x40400000 \
      TEE_LOAD_ADDR=0x56000000 \
      ATF_LOAD_ADDR=0x00970000 \
      ./mkimage_fit_atf.sh ${dtb_files} > "${out}" )
}

# Copy u-boot.dtb to boot tools
# When secure boot enabled DTB contains public keys for signature verification
do_compile:prepend() {
    if [ -f "${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_NAME}" ]; then
        install -m 0644 "${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_NAME}" "${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${UBOOT_DTB_NAME}"
    fi

    # U-Boot builds with UBOOT_CONFIG="dlp" and deploys artifacts with a -dlp
    # suffix, but the base compile_mx8m() expects the layer-level UBOOT_CONFIG
    # ("fspi") suffix. copy files (ddr firmware) with the new names.
    #
    # IMPORTANT: ALWAYS overwrite the destination.
    src_cfg="dlp"
    for f in \
        "${DEPLOY_DIR_IMAGE}/u-boot-spl.bin-${MACHINE}-${src_cfg}:${DEPLOY_DIR_IMAGE}/u-boot-spl.bin-${MACHINE}-${UBOOT_CONFIG}" \
        "${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${src_cfg}:${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG}" \
        "${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.bin-${src_cfg}:${DEPLOY_DIR_IMAGE}/${UBOOT_NAME}" \
    ; do
        src="${f%%:*}"
        dst="${f##*:}"
        if [ -f "${src}" ]; then
            install -m 0644 "${src}" "${dst}"
        fi
    done
}

do_compile:append() {
    # Stage all three board DTBs into BOOT_STAGING
    signed_dtb=""
    if [ "${UBOOT_SIGN_ENABLE}" = "1" ]; then
        if [ -f "${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_SIGNED}" ]; then
            signed_dtb="${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_SIGNED}"
            bbnote "Using signed DTB for key injection: ${UBOOT_DTB_SIGNED}"
        elif [ -f "${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_NAME}" ]; then
            signed_dtb="${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_NAME}"
            bbnote "Using u-boot.dtb for key injection (UBOOT_DTB_SIGNED missing)"
        else
            bbwarn "UBOOT_SIGN_ENABLE=1 but no signed DTB found under ${DEPLOY_DIR_IMAGE}"
        fi
    else
        bbnote "UBOOT_SIGN_ENABLE != 1: skipping RSA pubkey injection into board DTBs"
    fi

    for dt in ${DLP_BOARD_DTBS}; do
        src="${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${dt}.dtb"
        if [ ! -f "${src}" ]; then
            bbfatal "Missing board DTB: ${src}"
        fi
        # install -m always overwrites; never reuse a stale keyed dtb from a
        # previous build.
        install -m 0644 "${src}" "${BOOT_STAGING}/${dt}.dtb"
        if [ -n "${signed_dtb}" ]; then
            dlp_inject_sign_key "${signed_dtb}" "${BOOT_STAGING}/${dt}.dtb"
        fi
    done

    # Generate the multi-DTB u-boot.its and assemble u-boot.itb from it.
    dlp_gen_multi_dtb_its "${BOOT_STAGING}/u-boot.its"

    ( cd "${BOOT_STAGING}" && \
      uboot-mkimage -E -p 0x3000 -f u-boot.its u-boot.itb )

    bbnote "Built multi-DTB u-boot.itb with configs: ${DLP_BOARD_DTBS}"

    # Rebuild flash.bin from our multi-DTB u-boot.itb.
    for target in ${IMXBOOT_TARGETS}; do
        if [ -f "${BOOT_STAGING}/u-boot.dtb" ]; then
            cp "${BOOT_STAGING}/u-boot.dtb" "${BOOT_STAGING}/evk.dtb"
            touch -r "${BOOT_STAGING}/u-boot.dtb" "${BOOT_STAGING}/evk.dtb"
        fi
        touch "${BOOT_STAGING}/u-boot.itb"
        rm -f "${BOOT_STAGING}/flash.bin"

        make SOC=${IMX_BOOT_SOC_TARGET} ${REV_OPTION} \
             dtbs=${UBOOT_DTB_NAME} ${target}

        if [ -e "${BOOT_STAGING}/flash.bin" ]; then
            cp "${BOOT_STAGING}/flash.bin" "${S}/${BOOT_CONFIG_MACHINE}-${target}"
            bbnote "Built multi-DTB imx-boot for target ${target}"
        fi
    done
}

do_deploy:append() {
    # Clean up per-board artifacts
    rm -f "${DEPLOYDIR}/imx-boot-basearm1" \
          "${DEPLOYDIR}/imx-boot-basearm2" \
          "${DEPLOYDIR}/imx-boot-decoder"
}
