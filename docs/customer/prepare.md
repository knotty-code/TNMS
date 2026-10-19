# TNMS 9.1 on RHEL 8 — prepare the server

Do this before [using-make.md](using-make.md). The server does not need a clone of this repository.

TNMS Server and Mediation go on one machine. Pick the tier in the next section before you order the VM. The image is Red Hat Enterprise Linux 8, SELinux is Enforcing, and the SSH user can open a root shell with `sudo -i`. On this image that user is `azureuser`, and that group is the `make` default for `TNMS_ADMIN_GROUP`. `make` installs packages, sets the hostname, and creates the product directories. This page grows `/` and `/tmp`, mounts the data disk on `/opt`, and creates the swap file that `make` checks.

Run the commands as root. The prompt ends with `#`.

## Choose a scale

Order the VM from Nokia's tiers. CPU, RAM, and disks are [Table 3](../nokia-imn/02-preparation.md#23-hardware-requirements). Filesystem sizes, including swap, are [Table 8](../nokia-imn/03-os-configuration.md#32-disk-configuration). When Server and Mediation share a machine, swap is at least half the RAM ([Swap Configuration](../nokia-imn/04-initial-system-configuration.md#483-swap-configuration)). Table 8 is larger than that floor. Create the Table 8 size.

| | Small | Small Plus | Medium | Large |
| --- | --- | --- | --- | --- |
| vCPU | 16 | 32 | 64 | 160 |
| RAM | 16 GB | 32 GB | 64 GB | 256 GB |
| Swap | 60 GB | 100 GB | 100 GB | 130 GB |
| `/` | 940 GB | 150 GB | 150 GB | 170 GB |
| `/tmp` | — | 50 GB | 50 GB | 60 GB |
| `/oradata/ora1` | — | 300 GB | 700 GB | 600 GB |
| `/oradata/ora2` | — | 300 GB | 500 GB | 2500 GB |
| `/oradata/ora3` | — | 150 GB | 250 GB | 1500 GB |
| `/nokia` | — | 150 GB | 250 GB | 800 GB |
| Disks, no RAID | 1x 1 TB HDD | 2x 600 GB SSD | 2x 1 TB SSD | 1x 960 GB SSD + 3x 1.2 TB SSD |

Small's `/` is 940 GB because that tier has no separate `/tmp`, `/oradata/ora1`, `/oradata/ora2`, `/oradata/ora3`, or `/nokia`. Those cells are blank in Table 8, so the product, the database, and the data directory share the root filesystem. Small Plus, Medium, and Large split them onto their own filesystems, and `/` drops to 150 GB (170 GB on Large).

`/nokia` is the TNMS data directory. The programs are installed at `/opt/nokia/tnms`. Traces, the SFTP tree, and the other runtime data go in `/nokia/tnms`. Nokia puts that filesystem on the second disk for Small Plus and above: 150 GB, 250 GB, then 800 GB. This procedure does not create that partition. `make` bind-mounts `/opt/tnms-data` on `/nokia`, so the same data lands on the one data disk.

When those filesystems are separate, the data disk to order is 900 GB for Small Plus (300+300+150+150), 1700 GB for Medium, and 5400 GB for Large. Add swap, `/`, and `/tmp` when those sit on the OS disk.

A Small machine in production needs approval from a TNMS Product Line Manager and only one mediator. Node Manager and eDNA are Medium or Large. A Medium machine that also runs Transcend Controller against this database needs 256 GB more in `ora2`. The FE Server and the Windows client do not change with the tier. Their sizes are in Table 3.

The commands below do not build the Table 8 partitions. `make` accepts `/` of at least 8 GiB, `/tmp` of at least 16 GiB, one `/opt` volume of at least 100 GB, and a swap file of exactly 18 GiB. That 18 GiB file is what this procedure creates. It meets the Oracle installer check of 16 GB swap on the reference host. Nokia's Small Plus swap in Table 8 is 100 GB. A customer who will grow past this install orders the VM from the table. The steps on this page still create the smaller layout `make` checks.

## What TNMS requires

`make` stops before it creates a directory when any row below is wrong. The names are the ones it checks.

| Mount | Requirement | This image starts at |
| --- | --- | --- |
| `/` | `rootvg/rootlv` at least 8 GiB, with about 4531 MB free. `TNMS.bin` measures free space on `/`. | 2 GiB |
| `/tmp` | `rootvg/tmplv` at least 16 GiB, and not `noexec`. The six install files are about 11 GB and are copied here. | 2 GiB |
| `/home` | Stays on `rootvg` and stays under 100 GiB. | 1 GiB |
| `/opt` | `/dev/mapper/datavg-optlv`, XFS, at least 100 GB, and a line in `/etc/fstab`. | Empty directory on `/` |
| swap | `/opt/swapfile`, exactly 18 GiB, mode `600`, active, and a line in `/etc/fstab`. | Absent |

Leave `/home` on `rootvg`. Adding the data disk to `homelv` fails the install.

`/nokia`, `/oradata`, and the directories under `/opt` are absent when this page is done. `make` creates them.

## 1. Grow `/` and `/tmp`

