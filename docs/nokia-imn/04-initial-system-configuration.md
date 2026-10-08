Source: installation_manual_linux.pdf, chapter 4, pages 29–36.

# 4. Initial System Configuration

> **Tip:** It is highly recommended to take note of relevant configurations using the TNMS Installation Checklist (Linux) spreadsheet.
>
> For more information regarding this checklist refer to chapter TNMS Installation Checklist (p. 12).

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 4.1. System Hosts

TNMS requires the proper configuration of the hosts file (`/etc/hosts`) in every Server machine. Each host file must also include a localhost entry.

If the network also includes Transcend eDNA, all Transcend eDNA (TNMS Server and TNMS FE Server) machines must be listed in each TNMS machine hosts file.

The configuration of hosts files also ensures the functionality of Hot Standby as well as the interworking of TNMS and Transcend Controller (for Real-time Planning and Provisioning, etc).

> **Note:** The FQDN (Fully Qualified Domain Name) is displayed via `hostname --fqdn`.

The examples below outline two different scenarios with and without Hot Standby. The Transcend Controller IPs are only needed if Transcend Controller is included in the network.

For networks without Hot Standby the hosts file must be configured as follows:

- TNMS Server: IP Address FQDN hostname
- Transcend Controller: IP Address FQDN hostname
- TNMS FE Server: IP Address FQDN hostname

For networks with Hot Standby the hosts files must be configured as follows:

- Primary site Server hosts file:
  - TNMS Primary Server: IP Address FQDN hostname
  - TNMS Secondary Server: IP Address FQDN
  - Transcend Controller Primary: IP Address FQDN hostname
  - Transcend Controller Secondary: IP Address FQDN hostname
- Secondary site Server hosts file:
  - TNMS Secondary Server: IP Address FQDN hostname
  - TNMS Primary Server: IP Address FQDN
  - Transcend Controller Secondary: IP Address FQDN hostname
  - Transcend Controller Primary: IP Address FQDN hostname

> **Tip:** If there are more local IPs configured in the system, consider adding them to each hosts file to improve system diagnostic operations.

Host name valid characters are:

**Table 10: Valid characters for host name**

- `-` (must not be at the beginning or end of the name)
- `1234567890`
- `abcdefghijklmnopqrstuvwxyz`
- `ABCDEFGHIJKLMNOPQRSTUVWXYZ`

> **NOTICE:** The TNMS installer will check if the hosts file is correctly configured. If the server belongs to a domain, make sure FQDN matches the domain.
>
> If no domain exists and the hosts file is not configured, the installation will not proceed.

## 4.2. Virtual Memory

The system configuration file (`/etc/sysctl.conf`) must be updated with the following settings:

```text
vm.swappiness = 1
```

> **NOTICE:** The following parameters are not applicable to the TNMS Mediation Machine in a Special Deployment scenario:

```text
vm.min_free_kbytes = 1048576
vm.dirty_ratio = 15
vm.dirty_background_ratio = 3
```

> The second parameter configures the system to only use swapping as a last resource, that is, the system will use paging when needed. The remaining parameters are RHEL advised parameters.

## 4.3. FTP Configuration

> **NOTICE:** Perform this configuration only if the network contains 5500 DCC NEs or Embargo NE versions that support only FTP and need to be managed by TNMS.

To configure the FTP, do as follows:

1. Login as root.
2. Edit `/etc/vsftpd/vsftpd.conf`:

   **Step 2a.** Set the following property to:

   ```text
   anonymous_enable=NO
   ```

   or add the line above if this property is not in the file. After adding this line, save and exit.

   **Step 2b.** (Only required if IPv6 is disabled)

   - Set the following property to:

     ```text
     listen=YES
     ```

     or add the line above if this property is not in the file.
   - Comment out the following property:

     ```text
     # listen_ipv6=YES
     ```

   **Step 2c.** After editing the file, save and exit.
3. (Only required if SELinux is enabled)

   Allow the FTP daemon to access the filesystem:

   Linux 8.X and Linux 9.X:

   ```bash
   setsebool -P ftpd_full_access on
   ```
4. Restart the vsftpd service:

   Linux 8.X and Linux 9.X:

   ```bash
   systemctl restart vsftpd
   ```

## 4.4. Network Time Protocol

### 4.4.1. How NTP works

TNMS uses Network Time Protocol (NTP) and dedicated time servers to synchronize and manage NEs. The servers have a hierarchical, Client-Server relationship between them. Table 11: NTP hierarchy of management components (p. 31) shows an example of such a hierarchy with four Clients. Network components on stratum level n use the stratum level n-1 component as time server.

**Table 11: NTP hierarchy of management components**

