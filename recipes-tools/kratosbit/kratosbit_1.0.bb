SECTION = "examples"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "git://github.com/deadpoolcode1/kratos_bit.git;protocol=https;branch=master"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

# Skip specific QA checks and debug splitting
INSANE_SKIP:${PN} = "installed-vs-shipped arch binary dev-so rpaths buildpaths file-rdeps"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

do_compile() {
    :
}

do_install:append() {
    install -d ${D}${sysconfdir}
    install -m 0755 ${S}/TestClient_evb ${D}${sysconfdir}/TestClient_evb
    install -m 0755 ${S}/TestServer_evb ${D}${sysconfdir}/TestServer_evb
    install -m 0644 ${S}/config.json ${D}${sysconfdir}/config.json
}

