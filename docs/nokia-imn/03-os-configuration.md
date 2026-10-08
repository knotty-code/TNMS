Source: installation_manual_linux.pdf, chapter 3, pages 18–28.

# 3. TNMS Server Operating System Configuration

This chapter describes the procedures to install and configure the operating system of the TNMS Server. Before installing the server operating system, you must create and configure the logical drive where Linux OS will be installed.

The following chapter applies to the recommended small, small plus, medium and large hardware configurations only and these steps may differ in case you have any other hardware configurations.

> **NOTICE:** Only fresh installations are covered
>
> The Server software must either have been uninstalled from or never have been installed on, the machine in question.
>
> Perform the server installation in the order and strictly as prescribed.
>
> Failure to do so will cause the Server to malfunction.

> **Note:** The screen output in the current manual, while generally correct, is given as an example. Depending on your particular configuration, actual output may differ.

> **NOTICE:** The instructions in this chapter refer to HP machines and may differ for other hardware configurations.

> **Tip:** It is highly recommended to take note of relevant configurations using the TNMS Installation Checklist (Linux) spreadsheet.
>
> For more information regarding this checklist refer to chapter TNMS Installation Checklist (p. 12).

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 3.1. Integrated Lights-Out (iLO 6) Management Console

This chapter describes how to operate the Integrated Lights-Out (iLO) management console. This console is used to access the server machine and for administration purposes. Refer to the iLO specific documentation for further information.

### Accessing the Integrated Remote Console

Use the following information to access the console:

1. Address: `https://<machine IP>`
2. Username: `<user>`
3. Password: `<password>`
4. In the left panel tree, expand **Information** > **Overview**, and in **Integrated Remote Console**, click the **.NET** link.

## 3.2. Disk Configuration

It is recommended that you configure a RAID 1 for the disks where the operating systems will be installed.

While booting the machine, proceed as follows:

1. When the **Press any key to view Option ROM messages** appears, click **ENTER**.
2. When the internal controller displays the message **Press F10 to enter the Intelligent Provisioning**.
3. In the **Intelligent Provisioning Performance Maintenance** page, select **Intelligent Storage Configuration**.
4. In the **Intelligent Storage Configuration** > **Logical Drives** tab, select **Create Array**.
5. Using the default settings, create the RAID 1 configuration with the two available hard drives.

> **Note:** Select the appropriate RAID configuration and the layout of disks and file system as both will be requested later on.

> **Note:** It is also possible to configure additional mount points (for example, to comply with CIS Hardening specifications) from the disk space reserved to the root File System. For more information refer to the CIS Hardening Checklist available in the 9.1 TNMS_Prerequisites > Documentation folder.

**Table 7: Logical Disk Configuration**

| Logical name | FE RAID | FE disks | Small RAID | Small disks | Small Plus RAID | Small Plus disks | Medium RAID | Medium disks | Large RAID | Large disks |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sda | 1 | 2 | 1 | 2 | 1 | 2 | 1 | 2 | 1 | 2 |
| sdb | — | — | — | — | 1 | 2 | 1 | 2 | 6 | 6 |

**Table 8: File system and disk space size**

| Volume | Mount point | File system | FE (GB) | Small (GB) | Small Plus (GB) | Medium (GB) | Large (GB) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| /dev/sda | / | ext4 or xfs | 150 | 940 | 150 | 150 | 170 |
| /dev/sda | swap | swap | 100 | 60 | 100 | 100 | 130 |
| /dev/sda | /tmp | ext4 or xfs | 50 | — | 50 | 50 | 60 |
| /dev/sda | /oradata/ora1 | ext4 or xfs | — | — | 300 | 700 | 600 |
| /dev/sdb | /oradata/ora2 | ext4 or xfs | — | — | 300 | 500 | 2500 |
| /dev/sdb | /oradata/ora3 | ext4 or xfs | — | — | 150 | 250 | 1500 |
| /dev/sda | /nokia | ext4 or xfs | 100 | — | — | — | — |
| /dev/sdb | /nokia | ext4 or xfs | — | — | 150 | 250 | 800 |

> **Note:** File system formats (ext4 or xfs) must be the same in all partitions, except for the swap.

## 3.3. Linux Installation

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. This chapter contains instructions for RHEL installation only. All subsequent Linux instructions, hardening and commands in this manual are also based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

