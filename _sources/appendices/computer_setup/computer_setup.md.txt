# Instrument computer setup guide

The setup process for the instrument control computers is automated (to the extent possible) by scripts in the [`setup/`](https://github.com/magao-x/MagAOX/tree/master/setup) folder of [magao-x/MagAOX](https://github.com/magao-x/MagAOX).

Unfortunately, not _everything_ can be automated when real hardware is involved. To set up a new instrument computer, follow the steps below. Once the BIOS and OS are setup, you can [run the provisioning scripts](#run-provisioning-scripts).


## BIOS

Enter BIOS and change the following settings:

    - Advanced > ACPI > Enable Hibernation Disabled.
    - Advanced > ACPI > Suspend Disabled.
    - IntelRCSetup > Processor Config > Hyper-Threading Disabled
    - Advanced > APM > Restore AC Power Loss > Power On

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

For the **Real Time Controller** or **Instrument Control Computer**:

- Select "Minimal install"

For a **GUI workstation**:

- Select "KDE Plasma workstation"

For either:

- Select "Development Tools"
- Select "System Administration Tools"


### Users
- Set `root` password
- Create a non-root, non-administrator user
    - Username: `xsup`
    - Name: `MagAO-X Supervisor`

### Begin the installation

## After OS installation

- Log in as `root`
- Run `yum update`
- Add a user with admin privileges:
    ```
    # useradd jrmales
    # passwd jrmales
    ```
- Give that user sudo privileges:
    ```
    $ usermod -aG wheel jrmales
    ```

## Setup ssh

- Generate an ed25519 key for user xsup:

    ```
    [xsup@host ~]$ ssh-keygen -t ed25519
    ```

    Do not set a passphrase. This will create the .ssh directory with the correct permissions.
- Next, in the .ssh directory, create an authorized_keys file and set permissions:

    ```
    [xsup@host .ssh]$ touch authorized_keys
    [xsup@host .ssh]$ chmod 600 authorized_keys
    ```

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

## Prepare for automated provisioning

Log in via `ssh` as a user with `sudo` access.

**If you are provisioning an instrument control computer that needs a realtime kernel and the NVIDIA SDKs, first follow [Installing the realtime Linux kernel and the NVIDIA GPU driver](realtime_linux_config) and come back.**

1. Clone [magao-x/MagAOX](https://github.com/magao-x/MagAOX) into your home directory (**not** into `/opt/MagAOX`, yet)

   ```
   $ cd
   $ git clone https://github.com/magao-x/MagAOX.git
   ```

2. Download Intel MKL — This has to be done interactively, since Intel enforces a registration requirement to download the MKL package.

    **If you're not yet registered with Intel:** Starting at https://software.intel.com/en-us/mkl, click "Free Download" and follow the prompts to create and verify an account.

    **If you've registered before:** It's well hidden, but https://registrationcenter.intel.com/en/products/ should take you right to the page with the download links. We want Intel Performance Libraries for Linux, specifically Intel Math Kernel Library.

    Copy the download link (e.g. right-click and "Copy Link Location") and switch to a terminal on a production machine.

    ```
    $ cd
    $ curl -OL <pasted-url>
    ```
    (I'd put the download link in these docs, but it changes when there's a new release.)

3. Extract and install Intel MKL

   ```
   $ tar xvzf l_mkl_<tab>  # name subject to change ;)
   $ cd l_mkl_<tab>
   ```

   Install as root:

   ```
   $ sudo ./install.sh -s ~/MagAOX/setup/intel_mkl_silent_install.cfg
   ```

   Wait a few minutes for it to complete. You shouldn't see any output, but `/opt/intel` should now exist.

## Run provisioning scripts

1. Switch to the `setup` subdirectory in the MagAOX directory you cloned (in this example: `~/MagAOX/setup`) to set up users and groups.

    ```
    $ cd ~/MagAOX/setup
    $ ./setup_users_and_groups.sh
    ```

    Note: on ubuntu you will need to add a symlink: 'ln -s /usr/bin/sudo /bin/sudo
2. Log out and back in, verify groups

    ```
    $ logout
    [open new terminal]
    $ groups
    yourname wheel magaox-dev
    ```

    Because the last step changed the group memberships of the installing user (i.e. `$USER`, so most likely you), you will have to log out and back in. (Alternatively, you can run `newgrp magaox-dev` to start a new subshell where the new group is active, but this can get confusing.)

    Note: on ubuntu instead of `wheel` it will be `sudo`

3. Run the provisioning script

    ```
    $ cd ~/MagAOX/setup
    $ screen  # optional: lets you detach from the build and come back later. ("sudo yum install -y screen" to install.)
    $ ./production_provision.sh
    ```
