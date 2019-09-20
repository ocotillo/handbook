# Operation of the MagAO-X instrument

## Troubleshooting

### Troubleshooting a MagAO-X app that won't start

The typical MagAO-X app is started by `magaox startup` based on a line in a config file in `/opt/MagAOX/config/proclist_$MAGAOX_ROLE.txt`. This proclist determines which application to start and which config file from `/opt/MagAOX/config` should be supplied as the `-n` option (see [Standard options](#standard-options)). It also uses `sudo` to run the process as user `xsup`, regardless of which user called `magaox startup`.

Many, if not all, MagAO-X apps are intended to run "forever" (i.e until shutdown). Obviously, if the process exits early, that's cause for concern. To interrogate the list of running processes, use `magaox status`. To attempt a restart, you can attach to the `tmux` session that's the parent of the process in question with `magaox inspect PROCNAME` (where `PROCNAME` is the name of the failed process).

For example, if `trippLitePDU` is started by `magaox startup` with config specified by `-n pdu0` and there's a syntax error in `/opt/MagAOX/config/pdu0.conf` preventing startup, you can attach to the tmux session with

```
yourlogin$ magaox inspect pdu0
```

The errors before exit, if any, will be in the log. The last few lines of the log are shown in `magaox status` output, or you can do `logdump -f pdu0`.

The command that started the app will be of the form `/opt/MagAOX/bin/$appName -n $configName`. You can use the up-arrow key in the tmux session to retrieve it from the shell history and try to relaunch once you've corrected whatever error was preventing startup.

### EDT Framegrabber Problems (camwfs and camlowfs)

The EDT PCIe framegrabber occassionally stops responding.  The main symptom of this is no data from `camwfs`, and no response on the serial over camera link.  This has not yet been observed on `camlowfs` (which does not use serial over C.L.).

If `camwfs` (or any EDT camera) stops responding on serial, first shutdown the controlling application.

```
$ magaox inspect camwfs
<Ctrl-C>
```

then do these steps as root:

```
$ modprobe -r edt
$ cd /opt/EDTpdv
$ ./edt_load
```

This will reset the kernel module and restore operation.  Now restart the controlling application by returning to the tmux session, up-arrow to find the command, and press enter.

### killing indi zombies

If the `indiserver` crashes uncleanly (itself a subprocess of `xindiserver`), the associated `xindidriver` processes may become orphans.  This will prevent `xindiserver` from starting gain until these processes have been killed.  The following shell command will kill them:
```
$ kill $(ps -elf | awk '{if ($5 == 1){print $4" "$5" "$15}}' | grep MagAOX/drivers | awk '{print $1}')
```
To check if any remain use
```
$ ps -elf | awk '{if ($5 == 1){print $4" "$5" "$15}}' | grep MagAOX/drivers
```

## Adding a new user or developer account

User accounts on the RTC, ICC, and AOC machines are members of `magaox`. Developer accounts are additionally members of `magaox-dev` and `wheel`.

`/opt/MagAOX/source/MagAOX/setup/` contains scripts to help you remember which groups and what permissions the `~/.ssh` folder should have.

### `add_a_user.sh`

Creates a new user account in the group `magaox`, creates `.ssh` (`u=rwx,g=r,o=r`), and `.ssh/authorized_keys` (`u=rw,g=,o=`).

Example:

```
$ /opt/MagAOX/source/MagAOX/setup/add_a_user.sh klmiller
```

### `add_a_developer.sh`

Just like `add_a_user.sh` (in fact, uses it). Additionally adds the new account to the `wheel` (RTC/ICC) or `sudo` (AOC) group and `magaox-dev` groups.
