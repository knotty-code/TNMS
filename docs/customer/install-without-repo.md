# TNMS 9.1 on RHEL 8 — install without this repository

Run this on a fresh Red Hat Enterprise Linux 8 server, as root, from top to bottom. It is the sequence that installed TNMS 9.1.0.593.0 Server and Mediation with Oracle 19c on 2026-10-08.

Prepare the VM with [pre-install.md](pre-install.md) first. That guide mounts the 1 TB disk on `/opt`. Then run this guide. The wizard files and the three vendor zip files go in `/opt/tnms-install`.

One machine. Small Plus. TNMS Server and Mediation together. New database.

The TNMS client login follows the wizard-file section. The database and SFTP passwords are in the table after that. Write the database passwords into `/root/tnms-db-credentials` (mode 600). A step headed **This host** applies when the fresh server matches the condition in that step.

A line that says **Confirm by running** is a separate command. Run that command. The next **Expected output** block is what that command should print. Compare the two. A work command that prints nothing is finished when the shell prompt returns. Names and addresses below are this host. Sizes move with the disk. Replace `TNMS` and `172.16.0.4` with the site values.

## Where the install files go

> Get `install-tnms-wizard.sh`, `tnms-install.properties.in`, and the three vendor zip files with this guide. Put them in `/opt/tnms-install` after the pre-install checks pass. The script reads the properties file from that same directory. One file without the other stops the script.

| Wizard file | Path on the server |
| --- | --- |
| install-tnms-wizard.sh | /opt/tnms-install/install-tnms-wizard.sh |
| tnms-install.properties.in | /opt/tnms-install/tnms-install.properties.in |
| Three vendor zip files | /opt/tnms-install/resources/ |

`/opt` is the 1 TB volume from the pre-install guide. `/opt/oracle`, `/opt/nokia`, and `/opt/tnms-install` are directories on that volume. Copy the files after `df` shows `/opt` on `datavg-optlv`.

Keep both wizard file names. Leave `tnms-install.properties.in` unchanged. The script writes the server IPv4 into a separate response file, `/root/tnms-install.properties`. Database passwords stay in `/root/tnms-db-credentials` from step 6. Leave those passwords out of the properties file. Leave both wizard files out of the `TNMS.bin` directory. The copy commands are in **Copy the install files**, after step 4. Run the script in step 9.

## TNMS client login

Use this login in the browser and in the TNMS client.

| Client login | Value |
| --- | --- |
| Username | `Administrator` |
| Password | `e2e!Net4u#` |
| Address | `https://<server-ip>:8444/tnms-webclient` |
| Port | TCP `8444` |

> The first login asks for a new password. Use at least 8 characters, with two letters and one number, and change at least 3 characters from `e2e!Net4u#`. Keep the username out of the new password, and keep any run of letters or digits to 3.

Allow inbound TCP 8444 on the security group in front of the server. The browser warns about the certificate. Continue past that warning. The next table is the database and SFTP passwords. Those values go in `/root/tnms-db-credentials`.

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
| `SYS` password | `TnZT5hgW8Zwsp79` |
| `SYSTEM` password | `TnZT5hgW8Zwsp79` |
| `tnmsdba` password | `Tnc25xQ36XBUa9` |
| `tnms_sftp` password | `Tsvb5-Xe8ou3wR9` |
| Large disk | `/opt` on `datavg/optlv`, the 1 TB volume |
| Install files | `/opt/tnms-install` |
| Media directory | `/opt/tnms-install/resources` |

Password rule used for `SYS`, `SYSTEM`, and `tnmsdba`: 6 to 30 characters from `a-z`, `A-Z`, `0-9`, and `+ - _ { }`. `SYS` and `SYSTEM` are the same value. `tnmsdba` is a different value. The SFTP password is separate again.

## Media to copy onto the server

These three zip files are the Oracle and TNMS media. Copy them into `/opt/tnms-install/resources` with the wizard files, in **Copy the install files**.

| File | Role |
| --- | --- |
| `LINUX.X64_193000_db_home_and_patches.zip` | Oracle 19c. About 5.0 GB. `unzip -t` must pass. |
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

**Expected output:**

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

**Expected output:**

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

**Expected output:**

```text
TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net
```

**Confirm by running:**

```bash
getent hosts TNMS
```

**Expected output:**

```text
172.16.0.4      TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net TNMS
```

