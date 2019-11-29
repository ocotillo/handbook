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

## Configuring git for a new user account

We use GitHub Personal Access Tokens coupled with HTTPS push to synchronize changes on the instrument. Configuration is required for your credentials to be remembered.

1. Log in to the computer (AOC, RTC, ICC, vm, etc) where you want to configure git
2. Change directories to a repository (e.g. `cd /opt/MagAOX/calib`) and verify it is set up for HTTPS push:
   ```
   $ cd /opt/MagAOX/calib
   $ git remote -v
   origin	https://github.com/magao-x/calib.git (fetch)
   origin	https://github.com/magao-x/calib.git (push)
   ```
3. If you haven't already for this machine, configure your name and email address:
   ```
   $ git config --global user.email "youremailusernamehere@youremaildomainhere.com"
   $ git config --global user.name "Your Name Here"
   ```
4. Configure the 'store' credential helper, which will store your credentials so you do not have to re-enter them:
   ```
   $ git config --global credential.helper store
   ```
5. Create (or retrieve from your password manager) a GitHub Personal Access Token. If you don't have one, log in to GitHub and visit [https://github.com/settings/tokens](https://github.com/settings/tokens).
6. Attempt to push, and enter/paste your username and **personal access token as password**:
   ```
   $ git push
   Username for 'https://github.com/magao-x/calib.git': your-github-user-name
   Password for 'https://your-github-user-name@github.com/magao-x/calib.git':
   ```
   (Note that even if you don't see it, your key is being entered.)
7. Attempt to push again. You should not be prompted for credentials a second time.
