DESCRIPTION = "MDIO tool for direct manipulation of MDIO registers"
SECTION = "net"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "git://github.com/deadpoolcode1/kratos_mdio-tools;protocol=https;branch=master"
SRC_URI[sha256sum] = "a78376ba9e317002e1261f9e3aac2f4de2e97ce8b9411426d0375b94c40d1af8"
SRCREV = "f74eaf38dbda441df4fcaeb21ca4465957953a2f"

S = "${WORKDIR}/git"

inherit autotools pkgconfig autotools-brokensep

DEPENDS = "libmnl pkgconfig-native"

do_configure() {
    export PKG_CONFIG="$(which pkg-config)"
    oe_runconf
}

do_compile() {
    oe_runmake
}

do_configure:prepend() {
    autoreconf -vfi
}

do_install() {
    oe_runmake install DESTDIR=${D}
}

FILES_${PN} += "${bindir}/mdio-tool"
