# Networking

This document uses the hostnames of the machines interchangeably with their roles. For reference:

  - `exao1` — AOC
  - `exao2` — RTC
  - `exao3` — ICC

## Network Connections

### exao1

| connection name | device | IPv4 address | subnet mask | default route / gateway | DNS servers | search domains |
| --- | --- | --- | --- | --- | --- | --- |
| www-ua | enx2cfda1c61ddf | n/a (DHCP) | — | — | — | — |
| www-lco | enx2cfda1c61ddf | 200.28.147.221 | 255.255.255.0 | 200.28.147.1 | 200.28.147.4 200.28.147.2 139.229.97.26 | lco.cl |
| instrument | enx2cfda1c61dde | 192.168.0.10 | 255.255.255.0 | 192.168.0.1 | -- | -- |


**For reference:** At last setup, the automatic DHCP-assigned configuration for `www-ua` was:

  - IP Address: `128.196.208.35`
  - Subnet Mask: `255.255.252.0`
  - Default Route: `128.196.208.1`
  - DNS: `128.196.208.2 128.196.211.3 128.196.11.233 128.196.11.234`

### exao2

| connection name | device | IPv4 address | subnet mask | default route / gateway | DNS servers | search domains |
| --- | --- | --- | --- | --- | --- | --- |
| www-ua | enx2cfda1c6db1b | 10.130.133.207 | 255.255.254.0 | 10.130.132.1 | 128.196.208.2 128.196.209.2 128.196.11.233 | as.arizona.edu |
| www-lco | enx2cfda1c6db1b | 200.28.147.222 | 255.255.255.0 | 200.28.147.1 | 200.28.147.4 200.28.147.2 139.229.97.26 | lco.cl |
| instrument | enx2cfda1c6db1a | 192.168.0.11 | 255.255.255.0 | 192.168.0.1 | -- | -- |

### exao3

| connection name | device | IPv4 address | subnet mask | default route / gateway | DNS servers | search domains |
| --- | --- | --- | --- | --- | --- | --- |
| www-ua | enx2cfda1c61f17 | 10.130.133.208 | 255.255.254.0 | 10.130.132.1 | 128.196.208.2 128.196.209.2 128.196.11.233 | as.arizona.edu |
| www-lco | enx2cfda1c61f17 | 200.28.147.223 | 255.255.255.0 | 200.28.147.1 | 200.28.147.4 200.28.147.2 139.229.97.26 | lco.cl |
| instrument | enx2cfda1c61f16 | 192.168.0.12 | 255.255.255.0 | 192.168.0.1 | -- | -- |
| camsci1 | enx503eaa0ceeff | 192.168.102.2 | 255.255.255.0 | 192.168.102.1 | -- | -- |
| camsci2 | enx503eaa0cf4cd | 192.168.101.2 | 255.255.255.0 | 192.168.101.1 | -- | -- |

## Hostnames

Each instrument computer has a `/etc/hosts` file installed with names and aliases for devices internal to MagAO-X. Changes to this file are made in [setup/steps/configure_etc_hosts.sh](https://github.com/magao-x/MagAOX/blob/master/setup/steps/configure_etc_hosts.sh), and applied with `provision.sh`.

### University of Arizona

While at the University of Arizona, the FQDN is `<hostname>.as.arizona.edu`. Only `exao1` has a publicly-routable IP address, while `exao2` and `exao3` live behind the NAT.

### Las Campanas Observatory

While at LCO, the FQDN is `<hostname>.lco.cl`. All three instruments are accessible from the LCO-VISITORS wireless network and other usual places, but not from the outside internet.

## Time synchronization

Time synchronization depends on [chrony](https://chrony.tuxfamily.org/index.html), configured at `/etc/chrony/chrony.conf` (Ubuntu 18.04) or `/etc/chrony.conf` (CentOS 7). Those files are updated by `provision.sh` according to the script in [setup/steps/configure_chrony.sh](https://github.com/magao-x/MagAOX/blob/master/setup/steps/configure_chrony.sh).

The ICC and RTC take their time from AOC, which is configured to allow NTP queries from anyone in the `192.168.0.0/24` subnet.

AOC, in turn gets its time from a combination of

  - `lbtntp.as.arizona.edu` - LBT / Steward Observatory NTP server (when in the lab)
  - `ntp1.lco.cl` - Las Campanas NTP server (when at the telescope)
  - `ntp2.lco.cl` - Backup Las Campanas NTP server (when at the telescope)
  - `0.centos.pool.ntp.org` — Alias for a pool of hosts that contribute to pool.ntp.org (whenever reachable)

### Troubleshooting

If you need to see how system time relates to network time on an instrument computer, run `chronyc tracking`:

```
$ chronyc tracking
Reference ID    : C0A8000A (exao1)
Stratum         : 3
Ref time (UTC)  : Fri Nov 15 00:42:34 2019
System time     : 0.000012438 seconds fast of NTP time
Last offset     : +0.000014364 seconds
RMS offset      : 0.000025598 seconds
Frequency       : 0.688 ppm fast
Residual freq   : +0.012 ppm
Skew            : 0.132 ppm
Root delay      : 0.000474306 seconds
Root dispersion : 0.000256627 seconds
Update interval : 130.4 seconds
Leap status     : Normal
```

To force a (potentially discontinuous) time sync, `sudo chronyc -a makestep`.

To verify correct operation from RTC or ICC, use `chronyc sources`:

```
$ chronyc sources
210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* exao1                         2   6   377    25   +379ns[+1194ns] +/-   14ms
```

If `exao1` is shown with a `?` in the second column or `0` in the `Reach` column, you may have firewalled traffic on the internal "instrument" interface. You can examine the configuration files in `/etc/sysconfig/network-scripts/ifcfg-*` and ensure that the interface corresponding to `instrument` in `nmtui`/`nmcli` has `ZONE=trusted`.

If it's not any of that, consult the [chrony FAQ](https://chrony.tuxfamily.org/faq.html).

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
