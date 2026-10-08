# TNMS 9.1 on RHEL 8 — pre-install for a new VM

Run this on a new Red Hat Enterprise Linux 8 VM before [install-without-repo.md](install-without-repo.md). The VM matches the resources of the server that already has TNMS 9.1 installed. This guide builds the disk layout. The install guide installs Oracle and TNMS.

Run the commands as root. Section 1 opens that shell from the `azureuser` login. The prompt ends with `#`.

Leave the existing TNMS server as it is. Its 1 TB volume is mounted on `/home`.

A line that says **Confirm by running** is a separate command. Run that command. The next **Expected output** block is what that command should print. A work command that prints nothing is finished when the shell prompt returns. Sizes move with the disk.

## Where the software goes

Install the product on `/opt`. That is the filesystem location for add-on software, and it is Nokia's default.

| Path | Role |
| --- | --- |
| `/opt` | The 1 TB data disk |
| `/opt/oracle` | Oracle software. The database zip is unpacked in `/opt/oracle/oramedia`. |
| `/opt/nokia/tnms` | TNMS software. The installer creates this path. |
| `/opt/tnms-install` | Wizard script, properties file, zip files, and the unpacked installer. Mode `700`. |
| `/nokia` | TNMS data. Bind mount from `/opt/tnms-data`. The installer requires this path. |
| `/oradata` | Database files in `ora1`, `ora2`, and `ora3`. Bind mount from `/opt/oradata`. |
| `/home` | Login account. Small volume on the OS disk. |
| `/root` | `tnms-db-credentials`, the generated response file, and `tnms-wizard.log`. |

`/usr/local` is for software built on the machine. `/var` on this layout is 8 GB. `/home` is for user accounts. The first install put the 1 TB disk on `/home` and bind-mounted the product out of `/home/tnms-layout`. Those files were labeled `user_home_t`, and the first `scs_daemon` start failed until `restorecon`.

> The Nokia Small Plus table asks for a 150 GB `/`, 100 GB swap, 50 GB `/tmp`, separate `oradata` volumes of 300 GB, 300 GB, and 150 GB, and a 150 GB `/nokia`. This VM matches the machine already installed: 8 vCPU, 16 GB RAM, a 64 GB OS disk, a 1 TB data disk, and 18 GB swap.

## Resources to request

| Item | Value |
| --- | --- |
| OS | Red Hat Enterprise Linux 8, x86_64 |
| CPU | 8 vCPU |
| Memory | 16 GB |
| OS disk | 64 GB |
| Data disk | 1 TB, empty, separate from the OS disk |
| `/` | 8 GB (`rootvg/rootlv`) |
| `/usr` | 10 GB (`rootvg/usrlv`) |
| `/var` | 8 GB (`rootvg/varlv`) |
| `/tmp` | 16 GB (`rootvg/tmplv`), executable |
| `/boot` | 500 MB |
| `/boot/efi` | 495 MB |
| `/home` | About 1 GB on the OS disk (`1014M` on this image) |
| Swap | 18 GB, file `/opt/swapfile` |
| SELinux | Enforcing |

Oracle port 1521 stays closed to the network. The install guide opens the client on TCP 8444.

## 1. Confirm the VM

Log in as `azureuser`, then open a root shell. Every command after this one runs in that shell.

```bash
sudo -i
```

**Expected output:**

The prompt changes from `[azureuser@TNMSDEMO ~]$` to `[root@TNMSDEMO ~]#`. The hostname is the VM name.

**Confirm by running:**

```bash
id
```

**Expected output:**

```text
uid=0(root) gid=0(root) groups=0(root)
```

`lvs` in the `azureuser` shell stops with `Permission denied` on `/run/lock/lvm/P_global:aux`. That message means the shell is still `azureuser`. Run `sudo -i` again.

```bash
nproc
```

**Expected output:**

```text
8
```

**Confirm by running:**

```bash
awk '/MemTotal/ { printf "%.0f GB\n", $2 / 1024 / 1024 }' /proc/meminfo
```

**Expected output:**

