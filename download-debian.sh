#!/bin/bash
set -o nounset
# The system's debian-archive-keyring.gpg doesn't always contain all the keys which signed the Release.gpg so GPG sometimes returns non-zero exit code while we pipe it into fgrep to check for a valid signature.
# set -o pipefail
set -o errexit
set -o errtrace
trap 'echo "Error at line $LINENO, exit code is $?" >&2' ERR
shopt -s nullglob
shopt -s failglob

# Debian 9 (stretch)
DISTRIBUTION="http://ftp.debian.org/debian/dists/stretch"

mkdir -p debian
cd debian

echo "Deleting old download..."
rm -f Release.gpg Release SHA256SUMS mini.iso graphical-mini.iso mini.iso.INVALID graphical-mini.iso.INVALID

echo "Downloading Release file and checking its GPG signature..."
wget --quiet -O Release.gpg "$DISTRIBUTION"/Release.gpg
wget --quiet -O Release "$DISTRIBUTION"/Release
# Uncomment this to test signature verification:
#echo >> Release

if ! gpg --no-default-keyring --keyring /usr/share/keyrings/debian-archive-keyring.gpg --verify Release.gpg Release 2>&1 | fgrep 'gpg: Good signature from "Debian Archive Automatic Signing Key (7.0/wheezy) <ftpmaster@debian.org>"' ; then
	echo "GPG check failed!"
	exit 1
fi

path_sha256sums="main/installer-amd64/current/images/SHA256SUMS"
sha_sha256sums="$(fgrep "$path_sha256sums" Release | tail -1 | cut -d' ' -f2)"
echo "Expecting checksum for SHA256SUMS: $sha_sha256sums"

echo "Downloading SHA256SUMS and checking its sha256sum..."
wget --quiet -O SHA256SUMS "$DISTRIBUTION/$path_sha256sums"
# Uncomment this to test hash verification:
#echo >> SHA256SUMS

if ! sha256sum -c - <<< "$sha_sha256sums SHA256SUMS" ; then
	echo "sha256 check of SHA256SUMS file failed!"
	exit 1
fi

sha_iso="$(fgrep ./netboot/mini.iso SHA256SUMS | cut -d' ' -f1)"
sha_graphical_iso="$(fgrep ./netboot/gtk/mini.iso SHA256SUMS | cut -d' ' -f1)"
echo "Expecting checksum for mini.iso: $sha_iso"
echo "Expecting checksum for graphical-mini.iso: $sha_graphical_iso"

echo "Downloading ISOs and checking their sha256sums..."

if ! wget --quiet -O mini.iso "$DISTRIBUTION"/main/installer-amd64/current/images/netboot/mini.iso ; then
	# Delete the file to ensure an attacker cannot terminate the network connection after delivering a malicious ISO to bypass hash validation:
	# Users might use this script in cronjobs and not test its exit code.
	rm -f mini.iso
	echo "Download of mini.iso failed!"
	exit 1
fi

# Uncomment this to test hash verification:
#echo >> mini.iso

if ! sha256sum -c - <<< "$sha_iso mini.iso" ; then
	mv mini.iso mini.iso.INVALID
	echo "sha256 check of mini.iso file failed! Added .INVALID to filename!"
	exit 1
fi

if ! wget --quiet -O graphical-mini.iso "$DISTRIBUTION"/main/installer-amd64/current/images/netboot/gtk/mini.iso ; then
	# Delete the file to ensure an attacker cannot terminate the network connection after delivering a malicious ISO to bypass hash validation:
	# Users might use this script in cronjobs and not test its exit code.
	rm -f graphical-mini.iso
	echo "Download of graphical-mini.iso failed!"
	exit 1
fi

# Uncomment this to test hash verification:
#echo >> graphical-mini.iso

if ! sha256sum -c - <<< "$sha_graphical_iso graphical-mini.iso" ; then
	mv graphical-mini.iso graphical-mini.iso.INVALID
	echo "sha256 check of graphical-mini.iso file failed! Added .INVALID to filename!"
	exit 1
fi

echo
echo "Finished:"
sha256sum Release.gpg Release SHA256SUMS mini.iso graphical-mini.iso
