---
title: 'Installation'
---

If you are here, we try to make no assumptions about how much you know
or don't know.

## Prerequisites

* A computer to install to with a recommended hard drive size of 8GB or more.
  NOTE that as far as this documentation is concerned, we assume you are using
  the entire computer hard drive with no other OS to be used except
  Rocky Linux.
* A spare USB flash drive or other USB device that can be used only for the
  installation (no other files on the drive)
* An Internet connection for download and updates once the installation is
  complete
* Knowledge of the method of writing the installation image to your USB device
  so that it is bootable
* Knowledge of the target machine's method for booting to another device. This
  is typically done by a key pressed during the POST. You may have to do a
  little research on your machine's motherboard or BIOS in order to get this
  information, but probably a simple Google search will get you what you need.

## Install Steps (GUI/Anaconda) (Recommended)

Once the prerequisites have been met, you'll need to download a Rocky Linux ISO
from [rockylinux.org/downloads](https://rocky-linux.org/downloads).

You should then make sure the file hashes are correct to ensure your download
is an official Rocky Linux build and has not been compromised or modified in
any way.

```shell
$ gpg --keyserver-options auto-key-retrieve --verify rocky-linux-8.3-x86_64.iso.sig
```

Write the Rocky Linux ISO to your USB device so that it's bootable. Refer back
to your research for your particular operating system.

---

**For Linux/macOS:**

```shell
$ sudo dd if=rocky-linux-8.3-x86_64.iso of=/dev/sdx
```

**For Windows:**

On Windows, we recommend you use the tool [Etcher](https://etcher.io). Once
it's installed, simply open the tool, select the Rocky Linux ISO you downloaded
and select the USB drive you procured for the installer, and hit "Flash!".

---

Once the ISO has been written to the USB device, you can attach it to the
machine that you will be installing Rocky Linux on and boot to this device.
Again, refer to the prerequisites (above) to do this.

If you successfully boot to the Rocky Linux image, you should be looking at
a Rocky Linux splash screen giving you installation options.  

TODO: Screenshot

If you are using the entire drive of your target machine for Rocky Linux, the
easiest way to get up and running is to simply take the default installation
option.  

TODO: Screenshot

Choose your language preference on the first screen and click "Continue"  

TODO: Screenshot

On the next screen, choose your Time Zone, Keyboard, etc., This will also be
where you select something other than the default install options, if you are
looking for something besides a desktop (in other words, a server install w/o
graphical interface, for example) you would make changes to the installed
packages by getting into the "Software Selection" section You will also want to
enable the Network interface that you are using insert.

TODO: Screenshot

When you've made all of the changes that you wish to make here, click "Begin Installation".

You will be presented with a splash screen for setting the password for root and adding a user.

TODO: Screenshot

You can do this as the installation progresses. It is required that you have a
root password and highly recommended that you have a non-root user and password
also created.

Once the installation is complete, follow the on screen instructions to reboot
the machine and you should now have a working Rocky Linux installation.
