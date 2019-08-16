# Operation of the MagAO-X instrument

## Troubleshooting a MagAO-X app that won't start

The typical MagAO-X app is started with `magaox_procstart.sh $ROLE`, which parses a config file in `/opt/MagAOX/config/proclist_$ROLE.txt` to determine which applications should be started and which config file from `/opt/MagAOX/config` should be supplied as the `-n` option (see [Standard options](#standard-options)).

Many, if not all, MagAO-X apps are intended to run "forever" (i.e until shutdown). Obviously, if the process exits early, that's cause for concern. To interrogate the list of running processes, use `magaox_status.sh $ROLE`. To attempt a restart, you can attach to the `tmux` session that's the parent of the process in question.

For example, if `trippLitePDU` is started by `magaox_procstart.sh` with `-n pdu0` and there's a syntax error in `/opt/MagAOX/config/pdu0.conf` preventing startup, you can attach with

```
yourlogin$ su xsup
xsup$ tmux at -t pdu0
```

The errors before exit, if any, will be in the log. The last few lines of the log are shown in `magaox_status.sh` output, or you can do `logdump pdu0`.

The command that started the app will be of the form `/opt/MagAOX/bin/$appName -n $configName`. You can use the up-arrow key in the tmux session to retrieve it from the shell history and try to relaunch once you've corrected whatever error was preventing startup.

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
