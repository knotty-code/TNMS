# TNMS 9.1 on Linux — installation we are following

**Status: Oracle 19c (Small Plus, SID `TNMS`) and TNMS 9.1.0.593.0 Server and Mediation are installed on this host.** `scs_daemon` is running and NGINX answers on port 8444. The wizard reported one serious error, `ORA-02065` from `db_setup.sh`, and the install was kept.

The ordered commands to repeat on a fresh RHEL 8 server are in [install-log.md](install-log.md). The sections below are the same install, written against the Nokia manual.

This is the path for one physical machine, **Small Plus**, **RHEL**, with **TNMS Server and TNMS Mediation on that same machine**. A customer who repeats these steps, with their own site values, gets the same install.

The vendor procedure is the Nokia *TNMS Installation Manual (IMN, Linux)*, release 9.1, document A50023-K2268-X040-76D1, August 2026, Issue 001. The working copy is in `docs/nokia-imn/`. Section numbers below point at that copy. Where this guide chooses one of several legal options, the choice is stated here.

Passwords are not written in this file. Record them in the checklist (`docs/nokia-imn/tnms-installation-checklist-linux.xlsx` is the blank Nokia template) and keep that filled copy on encrypted storage.

## What this install includes

- Fresh RHEL, English, Server with GUI, static IPv4.
- Filesystem `xfs` on every partition except swap. The manual allows ext4 or xfs. xfs is the RHEL default, and the ext4-only steps (reserved-block `tune2fs`, extended attributes, `acl` mount option) are skipped for that reason.
- Oracle Database 19c Enterprise Edition with partitioning, installed by the TNMS 9.1 database installer, configuration **SP**.
- The 9.1 database security patches that ship in the V9.1 DB Security Patch (Linux) archive.
- TNMS 9.1 Server and Mediation, new database, default OS users and default directories.
- chrony pointed at two external NTP servers, the manual's sshd session limits, SFTP user locked down to `/nokia`, and the TNMS sudoers drop-in.

## What this install leaves out

Do not follow these manual chapters for this system:

| Left out | Why |
| --- | --- |
| TNMS Frontend Server, eDNA, Node Manager | Small Plus is not a supported tier for eDNA or Node Manager. No frontend server is in this design. |
| Separate mediation machine (special deployment) | Server and Mediation share this machine. |
| Hot standby, Transcend Controller | Not in this design. |
| Real-time Planning and Provisioning, web map | Needs licenses, certificates, and a map server. See the Administration Manual when that is in scope. |
| TMF CORBA NBI address binding | Only if that NBI is selected and the host has two or more interfaces. See manual section 7.4. |
| FTP (`vsftpd`) | No legacy NE that requires FTP. |
| SHA-1 crypto policy | Only for mTera or hiT 7300 on RHEL 9. |
| DSA host keys | Only for 7100 Nano or 7100 OTS on RHEL 8. |
| 5500 i686 libraries, ZTC / Kea, eDNA packages | Those package-list conditions are not in this design. |
| Migration, upgrade, uninstall | Fresh install. |

The Windows TNMS Client is a separate procedure in the *TNMS Installation Manual Windows*. This host is the server.

If the network later includes 7100 Nano or 7100 OTS on RHEL 9, stop and follow the Troubleshooting Manual chapter *SFTP Operations Failing in RHEL 9*. SFTP on this host is not compatible with those NEs on RHEL 9.

## Site values

Fill this in before the OS install. The examples are placeholders.

| Item | Value |
| --- | --- |
| RHEL major version | 8 or 9, the minor listed in the 9.1 Release Notes, Licensed Software |
| Hostname | short name, letters, digits, and hyphen, not starting or ending with a hyphen |
| FQDN | `hostname.example.com` |
| Static IPv4, prefix, gateway, DNS | |
| NTP primary and backup | two server IPs |
| Time zone | |
| OS admin username | any name except `tnms` |
| Oracle SID | `TNMS` unless this row says otherwise. 1–8 characters, first character A–Z, then A–Z or 0–9 |
| Listener port | `1521` |
| Data directory | `/oradata` |
| TNMS install directory | `/opt/nokia/tnms` |
| TNMS data directory | `/nokia/tnms` |
| Installer extract directory | `/install/tnms` |
| Prerequisites extract directory | `/install/prereq` |
| Managers, NBIs, and NE families selected in the wizard | list them in the install record |

