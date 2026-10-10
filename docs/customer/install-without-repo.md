# TNMS 9.1 on RHEL 8 — install without this repository

Run this on a fresh Red Hat Enterprise Linux 8 server, as root, after [pre-install.md](pre-install.md). That guide mounts the 1 TB disk on `/opt`. This one installs Oracle 19c and TNMS 9.1.0.593.0 Server and Mediation.

One machine. Small Plus. TNMS Server and Mediation together. New database.

The procedure is [scripts/Makefile](../../scripts/Makefile). The server does not need this git repository. Copy the Makefile to the server with the wizard files and run it there.

Names and addresses below are this host. Replace them with the site values by setting the variables in the next section. Sizes move with the disk.

## Before you start

Gather these six files in one directory on the workstation. The three zip files are not in this repository.

- `Makefile`
- `install-tnms-wizard.sh`
- `tnms-install.properties.in`
- `LINUX.X64_193000_db_home_and_patches.zip`
- `TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip`
- `TNMS_LUX_R9.1.0.593.0_1904.zip`

`/tmp` on the server is the 16 GB filesystem. The zip files are about 11 GB together. `/home` is about 1 GB, so leave these files out of `/home`.

```bash
scp Makefile install-tnms-wizard.sh tnms-install.properties.in \
  LINUX.X64_193000_db_home_and_patches.zip \
  TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip \
  TNMS_LUX_R9.1.0.593.0_1904.zip \
  <user>@<server-ip>:/tmp/
```

`<user>` is the SSH account. `<server-ip>` is the server address. `Permission denied` or `No such file` means stop and fix the path.

On the server, as root:

```bash
dnf -y install make
make -C /tmp -f Makefile
```

`make` reads the file before `stage` removes the `/tmp` copies, then continues from `/opt/tnms-install`. A later run can use `make -C /opt/tnms-install`.

`make status` only reads the host. It prints `ok` or `MISSING` for each condition and does not install, restart, or write a stamp. Stamps live in `/var/lib/tnms-install/`. A missing stamp does not by itself repeat Oracle or the TNMS wizard. Those two commands run only when the product is absent.

`make help` lists the targets. `make check` is the default goal: it finishes any target that is not done, then runs the checks at the end of this page.

These stay outside `make`:

- The disk layout in [pre-install.md](pre-install.md). The first recipe stops unless `findmnt` shows `/opt` on `/dev/mapper/datavg-optlv`.
- The `scp` above. The zip files are not in the repository, so there is no `make push`.
- The Azure security group for TCP 8444.
- The first client password change after login.
- License keys, the Windows client, and the manual GUI path at the bottom of this page.

## Variables

Set these on the `make` command line or in `/root/tnms-install.local.mk`. The defaults are this host.

| Variable | Default | Role |
| --- | --- | --- |
| `TNMS_HOSTNAME` | `TNMS` | Short hostname |
| `TNMS_IP` | detected | Server IPv4. Empty uses the same route lookup as the wizard. |
| `TNMS_ADMIN_GROUP` | `azureuser` | Group on `/opt/tnms-install`, and the SSH account name in the sftp check |
| `TNMS_SID` | `TNMS` | Oracle SID |
| `SYS_PASSWORD` | `TnZT5hgW8Zwsp79` | Oracle `SYS` |
| `SYSTEM_PASSWORD` | `TnZT5hgW8Zwsp79` | Oracle `SYSTEM`. Same value as `SYS`. |
| `TNMSDBA_PASSWORD` | `Tnc25xQ36XBUa9` | Database login `tnmsdba` |
| `TNMS_SFTP_PASSWORD` | `Tsvb5-Xe8ou3wR9` | OS account `tnms_sftp` |

The hosts line uses `TNMS_IP` and the `search` domain from `/etc/resolv.conf`. The FQDN is first, then the short name.