### 3.3.1. Internet Protocol Address Standards

TNMS supports different standards in Internet Protocol (IP) addresses and can migrate from an IPv4 Data Communication Network to an IPv6 infrastructure.

The user configures the NE to work with IPv4, IPv6 or both, depending on the capabilities of the NE. For example, a user can specify a unique IPv6 address as an alternative to IPv4 addresses in a dual-stack infrastructure, if the NE supports IPv6.

#### IPv4

IPv4 addresses are 32-bit, numeric dotted decimal notation addresses, for example: 192.159.252.76.

#### IPv6

IPv6 addresses are 128-bit, Hexadecimal notation (0-9 and A-F) addresses, for example: 3FFE:F200:0234:AB00:0123:4567:8901:ABCD.

All fields in TNMS that support IPv6 addresses:

- Automatically validate the formatting of IPv6 address.
- Automatically validate the special address restrictions.

**Table 9: IPv6 Special Address Restrictions**

| Address block (CIDR) | First address | Last address | Number of addresses | Purpose |
| --- | --- | --- | --- | --- |
| ::/128 | :: | :: | 1 | Unspecified address. |
| fe80::/10 | fe80:: | febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff | 2^118 | Link-local address |
| ff00::/8 | ff00:: | ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff | 2^120 | Multicast address. |

### 3.3.2. Installing Linux

> **Note:** The host IP addresses are static. Do not use DHCP dynamic addresses.

#### 3.3.2.1. Installing Linux 8.X or 9.X

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

Linux Red Hat Enterprise Linux is to be installed on the required hardware (see Table 3: Hardware requirements for installations of TNMS (p. 14)).

To install Linux follow the steps below. Use the arrow keys to move up and down, and **Enter** to select the desired option:

1. Start the machine with the Linux Installation DVD in the DVD-ROM drive.

   The Linux installation welcome screen is displayed
2. Select **Test this media & install Red Hat Enterprise Linux**.

   The disk currently in the drive will be tested for possible errors.

   If the test is successful, the installation begins.
3. In the language selection step, select for example **English (United States)**.

   Click **Continue**.

   The **Installation Summary** is displayed.
4. In the **Installation Summary** click on **Time & Date**.

   1. In the **Time & Date** step select your region, city, date and time.

      Click **Done** to return to the **Installation Summary**.
5. In the **Installation Summary** click on **Software Selection**.

   1. In the **Software Selection** step select **Server with GUI** as **Base Environment**.

      Click **Done** to return to the **Installation Summary**.
6. In the **Installation Summary** click on **Installation Destination**.

   1. In the **Installation Destination** step select the appropriate disks and select **Custom** under **Storage Configuration**. Click **Done**.
   2. In the **Manual Partitioning** step configure the partitions according to:

      - Table 7: Logical Disk Configuration (p. 19)
      - Table 8: File system and disk space size (p. 19)

      Click **Done**.
   3. In the **Summary of Changes** review the partitioning setup you made and click **Accept Changes**.

      > **Note:** No changes to the disks will be made until you begin the installation (in step 8 below)

      Click **Done** to return to the **Installation Summary**.
7. In the **Installation Summary** click on **Network and Host Name**.

   1. In the **Network and Host Name** step select the network interface card and turn the switch in the upper right corner of the window on.

      Enter the host name in the field **Host name**.

      Click **Configure** to edit the settings of the selected network interface card.
   2. In the **Editing `<network interface card name>`** window click on the **IPv4 Settings** tab.
   3. Select the **Method**: **Manual** and enter your network settings.

      Click **Save** and then **Done**.
8. In the **Configuration** screen, click on **Root password**.

   1. In the **Root password** enter a password and reenter it.
   2. Click **Done** to return to the **Configuration** screen.
9. In the **Installation Summary**, click on **Begin Installation**.

   The **Configuration** screen is displayed with a progress bar showing the installation progress.
10. After the installation finishes, click **Reboot**.
11. In the **Initial Setup** step, press 1 to select **License Information**.
12. In the **License Information** step, select **I accept the License Agreement**.

    Click **Done**.
13. Press **Finish Configuration**.
14. The **Welcome** step is displayed.

    Click **Next**.
15. In the **Privacy** step, turn off the **Location Services**.

    Click **Next**.