`/install/tnms` must not sit inside `/opt/nokia/tnms` or `/nokia/tnms`.

## 1. Media

Collect these before touching the server. Check each checksum with `sha256sum` against the value published with that download. The Release Notes name the exact zip files inside the database archives.

- RHEL installation image for the major version in the site table.
- V9.1 DB SW Installation (Linux), from the Nokia Customer Portal.
- V9.1 DB Security Patch (Linux).
- TNMS 9.1 Full Installation Package (Main).
- The latest 9.1 PDTs from the Customer Portal. They are copied into `TNMS_Installer/PUs` after extract.
- Legacy LCT package only if the site table says legacy LCTs are required.

Keep the zip files on a filesystem other than the one TNMS will be installed on. `/install` on the root filesystem is acceptable during install. Delete the extracted trees after a successful install (last step).

## 2. Hardware and BIOS

Small Plus, from manual Table 3 and Table 7:

- 16 cores / 32 threads / 32 vCPU, max turbo 3.7 GHz, AMD64 / x86_64.
- 32 GB RAM, DDR4-2666 or faster.
- Two RAID 1 pairs: logical `sda` from 2 disks, logical `sdb` from 2 disks. The manual's non-redundant disk row for this tier is 2×600 GB SSD. With redundancy it is 4×600 GB SSD.

On an HPE server with iLO 6 the manual's disk steps are:

1. Boot, and when **Press any key to view Option ROM messages** appears, press Enter.
2. When the controller says **Press F10 to enter the Intelligent Provisioning**, press F10.
3. Open **Intelligent Provisioning** > **Performance Maintenance** > **Intelligent Storage Configuration**.
4. **Logical Drives** > **Create Array**. Create RAID 1 with the default settings for the first pair, then again for the second pair.

Other servers: create the same two RAID 1 logical disks in that server's RAID tool. The partition sizes below are what the installer checks later.

BIOS, HPE with iLO 6 (manual section 2.8). Press F9 at the startup screen.

- Disable network boot: **System Configuration > BIOS (RBSU) > Network Options > Network Boot Options > PCIe Slot Network Boot**, every NIC **Disabled**.
- **System Configuration > BIOS (RBSU) > Virtualization Options > Intel Virtualization Technology (intel VT)** = Disabled.
- **Intel VT-d** = Disabled.
- **System Configuration > BIOS/Platform Configuration (RBSU)**, Workload Profile **Transactional Application Processing**. Press F12 to save.
- After reboot, **Power & Thermal > Power Settings**. Set **Power Regulator Setting** to **Static High Performance Mode** if it is not already, then **Apply**.

## 3. Install RHEL

Manual section 3.3.2.1. Boot the installation image.

1. **Test this media & install Red Hat Enterprise Linux**.
2. Language **English (United States)**. The server OS language must be English.
3. **Time & Date**: the site time zone, date, and time. **Done**.
4. **Software Selection**: base environment **Server with GUI**. **Done**.
5. **Installation Destination**: select both logical disks, storage configuration **Custom**. **Done**.
6. Partition with `xfs`, sizes in GB:

| Mount | Device | Size (GB) | File system |
| --- | --- | --- | --- |
| `/` | sda | 150 | xfs |
| swap | sda | 100 | swap |
| `/tmp` | sda | 50 | xfs |
| `/oradata/ora1` | sda | 300 | xfs |
| `/oradata/ora2` | sdb | 300 | xfs |
| `/oradata/ora3` | sdb | 150 | xfs |
| `/nokia` | sdb | 150 | xfs |

Confirm **Summary of Changes** and **Accept Changes**. Nothing is written until **Begin Installation**.

7. **Network & Host Name**. Turn the NIC on. Hostname is the FQDN. **Configure > IPv4 Settings > Method Manual**. Enter the address, prefix, gateway, and DNS from the site table. **Save**, **Done**.
8. **Root Password**. Store it in the checklist, not in git.
9. **Begin Installation**. Reboot when it finishes.
10. Initial setup: accept the license, **Finish Configuration**.
11. Turn **Location Services** off. **Skip** online accounts.
12. Create the admin user. The username must not be `tnms`. The manual's example is full name **System Administrator**, username `SysAdmin`.
13. **Start using Red Hat Enterprise Linux Server**.

