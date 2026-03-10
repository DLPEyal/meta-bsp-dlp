IMAGE_INSTALL:append = " systemd-ethtool kernel-modules firmware-imx-sdma-imx7d"

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

# Generate SSH host keys during image build
ROOTFS_POSTPROCESS_COMMAND += "generate_ssh_keys; "
generate_ssh_keys() {
    # Create SSH directory if it doesn't exist
    install -d ${IMAGE_ROOTFS}/etc/ssh

    # Use the host system's ssh-keygen
    /usr/bin/ssh-keygen -t rsa -f ${IMAGE_ROOTFS}/etc/ssh/ssh_host_rsa_key -N "" -q
    /usr/bin/ssh-keygen -t ecdsa -f ${IMAGE_ROOTFS}/etc/ssh/ssh_host_ecdsa_key -N "" -q  
    /usr/bin/ssh-keygen -t ed25519 -f ${IMAGE_ROOTFS}/etc/ssh/ssh_host_ed25519_key -N "" -q

    # Set correct permissions
    chmod 600 ${IMAGE_ROOTFS}/etc/ssh/ssh_host_*_key
    chmod 644 ${IMAGE_ROOTFS}/etc/ssh/ssh_host_*_key.pub
}