| Network component | Type | Time server | Stratum |
| --- | --- | --- | --- |
| Top Level Time Server | GPS clock | | 0 |
| Server | LINUX server | Top Level Time Server | 1 |
| Client 1, Client 2, Client 3, Client 4 | Windows PC | Server | 2 |

If the NE is a Gateway NE (GNE), the respective time server is the TNMS Server. If the NE is reached via embedded channels, there will be an NTP chain between these NEs. Table 12: NTP hierarchy of NEs (p. 31) shows the typical configuration, starting at the Server, serving time to the GNE, assuming four elements in the NE chain. The numbers in brackets indicate the stratum level in case GNE 1 fails.

**Table 12: NTP hierarchy of NEs**

| Network component | Type | Time server | Stratum |
| --- | --- | --- | --- |
| Server | LINUX server | Top Level Time Server | 1 |
| NE 1 (GNE) | LINUX | Server (NE 2) | 2 (5) |
| NE 2 | LINUX | NE 1 (NE 3) | 3 (4) |
| NE 3 | LINUX | NE 2 (NE 4) | 4 (3) |
| NE 4 (GNE) | LINUX | NE 3 (Server) | 5 (2) |

Each network component requires a specific installation and configuration. In an NTP network, each node is identified by its IP address or computer name, and holds a configuration file (`ntp.conf`) referring to its time servers by IP address.

> **Note:** Although NEs may also have an `ntp.conf` file, EMs handle their NTP management. For information on the NEs’ NTP configuration see NE-specific documentation.

### 4.4.2. Configuring NTP

Configure the Server as follows:

1. Edit configuration file `/etc/chrony.conf`.

   Issue:

   ```bash
   vi /etc/chrony.conf
   ```
2. Add the NTP server address and other NTP configurations to the `chrony.conf` file:

   ```text
   server aaa.bbb.ccc.ddd
   ```

   Where "aaa.bbb.ccc.ddd" is the external NTP Server's IP.

   It is recommended to set two external NTP Servers, a Primary and a Backup.
3. Enable the NTP service.

   Issue:

   ```bash
   systemctl enable --now chronyd
   ```
4. Check the NTP service status and start it if necessary.

   Issue:

   ```bash
   systemctl is-active chronyd
   systemctl start chronyd
   ```

## 4.5. Secure Shell/SSH File Transfer Protocol

It is necessary to configure the SSH File Transfer Protocol (SFTP) settings for correct use in TNMS.

> **Note:** Networks that include 7100 Nano or 7100 OTS NEs are not compatible with SFTP in RHEL 9. Refer to the TNMS Troubleshooting Manual > SFTP Operations Failing in RHEL 9 for 7100 Nano or 7100 OTS NEs chapter to configure an external SFTP server.

### 4.5.1. Recommend SFTP Settings:

1. Log in as root.
2. Edit the SSH daemon configuration file.

   Issue:

   ```bash
   cd /etc/ssh
   vi sshd_config
   ```
3. Set the following in `sshd_config`:

   ```text
   MaxStartups 150
   MaxSessions 100
   TCPKeepAlive yes
   ClientAliveInterval 60
   ClientAliveCountMax 5
   ```
4. Make changes effective by restarting the daemon.

   Issue:

   ```bash
   systemctl restart sshd
   ```

### 4.5.2. Enable SHA-1

SHA-1 usage for signatures is restricted in the default system-wide cryptographic policy in RHEL 9. For networks that include mTera and hiT 7300 NEs with the TNMS Server in RHEL 9, SHA-1 must be enabled:

1. Login as root
2. Enable SHA-1.

   Issue:

   ```bash
   update-crypto-policies --set DEFAULT:SHA1
   ```
3. Reboot the system.

   Issue:

   ```bash
   reboot
   ```

### 4.5.3. Enable DSA Host Keys

Only required for networks that include 7100 Nano or 7100 OTS NEs and the TNMS Server is in RHEL 8.

OpenSSH packaged in Linux disables DSA host keys by default. The keys must be regenerated and manually enabled in TNMS Servers / TNMS Mediations running in Linux RHEL 8 that manage 7100 Nano or OTS NEs. To regenerate the keys, do as follows.

1. Login as root.
2. To create new DSA keys run:

   ```bash
   ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
   ```

   > **Note:** The passphrase MUST be empty.
3. Edit `/etc/ssh/sshd_config` and add or uncomment the following lines:

   ```text
   HostKey /etc/ssh/ssh_host_dsa_key
   PubkeyAcceptedKeyTypes=+ssh-dss
   HostkeyAlgorithms=+ssh-dss
   ```
4. Optional step, only required if SELinux is being used.

   Issue:

   ```bash
   restorecon -v /etc/ssh/*
   ```
5. Edit `/etc/sysconfig/sshd` and add or uncomment the following line:

   ```text
   CRYPTO_POLICY=
   ```