Check the disks:

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
findmnt -t xfs,swap
```

Expect the seven mount points above. `/tmp` must not be mounted `noexec`:

```bash
findmnt -no OPTIONS /tmp
```

If `noexec` is listed, remove it from `/etc/fstab` and remount `/tmp`. The installer needs `/tmp` executable. It can be put back after TNMS is installed.

## 4. Packages and locale

Manual section 3.3.5. A trailing `*` on a package name in the manual means "install this when the network includes eDNA". This design has no eDNA, no ZTC, no 5500 NEs, and no legacy FTP, so those packages are not installed. A `*` in the middle of a name (`libnsl*2*`) is an RPM name pattern, and that package is installed.

Add EPEL, then install the set for the RHEL major version in the site table.

RHEL 8:

```bash
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install attr bc elfutils-libelf-devel fontconfig-devel gcc gcc-c++ \
  jemalloc ksh libaio-devel libnsl libXtst libzip make psmisc sysstat
```

RHEL 9:

```bash
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf -y install attr bc binutils compat-openssl11 chkconfig elfutils-libelf \
  elfutils-libelf-devel fontconfig fontconfig-devel glibc glibc-devel jemalloc ksh \
  libaio libasan liblsan libX11 libXau libXi libXrender libXtst libxcrypt-compat \
  libgcc libibverbs libnsl librdmacm libstdc++ libxcb libvirt-libs make net-tools \
  policycoreutils policycoreutils-python-utils polkit smartmontools sysstat
