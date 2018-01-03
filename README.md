# Linux distribution download scripts

These Bash scripts download the x86_64 installer ISOs of various distributions in a secure way:
- The GnuPG signature is validated - which is complex enough to justify the existence of this script for distributions such as Debian: The signature there signs a "Release" file, which contains the hash for a SHA256SUMS file, which contains the hash for the ISO. This chain of trust is validated by the script.
- The ISO is renamed if the signature is invalid to allow using the script in cronjobs.
- Deletes previously downloaded files before downloading new ones.

Text mode network installers aka mini ISOs are preferred where available.

Full / graphical ISOs are used otherwise.

# Debian

Downloads the Debian 9 (stretch) network installer mini ISO, both in the text mode and graphical (gtk) version.

Usage:
```shell
# Download my GnuPG key to verify the signature on this repository.
gpg --recv-key "1517 3ECB BC72 0C9E F420  5805 B26B E43E 4B5E AD69"
# Download the repository
git clone https://github.com/leo-bogert/distribution-download-scripts.git
cd distribution-download-scripts
# Verify the signature of the most recent tag
git verify-tag "$(git describe)"
./download-debian.sh
```