6. Restart ssh service.

   Issue

   ```bash
   systemctl restart sshd
   ```

## 4.6. Proxy Settings

If the environment variable `http_proxy` is configured in the operating system, make sure it is defined for all users using this syntax:

```text
http_proxy=http://proxy.domain:3128
```

where `proxy.domain` is the name of the proxy server with the network domain.

## 4.7. Required Configuration Values

This chapter describes the specific configurations set at installation that must not be modified to enable the correct functioning of TNMS.

### 4.7.1. Umask Configuration

The root user must have the umask default value set to 0022.

> **Note:** Modifying the umask default value is not supported.

To verify the umask default value:

1. Log in as root
2. Execute the below command:

   Issue:

   ```bash
   umask
   ```

   The command output should be: `0022`

### 4.7.2. No noexec in /tmp

During software installation and priority update installation there should be no noexec attribute set for `/tmp` partition.

To achieve no noexec in `/tmp` partition:

1. Execute the below command to check the partition attributes.

   ```bash
   cat /etc/fstab | grep /tmp
   ```
2. Remove noexec attribute and remount the partition if set.

   After installation the partition attributes can be restored to original values.

### 4.7.3. Kernel Parameters

The kernel parameters `kernel.shmall` and `kernel.shmmax` should be their initial values, or, above the minimum values recommended by Oracle, which are:

- `shmmax` should be half the physical memory size, measured in bytes.

  To verify `shmmax` value, execute:

  ```bash
  cat /proc/sys/kernel/shmmax
  ```
- `shmall` should be greater than or equal to value of `shmmax`, measured in pages.

  To verify `shmall` value, execute:

  ```bash
  cat /proc/sys/kernel/shmall
  ```

## 4.8. Other Configurations

### 4.8.1. Extended File System Attributes

This is only applicable to ext4 filesystem:

Check that the extended attributes of the file system are enabled.

To do so, check the properties of the device where the file system is mounted:

1. Find the device:

   Issue:

   ```bash
   df <Product_Installation_Folder>
   ```

   Output:

   ```text
   Filesystem 1K-blocks Used Available Use% Mounted on
   /dev/mapper/rootvol-root 72117368 45155488 23275480 66% /
   ```
2. Check the properties of the device:

   Issue:

   ```bash
   /sbin/dumpe2fs -h /dev/mapper/rootvol-root 2>/dev/null | grep 'Default mount options'
   ```

   Output:

   ```text
   Default mount options: user_xattr acl
   ```

   If the default mount option is `user_xattr` the file system has the extended attributes enabled.

### 4.8.2. File System ACL

This is only applicable to ext4 filesystem:

1. Edit the file `/etc/fstab`.
2. Find each line with: `<dir>` `/`, `<dir>` `/oradata/ora1`, `<dir>` `/oradata/ora2`, `<dir>` `/oradata/ora3`, `<dir>` `/nokia`. For example:

   **Table 13: File System Mounting Options 1**

   | `<device>` | `<dir>` | `<type>` | `<options>` | `<dump>` | `<fsck>` |
   | --- | --- | --- | --- | --- | --- |
   | `/dev/sda1` | `/` | ext4 | defaults,acl | 0 | 1 |

   or:

   **Table 14: File System Mounting Options 2**

   | `<device>` | `<dir>` | `<type>` | `<options>` | `<dump>` | `<fsck>` |
   | --- | --- | --- | --- | --- | --- |
   | `UUID=e3a3a46c-4730` | `/` | ext4 | defaults,acl | 0 | 1 |
3. In each line referring to the mountpoint directories listed in the previous step, check if `,acl` is written after `defaults` and, if not, add it. Otherwise no change is required.
4. Restart the machine to apply the permissions.

### 4.8.3. Swap Configuration

TNMS requires a swap configuration of at least 50% of physical memory size. When the TNMS Server and TNMS Mediation are installed in different machines (TNMS Special Deployment), TNMS mediation requires a swap configuration of 100% of the physical memory size. Check the configured swap by issuing:

```bash
swapon -s
```

In the following example of a system output, size is displayed in bytes:

| Filename | Type | Size | Used | Priority |
| --- | --- | --- | --- | --- |
| /dev/sda6 | partition | 15938556 | 0 | -1 |

> **Note:** If no output is provided then no swap is configured in the system, to confirm use the free command. Refer to chapter Disk Configuration (p. 19) for the required swap configuration.

### 4.8.4. Firewall Configuration

By default, the firewall is enabled after the operating system installation. To connect TNMS Client from remote clients, the firewall must be temporarily disabled.

Issue:

```bash
systemctl stop firewalld
systemctl disable firewalld
```

For security purposes, the firewall (i.e iptables) must be enabled. Refer to chapter Networking and Firewall Configuration in the TNMS Administration Manual.