```

Locale. `LANG` must be a UTF-8 locale and `LC_ALL` must be empty. This install uses `en_US.UTF-8`.

```bash
locale
localectl set-locale LANG=en_US.UTF-8
```

If `localectl` does not clear `LC_ALL`, edit `/etc/sysconfig/i18n` so it contains `LANG="en_US.UTF-8"` and does not set `LC_ALL`. Check again:

```bash
locale
locale -a | grep -i en_US.utf8
```

`LANG` is `en_US.UTF-8`. `LC_ALL` is empty.

## 5. Initial system configuration

Run as root. Manual chapter 4. Skip FTP, SHA-1, DSA host keys, and proxy unless the site table says otherwise.

### Hosts

`/etc/hosts` needs localhost and this server. No hot standby and no Transcend Controller, so no peer addresses.

```text
127.0.0.1   localhost
<site-ipv4> <fqdn> <hostname>
```

```bash
hostname --fqdn
```

The output is the FQDN in the site table. The installer refuses to continue when this file is wrong.

### Virtual memory

Append to `/etc/sysctl.conf`, then load it. `vm.min_free_kbytes` applies because Mediation is on this machine (the manual excludes it only for a separate mediation host).

```text
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 3
vm.min_free_kbytes = 1048576
```

```bash
sysctl -p
```

### NTP

Put both site NTP servers in `/etc/chrony.conf`:

```text
server <ntp-primary> iburst
server <ntp-backup> iburst
```

```bash
systemctl enable --now chronyd
systemctl is-active chronyd
chronyc sources
```

`chronyd` is `active`. `chronyc sources` shows both servers.

### SSH / SFTP limits

Set these in `/etc/ssh/sshd_config`. Add the line if it is missing. Leave the rest of the file.

```text
MaxStartups 150
MaxSessions 100
TCPKeepAlive yes
ClientAliveInterval 60
ClientAliveCountMax 5
```

```bash
systemctl restart sshd
```

### Values the installer expects

```bash
umask
```

Root's umask is `0022`. Do not change the default.

```bash
cat /proc/sys/kernel/shmmax
cat /proc/sys/kernel/shmall
```

`shmmax` is at least half of physical RAM in bytes (16 GiB or more on this 32 GB host). `shmall` is at least `shmmax` measured in pages. Leave the kernel defaults when they already meet that.

```bash
swapon --show
free -h
```

Swap is the 100 GB partition from the table above, which is more than half of RAM.

### Firewall for the install window

The manual disables firewalld so remote clients can connect, and points at the Administration Manual for turning a firewall back on. Stop it for the install. Re-enable it only from that manual and `Communication Matrix.xls`, which is not in this repository.

```bash
systemctl stop firewalld
systemctl disable firewalld
```

## 6. Oracle Database 19c

Manual chapter 5. The database has to be on this TNMS Server.

```bash
mkdir -p /opt/oracle/oramedia /install/prereq
```

Extract the V9.1 DB SW Installation (Linux) archive into `/opt/oracle/oramedia/`. The number of zip files inside it is listed in the Release Notes.

Extract the TNMS software prerequisites (from the TNMS media) to `/install/prereq`. Do not run the installer from `/root` or `/home`, and do not rearrange the extracted tree.

```bash
find /install/prereq/TNMS_Prerequisites/Oracle -type d -exec chmod 755 {} \;
find /install/prereq/TNMS_Prerequisites/Oracle -type f -exec chmod 644 {} \;
find /install/prereq/TNMS_Prerequisites/Oracle -name '*.sh' -exec chmod 755 {} \;
cd /install/prereq/TNMS_Prerequisites/Oracle/installation
./installation.sh
```

Answer the prompts as follows:

| Prompt | Answer |
| --- | --- |
| End user license | accept |
| Huge pages configured by the database | accept |
| Configuration | `SP` |
| ORADATA path | `/oradata` |
| Installer zip, TNMS installer folder, `TNMS.rsp`, template | accept each default when the files are in `/opt/oracle/oramedia` and the script's default matches the extract. Otherwise give the real path. |
| Database name | site SID, default `TNMS` |
| Listener port | `1521` |
| `SYS` password | checklist. Database user rules: 6–30 characters from the set in manual section 6.4.2. |
| `SYSTEM` password | checklist, same rules |

The script prints requirement checks for system, disk, memory, swap, hostname, NIS domain, users and groups, and directories. Fix any error before continuing. A memory example in the manual looks like `Required: 16 GB` against a smaller host. This host must show 32 GB.

Success:

```text
Final status of the execution: Success
```

Logs: `/tmp/oracle_installation:<timestamp>.log` and `/home/oracle/ossnms_installation_log`.

The installer creates OS user `orabackup` in group `dba`. That account must not expire, and it must stay in `dba`.

After success, delete the database zip files and their extracted folders from `/opt/oracle/oramedia`. Keep the directory. The patch step uses it next.

## 7. Database security patches

Extract the V9.1 DB Security Patch (Linux) archive into `/opt/oracle/oramedia`. It contains patch zips `p<number>_<version>_<Linux_Version>.zip` and `patch.zip`.

```bash
cd /opt/oracle/oramedia
unzip patch.zip
chown -R oracle:dba .
chmod 744 ./patch/patch.sh
su - oracle
cd /opt/oracle/oramedia/patch
./patch.sh
```

Accept the default patch directory `/opt/oracle/oramedia` if that is where the patch zips are. If the script asks to shut the application down, answer `y`. Success is the same `Final status of the execution: Success` line. Logs are under `/home/oracle/ossnms_installation_log/`. On failure the script can be run again. Table 15 in the manual covers the two messages it documents (out of space, and a datapatch error). The solution text in the PDF is cut off at the page edge.

Then delete, from `/opt/oracle/oramedia`: the security-patch archive, the `p*.zip` files, `patch.zip`, and the extracted `patch` directory and patch-number directories.

## 8. TNMS Server and Mediation

Manual sections 6.2 and 6.4. Skip section 6.4 step 2 (frontend server SQL*Net invite list). There is no frontend server.

Extract the Full Installation Package into `/install/tnms` after `sha256sum` matches. Copy the PDT zips into `/install/tnms/TNMS_Installer/PUs`. The manual prints that path with backslashes. On Linux it is `TNMS_Installer/PUs`.

On RHEL 9 only, run the prerequisite script before the wizard. The manual names the directory `<Product_Installation_Folder>/TNMS_Installer/verify_prerequisites`. TNMS is not installed yet, so the script that exists now is the one in the extracted installer. Run that copy:

```bash
cd /install/tnms/TNMS_Installer/verify_prerequisites
chmod +x verify_prerequisites_tnms.sh
./verify_prerequisites_tnms.sh
```

The script ends with `Error: Missing requirement.`, `Warning: Review needed before installation.`, or `Ok: All requirements met.` Correct every error before the wizard. On RHEL 8 the manual says this script does not apply. Skip it.

```bash
cd /install/tnms/TNMS_Installer
chmod 744 ./TNMS.bin
./TNMS.bin
```

This build rejects `-i console` (`Installer User Interface Mode Not Supported`). Run the GUI. On a host whose default target is `multi-user` and has no graphical session, run that GUI on a virtual display.

InstallAnywhere measures free space on `/`, even when `/opt/nokia/tnms` is a bind mount on a larger disk. `/` needs about 5 GB free before **Install** is clicked. On this host `rootlv` was extended from 2 GB to 8 GB.

The Small Plus page returns to itself unless `lsmem --summary` reports at least 32G. A host that reports less can pass the page only if that command prints 32G for the duration of the wizard. Put the real `lsmem` back as soon as the wizard has left that page.

Wizard choices for this design:

| Screen | Choice |
| --- | --- |
| License | **I accept the terms of the License Agreement** |
| Installation package | **TNMS Server and Mediation** |
| Transcend Controller | leave disabled. The screen is absent when TC is not in the system. |
| Hardware configuration | **Small Plus** |
| Customization | leave users, groups, and directories at the defaults unless a checkbox is required to display them. Defaults: OS user `tnms`, group `tnms`, SFTP user `tnms_sftp`, database OS user `oracle`, DBA group `dba`. Install directory `/opt/nokia/tnms`, data directory `/nokia/tnms`, database `/opt/oracle`, database data `/oradata`. The two TNMS directories are the glossary defaults for `<Product_Installation_Folder>` and `<Product_Data_Folder>`. |
| Connection | only if the host has more than one IP. Client access and server backend access are both the site IPv4. |
| Database | **New** |
| Database connection | IP `127.0.0.1`, port `1521`, user `tnmsdba`, SID from the site table, Oracle home `/opt/oracle/product/19c/dbhome_1`, `SYS` password from the checklist. The `tnmsdba` password follows the same database rules. |
| Advisory message | disabled, unless the site table names a message. |
| Components | the managers, NBIs, and NE families listed in the site table. Do not select Embedded DNA or Node Manager. |
| Pre-installation summary | confirm the PDT numbers. **Install**. |

If the wizard says users or groups already exist, stop. As root, remove only the names it names (`userdel` / `groupdel`) and run it again. Do not delete `oracle` or `orabackup`.

The manual shows a warning when the firewall is enabled (`Enabled Firewall detected`). firewalld is already stopped in section 5, so that warning should not appear. If it does, firewalld is still running. The Communication Matrix lists the ports to open when the firewall is turned back on.

The result page can say the installation finished with serious errors. On the 19.7 database from this media, `db_setup.sh` exits 2 because this statement is rejected:

```text
alter system set "_bug33046179_kqr_hot_copy_sleep_limit"=0
```

The SQL log shows `ORA-02065: illegal option for ALTER SYSTEM`. The tool continues, the component creation summary is OK, and **Done** still runs `configure_system.sh`. Keep the install when that is the only error. Uninstall is for a creation summary that is not OK.

Then:

```bash
. /etc/profile.d/ossnms.sh
```

The leading dot is required.

Delete the TNMS zip files and `/install/tnms` only after the checks in the next sections pass. Read the technical notes of every PDT that was installed before calling the system done.

## 9. After the wizard

### SFTP account

Manual section 7.5. The OS user `tnms` stays locked. Set a password for `tnms_sftp` and store it in the checklist. When that password changes later, change it in the TNMS Client as well (Administration Manual, SFTP chapter).

```bash
/usr/bin/passwd tnms_sftp
```

Restrict `tnms_sftp` to the data directory:

```bash
usermod -s /sbin/nologin tnms_sftp
chmod 755 /nokia
```

In `/etc/ssh/sshd_config`:

- Comment out `Subsystem sftp /usr/libexec/openssh/sftp-server`.
- Add `Subsystem sftp internal-sftp`.
- Add at the end:

```text
Match User tnms_sftp
    ChrootDirectory /nokia
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no
    PasswordAuthentication yes
