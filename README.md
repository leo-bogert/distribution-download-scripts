# Linux / BSD distribution download scripts

These Bash scripts download the x86_64 installer ISOs of various distributions in a secure way:
- The GnuPG signature is validated - which is complex enough to justify the existence of a script for distributions such as Debian: The signature there signs a "Release" file, which contains the hash for a SHA256SUMS file, which contains the hash for the ISO. This chain of trust is validated by the script.
- The ISO is downloaded to a temporary filename and only renamed to .iso if the signature is valid. This ensures the script is safe to run in cronjobs, and even is safe against power loss during download: There will either be a valid ISO file or none.
- Deletes previously downloaded files before downloading new ones.

Text mode network installers aka mini ISOs are preferred where available.
Network installers are better than regular ones because they download all packages from the Internet so the system is fully up to date after installation.

Full / graphical ISOs are used otherwise.

# Debian ISO download script

Downloads the Debian 9 (stretch) network installer mini ISO, both in the text mode and graphical (gtk) version.

Usage:
```shell
# Install dependencies
sudo apt install bash wget gnupg debian-archive-keyring
# Download my GnuPG key to verify the signature on this repository.
gpg --recv-key "1517 3ECB BC72 0C9E F420  5805 B26B E43E 4B5E AD69"
git clone https://github.com/leo-bogert/distribution-download-scripts.git
cd distribution-download-scripts
# Verify my signature of the most recent tag
git verify-tag "$(git describe)"
./download-debian.sh
# Output = "debian/mini.iso" and "debian/graphical-mini.iso".
# Signature files are kept in that directory as well for debugging purposes.
```

# Ubuntu ISO download script

Will ship as soon as I am in the mood to commit it, or sooner if you ask me :)

# Kali Linux ISO download script

Will ship as soon as I am in the mood to commit it, or sooner if you ask me :)

# FreeBSD ISO download script

Will ship as soon as I am in the mood to commit it, or sooner if you ask me :)