**Confirm by running:**

```bash
nisdomainname
```

**Expected output:**

The command exits 1. That exit code is the finished state. The output is:

```text
nisdomainname: Local domain name not set
```

**Confirm by running:**

```bash
getenforce
```

**Expected output:**

```text
Enforcing
```

## 2. Packages

```bash
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

**Expected output:**

The command ends with:

```text
Complete!
```

```bash
dnf -y install attr bc elfutils-libelf-devel fontconfig-devel gcc gcc-c++ \
  jemalloc ksh libaio libaio-devel libnsl libXtst libzip make psmisc sysstat \
  unzip perl binutils glibc-devel
```

**Expected output:**

The command ends with:

```text
Complete!
```

**Confirm by running:**

```bash
rpm -q epel-release jemalloc elfutils-libelf-devel fontconfig-devel libnsl make sysstat libXtst unzip
```

**Expected output:**

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

**Expected output:**

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

**Expected output:**

```text
Removed /etc/systemd/system/multi-user.target.wants/firewalld.service.
```

**Confirm by running:**

```bash
systemctl is-enabled firewalld
```

**Expected output:**

```text
disabled
```

**Confirm by running:**

```bash
systemctl is-active firewalld
```

**Expected output:**

```text
inactive
```

**Confirm by running:**

```bash
systemctl is-active chronyd
```

**Expected output:**

```text
active
```

`chronyd` is left as the image installed it (`pool 2.rhel.pool.ntp.org iburst` on this host). Firewalld stays off for the install window.

## 4. Disk space the installers actually check

The pre-install guide mounts the 1 TB disk on `/opt` and creates the directories below. This step confirms that layout. When a check fails, go back to `docs/customer/pre-install.md`. The original server grew `/` and `/tmp` and put the 1 TB disk on `/home`. That record is `docs/customer/install-log.md`.

The Oracle installer and `TNMS.bin` need all of the following:

- `/` has at least 4,531 MB free. The wizard script measures free space on `/`.
- `/opt` is the 1 TB volume. `TNMS.bin` measures free space on the filesystem that holds `/opt/nokia/tnms`.
- `/tmp` has at least 16 GB free and is not mounted `noexec`.
- Swap is 18 GB.
- `/opt/oracle`, `/opt/nokia`, `/nokia`, and `/oradata` are present. Oracle data uses `/oradata/ora1`, `/oradata/ora2`, and `/oradata/ora3`.

**Confirm by running:**

```bash
df -h / /tmp /home /opt
```

**Expected output:**

`/` is about 8G with several GB free. `/tmp` is 16G. `/home` is about 8G. `/opt` is about 1T. Used and available sizes move.

```text
/dev/mapper/rootvg-rootlv  8.0G  123M  7.9G   2% /
/dev/mapper/rootvg-tmplv    16G  1.3G   15G   8% /tmp
/dev/mapper/rootvg-homelv   8.0G  100M  7.9G   2% /home
/dev/mapper/datavg-optlv    1.1T   20G  1.1T   2% /opt
```

**Confirm by running:**

```bash
findmnt -no OPTIONS /tmp
```

**Expected output:**

The word `noexec` is absent.

```text
rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota
```

**Confirm by running:**

```bash
swapon --show
```

**Expected output:**

```text
NAME          TYPE SIZE USED PRIO
/opt/swapfile file  18G   0B   -2
```

The `USED` column moves. `SIZE` stays `18G`.

**Confirm by running:**

```bash
df -h /opt /opt/oracle /opt/nokia /opt/tnms-install /nokia /oradata
```

**Expected output:**

Every line is `datavg-optlv`. `/opt/oracle`, `/opt/nokia`, and `/opt/tnms-install` are directories on the 1 TB volume. `/nokia` and `/oradata` are bind mounts from that volume.

**Confirm by running:**

```bash
for p in /opt /nokia /oradata; do findmnt -n -o SOURCE,TARGET "$p"; done
```

**Expected output:**

`/opt` is `datavg-optlv`. `/nokia` and `/oradata` include the source directory in brackets.

```text
/dev/mapper/datavg-optlv              /opt
/dev/mapper/datavg-optlv[/tnms-data]  /nokia
/dev/mapper/datavg-optlv[/oradata]    /oradata
```

**Confirm by running:**

```bash
ls -d /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3 /opt/tnms-install/resources
```

**Expected output:**

```text
/opt/oradata/ora1
/opt/oradata/ora2
/opt/oradata/ora3
/opt/tnms-install/resources
```

## Copy the install files

Run this after the step 4 checks. `/opt/tnms-install` is on the 1 TB volume. `/tmp` is the 16 GB filesystem. The Oracle zip is about 5 GB.

Copy the two wizard files and the three zip files to `/tmp` on the server. Any SSH user can receive that copy. From the workstation directory that contains the five files:

```bash
scp install-tnms-wizard.sh tnms-install.properties.in \
  LINUX.X64_193000_db_home_and_patches.zip \
  TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip \
  TNMS_LUX_R9.1.0.593.0_1904.zip \
  <user>@<server-ip>:/tmp/
