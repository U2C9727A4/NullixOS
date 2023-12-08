# NullixOS
An immutable linux distribution based on void linux

# Licensing
The project is licensed under GPLV3 but some parts of void linux use diffirent licenses. I do not wish to affect those licenses, They are still there as normal and **are not GPL**. Everything that i make however (Such as installation scripts and stuff)
are all licensed under GPLV3.

# Considerations
The distribution is **extremely barebones**. Usage on bare metal will require linux expertise and command line profiency.
When installed, the distribution is not meant to be modified. (You can modify rootfs while still in the chroot that installs it, do changes before running setup.sh) Due to this, you will have to either remount rootfs as read-write or use external linux to come in and change the root filesystem, otherwise it cannot be modified in any way. It does not work like in ISOs. It does not accept any changes. ISOs accept changes but discard them on reboot, Nullix accepts nothing and will stay consisent (theoretically)
