# TNMSDEMO: remove the partial swap file

Run this on TNMSDEMO as root. The prompt is `[root@TNMSDEMO ~]#`. This undoes the 7.9 GiB `/opt/swapfile` that filled `/`. After the checks pass, continue in [pre-install.md](pre-install.md) at section 3 or section 4, as the `lvs` output below says.

`umount` may print `not mounted`. That is expected. A line that says `Stop` means paste `findmnt -R /opt` and `fuser -vm /opt` before doing anything else.

## 1. Remove the swap file and the fstab lines

```bash
umount /nokia 2>/dev/null || true
umount /oradata 2>/dev/null || true
opt_src=$(findmnt -n -o SOURCE /opt || true)
if [[ "$opt_src" == *datavg* ]]; then
  umount /opt || echo "Stop. /opt is busy."
fi
if swapon --show | grep -q swapfile; then
  swapoff /opt/swapfile
fi
rm -f /opt/swapfile
opt_src=$(findmnt -n -o SOURCE /opt || true)
if [[ "$opt_src" == *datavg* ]]; then
  echo "Stop. /opt is still ${opt_src}. The swap file is hidden under that mount."
else
  rm -rf /opt/oracle /opt/nokia /opt/tnms-data /opt/tnms-install /opt/oradata
fi
cp -a /etc/fstab /etc/fstab.bak
sed -i \
  -e '\|^UUID=.* /opt xfs |d' \
  -e '\|^/opt/tnms-data /nokia |d' \
  -e '\|^/opt/oradata /oradata |d' \
  -e '\|^/opt/swapfile none swap |d' \
  /etc/fstab
systemctl daemon-reload
echo "---- df / ----"
df -h /
echo "---- /opt ----"
find /opt -mindepth 1 -maxdepth 1 -printf '%f\n'
findmnt -n -o SOURCE,TARGET /opt || true
echo "---- lvs ----"
lvs
echo "---- swap ----"
swapon --show
echo "---- fstab ----"
tail -n 12 /etc/fstab
```

**Expected output:**

`df -h /` shows about 7.9G available on `/`. `find /opt` prints nothing. `swapon --show` prints only the header, or nothing. `/etc/fstab` has no `/opt`, `/nokia`, `/oradata`, or `swapfile` line. A copy of the old file is `/etc/fstab.bak`.

## 2. Mount the 1 TB disk

Use the `lvs` output from section 1.

When `lvs` shows `optlv` in `datavg`, mount that volume. Skip `parted`, `pvcreate`, `vgcreate`, `lvcreate`, and `mkfs`.

```bash
find /opt -mindepth 1 -maxdepth 1 -printf '%f\n'
mount /dev/datavg/optlv /opt
findmnt -n -o SOURCE,SIZE,TARGET /opt
```

**Expected output:**

`find` prints nothing. `findmnt` prints one line. `SOURCE` is `/dev/mapper/datavg-optlv` and `SIZE` is `1023.5G` on this image. That line is the output, not a command.

```text
/dev/mapper/datavg-optlv 1023.5G /opt
```

When `lvs` has no `datavg`, go to section 3 of [pre-install.md](pre-install.md) and run it from `DATA_DISK=` through the mount confirm. Then return here at section 3.

## 3. Directories, then the 18 GB swap file

`findmnt` must show `datavg-optlv` before these commands. Continue in section 4 of [pre-install.md](pre-install.md) from `install -d`. The gate immediately before `dd` is:

```bash
findmnt -n -o SOURCE,SIZE,TARGET /opt
df -h /opt
```

**Expected output:**

Both commands show `/dev/mapper/datavg-optlv`. `Avail` is about `1T` and greater than 20G. `mkswap` must then say `size = 18 GiB`.

Append `/etc/fstab` only after this prints a UUID. The UUID from the failed `mkswap` (`c4183139-f0c2-4e23-b139-27fa13a174fc`) belonged to the deleted 7.9 GiB file.

```bash
OPT_UUID=$(blkid -s UUID -o value /dev/datavg/optlv)
printf '%s\n' "$OPT_UUID"
```

**Expected output:**

One line, a UUID with hyphens. An empty line means stop and return to section 2.
