# Debian 12 - Minimal Install
1. Boot to Debian Netinstall ISO USB drive.
   - URL: [Index of /cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/)
2. Select **Advanced Options** from the menu.
   - Recommended selection will be **bold-faced**.
3. Select **Expert Install**.
   1. Choose language country, and locale.
   2. Configure keyboard
   3. Detect and mouint installation media.
   4. Load installer componenets from installation media.
   5. Detect network hardware.
      - Hit Enter and Enter again
      - Select primary network interface.
      - **Yes** to auto-configure network.
      - Enter hostname for the system.
      - Domain name - remove and continue.
   6. Choose mirror.
      - http
      - Select country. (United States)
      - Choose mirror (deb.debian.org is the default)
   7. Setup users and passwords.
      - Enable shadow passwords:
        - Yes (no passwork feedback)
        - **No** (enables password feedback)
      - Allow login as root
        - Yes - will have to install sudo after rebooting and add user to sudo group.
        - **No** - makes 1st user admin, installs sudo and adds user to sudo group.
      - Create your user and password.
   8. Configure the clock.
      - Set clock using NTP - **Yes**
      - NTP server - 0.debian.pool.ntp.org (default)
      - Set time zone (New York, Eastern Time)
   9. Detect disks.
      - Partitioning - choose manual
      - Select disk to partition.
      - Create a new an empty partition.
      - Partition table
        - UEFI - select `gpt`
        - Legacy - select `msdos`
      - Free space and create new partitions
        - Set partition size (300M or 500M for UEFI partition if UEFI)
        - Create as `vfat` and select EFI System Partition  (UEFI install)
        - Create root / home partitions (Make `/` bootable if not UEFI)
        - Create as 'ext4' and designate as `/` and `/home' respectively.
        - No swap parition, will be using `zram` for swap.
        - Write changes to disk.
   10. Install the base system.
       - Kernel to install - `linux-image-amd64`
       - Drivers - `generic`
   11. Configure package manager.
       - Use network mirror
       - Non-free software - **Yes**
       - Enable source repositories (yes/**no**)
       - Services to use (select all) - security updates, release updates, backported software
   12. Select and install software.
       - Updates
       - Select **No Automatic Updates**
       - Software selection
         - **No** desktop environment (Uncheck Desktop Environment and any checked desktop environments.)
         - Check **SSH server** (my preference)
         - Check **standard system utilities**
   13. Install the GRUB bootloader.
       - Force GRUB installations to the EFI removable media path - **No**
   14. Execute a shell. (Installing network-manager before rebooting makes things easier)
```bash
chroot /target
apt install git network-manager
```
   15. Finish the installation.
4. Remove installation media and reboot.
5. If you set up a root user, login as root to add the sudo group and add your user to it.
```bash
/usr/sbin/adduser rick  # if not created during OS installation
/usr/bin/apt install sudo
/usr/bin/getent group sudo 2>&1 > /dev/null || /usr/sbin/groupadd sudo
/usr/sbin/usermod -aG sudo rick
```
6. Login as your user and add your user to the sudo group if you enabled root login.
```bash
$ su -
# /usr/bin/apt install sudo
# /usr/bin/getent group sudo 2>&1 > /dev/null || /usr/sbin/groupadd sudo
# /usr/sbin/usermod -aG sudo rick
# exit
$ chfn rick    # add room number, phone to user data
 ```
7. Increase TTY font-size. (Optional)
```bash
$ sudo dpkg-reconfigure console-setup
```
   - Select UTF-8 and next (default)
   - Arrow down to Terminus
   - Select largest font size (May be too large, 2nd largest may be a better choice)
   - `Ctrl+l` to clear screen and set font
8. Install & configure Zram (Skip this step since Zram be installed in 'run.sh' if no swap is found.)
```bash
$ sudo apt install zram-tools
$ sudo nano /etc/default/zramswap
# Uncomment ALGO=lz4
ALGO=lz4
# Uncomment Percent=50 and change 50 to 25
PERCENT=25
# Use sed instead of nano (recommended)
$ sed -i.bak '/ALGO/s/^#//;/PERCENT/s/^#//;s/50$/25/' /etc/default/zramswap
```
9. Install `git` and clone the i3wm-debian repo to the home directory (`~/`).
```bash
$ sudo apt install git  # if not installed during Debian installation
$ git clone https://github.com/RickRomig/i3wm-debian.git` ~/i3wm-debian
```
### Repositories for my scripts and configuration files
For information only, repos will be cloned to `~/Downloads` by the `run.sh` installation script.
```bash
$ git clone https://github.com/RickRomig/scripts.git ~/Downloads/scripts
$ git clone https://github.com/RickRomig/configs.git ~/Downloads/configs
```
#### Rick Romig "*The Luddite Geek*"
#### 18 May 2025