Password rule used for `SYS`, `SYSTEM`, and `tnmsdba`: 6 to 30 characters from `a-z`, `A-Z`, `0-9`, and `+ - _ { }`. `tnmsdba` is a different value from `SYS`. The SFTP password is separate again.

`make` writes the database passwords into `/root/tnms-db-credentials` at mode 600. If that file already exists and a password differs, `make` stops and leaves the file in place. Leave `tnms-install.properties.in` unchanged. The wizard writes the server IPv4 into a separate response file, `/root/tnms-install.properties`.

## TNMS client login

Use this login in the browser and in the TNMS client.

| Client login | Value |
| --- | --- |
| Username | `Administrator` |
| Password | `e2e!Net4u#` |
| Address | `https://<server-ip>:8444/tnms-webclient` |
| Port | TCP `8444` |

The first login asks for a new password. Use at least 8 characters, with two letters and one number, and change at least 3 characters from `e2e!Net4u#`. Keep the username out of the new password, and keep any run of letters or digits to 3.

Allow inbound TCP 8444 on the security group in front of the server. The browser warns about the certificate. Continue past that warning.

## Values used on this host

| Item | This host |
| --- | --- |
| OS | Red Hat Enterprise Linux 8.10 |
| Short hostname | `TNMS` |
| Server IPv4 | `172.16.0.4` |
| Oracle SID | `TNMS` |
| Listener | `LISNER` on port 1521. The installer chooses this name. |
| Oracle home | `/opt/oracle/product/19c/dbhome_1` |
| ORADATA | `/oradata` with `ora1`, `ora2`, `ora3` |
| TNMS install directory | `/opt/nokia/tnms` |
| TNMS data directory | `/nokia/tnms` |
| OS user / group | `tnms` / `tnms` |
| SFTP user | `tnms_sftp` |
| Database OS user | `oracle`, groups `oinstall` and `dba` |
| Database login user | `tnmsdba` |
| Large disk | `/opt` on `datavg/optlv`, the 1 TB volume |
| Install files | `/opt/tnms-install` |
| Media directory | `/opt/tnms-install/resources` |

## Targets

`make` runs the targets below in order. Each one checks the result before it writes its stamp. Run one target with `make -C /opt/tnms-install <target>` after the Makefile is on `/opt`.

### stage

Creates `/opt/oracle`, `/opt/nokia`, `/opt/tnms-data`, `/opt/oradata/ora1`, `/opt/oradata/ora2`, and `/opt/oradata/ora3` at mode 755, root:root. Creates `/opt/tnms-install` and `/opt/tnms-install/resources` at mode 750, root:`TNMS_ADMIN_GROUP`. Copies the wizard to mode 740 and the properties file and zip files to mode 640. `grep -c @TNMS_IP@` must print 7. The properties file must still set `USER_INSTALL_DIR`, `USER_INSTALL_DIR_TMP`, `USER_DATA_DIR`, `ORACLE_INSTALL_DIR`, and `ORACLE_DATA_DIR`.

`restorecon` runs on those `/opt` directories. It does not run on the `/nokia` or `/oradata` bind mounts.

Skips the copy when that layout already matches. Mode 751 on `/opt/tnms-install` still counts as a match: `oracle` adds `o+x` so the `oracle` user can read `TNMS.rsp`. A later `stage` leaves that bit in place once `/etc/oratab` contains the SID. Putting the directory back to 750 makes `installation.sh` stop with `[INS-10101]`.

### host

Sets the short hostname, `preserve_hostname: true`, `LANG=en_US.UTF-8`, and the address line in `/etc/hosts`. Confirms `hostname --fqdn`, `getent -s files hosts`, and that `nisdomainname` is unset. `getent hosts` without `-s files` returns the IPv6 link-local address. That result is not the check.

Skips when those values already match. If `/etc/hosts` already names the short hostname with a different address or order, `host` stops and does not append a second line.

### packages