```

`<user>` is the SSH account. `<server-ip>` is the server address. The command finishes when all five files have been copied. `Permission denied` or `No such file` means stop and fix the path before continuing.

On the server, as root:

```bash
install -d -o root -g root -m 700 /opt/tnms-install /opt/tnms-install/resources
install -o root -g root -m 700 /tmp/install-tnms-wizard.sh /opt/tnms-install/install-tnms-wizard.sh
install -o root -g root -m 600 /tmp/tnms-install.properties.in /opt/tnms-install/tnms-install.properties.in
install -o root -g root -m 644 \
  /tmp/LINUX.X64_193000_db_home_and_patches.zip \
  /tmp/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip \
  /tmp/TNMS_LUX_R9.1.0.593.0_1904.zip \
  /opt/tnms-install/resources/
rm -f /tmp/install-tnms-wizard.sh /tmp/tnms-install.properties.in \
  /tmp/LINUX.X64_193000_db_home_and_patches.zip \
  /tmp/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip \
  /tmp/TNMS_LUX_R9.1.0.593.0_1904.zip
```

`install` prints nothing. `rm` prints nothing. The `/tmp` copies are removed. The properties file remains only under `/opt/tnms-install`.

**Confirm by running:**

```bash
ls -l /opt/tnms-install
```

**Expected output:**

Both wizard names are listed, plus the `resources` directory. The modes are the check. Sizes and dates follow the files you copied. On RHEL the mode column ends with a dot.

```text
-rwx------. 1 root root <size> <date> install-tnms-wizard.sh
drwx------. 2 root root <size> <date> resources
-rw-------. 1 root root <size> <date> tnms-install.properties.in
```

**Confirm by running:**

```bash
ls -1 /opt/tnms-install/resources
```

**Expected output:**

```text
LINUX.X64_193000_db_home_and_patches.zip
TNMS_LUX_R9.1.0.593.0_1904.zip
TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip
```

**Confirm by running:**

```bash
grep -c '@TNMS_IP@' /opt/tnms-install/tnms-install.properties.in
```

**Expected output:**

```text
7
```

`7` is the seven address fields the script fills in. `0` means this is the wrong file, or the file was edited. Replace it with the delivered `tnms-install.properties.in` and run the `install` commands again. Run `/opt/tnms-install/install-tnms-wizard.sh` in step 9.

**Confirm by running:**

```bash
df -h /opt/tnms-install /
```

**Expected output:**

On this layout, `/opt/tnms-install` is the large filesystem and `/` is about 8G with several GB free. When `/` was already large before step 4, both paths are that root filesystem.

## 5. Unpack the media

`MEDIA` is the directory that holds the three zip files.

```bash
MEDIA=/opt/tnms-install/resources
```

That assignment prints nothing. The three tests below use it. An `unzip -t` that stops before `No errors detected` is an incomplete zip. Replace that file before continuing.

**Confirm by running:**

```bash
unzip -t "$MEDIA/LINUX.X64_193000_db_home_and_patches.zip"
```

**Expected output:**

The last line is:

```text
No errors detected in compressed data of /opt/tnms-install/resources/LINUX.X64_193000_db_home_and_patches.zip.
```

**Confirm by running:**

```bash
unzip -t "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904.zip"
```

**Expected output:**

The last line is:

```text
No errors detected in compressed data of /opt/tnms-install/resources/TNMS_LUX_R9.1.0.593.0_1904.zip.
```

**Confirm by running:**

```bash
unzip -t "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip"
```

**Expected output:**

The last line is:

```text
No errors detected in compressed data of /opt/tnms-install/resources/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip.
```

```bash
mkdir -p /opt/oracle/oramedia /opt/tnms-install/prereq /opt/tnms-install/installer
unzip -o "$MEDIA/LINUX.X64_193000_db_home_and_patches.zip" -d /opt/oracle/oramedia
unzip -o "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip" -d /opt/tnms-install/prereq
unzip -o "$MEDIA/TNMS_LUX_R9.1.0.593.0_1904.zip" -d /opt/tnms-install/installer
```

`mkdir` prints nothing. Each `unzip -o` prints one line per file it writes and returns to the prompt when that zip is unpacked.

```bash
find /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle -type d -exec chmod 755 {} \;
find /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle -type f -exec chmod 644 {} \;
find /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle -name '*.sh' -exec chmod 755 {} \;
chmod 744 /opt/tnms-install/installer/TNMS_Installer/TNMS.bin
```

Those commands print nothing.

**Confirm by running:**

```bash
ls /opt/oracle/oramedia
```

**Expected output:**

```text
LINUX.X64_193000_db_home.zip
p30869156_190000_Linux-x86-64.zip
p30894985_190000_Linux-x86-64.zip
p35775632_190000_Linux-x86-64.zip
```

**Confirm by running:**

```bash
ls -l /opt/tnms-install/installer/TNMS_Installer/TNMS.bin
```

**Expected output:**

The permission field is `-rwxr--r--` (mode `744`).

**Confirm by running:**

```bash
ls -l /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle/installation/installation.sh
```

**Expected output:**

The permission field starts with `-rwx`. The file is executable.

The RHEL 9 script `verify-prerequisites/verify_prerequisites_tnms.sh` does not apply on RHEL 8. It was not run.

## 6. Database passwords

```bash
install -m 600 /dev/null /root/tnms-db-credentials
```

`install` prints nothing.

Edit that file so it contains these three lines:

```text
SYS_PASSWORD=TnZT5hgW8Zwsp79
SYSTEM_PASSWORD=TnZT5hgW8Zwsp79
TNMSDBA_PASSWORD=Tnc25xQ36XBUa9
```

`SYS_PASSWORD` and `SYSTEM_PASSWORD` are what `installation.sh` asks for. `TNMSDBA_PASSWORD` is typed into the TNMS wizard later. The Oracle installer also creates OS user `orabackup` in group `dba`. Leave that account in `dba`.

**Confirm by running:**

```bash
stat -c '%a %U:%G' /root/tnms-db-credentials
```

**Expected output:**

```text
600 root:root
```

**Confirm by running:**

```bash
grep -E '^[A-Z_]+=' /root/tnms-db-credentials
```

**Expected output:**

```text
SYS_PASSWORD=TnZT5hgW8Zwsp79
SYSTEM_PASSWORD=TnZT5hgW8Zwsp79
TNMSDBA_PASSWORD=Tnc25xQ36XBUa9
```

## 7. Install Oracle 19c

Silent Small Plus. The 32 GB memory check fails on a 16 GB server and the script continues because `-silent_mode=Y` is set. Wait until the log prints `Final status of the execution: Success`. The run on this host took about 23 minutes and exited 0.

```bash
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
set -a
. /root/tnms-db-credentials
set +a
cd /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle/installation
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

