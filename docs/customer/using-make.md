# TNMS 9.1 on RHEL 8 — install with make

Run this page after [pre-install.md](pre-install.md) sections 2 through 4. Those sections build the disk. This page copies six files to the server and runs `make`. `make` checks the disk, then installs Oracle 19c and TNMS 9.1.0.593.0 Server and Mediation on one Small Plus machine.

Copy the six files onto the server. A clone of this repository is not required there. `/home` is about 1 GB, so the files go to `/tmp`, then `make` moves them onto the 1 TB volume.

[install-without-repo.md](install-without-repo.md) describes what each target changes. Follow this page for the commands. Leave the manual GUI section in that file unused. `make` runs the wizard script. Running the GUI as well installs a second time.

Run the commands as root from section 4 on. The prompt ends with `#`. A line that says **Confirm by running** is a separate command. Run that command. The next **Expected output** block is what that command should print. A work command that prints nothing is finished when the shell prompt returns. Sizes move with the disk.

## 1. Confirm the disk

`make` stops before it creates a directory when this layout is missing. The fix is in [pre-install.md](pre-install.md) sections 2 through 4. Finish those sections, then return here.

**Confirm by running:**

```bash
for p in / /home /opt /nokia /oradata /tmp; do findmnt -n -o SOURCE,FSTYPE,TARGET "$p"; done
swapon --show
stat -c '%C %n' /opt /opt/tnms-data /opt/oradata /opt/swapfile
grep -E '^[^#].*(/opt|/nokia|/oradata|swapfile)' /etc/fstab
```

**Expected output:**

`/` , `/home`, and `/tmp` are `rootvg` volumes. `/opt` is `/dev/mapper/datavg-optlv`. `/nokia` and `/oradata` show that device with the directory in brackets. Swap is `/opt/swapfile` at 18G. The four paths are `usr_t`, except `/opt/swapfile`, which is `swapfile_t`. `/etc/fstab` has the `/opt` line, both binds, and the swap line.

```text
/dev/mapper/rootvg-rootlv xfs    /
/dev/mapper/rootvg-homelv xfs    /home
/dev/mapper/datavg-optlv  xfs    /opt
/dev/mapper/datavg-optlv[/tnms-data] xfs    /nokia
/dev/mapper/datavg-optlv[/oradata] xfs    /oradata
/dev/mapper/rootvg-tmplv  xfs    /tmp
NAME          TYPE SIZE USED PRIO
/opt/swapfile file  18G   0B   -2
system_u:object_r:usr_t:s0 /opt
system_u:object_r:usr_t:s0 /opt/tnms-data
system_u:object_r:usr_t:s0 /opt/oradata
system_u:object_r:swapfile_t:s0 /opt/swapfile
```

An empty line for `/nokia` or `/oradata` means stop. `make` will refuse the same layout, and it will not partition a disk for you.

**Confirm by running:**

```bash
df -h / /tmp
```

**Expected output:**

`/` is about 8G with several GB free. `/tmp` is 16G with at least 12G free. The three zip files are about 11 GB together, and they land in `/tmp` in the next section.

## 2. Gather the six files on the workstation

Use one directory on the workstation. These are the file names `make` looks for.

- `Makefile`
- `install-tnms-wizard.sh`
- `tnms-install.properties.in`
- `LINUX.X64_193000_db_home_and_patches.zip` (about 4.7 GB)
- `TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip` (about 86 MB)
- `TNMS_LUX_R9.1.0.593.0_1904.zip` (about 5.7 GB)

On a workstation that has this repository, the three small files are `scripts/Makefile`, `scripts/install-tnms-wizard.sh`, and `scripts/tnms-install.properties.in`. Copy those three into the directory with the zip files. The zip files are not in the repository.

Leave `tnms-install.properties.in` unchanged. It still contains seven `@TNMS_IP@` placeholders. The wizard fills those on the server.

## 3. Copy the six files to `/tmp`