Installs EPEL and the package set Oracle and TNMS check: `attr`, `bc`, `elfutils-libelf-devel`, `fontconfig-devel`, `gcc`, `gcc-c++`, `jemalloc`, `ksh`, `libaio`, `libaio-devel`, `libnsl`, `libXtst`, `libzip`, `make`, `psmisc`, `sysstat`, `unzip`, `perl`, `binutils`, and `glibc-devel`.

Skips when `rpm -q` already finds all of them.

### kernel

Writes `/etc/sysctl.d/99-tnms.conf` with `vm.swappiness = 1`, `vm.dirty_ratio = 15`, `vm.dirty_background_ratio = 3`, and `vm.min_free_kbytes = 1048576`, then runs `sysctl --system`. Stops and disables firewalld. `chronyd` must already be active. This target does not start it and does not change its NTP pool.

Skips when the sysctl file, the live values, firewalld, and chronyd already match.

### disk

Read-only. Confirms `/opt` is `datavg-optlv`, `/tmp` is not `noexec` and is at least 16 GB, swap is the 18 GB file `/opt/swapfile`, and `/nokia` and `/oradata` are the binds from `/opt/tnms-data` and `/opt/oradata`.

Before `/opt/nokia/tnms/server` exists, `/` must have about 4531 MB free. `TNMS.bin` measures free space on `/` and stops when it is short. After the product directory exists, that free-space gate is skipped because the copy has already used the space.

### unpack

Runs `unzip -t` on the three zip files and stops unless the test prints `No errors detected`. Unpacks Oracle under `/opt/oracle/oramedia`, the prerequisites under `/opt/tnms-install/prereq`, and TNMS under `/opt/tnms-install/installer`. Sets `TNMS.bin` to mode 744 and the Oracle shell scripts executable.

Skips when `TNMS.bin` is mode 744, `installation.sh` is executable, and the four Oracle zip names are present in `/opt/oracle/oramedia`.

The shorter Oracle zip of about 3.7 GB, with no end-of-archive record, is incomplete. `TNMS_WIN_R9.1.0.593.0_1904.zip` is the Windows client and is not part of this server install. `PUs/` in the Linux package was empty on this host, so no PDT zip was copied. The RHEL 9 script `verify_prerequisites_tnms.sh` is not run.

### credentials

Creates `/root/tnms-db-credentials` at mode 600 with `SYS_PASSWORD`, `SYSTEM_PASSWORD`, and `TNMSDBA_PASSWORD`. The SFTP password is added later by `sftp`.

Skips the write when the three values already match. A different value stops the target.

### oracle

Gives other users execute permission on `/opt/tnms-install`, then runs `installation.sh` in silent Small Plus mode. On a 16 GB server the log includes `Error checking requirements.` because the memory check wants 32 GB. With `-silent_mode=Y` the script continues. Success is exit 0 and `Final status of the execution: Success` in the newest log under `/home/oracle/ossnms_installation_log/`. The run on this host took about 23 minutes.

The listener name is `LISNER` on port 1521. `/etc/oratab` should contain `TNMS:/opt/oracle/product/19c/dbhome_1:Y`.

Skips `installation.sh` when that oratab line and the success log are already present. A SID that is present without the success log stops the target. A second `installation.sh` would be a new database install. `patch.sh` stays unrun. The later patch zips are not in this media.

If user `oracle` does not exist yet, the read test of `TNMS.rsp` is skipped. `installation.sh` creates that user. The directory is already `o+x`, which is what avoids `[INS-10101]`.

### wizard

Runs `/opt/tnms-install/install-tnms-wizard.sh`. The script fills the server IPv4 into `/root/tnms-install.properties`, installs a temporary `lsmem` wrapper when the host has less than 32 GB, and removes the wrapper before it exits. Small Plus refuses to continue until `lsmem --summary` reports at least 32G. Do not edit `/usr/bin/lsmem` by hand.

On this 19.7 database the script keeps one known SQL error and still exits 0:

```text
alter system set "_bug33046179_kqr_hot_copy_sleep_limit"=0
```

Oracle returns `ORA-02065: illegal option for ALTER SYSTEM`. The finished line is:

