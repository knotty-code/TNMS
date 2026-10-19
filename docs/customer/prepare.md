# TNMS 9.1 on RHEL 8 — prepare the server

Do this before [using-make.md](using-make.md). The server does not need a clone of this repository.

One Small Plus machine. TNMS Server and Mediation together. The image is Red Hat Enterprise Linux 8, SELinux is Enforcing, and the SSH user can open a root shell with `sudo -i`. On this image that user is `azureuser`, and that group is the `make` default for `TNMS_ADMIN_GROUP`. `make` installs packages, sets the hostname, and creates the product directories. This page grows `/` and `/tmp`, mounts the data disk on `/opt`, and creates the swap file.

Run the commands as root. The prompt ends with `#`.

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