```text
15 GB
```

16 GB of RAM reports as 15 GB after the kernel reserve.

**Confirm by running:**

```bash
lsblk -dn -o NAME,SIZE,TYPE
```

**Expected output:**

Two disks. One is about 64G. One is about 1T. Names vary. On the reference server they were `nvme0n1` and `nvme0n2`.

```text
nvme0n1  64G disk
nvme0n2   1T disk
```

**Confirm by running:**

```bash
lvs --noheadings -o lv_name,lv_size,vg_name
```

**Expected output:**

`rootvg` contains `rootlv`, `usrlv`, `varlv`, `tmplv`, and `homelv`. A new image of this family starts with `rootlv` at 2 GB, `tmplv` at 2 GB, and `homelv` at about 1 GB. Leave `homelv` at that size.

## 2. Grow `/` and `/tmp` when they are still small

`TNMS.bin` and the wizard script require about 4,531 MB free on `/`. `/tmp` needs 16 GB and must be executable.

Each command extends the volume only when it is smaller than the target. A volume that is already large enough prints nothing.

```bash
root_gb=$(lvs --noheadings --nosuffix --units g -o lv_size /dev/rootvg/rootlv | awk '{print int($1)}')
if [[ "$root_gb" -lt 8 ]]; then
  lvextend -r -L 8G /dev/rootvg/rootlv
fi
```

**Expected output:**

Either the command prints nothing, or the output includes:

```text
successfully resized
```

```bash
tmp_gb=$(lvs --noheadings --nosuffix --units g -o lv_size /dev/rootvg/tmplv | awk '{print int($1)}')
if [[ "$tmp_gb" -lt 16 ]]; then
  lvextend -r -L 16G /dev/rootvg/tmplv
fi
```

**Expected output:**

Either the command prints nothing, or the output includes `successfully resized`.

**Confirm by running:**

```bash
findmnt -no OPTIONS /tmp
```

**Expected output:**

The word `noexec` is absent.

**Confirm by running:**

```bash
df -h / /tmp /home
```

**Expected output:**

`/` is about 8G with several GB free. `/tmp` is 16G. `/home` is about 1G and is a `rootvg` volume. On this image the line is `1014M`. A `/home` of about 1T means the data disk was added to the home volume. Stop when that happens.

```text
/dev/mapper/rootvg-rootlv  8.0G  118M  7.9G   2% /
/dev/mapper/rootvg-tmplv    16G  149M   16G   1% /tmp
/dev/mapper/rootvg-homelv 1014M   40M  975M   4% /home
```

## 3. Mount the 1 TB disk on `/opt`

Set `DATA_DISK` to the empty 1 TB disk from step 1. The example name is the reference server. The OS disk is the one that already has partitions.

```bash
DATA_DISK=/dev/nvme0n2
```

That assignment prints nothing.

**Confirm by running:**

```bash
lsblk -no NAME,SIZE,FSTYPE,MOUNTPOINT "$DATA_DISK"
```

**Expected output:**

One line, about `1T`, with no filesystem type and no mountpoint. Any other line means stop. This command is about to erase `DATA_DISK`.

```bash
parted -s "$DATA_DISK" mklabel gpt
parted -s "$DATA_DISK" mkpart primary 1MiB 100%
parted -s "$DATA_DISK" set 1 lvm on
udevadm settle
```

`parted` prints nothing in script mode. `udevadm` prints nothing.

```bash
if [[ -b ${DATA_DISK}p1 ]]; then DATA_PART=${DATA_DISK}p1; else DATA_PART=${DATA_DISK}1; fi
pvcreate "$DATA_PART"
vgcreate datavg "$DATA_PART"
lvcreate -n optlv -l 100%FREE datavg
mkfs.xfs /dev/datavg/optlv
```

**Expected output:**

`pvcreate` prints `Physical volume ... successfully created`. `vgcreate` prints `Volume group "datavg" successfully created`. `lvcreate` prints `Logical volume "optlv" created`. `mkfs.xfs` prints `meta-data`.

**Confirm by running:**

