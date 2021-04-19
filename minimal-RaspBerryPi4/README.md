Minimalistic Raspberry Pi4
==========================

This image is based on the JeOS image, but further reduced.

You will *not* be able to install further packages using zypper
and there is no YaST to configure things.

This image description is supposed to get adapted and the image
rebuild for modifications instead.

Ideally we will have just the kernel and busybox running
here, but we are not there yet.

Todo
====

* get rid of EFI/grub and boot via u-boot only

* delete more packages

* make it easy to boot into a shell or own executables
  instead of providing a login prompt.

