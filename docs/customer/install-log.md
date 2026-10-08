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
| `LINUX.X64_193000_db_home_and_patches.zip` | End-of-archive record, then a walk of the local members | Fail. 3.7 GB, no end record. Transfer stopped 2026-10-08 00:04 UTC. |

The database installer on RHEL 8 waits until these three members exist in `/opt/oracle/oramedia` and match these MD5 checksums from `installation.sh`:

| Member | Required MD5 | In the file we have |
| --- | --- | --- |
| `LINUX.X64_193000_db_home.zip` | `1858bd0d281c60f4ddabd87b1c214a4f` | Complete. Checksum matches. |
| `p30869156_190000_Linux-x86-64.zip` | `f949a2bc8c5b1e01fd24ebee8c7feebe` | 879,020,465 of 1,215,493,402 bytes. |
| `p30894985_190000_Linux-x86-64.zip` | `f750a50f3e3f6a91bd4bc2e13c7a021b` | Not present. |

Unzipping the bundle does not create the missing patch. A finished bundle is larger than 4.3 GB, which is the size of the first two members before the third zip. The next check is `unzip -t` on the retransferred file, then the MD5 values above.

## Not done yet

No packages, mounts, firewall, or installer commands have been changed for TNMS. The only host change so far is the earlier extension of `/home` onto the 1 TB disk.
