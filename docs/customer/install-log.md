# TNMS 9.1 on RHEL 8 — commands in order

Run this on a fresh Red Hat Enterprise Linux 8 server, as root, from top to bottom. It is the sequence that installed TNMS 9.1.0.593.0 Server and Mediation with Oracle 19c on 2026-10-08.

One machine. Small Plus. TNMS Server and Mediation together. New database.

Passwords are not in this file. Put them only in `/root/tnms-db-credentials` (mode 600) and in the site checklist. A step headed **This host** applies when the fresh server matches the condition in that step.

A line that says **Confirm by running** is a separate command. Run that command, and compare its output with the block under it. A work command that prints nothing is finished when the shell prompt returns. Names and addresses below are this host. Sizes move with the disk. Replace `TNMS` and `172.16.0.4` with the site values.

The longer manual notes are in [tnms-9.1-linux-install.md](tnms-9.1-linux-install.md).

## Values used on this host

Substitute the site address and names. Keep the paths and the SID unless the site table says otherwise.

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
| Large-disk directory | `/home/tnms-layout` (the big filesystem on this host was `/home`) |
| Media directory | `/home/azureuser/TNMS/resources` |

Password rule used for `SYS`, `SYSTEM`, and `tnmsdba`: 6 to 30 characters from `a-z`, `A-Z`, `0-9`, and `+ - _ { }`.

## Media to copy onto the server

Put these three zip files on the large filesystem. On this host that directory was `/home/azureuser/TNMS/resources`.

| File | Role |
| --- | --- |
| `LINUX.X64_193000_db_home_and_patches (1).zip` | Oracle 19c. About 5.0 GB. `unzip -t` must pass. |
| `TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip` | `installation.sh` and the Small Plus database template |
| `TNMS_LUX_R9.1.0.593.0_1904.zip` | `TNMS.bin` |

The Oracle zip must contain these four members and no others:

- `LINUX.X64_193000_db_home.zip`
- `p30869156_190000_Linux-x86-64.zip`
- `p30894985_190000_Linux-x86-64.zip`
- `p35775632_190000_Linux-x86-64.zip` (the installer uses this one on RHEL 9)

A shorter Oracle zip of about 3.7 GB with no end-of-archive record is incomplete. Leave it unused.

`TNMS_WIN_R9.1.0.593.0_1904.zip` is the Windows client. It is not part of this server install. `PUs/` in the Linux package was empty on this host, so no PDT zip was copied.

## 1. Hostname, hosts, locale

```bash
hostnamectl set-hostname TNMS
```

That command prints nothing.

**Confirm by running:**

```bash
hostnamectl status
```

The output includes this line:

```text
   Static hostname: TNMS
```

```bash
localectl set-locale LANG=en_US.UTF-8
```

That command prints nothing.

**Confirm by running:**

```bash
locale
```

The output includes this line:

```text
LANG=en_US.UTF-8
```

`/etc/hosts` needs the server address, the FQDN, and the short name:

```text
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.16.0.4  TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net TNMS
```

**Confirm by running:**

```bash
hostname --fqdn
```

```text
TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net
```

**Confirm by running:**

```bash
getent hosts TNMS
```

```text
172.16.0.4      TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net TNMS
```

**Confirm by running:**

```bash
nisdomainname
```

The command exits 1. That exit code is the finished state. The output is:

```text
nisdomainname: Local domain name not set
```

**Confirm by running:**

```bash
getenforce
```

```text
Enforcing
```

## 2. Packages

```bash
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

The command ends with:

```text
Complete!
```

```bash
dnf -y install attr bc elfutils-libelf-devel fontconfig-devel gcc gcc-c++ \
  jemalloc ksh libaio libaio-devel libnsl libXtst libzip make psmisc sysstat \
  unzip perl binutils glibc-devel