```text
TNMS wizard finished. Installer exit <n>. Product files are present, scs_daemon is enabled, and configure scripts exited 0.
```

`<n>` may be 255. A line that says `TNMS wizard failed` means stop. Read `/root/tnms-wizard.log`. Do not start the script a second time until that failure is understood.

Skips the script when `/opt/nokia/tnms/server` already exists. The script refuses that second install itself. The target then checks that `scs_daemon` is enabled and that `/nokia/tnms/trace/system/install/system_configure.log` finished with each configure script exiting 0. The run on this host was 02:59 to 03:26 UTC.

The choices are TNMS Server and Mediation, Small Plus, a new database, users `tnms` / `tnms` / `tnms_sftp` / `oracle`, directories from the properties file, managers Ethernet, ASON, Optical, and Optical Spectrum Insight, and network element EM-MVM / Generic SNMP. Transport Controller, ZTC, frontend servers, and northbound interfaces stay off.

`make wizard` passes `--ip` when `TNMS_IP` is set. Otherwise the script detects the address.

To see the response file without starting `TNMS.bin`:

```bash
/opt/tnms-install/install-tnms-wizard.sh --dry-run
```

### lsmem

If `/usr/bin/lsmem.real` still exists, moves it back over `/usr/bin/lsmem`. The wizard script does this before it exits. This target is the check that a failed run did not leave the wrapper in place.

Passes when `/usr/bin/lsmem` is the ELF binary and `lsmem.real` is absent. The summary then shows the real RAM, 16G on this host.

### sftp

Sets the `tnms_sftp` password when `passwd -S` is not already `PS`, appends `TNMS_SFTP_PASSWORD` to `/root/tnms-db-credentials` when the line is absent, sets the shell to `/sbin/nologin`, and sets `/nokia` to mode 755, root:root. `tnms` stays locked.

Comments the external `sftp-server` subsystem, sets `Subsystem sftp internal-sftp`, and appends `Match User tnms_sftp` with `ChrootDirectory /nokia`, `ForceCommand internal-sftp`, and `PasswordAuthentication yes` inside that block only. The global `PasswordAuthentication no` line stays as the image shipped it. `sshd -t` must pass before the file is replaced. sshd restarts only when the file changed.

Skips when the shell, password, credentials line, `/nokia` mode, Match block, and `sshd -T` output already match. An incomplete Match block stops the target and does not append a second one.

In the TNMS client, after a client can log in, set the SFTP path to `/tnms/nedata` with nothing in front of `/tnms` (System Preferences, External Communications, and NE Properties). FTP stays off.

### sudo

Copies `/opt/nokia/tnms/system/install/resources/system/tnms_sudo` to `/etc/sudoers.d/tnms_sudo`, mode 440, root:root. `visudo -cf` must print `parsed OK`. `sudo -l -U tnms` includes the `scs_daemon` commands.

Skips when that check already passes.

### service

Runs `restorecon -RF /opt/nokia` so `scs_daemon` is `bin_t`. It does not relabel `/opt/oracle` while the database is open, and it does not relabel the `/nokia` or `/oradata` bind mounts. Starts `scs_daemon` when it is inactive. Waits up to 3 minutes for TCP 8444 and for `curl -k` to return `301` to `/tnms-webclient` from openresty.

The service can report `active` about a minute before the port opens. A start that fails with `status=203/EXEC` means the `bin_t` label is missing.

## Checks

`make check` runs these commands after the service is up. The same conditions are part of `make status`.