From that workstation directory, replace `<user>` and `<server-ip>` with the SSH account and the address you use to log in. On this image the account is `azureuser`. That address may be a public address. It is not the value `make` writes into `/etc/hosts`. Section 5 is where the server address is set.

```bash
scp Makefile install-tnms-wizard.sh tnms-install.properties.in \
  LINUX.X64_193000_db_home_and_patches.zip \
  TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip \
  TNMS_LUX_R9.1.0.593.0_1904.zip \
  <user>@<server-ip>:/tmp/
```

`Permission denied` or `No such file` means stop and fix the path. A zip that arrives a few kilobytes long is incomplete. Copy it again.

On the server:

**Confirm by running:**

```bash
ls -lh /tmp/Makefile /tmp/install-tnms-wizard.sh /tmp/tnms-install.properties.in \
  /tmp/LINUX.X64_193000_db_home_and_patches.zip \
  /tmp/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip \
  /tmp/TNMS_LUX_R9.1.0.593.0_1904.zip
df -h /tmp
```

**Expected output:**

Six files. `Makefile` is about 45 KB. The wizard and the properties file are about 5 KB each. The Oracle zip is about 4.7G, the prerequisites zip is about 86M, and the TNMS zip is about 5.7G. `/tmp` still has space free.

## 4. Install `make`

Log in as the SSH user, then open a root shell. Every command after this one runs in that shell.

```bash
sudo -i
```

**Expected output:**

The prompt ends with `#`.

```bash
dnf -y install make tmux
```

**Expected output:**

The command ends with `Complete!`. A second run ends with `Nothing to do.`

`tmux` keeps the install alive if the SSH session drops. A dropped session during Oracle or the wizard is not a safe place to start over. Those two steps run only when the product is absent, and a half-written database stops the next attempt.

```bash
tmux new -s tnms
```

The window looks the same, with a status bar. Detach with `Ctrl-b` then `d`. The install keeps running. Log in again and return with:

```bash
sudo -i
tmux attach -t tnms
```

**Confirm by running:**

```bash
make -C /tmp -f Makefile help
```

**Expected output:**

The first line is:

```text
TNMS 9.1 install. Run as root after pre-install.md sections 2 through 4.
```

The install targets listed are `stage host packages kernel disk unpack credentials oracle wizard lsmem sftp sudo service check`.

## 5. Set site values before the first run

The defaults apply when you do not set them.

| Variable | Default | Role |
| --- | --- | --- |
| `TNMS_HOSTNAME` | `TNMS` | Short hostname. The `host` target renames the server to this. |
| `TNMS_IP` | detected | IPv4 written into `/etc/hosts` and into the product. Empty uses the address on the NIC from the default route. |
| `TNMS_ADMIN_GROUP` | `azureuser` | Group on `/opt/tnms-install`. The group must already exist. |
| `TNMS_SID` | `TNMS` | Oracle SID |
| `SYS_PASSWORD` | `TnZT5hgW8Zwsp79` | Oracle `SYS` |
| `SYSTEM_PASSWORD` | `TnZT5hgW8Zwsp79` | Oracle `SYSTEM`. Same value as `SYS`. |
| `TNMSDBA_PASSWORD` | `Tnc25xQ36XBUa9` | Database login `tnmsdba` |
| `TNMS_SFTP_PASSWORD` | `Tsvb5-Xe8ou3wR9` | OS account `tnms_sftp` |

`SYS`, `SYSTEM`, and `tnmsdba` use 6 to 30 characters from `a-z`, `A-Z`, `0-9`, and `+ - _ { }`. `tnmsdba` is a different value from `SYS`. The SFTP password is separate again.

A public address used only for SSH is the wrong `TNMS_IP` unless that address is configured on the server NIC. Leave `TNMS_IP` unset to keep the detected NIC address.

Write `/root/tnms-install.local.mk` only for a value that differs from the table. Omit a line to keep its default. Set passwords here before `credentials` runs. A later change does not replace `/root/tnms-db-credentials` once that file exists.