```

`PasswordAuthentication yes` belongs only in this Match block. This image sets `PasswordAuthentication no` for every user. Leave that global line as it is, so `tnms_sftp` is the account that can use a password. Test the file with `sshd -t` before `systemctl restart sshd`.

```bash
systemctl restart sshd
```

In the TNMS Client, once a client can log in:

- **System Preferences**, SFTP tab: path `/tnms/nedata` with nothing in front of `/tnms`.
- **External Communications > SFTP Settings**: the same path.
- **NE Properties > SFTP Settings**: upload path `/tnms/nedata`.

FTP stays disabled. Do not `systemctl enable vsftpd`.

### Service management

Manual section 7.6. Root still administers the TNMS service. This also lets the `tnms` user do it through sudo.

```bash
cp -p "$SYSTEM_INSTALL_DIR/resources/system/tnms_sudo" /etc/sudoers.d
chown root:root /etc/sudoers.d/tnms_sudo
chmod 440 /etc/sudoers.d/tnms_sudo
visudo -cf /etc/sudoers.d/tnms_sudo
sudo -l -U tnms
```

The shipped file is mode 640, group `tnms`. Mode 440 is what this host uses so the drop-in stays readable by root only. `visudo -cf` checks the syntax before sudo will rely on it.

`sudo -l -U tnms` lists the TNMS service commands. If the OS user were not `tnms`, that name would have to be edited into `tnms_sudo`. This install keeps `tnms`.

### NGINX

Leave port 8444. Change it only when another program already has that port, using manual section 7.1.

The installer enables `scs_daemon.service` and leaves it stopped. If `/opt/nokia` is a bind mount from a directory created under `/home`, SELinux labels the tree `user_home_t` and the first start fails with status 203/EXEC. `restorecon -RF /opt/nokia` applies the `/opt` labels (`bin_t` on `*/bin` and `*/sbin`). Leave `/opt/oracle` alone while the database is running.

```bash
restorecon -RF /opt/nokia
systemctl reset-failed scs_daemon.service
systemctl start scs_daemon
ss -ltnp | grep 8444
```

`https://127.0.0.1:8444` returns 301 to `/tnms-webclient` when NGINX is up.