| Check | Expected |
| --- | --- |
| `hostname --fqdn` | the site FQDN |
| `grep TNMS /etc/oratab` | `TNMS:/opt/oracle/product/19c/dbhome_1:Y` |
| `ss -ltn` for 1521 | listener on 1521 |
| newest `oracle_installation_*.log` | `Final status of the execution: Success` |
| `lsmem --summary` | the real RAM, and `/usr/bin/lsmem` is the ELF binary |
| `. /etc/profile.d/ossnms.sh` | returns with no error |
| `passwd -S tnms` | locked |
| `getent passwd tnms_sftp` | shell `/sbin/nologin` |
| `sudo -l -U tnms` | the SCS commands |
| `systemctl is-active scs_daemon` | `active` |
| `ss -ltn` for 8444 | a `LISTEN` line |
| `curl -k -sI https://127.0.0.1:8444` | 301 to `/tnms-webclient` |

`db_setup.sh` exit 2 with the single `ORA-02065` above is the known result on this 19.7 database. The creation summary is OK and `configure_system.sh` exits 0.

Left out of this install: Frontend Server, eDNA, Node Manager, a separate mediation machine, hot standby, Transcend Controller, ZTC, northbound interfaces, FTP, the SHA-1 crypto policy, DSA host keys, and `patch.sh`.

The first install runs for 90 days on a trial license. License keys after that, and the Windows client, are separate procedures.


## What happened on this host

2026-10-08. RHEL 8.10, kernel `4.18.0-553.134.1.el8_10.x86_64`, 8 vCPU, 16 GB RAM. `installation.sh` finished at 02:46 UTC with Success. The TNMS wizard ran from 02:59 to 03:26 UTC, `configure_system.sh` exited 0, and NGINX answered on 8444 at 03:37 UTC. With the stack up, available memory was a few hundred MB and swap use was about 3.5 GB. No OOM kill was recorded, and `ora_pmon_TNMS` stayed up.

## Manual step 9: two SSH sessions

`make` does not run this section. The `wizard` target runs `/opt/tnms-install/install-tnms-wizard.sh`.

> **Use this section only to configure the wizard yourself, remotely, with two SSH sessions.** The `wizard` target runs `/opt/tnms-install/install-tnms-wizard.sh` and does not use these commands. Do not run the script and this section on the same server. If `/opt/nokia/tnms/server` already exists, the wizard has already been installed.

`TNMS.bin` rejects `-i console`. The SSH session has no monitor, so the GUI runs on a virtual screen. You keep two SSH sessions open on the server, and a third window on the workstation that is not logged into the server. The first SSH session runs the installer and sits with no prompt. The second SSH session takes each picture. The workstation window downloads the picture so you can see the page.

On a server where `lsmem --summary` reports less than 32G, install this wrapper before the commands below. The `wizard` target is not doing it for you on this path. Remove the wrapper after the first SSH session returns, as shown at the end of this section. On a server that already reports 32G or more, skip the wrapper.

```bash
mv /usr/bin/lsmem /usr/bin/lsmem.real
cat > /usr/bin/lsmem << 'EOF'
#!/bin/bash
if [[ "$*" == *summary* ]]; then
  echo "Memory block size:       128M"
  echo "Total online memory:      32G"
  echo "Total offline memory:      0B"
  exit 0
fi
exec /usr/bin/lsmem.real "$@"
EOF
chmod 755 /usr/bin/lsmem
```

`mv`, `cat`, and `chmod` print nothing.

**Confirm by running:**

```bash
lsmem --summary
```

**Expected output:**

```text
Memory block size:       128M
Total online memory:      32G
Total offline memory:      0B
```

Start the virtual screen in the first SSH session:

```bash
dnf -y install xorg-x11-server-Xvfb dejavu-sans-fonts
```

**Expected output:**

The command ends with:

```text
Complete!
```

```bash
mkdir -p /tmp/tnms-gui
chmod 1777 /tmp/tnms-gui
```

Those commands print nothing.

```bash
Xvfb :99 -screen 0 1400x900x24 -ac +extension GLX +render -noreset >/tmp/tnms-gui/xvfb.log 2>&1 &
```

The `&` returns a job number and leaves Xvfb running.

```bash
export DISPLAY=:99
export LANG=en_US.UTF-8
```

Those commands print nothing.

