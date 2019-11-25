# System Administration

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