### Checks

| Check | Expect |
| --- | --- |
| `hostname --fqdn` | site FQDN |
| `systemctl is-active chronyd` | `active` |
| Oracle installer and patch script | `Final status of the execution: Success` |
| `verify_prerequisites_tnms.sh` on RHEL 9 | no `Error:` line |
| Wizard | result page may name the single `ORA-02065` from `db_setup.sh`; component creation summary OK; `configure_system.sh` exits 0 |
| `. /etc/profile.d/ossnms.sh` | returns with no error |
| `sudo -l -U tnms` | TNMS service commands |
| `systemctl is-active scs_daemon` | `active` |
| `ss -ltnp \| grep 8444` | NGINX listening |

Trial license: the first install runs for 90 days with every feature available. License keys after that are an Administration Manual task, not part of this procedure.

## 10. Install record

Fill this in when the procedure has been run. Progress before that is recorded in [install-log.md](install-log.md).

| Field | Value |
| --- | --- |
| Date | 2026-10-08 |
| Hostname and FQDN | `TNMS`, `TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net` |
| RHEL `cat /etc/redhat-release` | Red Hat Enterprise Linux release 8.10 (Ootpa) |
| Kernel `uname -r` | `4.18.0-553.134.1.el8_10.x86_64` |
| TNMS build / zip name | `9.1.0.593.0`, from `TNMS_LUX_R9.1.0.593.0_1904.zip` |
| PDT numbers shown on the summary page | none. `PUs/` was empty |
| Oracle SID | `TNMS`, listener `LISNER` port 1521 |
| Managers, NBIs, NE families selected | Ethernet, ASON, Optical, Optical Spectrum Insight. No NBIs. Generic SNMP only |
| Deviations from this guide | 16 GB RAM with a temporary `lsmem` wrapper, removed after the wizard. `rootlv` grown from 2 GB to 8 GB. Wizard on Xvfb. `ORA-02065` kept. `PasswordAuthentication yes` only inside the `tnms_sftp` Match block. `restorecon -RF /opt/nokia` before `scs_daemon` would start. `patch.sh` not run; the later patch zips are not in this media |
| Database log directory | `/home/oracle/ossnms_installation_log` |
| Database install log | `/home/oracle/ossnms_installation_log/` |

## Reference

- Working copy of the Linux installation manual: `docs/nokia-imn/README.md`
- Blank checklist template: `docs/nokia-imn/tnms-installation-checklist-linux.xlsx`
- Not in this repository, still required before production: 9.1 Release Notes (exact RHEL minor, database zip list, security patch list), TNMS Administration Manual (firewall, licenses, hardening), TNMS Communication Matrix.
