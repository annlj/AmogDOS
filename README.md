# AmogDOS
AmogDOS is a very tiny heavily-modified Debian image containing IceWM, essestial linux commands, and the Calamares installer to install AmogOS. Think of it like Windows PE.

AmogDOS is being developed by @HVilaverde (/ussr/share#8627) for the AmogOS project.

FAQ:
- Upload the source code for it!
No, we can't upload the source code for the boot image as it's just a custom Debian image edited in VirturalBox, but we do have the VM image for upload.

- Why use a seprate image for Calamares instead of using it directly on the OS?
The OS itself is a live usb and all it's files are stored in a .sb SquashFS format. Calamares can't read or use the file, so instead we do some magic with AmogDOS to make it work (I actually have no idea how this works please insert how it workls here helena UwU)
