# Controller operating system setup

The controllers (ICC and RTC) use CentOS 7 for two reasons:

  - It has a long window of support, and will receive security and bug-fix updates [until June 30, 2024](https://en.wikipedia.org/wiki/CentOS#End-of-support_schedule).
  - It (or, equivalently, RHEL 7) is a supported platform for our more niche hardware like DMs and framegrabbers.

Once the hardware has been connected up, OS setup proceeds as follows.

## BIOS

```
AI Tweaker
|
 -- Spread Spectrum [Disabled] {This is critical for allowing PCIe expanion to work}

Advanced
|
 -- APM
   |
    -- Restore AC Power Loss [Power OFF]
 -- ACPI Settings
   |
    -- Enable Hibernation [Disabled]
    -- ACPI Suspend State [Suspend Disabled]
 -- PCI Subsystem Settings
   |
     -- Above 4G Decoding [Enabled] {This is critical for allowing PCIe expansion to work}

IntelRCSetup
|
 --Processor Configuration
   |
   -- DCU Mode [16KB 4Way With ECC] {This is critical for allowing PCIe expansion to work}
|
 --Miscellaneous Configuration
   |
   -- Active Video [Onboard Device] {Prevents sending video to a GPU}
```

## OS Installation

Boot into CentOS 7 x86_64 install media and proceed with interactive installation following these choices.

### Language

Language: English (United States)

### Network

Enter given static IP. (TODO: networking doc.)

### Date & Time

- Timezone: America/Phoenix
- Ensure setting time from the network (NTP) is enabled

### Partitions

- Select all disks
- Select "I will configure partitioning"
- On 2x 512 drives:
    - 500 MiB `/boot` - RAID 1
    - 16 GiB swap - RAID 1
    - The rest as `/` - RAID 1
- On the data drives (should be 3 or more identical drives):
    - All space as `/data` - RAID 5

#### Detailed steps
- Choose partitioning scheme = Standard Partition in drop down menu
- Then press `+` button:
    - Mount Point: `/boot`
    - Desired Capacity: `500 MiB`
    - Now press `Modify`
        - Select the 2x 500 GB O/S drives (Ctrl-click)
        - Press select
- Device Type: `RAID - RAID 1`
- File System: `XFS`
- Press `Update Settings`
- Then press `+` button:
    - Mount Point: swap
    - Desired Capacity: 16 GiB
    - Now press `Modify`
        - Select the 2 500 GB O/S drives (Ctrl-click)
        - Press select
    - Device Type: `RAID - RAID 1`
    - File System: `XFS`
    - Press `Update Settings`
- Then press `+` button:
    - Mount Point: `/`
    - Desired Capacity: `0`
    - Now press `Modify`
        - Select the 2x 500 GB O/S drives (Ctrl-click)
        - Press select
    - Device Type: `RAID - RAID 1`
    - File System: `XFS`
    - Change Desired Capacity to `0`
    - Press Update Settings
        - should be using all available space for `/`
- Then press `+` button:
    - Mount Point: `/data`
    - Desired Capacity: `0`
    - Now press `Modify`
        - Select the  data drives (Ctrl-click)
        - Press select
    - Device Type: `RAID - RAID 5`
    - File System: `XFS`
    - Change Desired Capacity to `0`
    - Press Update Settings
        - Should now have the full capacity for RAID 5 (N-1)
- Be sure to choose one of the 500 GB disks for boot loader install (at the "Full disk summary and boot loader" screen).

### Software

- Select "Minimal install"
- Select "Development Tools"
- Select "System Administration Tools"

### Users

- Set `root` password
- Create normal (admin) user account for use after reboot

### Begin the installation

## After OS installation

- Log in as `root`
- Run `yum update`

## Setup ssh

- Install a key for at least one user in their `.ssh` folder, and make sure they can log in with it without requiring a password.

- Now configure `sshd`.  Do this by editing `/etc/ssh/sshd_config` as follows:

    Allow only ecdsa and ed25519:
    ```
    # HostKey /etc/ssh/ssh_host_rsa_key
    # HostKey /etc/ssh/ssh_host_dsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_ed25519_key
    ```

    Ensure that authorized_keys is the file checked for keys:
    ```
    AuthorizedKeysFile      .ssh/authorized_keys
    ```

    Disable password authentication:
    ```
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    UsePAM yes
    ```

- And finally, restart the sshd
    ```
    service sshd restart
    ```

## Install GRUB to both candidate boot disks

From MagAO, thus far untested on MagAO-X:

> - to ensure the system will boot off either drive we must intall grub on
> both boot sectors
>    - as root, type grub
>    - in grub execute:
>       ```
>       grub>root (hd0,0)
>       grub>setup (hd0)
>       grub>root (hd1,0)
>       grub>setup (hd1)
>       ```
>    - This should be tested, by unplugging each drive (while shutdown) then verifying that grub loads with only one drive
>    - a full boot test should be conducted, but will require ~2.5 hours perdisk to rebuild the array.

Update https://github.com/magao-x/MagAOX/issues/19 if you do this!

## Return to the [main setup guide](computer_setup.md)