```bash
find /opt -mindepth 1 -maxdepth 1 -printf '%f\n'
```

**Expected output:**

The command prints nothing. `/opt` on the OS disk is empty. A name here would be hidden by the mount in the next command.

```bash
mount /dev/datavg/optlv /opt
```

That command prints nothing.

**Confirm by running:**

```bash
findmnt -n -o SOURCE,SIZE,TARGET /opt
```

**Expected output:**

One line. `SOURCE` is `/dev/mapper/datavg-optlv` and `SIZE` is `1023.5G` on this image. That is the 1 TB disk.

```text
/dev/mapper/datavg-optlv 1023.5G /opt
```

Empty output means `/opt` is not a mount. `/opt` is still a directory on the 8 GB root filesystem. Stop and repeat the `mount` command. Section 4 writes an 18 GB file under `/opt`.

## 4. Directories, data binds, and swap

```bash
install -d -m 755 /opt/oracle /opt/nokia /opt/tnms-data /nokia /oradata
install -d -m 755 /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3
install -d -o root -g root -m 700 /opt/tnms-install /opt/tnms-install/resources
mount --bind /opt/tnms-data /nokia
mount --bind /opt/oradata /oradata
```

Those commands print nothing. `/opt/tnms-install` is mode `700` because it will hold the properties file. The database passwords and the wizard log stay in `/root`.

**Confirm by running:**

```bash
findmnt -n -o SOURCE,SIZE,TARGET /opt
df -h /opt
```

**Expected output:**

`findmnt` prints one line for `/dev/mapper/datavg-optlv`. Empty `findmnt` output means `/opt` is not a mount. `df` shows that same device, with `Avail` about `1T` and greater than 20G. Continue to `dd` only when both are true. `df` showing `rootvg-rootlv` and a size of about 8G means `/opt` is still on the root filesystem. `dd` then stops with `No space left on device` after about 7.9 GiB and leaves `/` full.

```text
/dev/mapper/datavg-optlv 1023.5G /opt
Filesystem                Size  Used Avail Use% Mounted on
/dev/mapper/datavg-optlv  1.0T  7.2G 1017G   1% /opt
```

`Used` on a fresh filesystem is about 7.2G. `Avail` stays above 20G. The text block above is an example of the output. It is not a command.

```bash
dd if=/dev/zero of=/opt/swapfile bs=1G count=18 status=progress
chmod 600 /opt/swapfile
mkswap /opt/swapfile
swapon /opt/swapfile
```

`dd` finishes when it has written 18 GB. `chmod` prints nothing.

**Expected output:**

`mkswap` includes:

```text
Setting up swapspace version 1, size = 18 GiB
```

`swapon` prints nothing.

**Confirm by running:**

```bash
OPT_UUID=$(blkid -s UUID -o value /dev/datavg/optlv)
printf '%s\n' "$OPT_UUID"
```

**Expected output:**

One line, a UUID with hyphens. `blkid: error:` or an empty line means `/dev/datavg/optlv` does not exist. Stop. Leave `/etc/fstab` unchanged and return to section 3.

Write `/etc/fstab` with that UUID. `nofail` lets the VM boot when the data disk is absent. The checks in the next section catch a missing mount before the install. Append these lines only after the UUID check printed a value. An empty `UUID=` line is skipped by `mount -a` because of `nofail`, and that command still prints nothing.

```bash
cat >> /etc/fstab << EOF
UUID=${OPT_UUID} /opt xfs defaults,nofail 0 0
/opt/tnms-data /nokia none bind,nofail 0 0
/opt/oradata /oradata none bind,nofail 0 0
/opt/swapfile none swap sw,nofail 0 0
EOF
systemctl daemon-reload
mount -a
```

`cat`, `systemctl`, and `mount` print nothing.

```bash
restorecon -RF /opt/oracle /opt/nokia /opt/tnms-install /opt/tnms-data /opt/oradata /nokia /oradata
```

The command prints a line for each directory it relabels, or nothing when the labels are already right.

## 5. Checks

**Confirm by running:**

