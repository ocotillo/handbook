# Data Storage Management

## RAID arrays

The same configuration is used on RTC and ICC. (AOC has a smaller `/data` array due to reduced storage needs.)

- `/boot`, `/`, and `swap` — XFS formatted, replicated as RAID1 on two 500 GB SSDs.

- `/data` — XFS formatted, replicated as RAID5 on four 2 TB SSDs (effective capacity: 6 TB).


### Restoring failed drives

If a drive has been removed and reinserted, you should check to make sure it's reassembled after reboot.

  1. Check `/proc/mdstat` for missing drives

     ```
     $ cat /proc/mdstat
     Personalities : [raid1] [raid6] [raid5] [raid4]
     md124 : active raid5 sde1[2] sdd1[1] sdc1[0]
         5860144128 blocks super 1.2 level 5, 512k chunk, algorithm  2 [4/3] [UUU_]
         bitmap: 2/15 pages [8KB], 65536KB chunk

     md125 : active raid1 sda1[0] sdb1[1]
         470946816 blocks super 1.2 [2/2] [UU]
         bitmap: 2/4 pages [8KB], 65536KB chunk

     md126 : active raid1 sdb3[1] sda3[0]
         512000 blocks super 1.2 [2/2] [UU]
         bitmap: 0/1 pages [0KB], 65536KB chunk

     md127 : active raid1 sdb2[1] sda2[0]
         16776192 blocks super 1.2 [2/2] [UU]
     ```

     The `[UUU_]` is your hint that one of the four drives in `/dev/md124` is missing. Now, which one is it?

  2. Check for `/dev/sdXX` devices in `lsblk` that aren't parents of `/dev/mdXXX` devices. (**Note:** Don't count USB drives that aren't supposed to be part of a RAID!)

     For example:

     ```
     $ lsblk
     NAME      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
     sda         8:0    0 465.8G  0 disk
     ├─sda1      8:1    0 449.3G  0 part
     │ └─md125   9:125  0 449.1G  0 raid1 /
     ├─sda2      8:2    0    16G  0 part
     │ └─md127   9:127  0    16G  0 raid1 [SWAP]
     └─sda3      8:3    0   501M  0 part
       └─md126   9:126  0   500M  0 raid1 /boot
     sdb         8:16   0 465.8G  0 disk
     ├─sdb1      8:17   0 449.3G  0 part
     │ └─md125   9:125  0 449.1G  0 raid1 /
     ├─sdb2      8:18   0    16G  0 part
     │ └─md127   9:127  0    16G  0 raid1 [SWAP]
     └─sdb3      8:19   0   501M  0 part
       └─md126   9:126  0   500M  0 raid1 /boot
     sdc         8:32   0   1.8T  0 disk
     └─sdc1      8:33   0   1.8T  0 part
       └─md124   9:124  0   5.5T  0 raid5
     sdd         8:48   0   1.8T  0 disk
     └─sdd1      8:49   0   1.8T  0 part
       └─md124   9:124  0   5.5T  0 raid5
     sde         8:64   0   1.8T  0 disk
     └─sde1      8:65   0   1.8T  0 part
       └─md124   9:124  0   5.5T  0 raid5
     sdf         8:80   0   1.8T  0 disk
     └─sdf1      8:81   0   1.8T  0 part
     ```
     In this example, `sdf1` did not get reassembled into `md124` and isn't part of the `/data` RAID5 array.
  3. Hot-add the dropped device to the array with `mdadm`
     ```
     $ sudo mdadm /dev/md124 --add /dev/sdf
     ```
  4. Repeat steps 1 and 2 and verify all drives are present in the RAID


