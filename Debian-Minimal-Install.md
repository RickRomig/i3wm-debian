# Debian 12 - Minimal Install

1. Boot to Debian Netinstall

   - URL: [Index of /cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/)

2. Select **Advanced Options** from the menu.

3. Then select **Expert Install**.

   1. Choose language country, and locale, the continue.

   2. Configure keyboard

   3. Detect and mouint installation media.

   4. Load installer componenets from installation media.

   5. Detect network hardware.

      - Hit Enter and Enter again

      - Select primary network interface.

      - Yes to auto-configure network.

      - Enter hostname for the system.

      - Domain name - remove and continue.

   6. Choose mirror.

      - http

      - Select country.

      - Choose mirror (deb.debian.org is the default)

   7. Setup users and passwords

      - Enable shadow passwords:

        - Yes (no passwork feedback)

        - **No** (enables password feedback)

      - Allow login as root

        - Yes - will have to install sudo after rebooting and add user to sudo group.

        - **No** - makes 1st user admin, installs sudo and adds user to sudo group.

      - Create user and password.

   8. Configure the clock

      - Set clock using NTP - Yes

      - NTP server - 0.debian.pool.ntp.org (default)

      - Set time zone (New York, Eastern Time)

   9. Detect disks

      - Partitioning - choose manual

      - Select disk to partition.

      - Create a new an empty partition.

      - Partition table

        - UEFI - select gpt

        - Legacy - select msdos

      - Free sapce & create new partitions

        - Set partition size (300M or 500M for UEFI partition)

        - Keep as ext4 and select EFI System Partition

        - Create root / home partitions

        - Will be using `zram` for swap instead of a swap partition.

        - Write changes to disk.

   10. Install the base system

       - Kernel to install - linux-image-amd64

       - Drivers - generic

   11. Configure package manager

       - Use network mirror

       - Non-free software - Yes

       - Enable source repositories (**yes**/no)

       - Services to use (select all)

   12. Select and install software

       - Updates

       - Select No Automatic Updates

       - Software selection

         - **No** desktop environment

         - **SSH server** (my preference)

         - **standard system utilities**

   13. Install the GRUB bootloader

       - Force GRUB installations to the EFI removable media path - No

   14. Finish the installation

4. Remove installation media and reboot.

5. Login as your user if you created your user during the install, otherwise, create your user.
   ```bash
   # /usr/sbin/adduser rick  # if not created during OS installation
   # /usr/bin/apt install sudo
   # /usr/bin/getent group sudo 2>&1 > /dev/null || /usr/sbin/groupadd sudo
   # /usr/sbin/usermod -aG sudo rick
   ```

6. Add your user to the sudo group if you enabled root login
   ```bash
   $ su -
   # /usr/bin/apt install sudo
   # /usr/bin/getent group sudo 2>&1 > /dev/null || /usr/sbin/groupadd sudo
   # /usr/sbin/usermod -aG sudo rick
   # exit
   $ chfn rick    # add room number, phone to user data
  ```

7. Increase TTY font-size
   ```bash
   $ sudo dpkg-reconfigure console-setup
   # Select UTF-8 and next default
   # Arrow down to Terminus
   # Select largest font size
   Ctrl+l
   ```

8. Install & configure Zram (Zram is installed in 'run.sh')
   ```bash
   $ sudo apt install zram-tools
   $ sudo nano /etc/default/zramswap
   # Uncomment ALGO=lz4
   ALGO=lz4
   # Uncomment Percent=50 and change 50 to 25
   PERCENT=25
   # Use sed instead of nano:
   sed -i.bak '/ALGO/s/^#//;/PERCENT/s/^#//;s/50$/25/' /etc/default/zramswap
   ```
9. Install git
   ```bash
   $ sudo apt install git
   ```

### Install git and then clone i3wm-debian repo to home directory (~/).
`git clone http://192.168.0.16:3000/Nullifidian/i3wm-debian.git ~/i3wm-debian`

#### Repositories for my scripts and configs
For information only, repos are cloned in `run.sh` installation script.
```bash
git clone http://192.168.0.16:3000/Nullifidian/scripts.git ~/scripts
git clone http://192.168.0.16:3000/Nullifidian/configs.git ~/configs
```
