#!/bin/bash
# generate-keys.sh - Generate RSA-4096 keypair for secure boot
#
# Usage:
#   ./generate-keys.sh                  # -> keys in ../keys, name "secboot"
#   ./generate-keys.sh [output_dir]     # -> keys in output_dir, name "secboot"
#   ./generate-keys.sh [output_dir] [key_name]
#
# Default layout (script located in files/scripts):
#   files/
#     ├─ keys/        <- default key folder
#     └─ scripts/
#          └─ generate-keys.sh

set -e

# Determine default key directory relative to this script:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/../../../" && pwd)"   #base dir of the project
DEFAULT_KEYDIR="${BASE_DIR}/secboot-keys"
DEFAULT_KEYNAME="secboot"

# Parse arguments
KEYDIR="${1:-${DEFAULT_KEYDIR}}"
KEYNAME="${2:-${DEFAULT_KEYNAME}}"

KEY_BITS=4096
VALIDITY_DAYS=3650

echo "=== Secure Boot Key Generation ==="
echo "Key directory: ${KEYDIR}"
echo "Key name: ${KEYNAME}"
echo "Key size: ${KEY_BITS} bits"
echo ""

# Create directory
mkdir -p "${KEYDIR}"

# Check if keys already exist
if [ -f "${KEYDIR}/${KEYNAME}.key" ]; then
    echo "WARNING: Key ${KEYDIR}/${KEYNAME}.key already exists!"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "Generating RSA-${KEY_BITS} private key..."
openssl genrsa -F4 \
    -out "${KEYDIR}/${KEYNAME}.key" \
    ${KEY_BITS}

echo "Generating self-signed certificate..."
openssl req -batch -new -x509 \
    -key "${KEYDIR}/${KEYNAME}.key" \
    -out "${KEYDIR}/${KEYNAME}.crt" \
    -days ${VALIDITY_DAYS} \
    -subj "/CN=SecureBoot-${KEYNAME}/O=CustomSecureBoot/C=US"

echo "Extracting public key..."
openssl rsa \
    -in "${KEYDIR}/${KEYNAME}.key" \
    -pubout \
    -out "${KEYDIR}/${KEYNAME}.pub"

# Generate key hash for verification
echo "Generating key fingerprint..."
openssl rsa \
    -in "${KEYDIR}/${KEYNAME}.key" \
    -modulus -noout | \
    openssl sha256 > "${KEYDIR}/${KEYNAME}.fingerprint"

# Set secure permissions
chmod 600 "${KEYDIR}/${KEYNAME}.key"
chmod 644 "${KEYDIR}/${KEYNAME}.crt"
chmod 644 "${KEYDIR}/${KEYNAME}.pub"

echo ""
echo "=== Key Generation Complete ==="
echo "Private key: ${KEYDIR}/${KEYNAME}.key (KEEP SECURE!)"
echo "Certificate: ${KEYDIR}/${KEYNAME}.crt"
echo "Public key:  ${KEYDIR}/${KEYNAME}.pub"
echo "Fingerprint: ${KEYDIR}/${KEYNAME}.fingerprint"
echo ""
echo "Key fingerprint:"
cat "${KEYDIR}/${KEYNAME}.fingerprint"

# Verify key can be used with mkimage
echo "Verifying key compatibility with mkimage..."
if command -v mkimage &> /dev/null; then
    TMP_DIR="$(mktemp -d)"
    TMP_DATA="${TMP_DIR}/dummy-kernel.bin"
    TMP_ITS="${TMP_DIR}/test.its"
    TMP_FIT="${TMP_DIR}/test.fit"

    echo "test" > "${TMP_DATA}"

    cat > "${TMP_ITS}" << EOF
/dts-v1/;

/ {
    description = "Test FIT for secure boot key";
    #address-cells = <1>;

    images {
        kernel {
            description = "Dummy test kernel";
            data = /incbin/("${TMP_DATA}");
            type = "kernel";
            arch = "arm";
            os = "linux";
            compression = "none";
            load = <0x8000>;
            entry = <0x8000>;
            hash-1 {
                algo = "sha256";
            };
        };
    };

    configurations {
        default = "conf";
        conf {
            description = "Test configuration";
            kernel = "kernel";
            signature-1 {
                algo = "sha256,rsa4096";
                key-name-hint = "${KEYNAME}";
            };
        };
    };
};
EOF

    if mkimage -f "${TMP_ITS}" -k "${KEYDIR}" -r "${TMP_FIT}" >/dev/null 2>&1; then
        echo "✓ Keys verified compatible with mkimage (test FIT created and signed)"
    else
        echo "✗ Key verification with mkimage failed"
        echo "  Check u-boot-tools version and FIT signing support."
        echo "  This does NOT mean key generation failed; it only affects the test."
    fi

    rm -rf "${TMP_DIR}"
else
    echo "mkimage not found, skipping verification"
fi