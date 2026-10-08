# Install log

Running record of this host. The planned procedure is [tnms-9.1-linux-install.md](tnms-9.1-linux-install.md). Passwords stay out of this file and out of git.

Each change to the host or to these notes is committed and pushed on `main`. The history is the rollback path.

## Host

Checked 2026-10-08 before any install changes.

| Item | Value |
| --- | --- |
| Hostname | `TNMS` |
| FQDN | `TNMS.vmefr40i5gquree1lezspcyb0c.gx.internal.cloudapp.net` |
| OS | Red Hat Enterprise Linux 8.10, kernel `4.18.0-553.134.1.el8_10.x86_64` |
| CPU | 8 vCPU. The manual Small Plus table asks for 32. This install is a service stand-up, so that table is not a gate. |
| RAM | 15.4 GiB (`MemTotal` 16,133,408 kB). No swap. |
| Root filesystem | 2 GB on `/`. `/usr` 10 GB, `/var` 8 GB, `/tmp` 2 GB. |
| Data disk | 1 TB, added to `rootvg` and used to extend `/home` to 1.1 TB. `/data` was removed. |
| Address | `172.16.0.4/24` on `eth0`, `BOOTPROTO=dhcp`. `/etc/hosts` has localhost only. |
| GUI | `multi-user.target`. GNOME is not installed. |
| TNMS and Oracle packages | Not installed. |

The 2 GB `/` cannot hold `/opt/oracle` or `/opt/nokia`. When the media is complete, those paths, `/oradata`, and `/nokia` go on the large filesystem with bind mounts. A swap file of at least 8 GB goes on that filesystem too, because the database installer checks swap.

## Media

Archives live in `/home/azureuser/TNMS/resources/` and are gitignored.

| File | Check on 2026-10-08 | Result |
| --- | --- | --- |
| `TNMS_LUX_R9.1.0.593.0_1904.zip` | `unzip -t` | Pass. 5.7 GB, 259 members. This is the Linux TNMS installer. |
| `TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip` | End-of-archive record and earlier CRC test | Pass. Contains `installation.sh` and the Small Plus database template. |
| `TNMS_WIN_R9.1.0.593.0_1904.zip` | `unzip -t` | Pass. Windows client. Not used on this host. |
| `CuDo R9.1.zip` | `unzip -t` | Pass. Customer documentation. |
| `LINUX.X64_193000_db_home_and_patches.zip` | End-of-archive record, then a walk of the local members | Fail. 3.7 GB, no end record. Left in place. |
| `LINUX.X64_193000_db_home_and_patches (1).zip` | End-of-archive record and member checksums, 2026-10-08 02:17 UTC | Pass. 5.0 GB. This is the bundle to install from. |

The database installer on RHEL 8 waits until these three members exist in `/opt/oracle/oramedia` and match these MD5 checksums from `installation.sh`:

The first copy failed as follows. The `(1)` copy replaced every row with a matching checksum.

| Member | Required MD5 | First copy |
| --- | --- | --- |
| `LINUX.X64_193000_db_home.zip` | `1858bd0d281c60f4ddabd87b1c214a4f` | Complete. Checksum matches. |
| `p30869156_190000_Linux-x86-64.zip` | `f949a2bc8c5b1e01fd24ebee8c7feebe` | 879,020,465 of 1,215,493,402 bytes. |
| `p30894985_190000_Linux-x86-64.zip` | `f750a50f3e3f6a91bd4bc2e13c7a021b` | Not present. |

The retransfer arrived as `LINUX.X64_193000_db_home_and_patches (1).zip` at 02:14 UTC. All four members are complete and match the installer checksums, including `p35775632_190000_Linux-x86-64.zip` (`0428e0284fdc98e04971c565d0a7fd49`), which the installer uses only on RHEL 9. The original 3.7 GB file is still the failed copy. Use the `(1)` file.

## Host preparation, 2026-10-08

The 2 GB root filesystem cannot hold Oracle or TNMS. These paths are bind mounts onto `/home`:

| Path the installer uses | Backing directory |
| --- | --- |
| `/opt/oracle` | `/home/tnms-layout/oracle` |
| `/opt/nokia` | `/home/tnms-layout/nokia-opt` |
| `/nokia` | `/home/tnms-layout/nokia` |
| `/oradata` | `/home/tnms-layout/oradata` with `ora1`, `ora2`, and `ora3` |

Also done before the database installer:

- Swap file `/home/tnms-layout/swapfile`, 18 GB, in `/etc/fstab`.
- `/tmp` logical volume extended from 2 GB to 16 GB. It is not mounted `noexec`.
- `/etc/hosts` maps `172.16.0.4` to the FQDN and `TNMS`.
- `/etc/sysctl.d/99-tnms.conf` sets `vm.swappiness`, `vm.dirty_ratio`, `vm.dirty_background_ratio`, and `vm.min_free_kbytes` from the manual.
- `firewalld` stopped and disabled for the install window.
- RHEL 8 packages from the procedure installed, plus `unzip`, `perl`, `binutils`, `glibc-devel`, and `libaio`. EPEL was added for `jemalloc`.
- NIS domain name is `(none)`. SELinux is enforcing.
- Database configuration passed to the installer is Small Plus (`SP`), SID `TNMS`, listener port `1521`, listener name `LISNER`. The host has 16 GB of RAM, so the installer's 32 GB memory check will fail and silent mode is set to continue. Passwords are in `/root/tnms-db-credentials` and are not in git.

## Database install, 2026-10-08 02:46 UTC

`installation.sh` finished with `Final status of the execution: Success`. Exit code 0.

| Item | Value |
| --- | --- |
| Configuration | Small Plus (`SP`). The 32 GB RAM check failed at 16 GB and silent mode continued. |
| SID | `TNMS` |
| Oracle home | `/opt/oracle/product/19c/dbhome_1` |
| Listener | `LISNER` on port 1521, status READY |
| oratab | `TNMS:/opt/oracle/product/19c/dbhome_1:Y` |
| Patches from the bundle | `30869156` Database Release Update 19.7.0.0.200414, `30894985` OCW Release Update 19.7.0.0.0 |
| Logs | `/home/oracle/ossnms_installation_log/` |
| Passwords | `/root/tnms-db-credentials` |

The separate security-patch script in the prerequisites tree expects later patch zips (`p6880880`, `p38629535`, `p38586770`, `p38523609`). Those files are not in the media we have. The database installer already applied the 19.7 patches that shipped inside `LINUX.X64_193000_db_home_and_patches (1).zip`.

## Not done yet

TNMS Server and Mediation installation with `TNMS.bin`.
