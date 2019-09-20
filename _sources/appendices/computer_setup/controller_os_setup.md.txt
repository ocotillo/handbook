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

Boot
|
 -- Network Device BBS Priorities -- set all to "disabled"
 -- Hard Drive BBS Priorities -- set "disabled" for all non-boot SSDs
```

(Note that the BIOS likes to reshuffle boot order when drives appear and disappear in testing or RAID swapping. Disabling non-boot drives ensures it doesn't accidentally try to boot from them.)

## OS Installation

Boot into CentOS 7 x86_64 install media and proceed with interactive installation following these choices.

### Language

Language: English (United States)

### Network & Hostname

In the box at lower left, fill in the appropriate fully qualified domain name (e.g. `exao2.as.arizona.edu` not `exao2`). (TODO: Does this need changing when we travel to LCO?)

For each Ethernet controller listed on the left, click to select and click "Configure" to bring up the settings.

In the "Addresses" panel, click "Add" and enter the appropriate address from [the Networking Doc](../networking.md) table under "Network Connections". If the IP address  in the table is not "n/a (DHCP)", select Method: "Manual" from the dropdown under "IPv4 Settings".

To confirm the link works, `Ctrl-Alt-F2` gets you to a command prompt.

Try pinging Google:
```
$ ping 8.8.8.8
...
# Hit Ctrl-C after a few seconds
^C
```

Verify "0% packet loss".

And the MagAO-X internal router:

```
$ ping 192.168.0.1
# Hit Ctrl-C after a few seconds
^C
```

Verify "0% packet loss".

To return to the main installer, hit `Ctrl-Alt-F6`.

### Date & Time

- Timezone: America/Phoenix

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
- *If this is a reinstall:*
  - Click on the arrow next to "CentOS Linux..." to expand the list of existing partitions.
  - Click one to select and click the `-` button at the bottom of the list
  - Check the box saying `Delete all filesystems which are only used by CentOS Linux ...` and confirm
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
    - Desired Capacity: **blank**
    - Now press `Modify`
        - Select the 2x 500 GB O/S drives (Ctrl-click)
        - Press select
    - Device Type: `RAID - RAID 1`
    - File System: `XFS`
    - Change Desired Capacity to **blank** (again)
    - Press Update Settings
        - should be using all available space for `/`
- Then press `+` button:
    - Mount Point: `/data`
    - Desired Capacity: **blank**
    - Now press `Modify`
        - Select the three 1 TB data drives (Ctrl-click)
        - Press select
    - Device Type: `RAID - RAID 5`
    - File System: `XFS`
    - Change Desired Capacity to **blank** (again)
    - Press Update Settings
        - Should now have the full capacity for RAID 5 (N-1)

If you are prompted for a location to install the UEFI boot loader, you have somehow booted in UEFI mode instead of Legacy Boot / BIOS mode. (This has been observed booting from a liveUSB, despite UEFI boot being disabled in BIOS, but it goes away after reordering boot options in the BIOS interface and attempting to boot again.)

### Software

From the list on the Left:

- Select "Minimal install"

From the list on the right:

- Select "Development Tools"
- Select "Debugging Tools"
- Select "System Administration Tools"

### Begin the installation

### Users

- Set `root` password
- Create normal (admin) user account for use after reboot

## After OS installation

- Log in as `root`
- Run `yum update`
- Check RAID mirroring status: `cat /proc/mdstat`.
  - On new installs, it takes some time for the initial synchronization of the drives. (Like, "leave it overnight" time.)
- Configure internal-only network connections
  - Run `sudo nmtui`
  - Choose `Edit a connection`
  - Highlight `instrument` and hit `Enter`
  - Under `IPv4 CONFIGURATION` ensure `Never use this network for default route` is checked with an `[X]`
  - At the bottom of the list, ensure `Automatically connect` and `Available to all users` are checked

## Verify bootloader installation / RAID1 correctness

- Ensure RAID arrays are fully built with `cat /proc/mdstat`
- `shutdown`
- pop one of the two boot drives from the SSD cage
- boot, verify that 1) `grub` appears and 2) the OS comes up (after a longer boot delay)
- replace that boot drive, pop the other drive
- repeat verification step
- replace boot drive
- boot with both in place

## Configure `/data` array options

We should be able to boot with zero of the drives in the `/data` array without systemd dropping to a recovery prompt.

Edit `/etc/fstab`, and on the line for `/data` replace `defaults` with the options `noauto,x-systemd.automount`.

To verify:

  - `shutdown`
  - pop all data drives
  - verify boot is possible without dropping to recovery prompt

## Setup ssh

- Install a key for at least one user in their `.ssh` folder, and make sure they can log in with it without requiring a password.

- Now configure `sshd`.  Do this by editing `/etc/ssh/sshd_config` as follows:

    Allow only ecdsa and ed25519:
    ```
    #HostKey /etc/ssh/ssh_host_rsa_key
    #HostKey /etc/ssh/ssh_host_dsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_ed25519_key
    ```

    Disable password authentication:
    ```
    PasswordAuthentication no
    ```

- And finally, restart the sshd
    ```
    service sshd restart
    ```

## Return to the [main setup guide](computer_setup.md)
