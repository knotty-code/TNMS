Source: installation_manual_linux.pdf, chapter 5, pages 37–41.

# 5. Software Prerequisites Installation

> **Tip:** It is highly recommended to take note of relevant configurations using the TNMS Installation Checklist (Linux) spreadsheet.

For more information regarding this checklist refer to TNMS Installation Checklist (p. 12).

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 5.1. Database Software Download and Preparation

In terms of licensing, TNMS requires Oracle Database Server Enterprise Edition with the partitioning option. The database is installed and automatically configured to comply with the Center for Internet Security (CIS) security recommendations.

Extract the V9.1 DB SW Installation (Linux) archive (downloaded from the Customer Portal) to a new location. The default path is `/opt/oracle/oramedia`:

1. Log in as root.
2. Create the Database Software installation directory.

   Issue:

   ```bash
   mkdir -p /opt/oracle/oramedia
   ```
3. Extract the V9.1DB SW Installation (Linux) archive to `/opt/oracle/oramedia`.

   > **Note:** The number of database zip files in the V9.1 DB SW Installation (Linux) archive varies from release to release. Refer to the Release Notes for exact files included in TNMS release.

## 5.2. TNMS Database Installation and Configuration

1. Log in as root.
2. Insert the TNMS software for Linux disc and mount the drive unit.
3. Extract the content of TNMS software prerequisites to a directory with read permissions for all users, for example, `/install`.

   > **NOTICE:** The database software may be incorrectly installed if you:
   >
   > - Run the installation script (`./installation.sh`) from within a directory without read permissions, such as `/root` or `/home`.
   > - Perform any changes (directory structure, files and their location) to the extracted files and folders.
4. Ensure that all extracted files are readable to all users and the directories have execution permissions.

   Issue:

   ```bash
   find /install/TNMS_Prerequisites/Oracle -type d -exec chmod 755 {} \;
   find /install/TNMS_Prerequisites/Oracle -type f -exec chmod 644 {} \;
   find /install/TNMS_Prerequisites/Oracle -name '*.sh' -exec chmod 755 {} \;
   ```
5. Go to `<path>/TNMS_Prerequisites/Oracle/installation`.
6. Issue as root:

   ```bash
   ./installation.sh
   ```
7. Accept the End User License Agreement.
8. Accept the configuration of Huge Pages by the Database.
9. Select your configuration. by entering S for Small, SP for Small Plus, M for Medium or L for Large.
10. If a Large Configuration was selected in the previous step, choose if Node Manager should be installed.
11. Enter the ORADATA path, or accept the default, `/oradata`.
12. If required, enter the Installer zip file, or accept the default.

    This file is in `/opt/oracle/oramedia`, if the database software zip files were copied to the default location.
13. If required, enter the TNMS Installer folder path, or accept the default.
14. If required, enter the `TNMS.rsp` path or accept the default.
15. If required, enter the template file path or accept the default.

    The installer will now verify the requirements as shown in the example below:

    ```text
    Verifying requirements...
    ..-Verifying system requirements...done.
    ..-Verifying disk requirements...done
    ..-Verifying memory requirements...done
    ..-Verifying swap requirements...done
    ..-Verifying hostname...done
    ..-Verifying if NIS domain name is empty...done
    ..-Verifying User and Group configuration...done.
    ..-Verifying directories... done.
    ```

    If any error message is displayed (for example: Error in the `/etc/hosts` file), correct it before proceeding to the next step.

    As an example, an error in memory configuration is shown below:

    ```text
    ..-Verifying memory requirements...Error. Check RAM memory. Total: 8 GB.
    Required: 16 GB. Error checking requirements. Are you sure you want to continue (YES/no)? [no] :
    ```
16. Enter a name with 1 to 8 characters for the TNMS database, or accept the default name, TNMS.

    Valid names start with an upper case character (A-Z), followed by upper case characters (A-Z) or numbers (0-9).
17. Enter the listener port or press Enter to use the default port [1521].
18. Type the password for the default database administrator user SYS. Refer to Database User Password Complexity Rules (p. 50) section.

    > **Note:** Keep the username and password for future reference.
