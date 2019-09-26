# Instrument computer setup guide

The setup process for the instrument computers (ICC, RTC, AOC) is automated (to the extent possible) by scripts in the [`setup/`](https://github.com/magao-x/MagAOX/tree/master/setup) folder of [magao-x/MagAOX](https://github.com/magao-x/MagAOX).

Unfortunately, not _everything_ can be automated when real hardware is involved. To set up a new instrument computer, follow the steps below. Once the BIOS and OS are setup, you can [run the provisioning scripts](#run-provisioning-scripts).

The instrument computers use CentOS 7 for two reasons:

  - It has a long window of support, and will receive security and bug-fix updates [until June 30, 2024](https://en.wikipedia.org/wiki/CentOS#End-of-support_schedule).
  - It (or, equivalently, RHEL 7) is a supported platform for our more niche hardware like DMs and framegrabbers.

Once the hardware has been connected up, setup proceeds as follows.

## BIOS

### For all of AOC/ICC/RTC

```
Boot
|
 -- Network Device BBS Priorities -- set all to "disabled"
 -- Hard Drive BBS Priorities -- set "disabled" for all non-boot SSDs

Advanced
|
 -- APM
   |
    -- Restore AC Power Loss [Power OFF]
 -- ACPI Settings
   |
    -- Enable Hibernation [Disabled]
    -- ACPI Suspend State [Suspend Disabled]
```

(Note that the BIOS likes to reshuffle boot order when drives appear and disappear in testing or RAID swapping. Disabling non-boot drives ensures it doesn't accidentally try to boot from them.)

### For ICC/RTC

```
AI Tweaker
|
 -- Spread Spectrum [Disabled] {This is critical for allowing PCIe expanion to work}

Advanced
|
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

Boot into CentOS 7 x86_64 install media (ISOs [here](http://isoredirect.centos.org/centos/7/isos/x86_64/)) and proceed with interactive installation following these choices.

### Language

Language: English (United States)

### Network & Hostname

In the box at lower left, fill in the appropriate fully qualified domain name (e.g. `exao2.as.arizona.edu` not `exao2`). (TODO: Does this need changing when we travel to LCO?)

For each Ethernet controller listed on the left, click to select and click "Configure" to bring up the settings, and select the "IPv4 Settings" panel.

If the IP address in the table from [the Networking Doc](../networking.md) is not "n/a (DHCP)", select Method: "Manual" from the dropdown under "IPv4 Settings".

In the "Addresses" panel, click "Add" and enter the appropriate address from [the Networking Doc](../networking.md) table under "Network Connections".

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
        - Ctrl-click to select all the data drives (>500GB)
        - Press select
    - Device Type: `RAID - RAID 5`
    - File System: `XFS`
    - Change Desired Capacity to **blank** (again)
    - Press Update Settings
        - Should now have the full capacity for RAID 5 (N-1)

If you are prompted for a location to install the UEFI boot loader, you have somehow booted in UEFI mode instead of Legacy Boot / BIOS mode. (This has been observed booting from a liveUSB, despite UEFI boot being disabled in BIOS, but it goes away after reordering boot options in the BIOS interface and attempting to boot again.)

### Software

**ICC/RTC:**

From the list on the Left:

- Select "Minimal install"

From the list on the right:

- Select "Development Tools"
- Select "Debugging Tools"
- Select "System Administration Tools"

**AOC:**

From the list on the Left:

- Select "KDE Plasma Workspaces"

From the list on the right:

- Select "Development Tools"


### Begin the installation

### Users

- Set `root` password
- Create normal (admin) user account for use after reboot

## After OS installation

**Note:** For AOC, multiple monitors seem to confuse the default NVIDIA drivers. Stick to the VGA output until the NVIDIA drivers are set up (see below).

- Log in as `root`
- Run `yum update -y`
- Check RAID mirroring status: `cat /proc/mdstat`.
  - On new installs, it takes some time for the initial synchronization of the drives. (Like, "leave it overnight" time.)
- Configure internal-only network connections
  - Run `sudo nmtui`
  - Choose `Edit a connection`
  - Highlight `instrument` and hit `Enter`
    - Under `IPv4 CONFIGURATION` ensure `Never use this network for default route` **is** checked with an `[X]`
    - At the bottom of the list, ensure `Automatically connect` and `Available to all users` **are** checked
  - Highlight `www-ua` / `www-lco` and hit `Enter`
    - Under `IPv4 CONFIGURATION` ensure `Never use this network for default route` is **not** checked
    - At the bottom of the list, ensure `Automatically connect` and `Available to all users` **are** checked
- Disable graphical boot splash: `sudo plymouth-set-default-theme details; sudo dracut -f`

## Configure `/data` array options

We should be able to boot with zero of the drives in the `/data` array without systemd dropping to a recovery prompt.

Edit `/etc/fstab`, and on the line for `/data` replace `defaults` with the options `noauto,x-systemd.automount`.

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
    systemctl restart sshd
    ```

## AOC only: GPU drivers setup

Since we actually use the AOC GPU for **graphics** (shockingly enough), you will need to install NVIDIA's CUDA package with drivers before the monitors will work right. **You'll want `ssh` access in case anything goes wrong, so make sure it's working!**

0. Before starting, make sure everything's up to date: `yum update -y`
1. Download CUDA 10.1 from https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.168_418.67_linux.run (or whatever version is current in [setup/steps/install_cuda.sh](https://github.com/magao-x/MagAOX/blob/master/setup/steps/install_cuda.sh)) and take note of where it is saved
2. Install prerequisites: `sudo yum install -y kernel-devel kernel-headers`
3. As root, edit the line in `/etc/default/grub` that reads
   ```
   GRUB_CMDLINE_LINUX="[parts omitted] rhgb quiet"
   ```
   to read
   ```
   GRUB_CMDLINE_LINUX="[parts omitted] rhgb quiet rd.driver.blacklist=nouveau nouveau.modeset=0"
   ```
4. Install the new grub config with `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`
5. Create /etc/modprobe.d/blacklist-nouveau.conf with the contents
   ```
   blacklist nouveau
   options nouveau modeset=0
   ```
6. Execute `sudo systemctl set-default multi-user.target`
7. Shut down
8. Disconnect all monitors from the NVIDIA card
9. Connect a monitor to the VGA port from the motherboard's onboard graphics
10. Reboot to a text-mode prompt
11. Log in as `root`
12. Run CUDA installer with `bash cuda_10.1.168_418.67_linux.run --silent --driver --toolkit --samples` (or whatever version is downloaded)
13. Default to graphical boot: `systemctl set-default graphical.target`
14. Shut down
15. Disconnect the VGA port, reconnect the battle station monitors
16. Open up System Settings -> Display & Monitor and arrange the monitor geometry to reflect reality
17. Edit `/etc/default/grub` to remove `rd.driver.blacklist=nouveau nouveau.modeset=0` from `GRUB_CMDLINE_LINUX` and run `grub2-mkconfig -o /boot/grub2/grub.cfg`
18. Once everything's working satisfactorily, we want to lock the kernel version (so that we don't end up accidentally removing graphical boot capabilities with a `yum update -y`):

    1. `sudo yum install -y yum-versionlock`
    2. `sudo yum versionlock kernel kernel-headers kernel-devel`

## Perform (mostly) automated provisioning

Log in via `ssh` as a normal user with `sudo` access.

1. Clone [magao-x/MagAOX](https://github.com/magao-x/MagAOX) into your home directory (**not** into `/opt/MagAOX`, yet)

   ```
   $ cd
   $ git clone https://github.com/magao-x/MagAOX.git
   ```

2. Switch to the `setup` subdirectory in the MagAOX directory you cloned (in this example: `~/MagAOX/setup`) to perform pre-provisioning steps (i.e. steps requiring a reboot to take effect)

    ```
    $ cd ~/MagAOX/setup
    $ ./pre_provision.sh
    ```

    This sets up an `xsup` user and the `magaox` and `magaox-dev` groups. Because this step adds whoever ran it to `magaox-dev`, you will have to **log out and back in**.

    On ICC and RTC, this step also installs the CentOS realtime kernel and updates the kernel command line for ALPAO compatibility reasons. It also adds settings to disable the open-source `nouveau` drivers for the NVIDIA card. This is so that the CUDA install proceeds without errors. You must reboot before continuing.

3. Reboot, verify groups

    ```
    $ sudo reboot
    [log in again]
    $ groups
    yourname magaox-dev ...
    ```

4. *(optional)* Install `tmux` for convenience

    `tmux` allows you to preserve a running session across ssh disconnection and reconnection. (Ten second tutorial: Running `tmux` with no arguments starts a new self-contained session. `Ctrl-b` followed by `d` detatches from it, while any scripts you started continue to run. The `tmux attach` command reattaches.)

    ```
    $ sudo yum install -y tmux
    ```

    (It's used by the system, so it'll get installed anyway, but you might want it when you run the install.)

    To start a new session for the installation:

    ```
    $ tmux
    ```

5. **RTC/ICC only:** Obtain proprietary / non-redistributable software from the team Box folder

    Go to [MagAO-X/vendor_software/](https://arizona.box.com/s/dhmxrhjv00yh8lz4m0j7meivfaoyn9cn) _(invite required)_, click the "..." on `bundle` and choose "Download". Save `bundle.zip` in `MagAOX/setup/` next to `provision.sh`.

    ![Screenshot of Box interface to download bundle](download_bundle.png)

    This bundle includes software for the Andor, ALPAO, and Boston Micromachines hardware.

6. Run the provisioning script as a normal user

    ```
    $ cd ~/MagAOX/setup
    $ bash ./provision.sh
    ```

    If you installed and invoked `tmux` in the previous step, this would be a good time to `Ctrl-b` + `d` and go get a coffee.

Successful provisioning will end with the message "Finished!" and installed copies of MagAOX and its dependencies.

A lot of the things this script installs need environment variables set, so `source /etc/profile.d/*.sh` to keep working in the same terminal (or just log in again).

## Perform `xsup` key management

A new installation will generate new SSH keys for `xsup`. If you have an existing `.ssh` folder for the machine role (ICC, RTC, AOC) you're setting up, you can just copy its contents over the new `/home/xsup/.ssh/` (taking care not to change permissions).

If not, you must ensure passwordless SSH works bidirectionally by installing other servers' `xsup` keys and installing your own in their `/home/xsup/.ssh/authorized_keys`.

In the guide below, `$NEW_ROLE` is the role we just set up and `$OTHER_ROLE` is each of the other roles in turn. (For example, if we just set up the RTC, `$NEW_ROLE == RTC` and `$OTHER_ROLE` would be ICC and AOC.)

### Step-by-step

For each of the `$OTHER_ROLE`s:

1. On `$NEW_ROLE`, copy `/home/xsup/.ssh/id_ed25519.pub` to the clipboard
2. Connect to `$OTHER_ROLE` with your normal user account over SSH
3. Become `xsup` on `$OTHER_ROLE` and edit `/home/xsup/.ssh/authorized_keys` to insert the one you copied
4. On `$OTHER_ROLE`, copy `/home/xsup/.ssh/id_ed25519.pub` to the clipboard
5. Back on `$NEW_ROLE`, append the key you just copied to `/home/xsup/.ssh/authorized_keys`
6. On `$NEW_ROLE`, test you can `ssh $OTHER_ROLE` as `xsup` (potentially amending `~/.ssh/known_hosts`)
7. On `$OTHER_ROLE`, test you can `ssh $NEW_ROLE` as `xsup` (potentially amending `~/.ssh/known_hosts`)

## Verify bootloader installation / RAID correctness

- Ensure RAID arrays are fully built with `cat /proc/mdstat`
- `shutdown`
- Pop one of the two boot drives from the SSD cage
- Boot, verify that 1) `grub` appears and 2) the OS comes up (after a longer boot delay)
- Replace that boot drive, reboot
- Ensure RAID arrays are fully **rebuilt** with `cat /proc/mdstat`
- Pop the other drive
- Repeat verification steps
- Replace boot drive
- Boot with both in place
- Shutdown, pop **all** data drives
- Ensure boot proceeds without dropping to recovery prompt
- Replace all data drives, boot with everything in place
