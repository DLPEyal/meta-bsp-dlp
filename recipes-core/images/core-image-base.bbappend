IMAGE_INSTALL:append = " systemd-ethtool"

ROOTFS_POSTPROCESS_COMMAND:append = " enable_ethtool_service; "

enable_ethtool_service() {
    ln -sf /lib/systemd/system/ethtool.service ${IMAGE_ROOTFS}/etc/systemd/system/multi-user.target.wants/ethtool.service
}