```bash
for p in / /home /opt /nokia /oradata /tmp; do findmnt -n -o SOURCE,FSTYPE,TARGET "$p"; done
```

**Expected output:**

`/` and `/home` and `/tmp` are `rootvg` volumes. `/opt` is `/dev/mapper/datavg-optlv`. `/nokia` and `/oradata` show that device with the directory in brackets. The lines look like this. Volume names follow the VM.

```text
/dev/mapper/rootvg-rootlv xfs    /
/dev/mapper/rootvg-homelv xfs    /home
/dev/mapper/datavg-optlv  xfs    /opt
/dev/mapper/datavg-optlv[/tnms-data] xfs    /nokia
/dev/mapper/datavg-optlv[/oradata] xfs    /oradata
/dev/mapper/rootvg-tmplv  xfs    /tmp
```

**Confirm by running:**

```bash
df -h / /home /opt /opt/oracle /opt/nokia /opt/tnms-install
```

**Expected output:**

`/home` is about 1G. `/opt`, `/opt/oracle`, `/opt/nokia`, and `/opt/tnms-install` are the 1 TB volume. `/` has several GB free.

**Confirm by running:**

```bash
swapon --show
```

**Expected output:**

```text
NAME          TYPE SIZE USED PRIO
/opt/swapfile file  18G   0B   -2
```

The `USED` column moves later. `SIZE` stays `18G`.

**Confirm by running:**

```bash
getenforce
```

**Expected output:**

```text
Enforcing
```

**Confirm by running:**

```bash
stat -c '%a %n' /opt/tnms-install /opt/tnms-install/resources
```

**Expected output:**

```text
700 /opt/tnms-install
700 /opt/tnms-install/resources
```

Reboot, log in again, and run the five checks in this section a second time. The same mounts and the same swap file mean `/etc/fstab` is in effect.

## 6. VS Code Remote SSH

`/home` is about 1 GB. VS Code Remote SSH unpacks its server into `/home/azureuser/.vscode-server`. That unpack is larger than `/home` and stops with `No space left on device`. The TNMS install does not need VS Code. Run this section before connecting with VS Code Remote SSH.

The server directory goes on the 1 TB volume. The login path stays `/home/azureuser/.vscode-server`, and that path is a symlink. Run as root.

```bash
rm -rf /home/azureuser/.vscode-server
install -d -o azureuser -g "$(id -gn azureuser)" -m 700 /opt/azureuser/vscode-server
ln -s /opt/azureuser/vscode-server /home/azureuser/.vscode-server
chown -h azureuser:"$(id -gn azureuser)" /home/azureuser/.vscode-server
```

`rm` deletes the failed unpack on `/home`. `install` and `chown` print nothing.

**Confirm by running:**

```bash
df -h /home
ls -ld /home/azureuser/.vscode-server /opt/azureuser/vscode-server
```

**Expected output:**

`/home` has several hundred MB free. The first `ls` line is a symlink to `/opt/azureuser/vscode-server`. The second line is mode `700` and owned by `azureuser`.

```text
/dev/mapper/rootvg-homelv 1014M   40M  975M   4% /home
lrwxrwxrwx. 1 azureuser azureuser 28 Oct  8 20:00 /home/azureuser/.vscode-server -> /opt/azureuser/vscode-server
drwx------. 2 azureuser azureuser  6 Oct  8 20:00 /opt/azureuser/vscode-server
```

The date and the link size follow the VM. Connect again as `azureuser`. New server files are written on `/opt`. Leave `/opt/tnms-install` mode `700` and owned by root. Put the five install files in `/tmp`, as `docs/customer/install-without-repo.md` describes.

## 7. Next

Continue with `docs/customer/install-without-repo.md`. Copy `install-tnms-wizard.sh`, `tnms-install.properties.in`, and the three vendor zip files into `/opt/tnms-install` as that guide describes. The properties file stays beside the script. The unpacked prerequisites and `TNMS.bin` go under `/opt/tnms-install/prereq` and `/opt/tnms-install/installer`.