16. In the **Connect Your Online Accounts** step click **Skip**.
17. In the **About You** step add the user details. For example:

    - **Full Name**: System Administrator
    - **Username**: SysAdmin

    > **Note:** "tnms" is not a valid Username.

    Click **Next**.
18. In the **Set a password** step enter and reenter the user password.

    Click **Next**.
19. In the final step click **Start using Red Hat Enterprise Linux Server**.

The Red Hat Enterprise Linux Server installation is complete.

### 3.3.3. Configuring Database Filesystems

> **Note:** This is only applicable to ext4 filesystems.

For Small Plus, Medium and Large configurations run the following commands to configure the database system:

1. Login as root.
2. Execute:

   ```bash
   df | grep oradata | cut -d ' ' -f1
   ```

   The output of this command will show the device names for the database data directories. For example:

   ```text
   /dev/sda3

   /dev/sda1

   /dev/sda2
   ```

3. Execute the following command for each device listed in step 2:

   ```bash
   tune2fs -m0 device_name
   ```

   For example:

   ```bash
   tune2fs -m0 /dev/sda3
   tune2fs -m0 /dev/sdb1
   tune2fs -m0 /dev/sdb2
   ```

### 3.3.4. Creating Additional Directories

The following steps are only required for the TNMS Small Configuration. The folders should already exist for the Small Plus, Medium and Large Configurations.

To create the additional directories, do as follows:

1. Login as root.
2. As root create the following directories to support TNMS.

   Issue:

   ```bash
   mkdir -p /oradata/ora1
   mkdir -p /oradata/ora2
   mkdir -p /oradata/ora3
   ```

### 3.3.5. Installing Additional Packages

Some additional operating system packages need to be installed. To do so follow the steps below.

> **Note:** For offline installations of Linux, these packages must be downloaded and available in the TNMS Server Machine before proceeding.

#### 3.3.5.1. Linux 8.X

Add repositories and install additional operating system packages:

1. Add the EPEL repository.

   For example as root issue:

   ```bash
   dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
   ```

2. If ZTC is installed, add the KEA Repository.

   For example, as root issue:

   ```bash
   wget https://dl.cloudsmith.io/public/isc/kea-2-6/setup.rpm.sh
   chmod +x setup.rpm.sh
   ./setup.rpm.sh
   ```

3. Download and install the packages below. This can be done manually (with rpm package manager) or automatically (by configuring a package manager).

   - `alsa-lib*`
   - `atk*`
   - `at-spi2-atk*`
   - `at-spi2-core*`
   - `attr`
   - `bash*`
   - `bc`
   - `ca-certificates*`
   - `cairo*`
   - `chkconfig*`
   - `cups-libs*`
   - `dbus-libs*`
   - `elfutils-libelf-devel`
   - `expat*`
   - `fontconfig-devel`
   - `ftp` (Install only if required by legacy NEs; refer to NE Release Notes)
   - `gcc`
   - `gcc-c++`
   - `glib2*`
   - `glibc*`
   - `gtk3*`
   - `isc-kea-dhcp4-2.6.3` (only if ZTC is installed)
   - `jemalloc`
   - `ksh`
   - `libaio-devel`
   - `libnsl*2*`
   - `libnsl.i686` (For networks with 5500 NEs)
   - `libstdc++.i686` (For networks with 5500 NEs)
   - `libXext*`
   - `libXi*`
   - `libX11*`
   - `libXrender*`
   - `libXcomposite*`
   - `libXdamage*`
   - `libXfixes*`
   - `libXtst`
   - `libXrandr*`
   - `libcurl*`
   - `libdrm*`
   - `liberation-fonts*`
   - `libgcc*`
   - `libxcb*`
   - `libxkbcommon*`
   - `mesa-libgbm*`
   - `libzip`
   - `make`
   - `nspr*`
   - `nss*`
   - `nss-util*`
   - `pango*`
   - `psmisc`
   - `protobuf` (only if ZTC is installed)
   - `sysstat`
   - `vsftpd` (Install only if required by legacy NEs; refer to NE Release Notes)
   - `vulkan-loader*`
   - `wget*`
   - `xdg-utils*`
   - `xorg-x11-server-Xvfb*`
   - `zlib.i686` (For networks with 5500 NEs)

`*` For networks that include eDNA.

#### 3.3.5.2. Linux 9.X

Add repositories and install additional operating system packages:

1. Add the EPEL repository.

   For example, as root issue:

   ```bash
   dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
   ```

2. If ZTC is installed, add the KEA Repository.

   For example, as root issue:

   ```bash
   wget https://dl.cloudsmith.io/public/isc/kea-2-6/setup.rpm.sh
   chmod +x setup.rpm.sh
   ./setup.rpm.sh
   ```

3. Download and install the packages below. This can be done manually (with rpm package manager) or automatically (by configuring a package manager).

   - `alsa-lib*`
   - `alternatives*`
   - `at-spi2-atk*`
   - `at-spi2-core*`
   - `atk*`
   - `attr`
   - `bash*`
   - `bc`
   - `binutils`
   - `ca-certificates*`
   - `cairo*`
   - `cups-libs*`
   - `compat-openssl11`
   - `chkconfig`
   - `dbus-libs*`
   - `elfutils-libelf`
   - `elfutils-libelf-devel`
   - `expat*`
   - `fontconfig`
   - `fontconfig-devel`
   - `ftp` (Install only if required by legacy NEs; refer to NE Release Notes)
   - `glibc`
   - `glibc-devel`
   - `glib2*`
   - `gtk3*`
   - `isc-kea-dhcp4-2.6.3` (only if ZTC is installed)
   - `jemalloc`
   - `ksh`
   - `libaio`
   - `libasan`
   - `libcurl*`
   - `libdrm*`
   - `liberation-fonts*`
   - `liblsan`
   - `libX11`
   - `libXau`
   - `libXi`
   - `libXrender`
   - `libXtst`
   - `libxcrypt-compat`
   - `libgcc`
   - `libibverbs`
   - `libnsl*2*`
   - `librdmacm`
   - `libstdc++`
   - `libxcb`
   - `libxkbcommon*`
   - `libxcomposite*`
   - `libXdamage*`
   - `libvirt-libs`
   - `libnsl.i686` (For networks with 5500 NEs)
   - `libstdc++.i686` (For networks with 5500 NEs)
   - `libXext*`
   - `libXfixes*`
   - `libXrandr*`
   - `make`
   - `mesa-libgbm*`
   - `net-tools`
   - `nspr*`
   - `nss*`
   - `nss-util*`
   - `pango*`
   - `policycoreutils`
   - `policycoreutils-python-utils`
   - `polkit`
   - `protobuf` (only if ZTC is installed)
   - `smartmontools`
   - `sysstat`
   - `vsftpd` (Install only if required by legacy NEs; refer to NE Release Notes)
   - `vulkan-loader*`
   - `wget*`
   - `xdg-utils*`
   - `xorg-x11-server-Xvfb*`
   - `zlib.i686` (For networks with 5500 NEs)

`*` For networks that include eDNA.

### 3.3.6. Checking the System Locale

After installing the OS, ensure the system locale is correct by executing the following command:

1. Login as root.
2. Issue:

   ```bash
   locale
   ```

   The following is an example of the command output:

   ```text
   LANG=pt_PT.UTF-8
   LC_CTYPE="pt_PT.UTF-8"
   LC_NUMERIC="pt_PT.UTF-8"
   LC_TIME="pt_PT.UTF-8"
   LC_COLLATE="pt_PT.UTF-8"
   LC_MONETARY="pt_PT.UTF-8"
   LC_MESSAGES="pt_PT.UTF-8"
   LC_PAPER="pt_PT.UTF-8"
   LC_NAME="pt_PT.UTF-8"
   LC_ADDRESS="pt_PT.UTF-8"
   LC_TELEPHONE="pt_PT.UTF-8"
   LC_MEASUREMENT="pt_PT.UTF-8"
   LC_IDENTIFICATION="pt_PT.UTF-8"
   LC_ALL=
   ```

   Make sure the `LANG` variable is set to a UTF-8 encoding and that the `LC_ALL` variable is not set.

   In case the `LANG` variable is not set, or the `LC_ALL` is set, edit the Linux system configuration file for the locale information: `/etc/sysconfig/i18n`.

   For example:

   ```text
   LANG="en_US.UTF-8"
   ```

   If no UTF-8 locale is defined in `LANG`, `LC_CTYPE` or `LC_ALL` in the output above, check there are UTF-8 encodings for your language:

   ```bash
   locale -a | grep -i utf
   ```

   If no output is returned, install the language packs for your region.
