#!/usr/bin/env bash
set -euxo pipefail

VERSION="1.12.0"
TOOL="packer"
EDITION="linux_amd64"
BASE="https://releases.hashicorp.com/${TOOL}/${VERSION}"

curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --import
sudo apt-get update
sudo apt-get install -y unzip wget

tmpdir=$(mktemp -d)
trap 'rm -rf -- "$tmpdir"' EXIT
cd "$tmpdir"

# Download the binary and signature files.
wget -q "${BASE}/${TOOL}_${VERSION}_${EDITION}.zip"
wget -q "${BASE}/${TOOL}_${VERSION}_SHA256SUMS"
wget -q "${BASE}/${TOOL}_${VERSION}_SHA256SUMS.sig"

# Verify the signature file is untampered.
gpg --verify "${TOOL}_${VERSION}_SHA256SUMS.sig" "${TOOL}_${VERSION}_SHA256SUMS"

# Verify the SHASUM matches the binary.
grep "${EDITION}.zip" "${TOOL}_${VERSION}_SHA256SUMS" | shasum -a 256 -c -

unzip -o "${TOOL}_${VERSION}_${EDITION}.zip"
sudo install -m 0755 "${TOOL}" "/usr/local/bin/${TOOL}"

"${TOOL}" --version