Each command extends the volume only when it is smaller than the size in the table.

```bash
root_gb=$(lvs --noheadings --nosuffix --units g -o lv_size /dev/rootvg/rootlv | awk '{print int($1)}')
if [[ "$root_gb" -lt 8 ]]; then
  lvextend -r -L 8G /dev/rootvg/rootlv
fi
tmp_gb=$(lvs --noheadings --nosuffix --units g -o lv_size /dev/rootvg/tmplv | awk '{print int($1)}')
if [[ "$tmp_gb" -lt 16 ]]; then
  lvextend -r -L 16G /dev/rootvg/tmplv
fi
```

A volume that is already large enough prints nothing. A volume that grows prints `successfully resized`.

If `findmnt -no OPTIONS /tmp` contains `noexec`, stop. This image does not mount `/tmp` that way.

## 2. Mount the data disk on `/opt`

Set `DATA_DISK` to the empty data disk. The OS disk is the one that already has partitions. On this image the empty disk is `nvme0n2`.

```bash
DATA_DISK=/dev/nvme0n2
lsblk -no NAME,SIZE,FSTYPE,MOUNTPOINT "$DATA_DISK"
```

One line, about `1T`, with no filesystem type and no mountpoint. Any other line means stop. The next command erases that disk.

```bash
parted -s "$DATA_DISK" mklabel gpt
parted -a optimal -s "$DATA_DISK" mkpart primary 0% 100%
parted -s "$DATA_DISK" set 1 lvm on
udevadm settle
parted "$DATA_DISK" align-check optimal 1
```

The align check prints `1 aligned`. Stop when it does not. `mkpart` with a `1MiB` start misaligns this disk. Recreate the partition with the `-a optimal` command above before `pvcreate`.

```bash
if [[ -b ${DATA_DISK}p1 ]]; then DATA_PART=${DATA_DISK}p1; else DATA_PART=${DATA_DISK}1; fi
pvcreate "$DATA_PART"
vgcreate datavg "$DATA_PART"
lvcreate -n optlv -l 100%FREE datavg
mkfs.xfs /dev/datavg/optlv
```

`pvcreate`, `vgcreate`, and `lvcreate` each print `successfully created` or `created`. `mkfs.xfs` prints `meta-data`.

```bash
find /opt -mindepth 1 -maxdepth 1 -printf '%f\n'
```

That prints nothing. A name here would be hidden by the mount. Move it aside before the next command.

```bash
mount /dev/datavg/optlv /opt
OPT_UUID=$(blkid -s UUID -o value /dev/datavg/optlv)
grep -qE '^[^#].*[[:space:]]/opt[[:space:]]' /etc/fstab || printf '%s\n' "UUID=${OPT_UUID} /opt xfs defaults,nofail 0 0" >> /etc/fstab
systemctl daemon-reload
```

`OPT_UUID` is a UUID with hyphens. An empty value means stop. Leave `/etc/fstab` unchanged and return to the `mkfs` step.

## 3. Create the 18 GiB swap file

`make` does not create this file. The file size is exact: 18 GiB, which is `18 * 1024^3` bytes. `swapon --bytes` prints 4096 bytes less, because the swap header uses the first page. `make` accepts that reported size. A different file size fails the check.

```bash
findmnt -n -o SOURCE,SIZE,TARGET /opt
df -h /opt
```

`SOURCE` is `/dev/mapper/datavg-optlv` and `df` shows that device with about 1T free. `df` showing `rootvg-rootlv` and a size of about 8G means `/opt` is still on the root filesystem. Stop. `dd` would fill `/`.

```bash
dd if=/dev/zero of=/opt/swapfile bs=1G count=18 status=progress
chmod 600 /opt/swapfile
mkswap /opt/swapfile
swapon /opt/swapfile
grep -qE '^[^#].*swapfile' /etc/fstab || printf '%s\n' "/opt/swapfile none swap sw,nofail 0 0" >> /etc/fstab
systemctl daemon-reload
swapon -a
chcon -t swapfile_t /opt/swapfile
```

`dd` finishes at 18 GiB. `mkswap` includes `size = 18 GiB`. `chmod`, `swapon`, and `chcon` print nothing.

## 4. Confirm

```bash
for p in / /home /opt /tmp; do findmnt -n -o SOURCE,FSTYPE,TARGET "$p"; done
df -h / /tmp
swapon --show
grep -E '^[^#].*([[:space:]]/opt[[:space:]]|swapfile)' /etc/fstab
```

`/` and `/home` and `/tmp` are `rootvg` volumes. `/` is about 8G. `/tmp` is 16G. `/opt` is `/dev/mapper/datavg-optlv`. Swap is `/opt/swapfile` at 18G. `/etc/fstab` has the `/opt` line and the swap line.

A reboot is optional. Log in again and run the same four commands. The same `/opt` mount and the same swap file mean `/etc/fstab` is in effect.

VS Code Remote SSH unpacks into `/home`, which is about 1 GB, and stops when that filesystem is full. The install does not need VS Code. [pre-install.md](pre-install.md) section 6 moves that directory onto `/opt` when the unpack reports no space.

Continue with [using-make.md](using-make.md).
