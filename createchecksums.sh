#!/bin/bash
# Run this simple script to generate checksums for all files before making a commit.
# This is important: if source code is distributed that does not comform to the checksums in this repo, then it is a derivative work.

md5sum etc/calamares/settings.conf > etc/checksums
md5sum etc/calamares/branding/debian/* >> etc/checksums
md5sum etc/calamares/modules/* >> etc/checksums

md5sum home/symlink/* > home/checksums

md5sum src/home.bas > src/checksums