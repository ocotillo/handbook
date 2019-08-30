# Networking

This document uses the hostnames of the machines interchangeably with their roles. For reference:

  - `exao1` — AOC
  - `exao2` — RTC
  - `exao3` — ICC

## Hostnames

Each instrument computer has a `/etc/hosts` file installed with names and aliases for devices internal to MagAO-X. Changes to this file are made in [setup/steps/configure_etc_hosts.sh](https://github.com/magao-x/MagAOX/blob/master/setup/steps/configure_etc_hosts.sh), and applied with `provision.sh`.

### University of Arizona

While at the University of Arizona, the FQDN is `<hostname>.as.arizona.edu`. Only `exao1` has a publicly-routable IP address, while `exao2` and `exao3` live behind the NAT.

### Las Campanas Observatory

TODO

## Time synchronization

Time synchronization depends on [chrony](https://chrony.tuxfamily.org/index.html), configured at `/etc/chrony/chrony.conf` (Ubuntu 18.04) or `/etc/chrony.conf` (CentOS 7). Those files are updated by `provision.sh` according to the script in [setup/steps/configure_chrony.sh](https://github.com/magao-x/MagAOX/blob/master/setup/steps/configure_chrony.sh).

The ICC and RTC take their time from AOC, which is configured to allow NTP queries from anyone in the `192.168.0.0/24` subnet.

AOC, in turn gets its time from a combination of

  - `lbtntp.as.arizona.edu` - LBT / Steward Observatory NTP server (when in the lab)
  - `ntp1.lco.cl` - Las Campanas NTP server (when at the telescope)
  - `ntp2.lco.cl` - Backup Las Campanas NTP server (when at the telescope)
  - `0.centos.pool.ntp.org` — Alias for a pool of hosts that contribute to pool.ntp.org (whenever reachable)

### Troubleshooting

To force a (potentially discontinuous) time sync, `sudo chronyc -a makestep`.

To verify correct operation from RTC or ICC, use `chronyc sources`:

```
$ chronyc sources
210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* exao1                         2   6   377    25   +379ns[+1194ns] +/-   14ms
```

If `exao1` is shown with a `?` in the second column or `0` in the `Reach` column, consult the [chrony FAQ](https://chrony.tuxfamily.org/faq.html).

To verify correct operation from the AOC end, `sudo chronyc clients`:

```
$ sudo chronyc clients
[sudo] password for jlong:
Hostname                      NTP   Drop Int IntL Last     Cmd   Drop Int  Last
===============================================================================
localhost                       0      0   -   -     -      49      0  11    16
exao2                          92      0   6   -    21       0      0   -     -
exao3                          27      0   6   -    16       0      0   -     -
```

If either exao2 or exao3 does not appear, ssh into them and verify `chronyd` has started...

```
$ systemctl is-active chronyd
active
```

...ensure `exao1` is reachable via that name...

```
$ ping exao1
PING exao1 (192.168.0.10) 56(84) bytes of data.
64 bytes from exao1 (192.168.0.10): icmp_seq=1 ttl=64 time=0.196 ms
...
```

...and finally, consult the [chrony FAQ](https://chrony.tuxfamily.org/faq.html).

## Topology

Figure TODO