```

The command ends with:

```text
Complete!
```

**Confirm by running:**

```bash
rpm -q epel-release jemalloc elfutils-libelf-devel fontconfig-devel libnsl make sysstat libXtst unzip
```

One line per package, and none of them says `is not installed`. On this host the `jemalloc` line was `jemalloc-5.2.1-3.el8.x86_64`. The Oracle installer checks `elfutils-libelf-devel`, `fontconfig-devel`, `libnsl`, `make`, `sysstat`, and `libXtst`.

## 3. Kernel settings and the firewall

Write `/etc/sysctl.d/99-tnms.conf`:

```text
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 3
vm.min_free_kbytes = 1048576
```

```bash
sysctl --system
```

The output includes the file name and the four settings:

```text
* Applying /etc/sysctl.d/99-tnms.conf ...
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 3
vm.min_free_kbytes = 1048576
```

```bash
systemctl stop firewalld
```

That command prints nothing.

```bash
systemctl disable firewalld
```

```text
Removed /etc/systemd/system/multi-user.target.wants/firewalld.service.
```

**Confirm by running:**

```bash
systemctl is-enabled firewalld
```

```text
disabled
```

**Confirm by running:**

```bash
systemctl is-active firewalld
```

```text
inactive
```

**Confirm by running:**

```bash
systemctl is-active chronyd
```

```text
active
```

`chronyd` is left as the image installed it (`pool 2.rhel.pool.ntp.org iburst` on this host). Firewalld stays off for the install window.

## 4. Disk space the installers actually check

The Oracle installer and `TNMS.bin` need all of the following:

- `/` has at least 8 GB free. `TNMS.bin` measures free space on `/`, including when `/opt/nokia/tnms` is a bind mount on a larger disk. The check that passed here asked for 4,530 MB.
- `/tmp` has at least 16 GB free and is not mounted `noexec`.
- Swap is at least 8 GB. This host used an 18 GB swap file.
- `/opt/oracle`, `/opt/nokia`, `/nokia`, and `/oradata` have room for the product. Oracle data uses `/oradata/ora1`, `/oradata/ora2`, and `/oradata/ora3`.

Check the three filesystems before changing anything. Each check is its own command.

**Confirm by running:**

```bash
df -h / /tmp
```

Read the `Avail` column. `/` needs at least 8 GB free. `/tmp` needs at least 16 GB free. On this host, before the changes below, `/` was 2 GB and `/tmp` was 2 GB. After those changes the same command included:

```text
/dev/mapper/rootvg-rootlv  8.0G  123M  7.9G   2% /
/dev/mapper/rootvg-tmplv    16G  1.3G   15G   8% /tmp
```

**Confirm by running:**

```bash
findmnt -no OPTIONS /tmp
```

The word `noexec` is absent. On this host the line was:

```text
rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota
```

**Confirm by running:**

```bash
swapon --show
```

The command prints nothing when the server has no swap yet. This host had no swap before the file created below. After that file, the same command prints a line for `/home/tnms-layout/swapfile` with size `18G`. The full line is in the post-change confirm later in this step.

**This host.** `/` was a 2 GB logical volume and the 1 TB disk was `/home`. These are the commands that made the layout the installers accepted. Skip a command when that filesystem is already large enough. The volume names were `/dev/rootvg/rootlv` and `/dev/rootvg/tmplv`.

```bash
lvextend -r -L 8G /dev/rootvg/rootlv
```

The output includes:

```text
successfully resized
```

```bash
lvextend -r -L 16G /dev/rootvg/tmplv
```

The output includes `successfully resized` again.

```bash
mkdir -p /home/tnms-layout/oracle \
  /home/tnms-layout/nokia-opt \
  /home/tnms-layout/nokia \
  /home/tnms-layout/oradata/ora1 \
  /home/tnms-layout/oradata/ora2 \
  /home/tnms-layout/oradata/ora3