19. Type the SYS password again.
20. Type the password for the default database administrator user SYSTEM with at least 6 characters and a maximum of 30.

    Refer to Database User Password Complexity Rules (p. 50) section.

    > **Note:** Keep the username and password for future reference.
21. Type SYSTEM password again.

    Afterwards the installation process installs and configures the database.

    Wait until the installation process is finished. This step may take several minutes and the progress can be seen in `/tmp/oracle_installation:<timestamp>.log`.

    At the end of a successful installation the following message is displayed:

    ```text
    Final status of the execution: Success
    ```

    > **Note:** At the end of the installation, the Oracle logs are written to the following folder: `/home/oracle/ossnms_installation_log`

    > **NOTICE:** The operating system user `orabackup` has been created and added to the `dba` group. This user must have no password expiration date and must not be deleted or removed from this group.
22. After a successful installation of the TNMS Database, navigate to the Database Software installation folder (by default `/opt/oracle/oramedia`).
23. Delete the V9.1 DB SW Installation (Linux) zip files and the corresponding extracted folders.

## 5.3. Installing Database Security Patches

Oracle publishes regular patch updates with fixes for multiple security vulnerabilities. These patches must be applied to ensure correct system behavior.

> **Note:** For a comprehensive list of the Database Security patches applicable to this release, please refer to the Database Security patches chapter in the Release Notes Appendix.

Before proceeding, extract the V9.1 DB Security Patch (Linux) archive (downloaded from the Customer Portal) to a new location (by default `/opt/oracle/oramedia`):

1. Log in as root.
2. Create the directory (by default `/opt/oracle/oramedia`), if it was not already created in Step 2 (p. 37).

   Issue:

   ```bash
   mkdir -p /opt/oracle/oramedia
   ```
3. Extract the V9.1 DB Security Patch (Linux) archive to `/opt/oracle/oramedia/`.

   This archive contains the Database Security patches (`p<number>_<version>_<Linux_Version>.zip`) and the Patch Installation zip file (`patch.zip`).

### 5.3.1. Installing Database Security Patches

1. In the TNMS Server Machine, log in as root.
2. In the oramedia directory (by default `/opt/oracle/oramedia`), extract the `patch.zip` file and execute.

   Issue:

   ```bash
   chown -R oracle:dba .
   chmod 744 ./patch/patch.sh
   ```
3. Apply the Database Security patches as Database software owner.

   Issue:

   ```bash
   su - oracle
   cd /opt/oracle/oramedia/patch (if default path was chosen)
   ./patch.sh
   ```
4. Enter the directory where the Database Security patches are located, or accept the default (`/opt/oracle/oramedia`).

   > **Note:** If a database shutdown is required, the script will ask you to shutdown the application before proceeding. If applicable, type y to continue.

   The script can be re-executed in case of failure.

   A successful execution ends with the message:

   ```text
   Final status of the execution: Success
   ```

   > **Note:** At the end of the installation, the Database logs are written to the following folder: `home/oracle/ossnms_installation_log`
5. After a successful installation of the TNMS Database Security Patches, navigate to the Database Software installation folder (by default `/opt/oracle/oramedia`).
6. Delete the following files:
   - The V9.1 DB Security Patch (Linux) archive.
   - All Database Security patches zips (`p<number> <version> <Linux Version>.zip`)
   - The Patch Installation zip (`patch.zip`)
   - All extracted archives: directories patch and directories `<number>`

### 5.3.2. Security Patches Installation Troubleshooting

> **Note:** Consult the individual patch logs for more details about the errors in the table below. The logs can be found in `/home/oracle/ossnms_installation_log/ossnms_patch_installation_<timestamp>`.

**Table 15: Security Patch Logs**

| Message | Cause | Solution |
| --- | --- | --- |
| OPatch failed with error Code = 73. Prerequisite "CheckSystem-Space" failed. Required amount of space is not available. | Not enough free space in drive | Free the amount of space required and reapply the patch, |
| Error applying datapatch in [database name] | Internal datapatch issue | Restart patch installation. |

> **Gap:** PDF page 41, see installation_manual_linux.pdf. Both solution cells are cut off at the page edge.
