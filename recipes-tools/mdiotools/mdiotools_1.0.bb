DESCRIPTION = "MDIO tool for direct manipulation of MDIO registers"
SECTION = "net"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${S}/COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://github.com/deadpoolcode1/kratos_mdio-tools;protocol=git;branch=master"
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