**Open a second SSH session before the next command.** `./TNMS.bin` does not return until the wizard exits. The SSH window that starts it sits there with no prompt. From the workstation, open a new SSH connection to this same server and log in as root. That new connection is the second shell. Leave both connections open. Do not type in the first one, and do not close it. Every check and every screenshot below runs in the second shell. Keep a third window on the workstation, a terminal that is not logged into the server. That third window is only for downloading each picture.

```bash
cd /opt/tnms-install/installer/TNMS_Installer
./TNMS.bin -i gui -r /root/tnms-install.properties -tempdir /tmp/tnms-gui
```

Run that command in the first SSH session. The installer window title is `TNMS 9.1.0.593.0 Installer`. The prompt in that session does not come back until the wizard exits.

**Confirm by running,** in the second SSH session, before answering screens:

```bash
ps -C Xvfb -o args=
```

**Expected output:**

```text
Xvfb :99 -screen 0 1400x900x24 -ac +extension GLX +render -noreset
```

This command does not open the installer. It prints the command line of the virtual screen, with no column heading. Read the line as follows:

- `Xvfb` is the virtual screen. It is a screen held in memory. No monitor is attached to it.
- `:99` is the name of that screen. `export DISPLAY=:99` is the line that sent the installer there. The installer window is drawn on `:99`.
- `-screen 0 1400x900x24` is one screen, 1400 by 900 pixels, 24-bit color. The wizard fits inside that rectangle.
- `-ac` lets another program on this server read the screen. That is what makes the screenshot command below work.
- A line that matches means the screen is up. The shell redirection `>/tmp/tnms-gui/xvfb.log` and the `&` are absent here. Those belong to the shell that started Xvfb, and they are not part of the process command line.

Both SSH sessions show only text. The wizard is a picture on display `:99`. You see a page by saving that picture in the second SSH session, downloading the file to the workstation, and opening the file there. The numbered list below is the questions. The picture tells you which number you are on.

If `ps -C Xvfb -o args=` prints nothing, the virtual screen is not running. Start Xvfb again before `./TNMS.bin`.

Install the picture program once. In the second SSH session:

```bash
dnf -y install ImageMagick
```

**Expected output:**

The command ends with:

```text
Complete!
```

`dnf` installs `import`. It does not take a picture. Do not run `dnf` again.

**For every wizard page, use these three windows in this order.**

1. Second SSH session. Save the page and let the workstation read the file:

```bash
import -window root -display :99 /tmp/tnms-gui/screen.png
chmod 644 /tmp/tnms-gui/screen.png
```

Both commands print nothing.

**Confirm by running,** in the second SSH session:

```bash
ls -l /tmp/tnms-gui/screen.png
```

**Expected output:**

The line includes `-rw-r--r--` and `/tmp/tnms-gui/screen.png`. The size is not `0`.

2. Workstation terminal. This is the third window. It is on your computer, and it is not logged into the server. If the prompt is a prompt on the server, this is the wrong window. Download the picture. Use the site admin name and the site address. On this host:

```bash
scp azureuser@172.16.0.4:/tmp/tnms-gui/screen.png .
```

**Expected output:**

The transfer reaches `100%`. The workstation directory where you ran `scp` now contains `screen.png`. Each download replaces that file. Close the old picture before you open the new one, or the viewer can keep showing the previous page.

3. On the workstation, open `screen.png` in an image viewer. The picture is one wizard page. The title is `TNMS 9.1.0.593.0 Installer`. Read the words on the page. Find that same page in the numbered list below. The text under that number is the required answer.

Clicking the downloaded picture does nothing. The picture is only how you see the page. On this host the click or the typed value was sent with `xdotool` from the second SSH session, with `DISPLAY=:99`. The first SSH session stays inside `./TNMS.bin` and is not where answers are typed.

After the answer, start again at action 1. Download the new picture and open it. The new picture must show the next page before you use the next number. If it shows the same page, the answer did not land. Send the answer again, then take another picture.

Stop when the first SSH session returns to a shell prompt.

The pages, in order:

1. License. Accept the terms.
2. PDT warning (`Check for available PDTs`, folder `TNMS_Installer/PUs`). Dismiss it when `PUs/` is empty.
3. Installation package. **TNMS Server and Mediation**.
4. Transport Controller. Leave it unchecked. Ports 12443 and 12351 stay unused.
5. Hardware. **Small Plus**. The page opens on Medium.
6. Customization. Leave **Users And Groups** and **Deployment Directories** unchecked. The defaults are user `tnms`, group `tnms`, SFTP user `tnms_sftp`, Oracle user `oracle`, DBA group `dba`, install directory `/opt/nokia/tnms`, data directory `/nokia/tnms`.
7. Database. **New**.
8. Connection. Host `127.0.0.1`, port `1521`, user `tnmsdba`, SID `TNMS`, Oracle home `/opt/oracle/product/19c/dbhome_1`. The password field labeled for user `sys` is `TnZT5hgW8Zwsp79`. The `tnmsdba` password is `Tnc25xQ36XBUa9`.
9. Advisory message. Leave it disabled.
10. Managers. Check Ethernet Manager, ASON Manager, Optical Manager, and Optical Spectrum Insight. Leave ZTC Manager unchecked.
11. Frontend servers. Add none.
12. Northbound interfaces. Check none.
13. Network elements. Under EM-MVM, check Generic SNMP only.
14. Summary. Confirm the rows below, then **Install**.

| Summary row | Value |
| --- | --- |
| Product | TNMS 9.1.0.593.0 |
| Install directory | `/opt/nokia/tnms` |
| Data directory | `/nokia/tnms` |
| Server IP | the site IPv4 (`172.16.0.4` here) |
| Set | Server and Mediation |
| Hardware | Small Plus |
| User / group | `tnms` / `tnms` |
| SFTP user | `tnms_sftp` |
| Database | Build, Oracle user `oracle` |
| Managers | Ethernet, ASON, Optical, Optical Spectrum Insight |
| Network elements | EM-MVM / Generic SNMP |

A picture can also show a dialog that is not one of those 14 pages. Use the same three windows for it: save, download, open, then answer. If a firewall warning appears, firewalld is still running. Stop it and continue. If the wizard says a user or group already exists, stop and remove only the name it prints. Leave `oracle` and `orabackup` in place.

The copy on this host then stopped on **Not Enough Disk Space** (4,530.80 MB required on `/opt/nokia/tnms`, 1,959.78 MB reported). That number is the free space of `/`. Step 4 is what clears it. After growing `rootlv` to 8 GB the next page was **Enough Disk Space**. **Install** was clicked again and the copy started.

When the progress reaches the end, a dialog titled **Installation fatal errors** says the installation finished with serious errors. Click **OK**. The result page names `Error in db_setup.sh`. Click **Done**. Done is what runs `configure_system.sh`. On this host that script exited 0 and registered `scs_daemon.service`.

That error is one statement in `/nokia/tnms/trace/system/install/sql/db_setup_TNMS_*.log`:

```text
alter system set "_bug33046179_kqr_hot_copy_sleep_limit"=0
```

Oracle 19.7 returns `ORA-02065: illegal option for ALTER SYSTEM`. The SQL tool continues, and the component creation summary (`/tmp/tnms-gui/ossnms/sql/creation_summary_TNMSDBA_*.log` when the wizard temp dir is `/tmp/tnms-gui`) shows each component `OK`. Keep the install when that is the only SQL error.

When the first SSH session returns to a prompt, put `lsmem` back if this section installed the wrapper:

```bash
mv -f /usr/bin/lsmem.real /usr/bin/lsmem
```

That command prints nothing. If `/usr/bin/lsmem.real` does not exist, the wrapper was not installed, so skip that command.

Then run the checks that start with `. /etc/profile.d/ossnms.sh`. Continue at `lsmem` to confirm `lsmem` is the real program, then `sftp`, `sudo`, `service`, and `check`.

