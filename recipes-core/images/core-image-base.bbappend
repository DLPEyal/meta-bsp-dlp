IMAGE_INSTALL:append = " systemd-ethtool"

ROOTFS_POSTPROCESS_COMMAND:append = " enable_ethtool_service; write_build_info; remove_boot_image; "

enable_ethtool_service() {
    ln -sf /lib/systemd/system/ethtool.service ${IMAGE_ROOTFS}/etc/systemd/system/multi-user.target.wants/ethtool.service
}

write_build_info() {
    install -d ${IMAGE_ROOTFS}/etc
    echo "BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')" \
        >> ${IMAGE_ROOTFS}/etc/build-info
}

remove_boot_image() {
	rm -rf ${IMAGE_ROOTFS}/boot
}