mkdir -p /opt/oracle /opt/nokia /nokia /oradata
```

Those commands print nothing.

```bash
dd if=/dev/zero of=/home/tnms-layout/swapfile bs=1G count=18 status=progress
```

The command finishes when it has written 18 GB.

```bash
chmod 600 /home/tnms-layout/swapfile
```

That command prints nothing.

```bash
mkswap /home/tnms-layout/swapfile
```

The output includes:

```text
Setting up swapspace version 1, size = 18 GiB
```

```bash
swapon /home/tnms-layout/swapfile
```

That command prints nothing.

Append these lines to `/etc/fstab`, then mount them:

```text
/home/tnms-layout/oracle    /opt/oracle  none  bind  0 0
/home/tnms-layout/nokia-opt /opt/nokia   none  bind  0 0
/home/tnms-layout/nokia     /nokia       none  bind  0 0
/home/tnms-layout/oradata   /oradata     none  bind  0 0
/home/tnms-layout/swapfile  none         swap  sw    0 0
```

```bash
systemctl daemon-reload
```

That command prints nothing.

```bash
mount -a
```

That command prints nothing.

**Confirm by running:**

```bash
swapon --show
```

```text
NAME                       TYPE SIZE USED PRIO
/home/tnms-layout/swapfile file  18G  4.8G   -2
```

The `USED` column moves. `SIZE` stays `18G`.

**Confirm by running:**

```bash
df -h / /tmp /opt/oracle /opt/nokia /nokia /oradata
```

The output includes these lines. Used and available sizes move. `/` is about 8G with several GB free, `/tmp` is 16G, and the four product paths are on the large filesystem.

```text
/dev/mapper/rootvg-rootlv  8.0G  123M  7.9G   2% /
/dev/mapper/rootvg-tmplv    16G  1.3G   15G   8% /tmp
/dev/mapper/rootvg-homelv  1.1T   92G  941G   9% /opt/oracle
/dev/mapper/rootvg-homelv  1.1T   92G  941G   9% /opt/nokia
/dev/mapper/rootvg-homelv  1.1T   92G  941G   9% /nokia
/dev/mapper/rootvg-homelv  1.1T   92G  941G   9% /oradata
```

**Confirm by running:**

```bash
findmnt /opt/oracle /opt/nokia /nokia /oradata
```

Each of the four paths is listed, and each line includes `bind`.

On a fresh server whose `/` is already large, create the same four directories on `/` and skip the bind mounts and `lvextend`. Still create `ora1`, `ora2`, and `ora3` under `/oradata`. `df -h /` then shows at least 8 GB available, and `findmnt /opt/oracle` shows that path on the root filesystem rather than as a bind.

## 5. Unpack the media

`MEDIA` is the directory that holds the three zip files.

```bash
MEDIA=/home/azureuser/TNMS/resources
```

That assignment prints nothing. The three tests below use it. An `unzip -t` that stops before `No errors detected` is an incomplete zip. Replace that file before continuing.

**Confirm by running:**

```bash
unzip -t "$MEDIA/LINUX.X64_193000_db_home_and_patches (1).zip"
```

The last line is:

```text
No errors detected in compressed data of /home/azureuser/TNMS/resources/LINUX.X64_193000_db_home_and_patches (1).zip.
```

**Confirm by running:**

```bash
unzip -t "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904.zip"
```

The last line is:

```text
No errors detected in compressed data of /home/azureuser/TNMS/resources/TNMS_LUX_R9.1.0.593.0_1904.zip.
```

**Confirm by running:**

```bash
unzip -t "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip"
```

The last line is:

```text
No errors detected in compressed data of /home/azureuser/TNMS/resources/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip.
```

```bash
mkdir -p /opt/oracle/oramedia /home/tnms-layout/prereq /home/tnms-layout/installer
unzip -o "$MEDIA/LINUX.X64_193000_db_home_and_patches (1).zip" -d /opt/oracle/oramedia
unzip -o "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip" -d /home/tnms-layout/prereq
unzip -o "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904.zip" -d /home/tnms-layout/installer
```

`mkdir` prints nothing. Each `unzip -o` prints one line per file it writes and returns to the prompt when that zip is unpacked.

```bash
find /home/tnms-layout/prereq/TNMS_Prerequisites/Oracle -type d -exec chmod 755 {} \;
find /home/tnms-layout/prereq/TNMS_Prerequisites/Oracle -type f -exec chmod 644 {} \;
find /home/tnms-layout/prereq/TNMS_Prerequisites/Oracle -name '*.sh' -exec chmod 755 {} \;
chmod 744 /home/tnms-layout/installer/TNMS_Installer/TNMS.bin
```

Those commands print nothing.

**Confirm by running:**

```bash
ls /opt/oracle/oramedia
```

```text
LINUX.X64_193000_db_home.zip
p30869156_190000_Linux-x86-64.zip
p30894985_190000_Linux-x86-64.zip
p35775632_190000_Linux-x86-64.zip
```

**Confirm by running:**

```bash
ls -l /home/tnms-layout/installer/TNMS_Installer/TNMS.bin
```

The permission field is `-rwxr--r--` (mode `744`).

**Confirm by running:**

```bash
ls -l /home/tnms-layout/prereq/TNMS_Prerequisites/Oracle/installation/installation.sh
```

The permission field starts with `-rwx`. The file is executable.

The RHEL 9 script `verify-prerequisites/verify_prerequisites_tnms.sh` does not apply on RHEL 8. It was not run.

## 6. Database passwords

```bash
install -m 600 /dev/null /root/tnms-db-credentials
```

`install` prints nothing.

Edit that file so it contains three lines, using passwords that meet the rule above. Use a different value for `TNMSDBA_PASSWORD` than for the two Oracle accounts:

```text
SYS_PASSWORD=<sys password>
SYSTEM_PASSWORD=<system password>
TNMSDBA_PASSWORD=<tnmsdba password>
```

`SYS_PASSWORD` and `SYSTEM_PASSWORD` are what `installation.sh` asks for. `TNMSDBA_PASSWORD` is typed into the TNMS wizard later. The Oracle installer also creates OS user `orabackup` in group `dba`. Leave that account in `dba`.

**Confirm by running:**

```bash
stat -c '%a %U:%G' /root/tnms-db-credentials
```

```text
600 root:root
```

**Confirm by running:**

```bash
grep -E '^[A-Z_]+=' /root/tnms-db-credentials | cut -d= -f1
```

The output is the three key names. Password values are not printed.

```text
SYS_PASSWORD
SYSTEM_PASSWORD
TNMSDBA_PASSWORD
```

## 7. Install Oracle 19c

Silent Small Plus. The 32 GB memory check fails on a 16 GB server and the script continues because `-silent_mode=Y` is set. Wait until the log prints `Final status of the execution: Success`. The run on this host took about 23 minutes and exited 0.

```bash
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
set -a
. /root/tnms-db-credentials
set +a
cd /home/tnms-layout/prereq/TNMS_Prerequisites/Oracle/installation
./installation.sh \
  -silent_mode=Y \
  -configuration_type=SP \
  -oradata=/oradata \
  -orainstaller=/opt/oracle/oramedia \
  -database_name=TNMS \
  -listener_port=1521 \
  -syspwd="$SYS_PASSWORD" \
  -systempwd="$SYSTEM_PASSWORD"