**Expected output:**

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

**Expected output:**

```text
0
```

The log file keeps the same lines. Its name includes a timestamp.

**Confirm by running:**

```bash
grep -F 'Final status of the execution:' /home/oracle/ossnms_installation_log/oracle_installation_*.log
```

**Expected output:**

```text
Final status of the execution: Success
```

If more than one log exists, each matching line is printed. The newest file is the run just finished.

**Confirm by running:**

```bash
grep -E 'Total memory:|Required memory:|Total swap:|Required swap:|Error checking requirements\.|nr_hugepages' /home/oracle/ossnms_installation_log/oracle_installation_*.log
```

**Expected output:**

The output includes the memory, swap, and huge-page lines shown above, in that order.

**Confirm by running:**

```bash
grep TNMS /etc/oratab
```

**Expected output:**

```text
TNMS:/opt/oracle/product/19c/dbhome_1:Y
```

**Confirm by running:**

```bash
ss -ltn | grep 1521
```

**Expected output:**

```text
LISTEN 0      400                0.0.0.0:1521       0.0.0.0:*
```

**Confirm by running:**

```bash
grep '^LISNER' /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
```

**Expected output:**

```text
LISNER =
```

The listener name in `listener.ora` is `LISNER`. Logs are `/home/oracle/ossnms_installation_log/oracle_installation_<timestamp>.log` and a copy under `/tmp`.

