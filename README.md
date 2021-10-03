# AmogDOS
AmogDOS is a very tiny Linux distribution based on Helena's Obvious, Minimal Environment (HOME) containing IceWM and essential Linux utilities and commands. Currently it doesn't do much and serves only a a system recovery and repair image, but it will soon enough be expanded into a full installation environment for AmogOS.

AmogDOS is being developed by @HVilaverde (Helena) for the AmogOS project.

## FAQ

- Upload the source code for it!
There are just too many files within! Since most of the distro is repackaged software, only the relevant custom source code is uploaded under the /src directory.

- Why use a separate image for Calamares instead of using it directly on the OS?
Not only does using a separate image allows us more flexibility and allows users to perform system recovery, but it also fixed a big issue with AmogOS and other Debian + Slax Live distributions: They're a big pain to create SquashFS filesystems for at OS startup, as Slax just blows it's uncompressed load directly into the RAM filesystem. Having AmogOS just be a gigantic file inside another live image pretty much fixes this problem.

- Why can't I create users/modify the home directory?
HOME breaks the Single UNIX Specification (haha SUS funny) in that it only allows for one user: the root user. All commands related to user actions were removed from the userland and are just symlinks to the main "home" startup program. In HOME the /home folder is used for all sorts of things, from scripts to command lists to programs (although it is pretty barren right now). The /home directory is turned immutable at system reboot, and modifying the files inside it is not recommended. You can make it mutable by doing the command: "chattr -R -i /home"

## License

All custom software and changes in AmogDOS are licensed under the Reciprocal Public License, Version 1.5 WHERE APPLICABLE. Check terms in the "LICENSE" file.

HOME GNU/Linux is a Copyright (c) of HVilaverde, 2021.