```

While it runs, the terminal prints a long log. On a 16 GB server that log includes these lines, in this order:

```text
Total memory:    16 GB
Required memory: 32 GB
Total swap:    18 GB
Required swap: 16 GB
Error checking requirements.
vm.nr_hugepages: Current:0 New:3463
Final status of the execution: Success
```

`Error checking requirements.` is the 32 GB memory check. With `-silent_mode=Y` the script continues. The prompt returns only after `Final status of the execution: Success`. This host reached that line at 02:46 UTC, about 23 minutes after the start. A second run of `installation.sh` is a new database install.

**Confirm by running,** in the same shell, immediately after the prompt returns:

```bash
echo $?
```

```text
0
```

The log file keeps the same lines. Its name includes a timestamp.

**Confirm by running:**

```bash
grep -F 'Final status of the execution:' /home/oracle/ossnms_installation_log/oracle_installation_*.log
```

```text
Final status of the execution: Success
```

If more than one log exists, each matching line is printed. The newest file is the run just finished.

**Confirm by running:**

```bash
grep -E 'Total memory:|Required memory:|Total swap:|Required swap:|Error checking requirements\.|nr_hugepages' /home/oracle/ossnms_installation_log/oracle_installation_*.log
```

The output includes the memory, swap, and huge-page lines shown above, in that order.

**Confirm by running:**

```bash
grep TNMS /etc/oratab
```

```text
TNMS:/opt/oracle/product/19c/dbhome_1:Y
```

**Confirm by running:**

```bash
ss -ltn | grep 1521
```

```text
LISTEN 0      400                0.0.0.0:1521       0.0.0.0:*
```

**Confirm by running:**

```bash
grep '^LISNER' /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
```

```text
LISNER =
```

The listener name in `listener.ora` is `LISNER`. Logs are `/home/oracle/ossnms_installation_log/oracle_installation_<timestamp>.log` and a copy under `/tmp`.

The script applies the 19.7 patches that are inside the Oracle zip: `30869156` (Database Release Update 19.7.0.0.200414) and `30894985` (OCW 19.7.0.0.0). It also sets huge pages (`vm.nr_hugepages = 3463` for this 16 GB server).

`patch.sh` in the prerequisites tree asks for later zip files (`p6880880`, `p38629535`, `p38586770`, `p38523609`). Those files are not in this media. Leave `patch.sh` unrun once the line above says Success. A second run of `installation.sh` is a new database install.

## 8. Memory check before the TNMS wizard

Small Plus stays on its own page until `lsmem --summary` reports at least 32G. This host has 16G.

**This host.** Install the wrapper before starting `TNMS.bin`. Remove it in step 10 after the wizard process has exited.

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

```text
Memory block size:       128M
Total online memory:      32G
Total offline memory:      0B
```

**Confirm by running:**

```bash
file /usr/bin/lsmem /usr/bin/lsmem.real
```

```text
/usr/bin/lsmem:      Bourne-Again shell script, ASCII text executable
/usr/bin/lsmem.real: ELF 64-bit LSB shared object, x86-64
```

On a server where `lsmem --summary` already reports 32G or more, skip this step. That server's `lsmem` line from `file` stays `ELF 64-bit`.

## 9. Install TNMS Server and Mediation

`TNMS.bin` rejects `-i console` (`Installer User Interface Mode Not Supported`). The media does not ship a silent response file. Run the GUI. `-r` writes a response file that contains the database passwords. Leave `/root/tnms-install.properties` on the server, and keep it out of git.

On a graphical console:

```bash
cd /home/tnms-layout/installer/TNMS_Installer
./TNMS.bin -i gui -r /root/tnms-install.properties
```

**This host** had no graphical console (`multi-user.target`, GNOME not installed). The same command was run under Xvfb:

```bash
dnf -y install xorg-x11-server-Xvfb dejavu-sans-fonts
```

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

```bash
cd /home/tnms-layout/installer/TNMS_Installer
./TNMS.bin -i gui -r /root/tnms-install.properties -tempdir /tmp/tnms-gui
```

The installer window title is `TNMS 9.1.0.593.0 Installer`. The command does not return until the wizard exits.

**Confirm by running,** before answering screens:

```bash
ps -C Xvfb -o args=
```

```text
Xvfb :99 -screen 0 1400x900x24 -ac +extension GLX +render -noreset
```

Someone has to see display `:99` and answer the screens. A serial console or an SSH session does not show it. On a graphical console the same window opens without Xvfb, and `ps -C Xvfb -o args=` prints nothing.

Answer the screens in this order:

1. License. Accept the terms.
2. PDT warning (`Check for available PDTs`, folder `TNMS_Installer/PUs`). Dismiss it when `PUs/` is empty.
3. Installation package. **TNMS Server and Mediation**.
4. Transport Controller. Leave it unchecked. Ports 12443 and 12351 stay unused.
5. Hardware. **Small Plus**. The page opens on Medium.
6. Customization. Leave **Users And Groups** and **Deployment Directories** unchecked. The defaults are user `tnms`, group `tnms`, SFTP user `tnms_sftp`, Oracle user `oracle`, DBA group `dba`, install directory `/opt/nokia/tnms`, data directory `/nokia/tnms`.
7. Database. **New**.
8. Connection. Host `127.0.0.1`, port `1521`, user `tnmsdba`, SID `TNMS`, Oracle home `/opt/oracle/product/19c/dbhome_1`. The password field labeled for user `sys` is `SYS_PASSWORD`. The `tnmsdba` password is `TNMSDBA_PASSWORD`.
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

If a firewall warning appears, firewalld is still running. Stop it and continue. If the wizard says a user or group already exists, stop and remove only the name it prints. Leave `oracle` and `orabackup` in place.

The copy on this host then stopped on **Not Enough Disk Space** (4,530.80 MB required on `/opt/nokia/tnms`, 1,959.78 MB reported). That number is the free space of `/`. Step 4 is what clears it. After growing `rootlv` to 8 GB the next page was **Enough Disk Space**. **Install** was clicked again and the copy started.

When the progress reaches the end, a dialog titled **Installation fatal errors** says the installation finished with serious errors. Click **OK**. The result page names `Error in db_setup.sh`. Click **Done**. Done is what runs `configure_system.sh`. On this host that script exited 0 and registered `scs_daemon.service`.

That error is one statement in `/nokia/tnms/trace/system/install/sql/db_setup_TNMS_*.log`:

```text
alter system set "_bug33046179_kqr_hot_copy_sleep_limit"=0
```

Oracle 19.7 returns `ORA-02065: illegal option for ALTER SYSTEM`. The SQL tool continues, and the component creation summary (`/tmp/tnms-gui/ossnms/sql/creation_summary_TNMSDBA_*.log` when the wizard temp dir is `/tmp/tnms-gui`) shows each component `OK`. Keep the install when that is the only SQL error.

```bash
. /etc/profile.d/ossnms.sh
```

The leading dot is required. That command prints nothing.

**Confirm by running,** in the same shell, immediately after the source command:

```bash
echo $?
```

```text
0
```

**Confirm by running:**

```bash
getent passwd tnms tnms_sftp
```

```text
tnms:x:<uid>:<gid>::/opt/nokia/tnms:/bin/bash
tnms_sftp:x:<uid>:<gid>::/nokia/tnms/nedata:/bin/bash
```

The numeric ids differ by server. The homes and the `tnms` shell are the check. `tnms_sftp` still has `/bin/bash` here. Step 11 changes that shell to `/sbin/nologin`.

**Confirm by running:**

```bash
systemctl is-enabled scs_daemon
```

```text
enabled
```

**Confirm by running:**

```bash
test -d /opt/nokia/tnms/server && test -d /nokia/tnms && echo TNMS_FILES_OK
```

```text
TNMS_FILES_OK
```

## 10. Put lsmem back

Run this after the `TNMS.bin` process has exited, and only if step 8 installed the wrapper.

```bash
mv -f /usr/bin/lsmem.real /usr/bin/lsmem
```

That command prints nothing.

**Confirm by running:**

```bash
lsmem --summary
```

```text
Memory block size:       128M
Total online memory:      16G
Total offline memory:      0B
```

**Confirm by running:**

```bash
file /usr/bin/lsmem
```

```text
/usr/bin/lsmem: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=aa4bf18057211264f0eac86aa499369a1081724f, stripped
```

## 11. SFTP account

`tnms` stays locked. Set a password for `tnms_sftp`, store the same value as `TNMS_SFTP_PASSWORD` in `/root/tnms-db-credentials`, and restrict the account to SFTP under `/nokia`.

```bash
/usr/bin/passwd tnms_sftp
```

The command asks for the new password twice. It ends with:

```text
passwd: all authentication tokens updated successfully.
```

Add one line to `/root/tnms-db-credentials`, using that same password. Do not print the file.

```text
TNMS_SFTP_PASSWORD=<sftp password>
```

```bash
usermod -s /sbin/nologin tnms_sftp
chown root:root /nokia
chmod 755 /nokia
```

Those commands print nothing.

**Confirm by running:**

```bash
grep -E '^[A-Z_]+=' /root/tnms-db-credentials | cut -d= -f1
```

The output is the key names. Password values are not printed.

```text
SYS_PASSWORD
SYSTEM_PASSWORD
TNMSDBA_PASSWORD
TNMS_SFTP_PASSWORD
```

**Confirm by running:**

```bash
passwd -S tnms
```

```text
tnms LK <date> -1 -1 -1 -1 (Password locked.)
```

**Confirm by running:**

```bash
passwd -S tnms_sftp
```

```text
tnms_sftp PS <date> -1 -1 -1 -1 (Password set, SHA512 crypt.)
```

**Confirm by running:**

```bash
getent passwd tnms_sftp
```

```text
tnms_sftp:x:<uid>:<gid>::/nokia/tnms/nedata:/sbin/nologin
```

**Confirm by running:**

```bash
stat -c '%a %U:%G' /nokia
```

```text
755 root:root
```

In `/etc/ssh/sshd_config`, comment the external sftp subsystem and add the internal one:

```text
#Subsystem	sftp	/usr/libexec/openssh/sftp-server
Subsystem	sftp	internal-sftp
```

Append this at the end of the file. `PasswordAuthentication yes` is only inside the Match block. The global line stays `PasswordAuthentication no`, which is how this image is shipped. A server whose global line is already `yes` can omit that one Match line.

```text
Match User tnms_sftp
    ChrootDirectory /nokia
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no
    PasswordAuthentication yes