The script applies the 19.7 patches that are inside the Oracle zip: `30869156` (Database Release Update 19.7.0.0.200414) and `30894985` (OCW 19.7.0.0.0). It also sets huge pages (`vm.nr_hugepages = 3463` for this 16 GB server).

`patch.sh` in the prerequisites tree asks for later zip files (`p6880880`, `p38629535`, `p38586770`, `p38523609`). Those files are not in this media. Leave `patch.sh` unrun once the line above says Success. A second run of `installation.sh` is a new database install.

## 8. Memory check before the TNMS wizard

Small Plus refuses to continue until `lsmem --summary` reports at least 32G. This host has 16G. Do not edit `/usr/bin/lsmem` by hand. The step 9 script installs that wrapper for the duration of `TNMS.bin` and puts the real command back before it exits. On a server that already reports 32G or more, the script leaves `lsmem` alone.

## 9. Install TNMS Server and Mediation

`TNMS.bin` rejects `-i console` (`Installer User Interface Mode Not Supported`). The recorded run wrote a response file, and that file sets `INSTALLER_UI=silent`. One script replays those choices. There is no second SSH session and no screenshot. To answer the screens yourself from two SSH sessions, use [Manual step 9](#manual-step-9-two-ssh-sessions) at the bottom of this guide instead of the script. Do not do both.

The script is `/opt/tnms-install/install-tnms-wizard.sh`, in the same directory as `tnms-install.properties.in`. Both files were copied in **Copy the install files**. If either file is missing, stop and complete that section. The script reads `SYS_PASSWORD` and `TNMSDBA_PASSWORD` from `/root/tnms-db-credentials`, writes the server IPv4 into the response file, and runs `TNMS.bin -f /root/tnms-install.properties`. On a host with less than 32 GB it installs the `lsmem` wrapper for that run and removes the wrapper before it exits. It refuses to start when `/opt/nokia/tnms/server` already exists.

Run it as root, in the same SSH session:

```bash
/opt/tnms-install/install-tnms-wizard.sh
```

The command prints the address it wrote, then the installer log. The run takes about the same time as the wizard on this host, which was 02:59 to 03:26 UTC.

**Expected output:**

The last lines are:

```text
TNMS wizard finished. Installer exit <n>. Product files are present, scs_daemon is enabled, and configure scripts exited 0.
```

On this 19.7 database the line above that is:

```text
Known SQL error kept: ORA-02065 on _bug33046179_kqr_hot_copy_sleep_limit
```

`<n>` is the installer exit code. The finished line is the check, including when `<n>` is not 0. A line that says `TNMS wizard failed` means stop. Read `/root/tnms-wizard.log`. Do not start the script a second time until that failure is understood.

The script selects the same choices this host used:

| Choice | Value |
| --- | --- |
| Package | TNMS Server and Mediation (`Server+NetServer`) |
| Transport Controller | off. Ports 12443 and 12351 stay unused |
| Hardware | Small Plus |
| Users, groups, directories | the product defaults |
| Database | New. Host `127.0.0.1`, port `1521`, user `tnmsdba`, SID `TNMS`, Oracle home `/opt/oracle/product/19c/dbhome_1` |
| `sys` password | `SYS_PASSWORD` from step 6 |
| `tnmsdba` password | `TNMSDBA_PASSWORD` from step 6 |
| Advisory message | off |
| Managers | Ethernet, ASON, Optical, Optical Spectrum Insight. ZTC off |
| Frontend servers | none |
| Northbound interfaces | none |
| Network elements | EM-MVM / Generic SNMP only |

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

`/` must have about 4531 MB free before the script starts. The script stops when it does not. Step 4 is what clears that. On this host the first GUI attempt reported 1,959.78 MB free and stopped; after `rootlv` was 8 GB the copy ran.

The script keeps the install when the only SQL error is this statement in `/nokia/tnms/trace/system/install/sql/db_setup_TNMS_*.log`:

```text
alter system set "_bug33046179_kqr_hot_copy_sleep_limit"=0
```

Oracle 19.7 returns `ORA-02065: illegal option for ALTER SYSTEM`. The SQL tool continues, and the component creation summary shows each component `OK`. The configure log `/nokia/tnms/trace/system/install/system_configure.log` ends with `Product configuration ended`, and each after-script exits 0, including `95_scs_service.sh`.

To see the response file without starting the installer:

```bash
/opt/tnms-install/install-tnms-wizard.sh --dry-run
```

**Expected output:**

```text
Response file: /tmp/tnms-install.properties.dry-run
Server IPv4 written into the response file: 172.16.0.4
lsmem wrapper would be installed for this run and removed when the script exits.
TNMS.bin was not started.
```

The address and the wrapper line follow the server. `TNMS.bin was not started.` is the check that the dry run did not install anything.

```bash
. /etc/profile.d/ossnms.sh
```

The leading dot is required. That command prints nothing.

**Confirm by running,** in the same shell, immediately after the source command:

```bash
echo $?
```

**Expected output:**

```text
0
```

**Confirm by running:**

```bash
getent passwd tnms tnms_sftp
```

**Expected output:**

```text
tnms:x:<uid>:<gid>::/opt/nokia/tnms:/bin/bash
tnms_sftp:x:<uid>:<gid>::/nokia/tnms/nedata:/bin/bash
```

The numeric ids differ by server. The homes and the `tnms` shell are the check. `tnms_sftp` still has `/bin/bash` here. Step 11 changes that shell to `/sbin/nologin`.

**Confirm by running:**

```bash
systemctl is-enabled scs_daemon
```

**Expected output:**

```text
enabled
```

**Confirm by running:**

```bash
test -d /opt/nokia/tnms/server && test -d /nokia/tnms && echo TNMS_FILES_OK
```

**Expected output:**

```text
TNMS_FILES_OK
```

## 10. Put lsmem back

The step 9 script removes its wrapper before it exits. Confirm the real command is back. If `/usr/bin/lsmem.real` still exists, the script stopped before that restore. Run this only in that case:

```bash
mv -f /usr/bin/lsmem.real /usr/bin/lsmem
```

That command prints nothing.

**Confirm by running:**

```bash
lsmem --summary
```

**Expected output:**

```text
Memory block size:       128M
Total online memory:      16G
Total offline memory:      0B
```

**Confirm by running:**

```bash
file /usr/bin/lsmem
```

**Expected output:**

```text
/usr/bin/lsmem: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=aa4bf18057211264f0eac86aa499369a1081724f, stripped
```

## 11. SFTP account

`tnms` stays locked. Set the `tnms_sftp` password to `Tsvb5-Xe8ou3wR9`, store that same value in `/root/tnms-db-credentials`, and restrict the account to SFTP under `/nokia`.

```bash
/usr/bin/passwd tnms_sftp
```

**Expected output:**

The command asks for the new password twice. Type `Tsvb5-Xe8ou3wR9` both times. It ends with:

```text
passwd: all authentication tokens updated successfully.
```

Add this line to `/root/tnms-db-credentials`:

```text
TNMS_SFTP_PASSWORD=Tsvb5-Xe8ou3wR9
```

```bash
usermod -s /sbin/nologin tnms_sftp
chown root:root /nokia
chmod 755 /nokia
```

Those commands print nothing.

**Confirm by running:**

```bash
grep -E '^[A-Z_]+=' /root/tnms-db-credentials
```

**Expected output:**

```text
SYS_PASSWORD=TnZT5hgW8Zwsp79
SYSTEM_PASSWORD=TnZT5hgW8Zwsp79
TNMSDBA_PASSWORD=Tnc25xQ36XBUa9
TNMS_SFTP_PASSWORD=Tsvb5-Xe8ou3wR9
```

**Confirm by running:**

```bash
passwd -S tnms
```

**Expected output:**

```text
tnms LK <date> -1 -1 -1 -1 (Password locked.)
```

**Confirm by running:**

```bash
passwd -S tnms_sftp
```

**Expected output:**

```text
tnms_sftp PS <date> -1 -1 -1 -1 (Password set, SHA512 crypt.)
```

**Confirm by running:**

```bash
getent passwd tnms_sftp
```

**Expected output:**

```text
tnms_sftp:x:<uid>:<gid>::/nokia/tnms/nedata:/sbin/nologin
```

**Confirm by running:**

```bash
stat -c '%a %U:%G' /nokia
```

**Expected output:**

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

**Expected output:**

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

**Expected output:**

```text
active
```

**Confirm by running:**

```bash
sshd -T -C user=tnms_sftp,host=127.0.0.1,addr=127.0.0.1 | grep -E 'chrootdirectory|forcecommand|passwordauthentication'
```

**Expected output:**

```text
passwordauthentication yes
forcecommand internal-sftp
chrootdirectory /nokia
```

**Confirm by running:**

```bash
sshd -T -C user=azureuser,host=127.0.0.1,addr=127.0.0.1 | grep -E 'chrootdirectory|passwordauthentication'
```

**Expected output:**

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

**Expected output:**

```text
/etc/sudoers.d/tnms_sudo: parsed OK
```

**Confirm by running:**

```bash
stat -c '%a %U:%G' /etc/sudoers.d/tnms_sudo
```

**Expected output:**

```text
440 root:root
```

**Confirm by running:**

```bash
sudo -l -U tnms
```

**Expected output:**

The output includes this line:

```text
    (root) NOPASSWD: /usr/bin/systemctl * scs_daemon.service, /opt/nokia/tnms/system/services/bin/scs_daemon, /opt/nokia/tnms/system/admin/emsstarterdaemon.sh, /opt/nokia/tnms/system/admin/database.sh
```

The shipped file is mode 640, group `tnms`. Mode 440 is what this host uses.

## 13. Start the service

The wizard enables `scs_daemon.service` and leaves it stopped. On the original server the first start failed with status 203/EXEC. SELinux denied execute because the files under the `/home` bind mount were labeled `user_home_t`. This VM creates those files on the `/opt` volume. Relabel `/opt/nokia` before the first start. Leave `/opt/oracle` alone while the database is open.

```bash
restorecon -RF /opt/nokia
```

The command prints a line for each file it relabels, or nothing when the labels are already right.

**Confirm by running:**

```bash
ls -Z /opt/nokia/tnms/system/services/bin/scs_daemon
```

**Expected output:**

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

**Expected output:**

```text
0
```

**Confirm by running:**

```bash
systemctl is-active scs_daemon
```

**Expected output:**

```text
active
```

**Confirm by running:**

```bash
ss -ltn | grep 8444
```

**Expected output:**

```text
LISTEN 0      511                0.0.0.0:8444       0.0.0.0:*
```

Port 8444 was left at the product default. The service takes about a minute to open that port after `is-active` already says `active`. Run the `ss` command again until the line appears.

**Confirm by running:**

```bash
curl -k -sI https://127.0.0.1:8444 | head -n 8
```

**Expected output:**

The output includes these lines:

```text
HTTP/1.1 301 Moved Permanently
Server: openresty
Location: https://127.0.0.1:8444/tnms-webclient
```

When that 301 is present, the client can log in. Use the **TNMS client login** at the start of this document: username `Administrator`, password `e2e!Net4u#`, address `https://<server-ip>:8444/tnms-webclient`.

Startup logs can say `LD_PRELOAD` of `libjemalloc.so` cannot be preloaded. `jemalloc-5.2.1-3.el8` was installed and the processes still started.

## 14. Checks

Each row is one command. Run the command in the Check column. The Expected output column is what that command should show. The same commands, with their full output, are in the steps above.

| Check | Expected output |
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

## Manual step 9: two SSH sessions

> **Use this section only to configure step 9 yourself, remotely, with two SSH sessions.** Step 9 above runs `/opt/tnms-install/install-tnms-wizard.sh` and does not use these commands. Do not run the script and this section on the same server. If `/opt/nokia/tnms/server` already exists, the wizard has already been installed.

`TNMS.bin` rejects `-i console`. The SSH session has no monitor, so the GUI runs on a virtual screen. You keep two SSH sessions open on the server, and a third window on the workstation that is not logged into the server. The first SSH session runs the installer and sits with no prompt. The second SSH session takes each picture. The workstation window downloads the picture so you can see the page.

On a server where `lsmem --summary` reports less than 32G, install this wrapper before the commands below. The step 9 script is not doing it for you on this path. Remove the wrapper after the first SSH session returns, as shown at the end of this section. On a server that already reports 32G or more, skip the wrapper.

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

Then run the checks in step 9 that start with `. /etc/profile.d/ossnms.sh`. Continue at step 10 to confirm `lsmem` is the real program, then steps 11 through 14.