```bash
cat > /root/tnms-install.local.mk << 'EOF'
TNMS_HOSTNAME = TNMS
EOF
chmod 600 /root/tnms-install.local.mk
```

That example keeps the default name and shows the file format. Skip both commands when every default is the site value.

`make` also reads `/root/tnms-install.answers` when that file exists. On a new server the file is absent.

## 6. Read the server before changing it

```bash
make -C /tmp -f Makefile status
```

**Expected output:**

A `storage:` block, then one line for each condition. Match the device names. The sizes below are one example, and the free column moves. Before the install, product conditions print `MISSING` and the command exits non-zero. That report is what an unfinished server looks like.

```text
storage:
  /          /dev/mapper/rootvg-rootlv                    8.0G     7.9G free
  /tmp       /dev/mapper/rootvg-tmplv                      16G      16G free
  /home      /dev/mapper/rootvg-homelv                   1014M     941M free
  /opt       /dev/mapper/datavg-optlv                     1.0T    1017G free
  /nokia     /dev/mapper/datavg-optlv[/tnms-data]         1.0T    1017G free
  /oradata   /dev/mapper/datavg-optlv[/oradata]           1.0T    1017G free
  swap       /opt/swapfile                                 18G
preflight        ok
stage            MISSING
makefile         not-installed
host             MISSING
```

The free column moves. `makefile` prints `not-installed` until `stage` copies the Makefile. Stamp lines print `absent`.

Stop when any of these is true:

- `/opt` is not `/dev/mapper/datavg-optlv`, or its size is under 100 GB.
- `/nokia`, `/oradata`, or `swap` prints `missing`.
- `preflight` prints `MISSING`. Read the line above it. The usual causes are a shell that is not root, a missing `TNMS_ADMIN_GROUP`, SELinux not `Enforcing`, or a system that is not Red Hat Enterprise Linux 8.

`MISSING` on `stage`, `host`, `packages`, `kernel`, `unpack`, `credentials`, `oracle`, `wizard`, `lsmem`, `sftp`, `sudo`, or `service` is expected here. Those are the steps the next command runs.

## 7. Run the install

Stay inside the `tmux` session from section 4.

```bash
make -C /tmp -f Makefile
```

That command is the whole install. The default goal runs each target that is not done, then runs the checks. Leave the session attached, or detach with `Ctrl-b` then `d`. Reattach with `tmux attach -t tnms`. Closing the SSH window without detaching can deliver `SIGHUP` to `make`.

`stage` copies the six files to `/opt/tnms-install` and deletes the `/tmp` copies while this command is still running. This `make` already read `/tmp/Makefile`, so it continues. A later command uses `/opt/tnms-install`, because `/tmp/Makefile` is gone.

On the reference host, Oracle took about 23 minutes and the wizard took about 27 minutes. The service target waits up to 3 minutes for port 8444.

Headings mark each target:

```text
=== stage: directories, media, and modes ===
=== host: hostname, hosts, and locale ===
=== packages ===
=== kernel: sysctl and firewall ===
=== unpack ===
=== credentials ===
=== oracle ===
=== wizard ===
=== lsmem ===
=== sftp ===
=== sudo ===
=== service ===
=== check ===
```

`stage` ends with `stage: done`. The wizard script and the properties file are in `/opt/tnms-install`. The three zip files are in `/opt/tnms-install/resources`. `/opt/tnms-install/Makefile` is the file later commands use.

`oracle` may print `Error checking requirements.` on a 16 GB server. The memory check wants 32 GB, and silent mode continues. The target ends with `oracle: done`.

`wizard` may print this SQL statement and still finish:

```text
alter system set "_bug33046179_kqr_hot_copy_sleep_limit"=0
```

Oracle returns `ORA-02065: illegal option for ALTER SYSTEM`. The finished line is:

```text
TNMS wizard finished. Installer exit <n>. Product files are present, scs_daemon is enabled, and configure scripts exited 0.
```