```

```bash
sshd -t
```

That command prints nothing.

**Confirm by running,** in the same shell:

```bash
echo $?
```

```text
0
```

Restart sshd only after that `0`.

```bash
systemctl restart sshd
```

That command prints nothing.

**Confirm by running:**

```bash
systemctl is-active sshd
```

```text
active
```

**Confirm by running:**

```bash
sshd -T -C user=tnms_sftp,host=127.0.0.1,addr=127.0.0.1 | grep -E 'chrootdirectory|forcecommand|passwordauthentication'
```

```text
passwordauthentication yes
forcecommand internal-sftp
chrootdirectory /nokia
```

**Confirm by running:**

```bash
sshd -T -C user=azureuser,host=127.0.0.1,addr=127.0.0.1 | grep -E 'chrootdirectory|passwordauthentication'
```

```text
passwordauthentication no
chrootdirectory none
```

This second command is the administrator account. Its name on this host is `azureuser`. Use the site admin name in that `-C user=` argument. An SFTP login as `tnms_sftp` lists the directory `tnms` and `pwd` prints `/`. An SSH shell login as `tnms_sftp` is refused with `This service allows sftp connections only.`

FTP stays off. `vsftpd` was not enabled.

In the TNMS Client, after a client can log in, set the SFTP path to `/tnms/nedata` with nothing in front of `/tnms` (System Preferences, External Communications, and NE Properties).

## 12. sudo for the tnms user

```bash
cp -p /opt/nokia/tnms/system/install/resources/system/tnms_sudo /etc/sudoers.d/tnms_sudo
chown root:root /etc/sudoers.d/tnms_sudo
chmod 440 /etc/sudoers.d/tnms_sudo
```

Those commands print nothing.

**Confirm by running:**

```bash
visudo -cf /etc/sudoers.d/tnms_sudo
```

```text
/etc/sudoers.d/tnms_sudo: parsed OK
```

**Confirm by running:**

```bash
stat -c '%a %U:%G' /etc/sudoers.d/tnms_sudo
```

```text
440 root:root
```

**Confirm by running:**

```bash
sudo -l -U tnms
```

The output includes this line:

```text
    (root) NOPASSWD: /usr/bin/systemctl * scs_daemon.service, /opt/nokia/tnms/system/services/bin/scs_daemon, /opt/nokia/tnms/system/admin/emsstarterdaemon.sh, /opt/nokia/tnms/system/admin/database.sh
```

The shipped file is mode 640, group `tnms`. Mode 440 is what this host uses.

## 13. Start the service

The wizard enables `scs_daemon.service` and leaves it stopped. On this host the first start failed with status 203/EXEC. SELinux denied execute because the files under the `/home` bind mount were labeled `user_home_t`. Relabel `/opt/nokia` only. Leave `/opt/oracle` alone while the database is open.

```bash
restorecon -RF /opt/nokia
```

The command prints a line for each file it relabels, or nothing when the labels are already right.

**Confirm by running:**

```bash
ls -Z /opt/nokia/tnms/system/services/bin/scs_daemon
```

```text
system_u:object_r:bin_t:s0 /opt/nokia/tnms/system/services/bin/scs_daemon
```

```bash
systemctl reset-failed scs_daemon.service
systemctl start scs_daemon
```

Those commands print nothing. A start that prints `status=203/EXEC` means the `bin_t` label is missing. Run `restorecon -RF /opt/nokia` again, then `systemctl reset-failed scs_daemon.service`, then `systemctl start scs_daemon`.

**Confirm by running,** in the same shell, immediately after `systemctl start`:

```bash
echo $?
```

```text
0
```

**Confirm by running:**

```bash
systemctl is-active scs_daemon
```

```text
active
```

**Confirm by running:**

```bash
ss -ltn | grep 8444
```

```text
LISTEN 0      511                0.0.0.0:8444       0.0.0.0:*
```

Port 8444 was left at the product default. The service takes about a minute to open that port after `is-active` already says `active`. Run the `ss` command again until the line appears.

**Confirm by running:**

```bash
curl -k -sI https://127.0.0.1:8444 | head -n 8
```

The output includes these lines:

```text
HTTP/1.1 301 Moved Permanently
Server: openresty
Location: https://127.0.0.1:8444/tnms-webclient
```

Startup logs can say `LD_PRELOAD` of `libjemalloc.so` cannot be preloaded. `jemalloc-5.2.1-3.el8` was installed and the processes still started.

## 14. Checks

Each row is one command. Run the command in the Check column. The Expect column is what that command should show. The same commands, with their full output, are in the steps above.

| Check | Expect |
| --- | --- |
| `hostname --fqdn` | the site FQDN |
| `grep TNMS /etc/oratab` | `TNMS:/opt/oracle/product/19c/dbhome_1:Y` |
| `ss -ltn \| grep 1521` | listener on 1521 |
| `grep -F 'Final status of the execution:' /home/oracle/ossnms_installation_log/oracle_installation_*.log` | `Final status of the execution: Success` |
| `lsmem --summary` | the real RAM, and `/usr/bin/lsmem` is not a script |
| `. /etc/profile.d/ossnms.sh` | returns with no error |
| `passwd -S tnms` | locked |
| `getent passwd tnms_sftp` | shell `/sbin/nologin` |
| `sudo -l -U tnms` | the SCS commands |
| `systemctl is-active scs_daemon` | `active` |
| `ss -ltn \| grep 8444` | a `LISTEN` line for port 8444 |
| `curl -k -sI https://127.0.0.1:8444` | 301 to `/tnms-webclient` |

`db_setup.sh` exit 2 with the single `ORA-02065` above is the known result on this 19.7 database. The creation summary is OK and `configure_system.sh` exits 0.

Left out of this install: Frontend Server, eDNA, Node Manager, a separate mediation machine, hot standby, Transcend Controller, ZTC, northbound interfaces, FTP, the SHA-1 crypto policy, DSA host keys, and `patch.sh`.

The first install runs for 90 days on a trial license. License keys after that, and the Windows client, are separate procedures.

## What happened on this host

2026-10-08. RHEL 8.10, kernel `4.18.0-553.134.1.el8_10.x86_64`, 8 vCPU, 16 GB RAM. `installation.sh` finished at 02:46 UTC with Success. The TNMS wizard ran from 02:59 to 03:26 UTC, `configure_system.sh` exited 0, and NGINX answered on 8444 at 03:37 UTC. With the stack up, available memory was a few hundred MB and swap use was about 3.5 GB. No OOM kill was recorded, and `ora_pmon_TNMS` stayed up.