`<n>` may be 255. The target then ends with `wizard: done`. A line that says `TNMS wizard failed` means stop. Read `/root/tnms-wizard.log`. Leave the wizard script unstarted until that failure is understood.

`sftp` restarts `sshd` when it changes `/etc/ssh/sshd_config`. The SSH session can drop. Log in again, open the root shell, and reattach:

```bash
sudo -i
tmux attach -t tnms
```

The last line of a finished install is:

```text
check: ok
```

## 8. When a target stops

The last lines name the target and the requirement. Fix that requirement. Targets that already printed `done` have a stamp in `/var/lib/tnms-install/`. The next run skips them.

```bash
make -C /opt/tnms-install
```

Use that form after `stage: done`. Use `make -C /tmp -f Makefile` only when `/tmp/Makefile` is still there.

These two messages mean stop, and a second `make` will stop in the same place:

- `oracle: <SID> is already in /etc/oratab but the success log does not match. installation.sh was not started.`
- `TNMS wizard failed`

Read the log named in the message. Do not delete `/var/lib/tnms-install/oracle` or `/var/lib/tnms-install/wizard` to force another install. `installation.sh` and the wizard script run only when the product is absent.

**Confirm by running:**

```bash
make -C /opt/tnms-install status
```

**Expected output:**

Each finished condition prints `ok`. Its stamp prints `present`. A condition that still has work prints `MISSING`, and the command exits non-zero. `status` only reads the server.

To run through one target and stop, name it. The targets before it run when their stamps are absent.

```bash
make -C /opt/tnms-install oracle
```

The names, in order, are `stage`, `host`, `packages`, `kernel`, `unpack`, `credentials`, `oracle`, `wizard`, `lsmem`, `sftp`, `sudo`, `service`, `check`.

`make -C /opt/tnms-install disk` only reads the disk. It does not install.

## 9. Confirm the finished install

**Confirm by running:**

```bash
make -C /opt/tnms-install status
make -C /opt/tnms-install check
```

**Expected output:**

`status` ends with `status: install conditions match`. `check` ends with `check: ok`. A second `make -C /opt/tnms-install` skips work that is done and ends with `check: ok` again.

**Confirm by running:**

```bash
hostname --fqdn
grep TNMS /etc/oratab
systemctl is-active scs_daemon
ss -ltn | grep -E '[:.]1521[[:space:]]|[:.]8444[[:space:]]'
curl -k -sI --max-time 5 https://127.0.0.1:8444
```

**Expected output:**

`hostname --fqdn` prints the short name, a dot, and the `search` domain from `/etc/resolv.conf`. `oratab` contains `TNMS:/opt/oracle/product/19c/dbhome_1:Y`. `scs_daemon` is `active`. `ss` shows listeners on 1521 and 8444. `curl` shows `HTTP/1.1 301`, a location under `/tnms-webclient`, and `Server: openresty`.

The database passwords are in `/root/tnms-db-credentials`, mode 600. The SFTP password is in that file after `sftp` finishes.

## 10. Open the client

Allow inbound TCP 8444 on the security group in front of the server. `make` does not change that group.

| Client login | Value |
| --- | --- |
| Username | `Administrator` |
| Password | `e2e!Net4u#` |
| Address | `https://<reachable-address>:8444/tnms-webclient` |
| Port | TCP `8444` |

`<reachable-address>` is an address that can open TCP 8444, which may be the public address. The browser warns about the certificate. Continue past that warning.

The first login asks for a new password. Use at least 8 characters, with two letters and one number, and change at least 3 characters from `e2e!Net4u#`. Keep the username out of the new password, and keep any run of letters or digits to 3.

In the TNMS client, set the SFTP path to `/tnms/nedata` with nothing in front of `/tnms`. FTP stays off.

The first install runs for 90 days on a trial license. License keys after that, and the Windows client, are separate procedures.

`make` does not reboot the server. To prove the disk layout survives a reboot, reboot after `check: ok`, log in, and run section 9 again.
