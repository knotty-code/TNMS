Source: installation_manual_linux.pdf, chapter 6, pages 42–58.

# 6. TNMS Installation

This chapter describes the TNMS installation. If you have a previous TNMS version installed in your system, jump to Update TNMS (p. 65).

Before you install TNMS be sure to read and follow the directions below. Failing to comply will result in a failed installation.

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 6.1. Installation Packages

TNMS is delivered with a Full Installation Package (Main), as well as Legacy LCTs Package (Legacy LCTs).

- Main: includes TNMS, OEMs and LCTs.
- Legacy LCTs: includes legacy LCTs and their required OEMs. For a list of Legacy LCTs refer to the TNMS Release Notes, Supported NEs chapter.

> **Note:** For more information on upgrading TNMS refer to the TNMS Upgrade Manual.

> **Tip:** It is highly recommended to take note of relevant configurations using the TNMS Installation Checklist (Linux) spreadsheet. For more information regarding this checklist refer to TNMS Installation Checklist (p. 12).

## 6.2. TNMS Installer Integrity Validation

Before proceeding with the TNMS Installation, the Full Installation Package (Main) must first be verified and extracted. This must be done in each machine that the TNMS Server, TNMS Mediation or TNMS Client will be installed.

1. Verify the checksum against the one provided.

   Issue:

   ```bash
   sha256sum <Installer Zip File>
   ```

2. Extract the TNMS software to a directory in the machine, now referred to as `<Product_Installer_Folder>`.

   > **NOTICE:** The `<Product_Installer_Folder>` must not be in the same directory as the `<Product_Installation_Folder>` or the `<Product_Data_Folder>`.

3. If Legacy LCTs are required:

   **Step 3a.** Verify the checksum against the one provided.

   Issue:

   ```bash
   sha256sum TNMS _Legacy_LCTs_zip
   ```

   **Step 3b.** Extract the TNMS Legacy LCTs to the `<Product_Installer_Folder>`.

4. Verify that the latest available 9.1 PDTs in the Nokia Customer Portal are downloaded and stored in `<Product_Installer_Folder>\TNMS_Installer\PUs`.

## 6.3. Prerequisites and Validation before TNMS Installation

Ensure prerequisites are validated before installing TNMS.

> **Note:** This script is applicable only for Linux 9.X.

1. Go to `<Product_Installation_Folder>/TNMS_Installer/verify_prerequisites`.
2. Set execution permissions for the `verify_prerequisites_tnms.sh` script.

   Issue:

   ```bash
   chmod +x verify_prerequisites_tnms.sh
   ./verify_prerequisites_tnms.sh
   ```

   Follow the instructions. The script checks requirements and concludes with one of the following messages:

   - Error: Missing requirement.
   - Warning: Review needed before installation.
   - Ok: All requirements met.

> **Note:** Ensure all errors are corrected before installation.

## 6.4. TNMS Server and Mediation Installation

To install TNMS Server and Mediation:

1. Log in as root.
2. Configure the TNMS FE Server connection.

   > **Note:** This step is only applicable if TNMS FE Servers are included in the system.

   Configure the Server as follows:

   **Step 2a.** Edit the file `/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora`.

   **Step 2b.** Add the IPs of the TNMS FE Server machines to the property `TCP.INVITED_NODES`.

   For example:

   ```
   TCP.INVITED_NODES=(127.0.0.1, loghost)
   ```

   should be changed to

   ```
   TCP.INVITED_NODES=(127.0.0.1, loghost, 10.79.32.160,10.46.84.68)
   ```

   where 10.79.32.160 and 10.46.84.68 are the TNMS FE machine.

   **Step 2c.** Reload the database listener.

   Issue:

   ```bash
   su - oracle
   lsnrctl stop lisner
   lsnrctl start lisner
   exit
   ```

3. Go to `<Product_Installer_Folder>`, created during the TNMS Installer Integrity Validation (p. 42) and manually assign Execution permissions.

   Issue:

   ```bash
   cd <path>/TNMS_Installer
   chmod 744 ./TNMS.bin
   ```

4. Start the installation wizard.

   Run:

   ```bash
   ./TNMS.bin
   ```

   The installation wizard opens in **Introduction** and the complete list of installation steps is displayed on the left pane.

5. Read the License Agreement and select **I accept the terms of the License Agreement**.
6. In **Installation Package**, click **TNMS Server and Mediation**.
7. In **Server Preparation: Transcend Controller**:

   > **Note:** This step is only applicable if Transcend Controller is included in the system.

   **Step 7a.** Click **Enable Connection to Transcend Controller (TC)** to configure the following parameters:

   - **TC IP:** Transcend Controller IP address.
   - **TC OIF Port:** Transcend Controller OIF Port (Default is: 12443).
   - **TC Gateway Port:** Transcend Controller Gateway Port (Default is 12351).

   > **NOTICE:** This is needed for the correct interworking of TNMS and Transcend Controller functionalities (for example Hot Standby, Real-time Planning and Provisioning, etc). Before proceeding, ensure that the Transcend Controller Server IP and FQDN have been configured, refer to chapter System Hosts (p. 29).

8. In **Server Preparation: Hardware Configuration** select your hardware configuration: **Small**, **Small Plus**, **Medium** or **Large** (see Hardware Requirements (p. 13)).
9. In **Server Preparation: Customization**, select items to customize:

   - For each checked item the respective customization step is displayed. Either accept or change the default values.
   - Unchecked items will automatically apply defaults values to the installation.

   **Step 9a.** Users and groups checked.

   In **Users and Groups** enter:

   - **TNMS User Name** (default is `tnms`).

     Checking **Create** enables User ID.

   - **TNMS Group** (default is `tnms`).

     Checking **Create** enables Group ID.

   - **SFTP User Name** (default is `tnms_sftp`).

     Checking **Create** enables User ID.

   - **Database User Name** (database owner name. Default is `oracle`).

   > **Note:** The User ID and Group ID values must be numeric.

   - **DBA Group Name** (default is `dba`).

   > **NOTICE:** If the warning message **Users or usergroup being created already exist** is displayed, before proceeding delete the impacted user or user group.
   >
   > i. Login as root.
   >
   > ii. Delete applicable users or user groups. If default user and user group names are used, issue the applicable command:
   >
   > ```bash
   > userdel tnms
   > userdel tnms_sftp
   > groupdel tnms
   > ```

   **Step 9b.** Deployment Directories checked.

   In **Deployment Directories** enter the path of the following folders (default paths are provided):

   - **TNMS Installation Directory**

     If you choose a directory other than the default, the path cannot contain spaces.

     > **Note:** Throughout the customer documentation this folder will be referred to as `<Product_Installation_Folder>`. Take note of the location of this folder for future reference.

   - **TNMS Data Directory**

     If you choose a directory other than the default, the path cannot contain spaces.

     > **Note:** Throughout the customer documentation this folder will be referred to as `<Product_Data_Folder>`. Take note of the location of this folder for future reference.

   - **Database Installation Directory** (default is `/opt/oracle`)
   - **Database Data Directory**

     Enter the path you defined in 5.1.1 Installation and Configuration (default is `/oradata`). Backups will be stored under subfolders of this folder.

10. Only displayed if more than one IP is configured.

    In **Server Preparation: Connection Configuration**, enter the required IP for:

    - **Client Access:** The IP Address through which the TNMS server communicates with TNMS Clients.
    - **Server Backend Access:** The IP Address through which the TNMS server communicates with other connected systems.

    In Special Deployments:

    - TNMS Server installation: this is the IP Address through which the TNMS Server communicates with TNMS Mediation.
    - TNMS Mediation installation: this is the IP Address through which TNMS Mediation communicates with the NE Network.

11. In **Server Preparation: Database** select:

    - **New:** creates a clean database.
    - **Migration:** migrates an existing database. Use this option to add managers and NBIs to your database. The components already present in the database will be grayed out throughout the installation wizard. Some parameters will also not be displayed as they are defined in the database.

    > **Note:** Please refer to the TNMS Upgrade Manual for the supported migration paths.

12. In the **Server Preparation: Database Connection** enter the required information for the TNMS Database connection:

    - **Database IP Address:** IP assigned to the database to communicate with TNMS.
    - **Localhost:** Hostname of the local computer running TNMS (Default is `127.0.0.1`).
    - **Database Port:** Port assign to the database to communicate with TNMS (Default is `1521`).
    - **Database User Name:** Name of the database user (Default is `tnmsdba`).

    > **NOTICE:** Special characters are not allowed when selecting a different user name for the Database.

    > **NOTICE:** If a standby server is deployed in the network, the same user name and password must be used for both the Primary and Secondary Servers. It is recommended that the same user name and password are used in all server machine installations in the network, ensuring database restoration in any machine. If a standby server is not deployed in the network, unique user name and passwords can be used for each server machine if required for security reasons. Recording and storing all server user names and passwords in the Installation Checklist (refer to chapter TNMS Installation Checklist (p. 12)) is highly recommended to ensure that backup and restore can be performed when required in future.

    - **Database User Password:** Password for the database user that complies with the Password Complexity Rules.

    > **Tip:** Keep the user name and password for future reference, for example, in the TNMS Installation Checklist (p. 12).

    - **Re-enter Database User Password:** Re-enter the password.
    - **Database Name (SID):** Name of the database that has been created previously (DB instance), which, by default, is `TNMS` (Refer 5.1 Database Software Download and Preparation (p. 37)).
    - **Database User 'sys' Password:** Password defined in 5.1 Database Software Download and Preparation (p. 37) for the default database administrator user SYS.
    - **Home Directory:** Database home directory (Default is `/opt/oracle/product/19c/dbhome_1`).

13. In **Server Preparation: Advisory Message**:

    - Enable or disable an advisory message before login.
    - If enabled, write the desired advisory message in the box.

    This message will pop-up before a user's login.

14. In **Components:TNMS** select which managers to install.

    Selecting **Embedded DNA** will install eDNA Server. Applicable only for machines with a Medium or Large hardware configuration.

    > **NOTICE:** Node Manager and eDNA cannot be installed in the same machine.

    > **NOTICE:** The TNMS Server supports:
    >
    > - A maximum of fifteen (15) eDNA desktop clients in any network. If there are more than fifteen (15) eDNA desktop clients, TNMS FE Servers are required. TNMS FE Servers support a maximum of fifteen (15) eDNA clients each. If TNMS FE Servers are included in the network, eDNA desktop clients connect to the TNMS FE Servers in a round robin fashion. For more information refer to TNMS Special Deployment (p. 50).
    > - A maximum of two (2) simultaneous eDNA webclient sessions in a Large or Medium configuration. Support for more eDNA webclients requires TNMS FE Server machines. Each TNMS FE Server machine supports up to 15 eDNA webclients.

    Each TNMS component in this step requires a license, except Node Manager and eDNA.

15. In **Components: TNMS FE Servers** enter a list of hostnames, fully qualified, and respective IPs in the following format:

    ```
    # <hostname>.<domainname>=<IP>
    ```

    For example: `funchal.nokia.com=10.1.1.2`

16. Only displayed if you selected **Embedded DNA** in step 13.

    In **Components: DNA FE Servers** enter a list of hostnames, fully qualified, and respective IPs in the following format:

    ```
    FE_<hostname>.<domainname>_BIND_IP=<IP>
    ```

    For example: `FE_funchal.nokia.com_BIND_IP=10.1.1.2`

17. In **Components:Northbound Interfaces** select the North Bound Interfaces to install.

    - **SNMP**
    - **TMF CORBA NBI**

    By default the TMF CORBA NBI interface uses the TMF 814 MESH topology.

    Check **Legacy Mode** only if you are migrating from TNMS Core, with TCOA integration, and need to maintain the TMF 814 SINGLETON topology.

    > **Note:** If you install TMF CORBA NBI and if TNMS Server is running in a machine with two or more network interfaces you must, after the TNMS Server installation, perform the configuration described in 7.4 Configuring NTI Notification Service Address (p. 60).

    - **TRANSCEND REST NBI**

    > **Note:** Refer to chapter Northbound Interfaces, in the TNMS Administration Manual, for more information.

18. In the **Components: Network Elements** select the NEs to install.
19. Only displayed if you selected to migrate your database.

    In **Pre-migration Backup** your current database to avoid data loss if any issue occurs during the migration.

20. If you selected to install Node Manager, enter the FTP/SFTP Settings for Node Manager to communicate with the 5500 NEs. Skip this step in case of other NE types.

    These FTP/SFTP settings are the ones that TNMS will also use.

    > **Note:** These settings must match those configured during the Setting Up the Password for TNMS, SFTP and FTP User (p. 62) procedure. The TNMS Installation Checklist (p. 12) provides fields for the recording of these settings.

21. Only displayed if you chose to install Node Manager in a Large configuration. In **Server Preparation: Database Connection** enter the required information for the Node Manager Database connection:

    - **Database IP Address:** default is `127.0.0.1`, shown if localhost is checked.
    - **Database Port:** default is `1521`.
    - **Database User Name:** the user that owns the scheme of the database to be created. This user name should be the TNMS database username defined in the previous step plus "_NM", such as in `tnmsdba_NM`.

    > **NOTICE:** For networks with a Standby Server, the username and password for both the Primary and Secondary Servers must be the same. The same approach is also recommended for all TNMS database installations to ensure that the database is restorable in any machine. The TNMS Installation Checklist (p. 12) provides fields for the recording of usernames and passwords.

    - **Database User Password:** password for the Node Manager database user that complies with the Password Complexity Rules.

    > **Note:** Keep the username and password for future reference.

    - **Re-enter Database User Password:** re-enter the password.
    - **Database Name (SID):** the name of the Node Manager database which is `NMDB`.

    > **NOTICE:** The Node Manager database name cannot be the same as the TNMS database name.

    - **Database User 'sys' Password:** Password defined in 5.1.1 Installation and Configuration for the default database administrator user SYS.

22. A summary of the installation settings is displayed in the **Pre-Installation Summary** step. If PDTs were stored in the `<Product_Installer_Folder>\TNMS_Installer\PUs` folder, the PDT numbers will be displayed for verification. Confirm all configurations are correct and click **Install**.

    > **NOTICE:** If the firewall is enabled, a warning message is displayed stating **Enabled Firewall detected**.

    For the full list of all the ports that need to be opened in the firewall for the correct functioning of TNMS refer to the `Communication Matrix.xls` (`<Product_Installation_Folder>\client\help`). To obtain a direct correlation between a previously installed version with the current ports, see the Instructions worksheet for more information.

23. Only displayed if you selected to migrate your database.

    In **Post-migration Backup** your database after migration.

24. The results of the installation are presented in **Installation Results**.

    Click **Done** to finish the installation.

25. The TNMS environment variables must be updated post installation.

    Execute:

    ```bash
    . /etc/profile.d/ossnms.sh
    ```

26. After a successful installation of TNMS Server and Mediation, navigate to the `<Product_Installer_Folder>`.
27. Delete the TNMS Software zip files and the `<Product_Installer_Folder>`.
28. Consult the Technical Notes from all applicable Priority Updates or Workarounds for updated recommendations or additional requirements.

> **Note:** The TNMS Server machine hostname should be resolved through the DNS Servers on the Client side. Update of the NGINX CA and host certificate is also required, see in 2.4.2 chapter of the TNMS Administration Manual.

### 6.4.1. Password Complexity Rules

The passwords are validated by the system according to the rules below:

- The password must have between 8 - 32 valid characters (see Table 16: Valid Characters (p. 50)).
- The password must not contain the username, the reversed username nor a circular shifted version of the username.
- The password must not contain sequences of three or more characters of the user name.
- The password must not contain more than three repeated characters of the same type, either lower or upper-case, for example aAaA.
- The password must not contain more than three consecutive characters in ascending or descending order, either lower or upper-case, for example aBcD.
- The password must not contain a sequence of two or more repeated characters, for example a12b12.
- The password must not begin nor end with a space.
- The password must include at least three of the following four specifications: one lower case alpha character, one upper case alpha character, one numeric character and one special character.

### 6.4.2. Database User Password Complexity Rules

The password must have between 6 - 30 valid characters (see Table 16: Valid Characters (p. 50)).

**Table 16: Valid Characters**

- `+-:{}`
- `1234567890`
- `abcdefghijklmnopqrstuvwxyz`
- `ABCDEFGHIJKLMNOPQRSTUVWXYZ`

## 6.5. TNMS Client Installation

For the TNMS Client Installation procedure please refer to chapter TNMS Client Installation in the TNMS Installation Manual Windows.

## 6.6. TNMS Special Deployment

The procedures below describe how to install a TNMS Server and TNMS Mediations in different machines. However, if you intend to proceed with a special deployment, first contact Nokia Technical Support or Product Management, so they can advise you on finding the best solution for your business.

Nokia recommends that you install one TNMS mediator per TNMS Mediation machine, however the Node Manager mediator can be installed in a TNMS Mediation machine also.

**Installation Sequence**

The TNMS Server must be installed first, followed by TNMS and Node Manager Mediation(s) afterwards.

### 6.6.1. TNMS Server Installation

**Hardware requirements for TNMS Server installation**

The hardware requirements for the installation of the TNMS Server without Mediations are the same as described in Table 3: Hardware requirements for installations of TNMS (p. 14).

**TNMS Server Installation Procedure**

To install TNMS Server without the Mediation or Transcend eDNA FE Servers separately, proceed as follows:

1. Log in as root.
2. Configure the Database Server as follows:

   **Step 2a.** Edit the file `/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora`.

   **Step 2a.** Add the IPs of the Mediation machines (where Node Manager will be installed) and of the eDNA FE machines to the property `TCP.INVITED_NODES`. For example:

   ```
   TCP.INVITED_NODES=(127.0.0.1, loghost)
   ```

   should be changed to:

   ```
   TCP.INVITED_NODES=(127.0.0.1, loghost, 10.79.32.160,10.46.84.68)
   ```

   where 10.79.32.160 is the Mediation machine that will have Node Manager installed and 10.46.84.68 is the eDNA FE machine.

   **Step 2b.** Reload the database listener.

   Issue:

   ```bash
   su - oracle
   lsnrctl stop lisner
   lsnrctl start lisner
   exit
   ```

3. Follow the procedure described in 6.1 TNMS Server and Mediation Installation (the procedure in this file is section 6.4). Skip the any steps that are not displayed in the wizard because they do not apply to the TNMS Server installation.
4. After a successful installation of TNMS Server and Mediation, navigate to the `<Product_Installer_Folder>`.
5. Delete the TNMS Software zip files and the `<Product_Installer_Folder>`.

> **NOTICE:** If the mandatory installation sequence was not followed and you have installed the TNMS Server after the TNMS Mediations with Node Manager, then you must stop and start all Node Manager services in the following sequence:
>
> a. Stop all Node Manager services in the TNMS Server and TNMS Mediations.
>
> b. Start the Node Manager services in the TNMS Mediations and wait until all those services are running.
>
> c. Start the Node Manager services in the TNMS Server.
>
> This sequence also applies to any other issue that requires the Node Manager services to be stopped are started.

### 6.6.2. TNMS Mediation Installation

**Hardware requirements for TNMS Mediation installation**

The table below provides an overview of the hardware recommendations for TNMS Mediation.

**Table 17: Minimum hardware requirements for TNMS Mediation installations.**

| | |
| --- | --- |
| CPU | 16 threads, 2.8 GHz |
| RAM | 8 GB |
| HDD | 100 GB |

The manual prints `16 Threads, 2,8 GHz` and `100 Gb`.

These hardware requirements refer to virtual machines. If you use physical machines the hardware requirements must be compatible with the ones defined for virtual machines.

**Supported Mediators**

- Generic Mediator (NEs of EM-GM type)
- MVM (NEs of EM-MVM and EM-NMS type)
- Node Manager

> **Note:** For Node Manager to work you must install both the MVM mediator and Node Manager. All NEs installed in the TNMS Mediations must also be installed in the TNMS Server.

**TNMS Mediation Installation Procedure**

To install TNMS Mediation only, proceed as follows:

1. Log in as root.
2. As root, edit the file `/etc/sysctl.conf`.

   **Step 2a.** Add the following lines to the end of the file or change the values if the lines already exist:

   ```
   net.ipv4.neigh.default.gc_thresh1 = 2048
   net.ipv4.neigh.default.gc_thresh2 = 4096
   net.ipv4.neigh.default.gc_thresh3 = 8192
   ```

   **Step 2b.** Save the file and execute:

   ```bash
   sysctl -p
   ```

3. Extract the TNMS software to a directory in your machine.
4. Go to the `<Product_Installer_Folder>`, within the directory where the TNMS software files were extracted to and manually assign Execution permissions by running the following commands:

   ```bash
   cd <path>/TNMS_Installer
   chmod 744 ./TNMS.bin
   ```

5. Start the installation wizard.

   Run:

   ```bash
   ./TNMS.bin
   ```

   The installation wizard opens in **Introduction** and the complete list of installation steps is displayed on the left pane.

6. Read the License Agreement and select **I accept the terms of the License Agreement**.
7. In **Installation Package** click **TNMS Mediation**.
8. In **Server Preparation: Customization**, select items to customize:

   - For each checked item the respective customization step is displayed. Either accept or change the default values.
   - Unchecked items will automatically apply defaults values to the installation.

   > **NOTICE:** If **DB Connection** is unchecked, a randomly generated password will be assigned. This password can be changed later, by running the password script described in TNMS Administration Manual 4.10.2 Changing TNMS Database Password.

   **Step 8a.** Users and groups checked.

   In **Users and Groups** enter:

   - **TNMS User Name** (default is `tnms`).

     Checking **Create** enables User ID.

   - **TNMS Group** (default is `tnms`).

     Checking **Create** enables Group ID.

   - **SFTP User Name** (default is `tnms_sftp`).

     Checking **Create** enables User ID.

   Click **Next**.

   **Step 8b.** Deployment Directories checked.

   In **Deployment Directories** enter the path of the following folders (default paths are provided):

   - **TNMS Installation Directory**

     If you choose a directory other than the default, the path cannot contain spaces.

     > **Note:** Throughout the customer documentation this folder will be referred to as `<Product_Installation_Folder>`. Take note of the location of this folder for future reference.

   - **TNMS Data Directory**

     If you choose a directory other than the default, the path cannot contain spaces.

     > **Note:** Throughout the customer documentation this folder will be referred to as `<Product_Data_Folder>`. Take note of the location of this folder for future reference.

   - **Database Installation Directory** (default is `/opt/oracle`)
   - **Database Data Directory**

     Enter the path you defined in 5.1.1 Installation and Configuration (default is `/oradata`). Backups will be stored under subfolders of this folder.

9. In **Server Preparation: Connection Configuration** enter the IP Address to which the TNMS Server and Network Elements you are installing will connect to.
10. In **Components: NM Mediators** select which Node Manager Configuration Managers to install.

    These refer to the type of NEs Node Manager will be managing.

    > **Note:** It is generally recommended that you install one mediator per Mediation machine. However, installing both MVM and Node Manager in the same machine is mandatory for Node Manager to work in this scenario.

11. In **Components: Network Elements** select the NEs to install.

    > **Note:** The TNMS mediators to be installed are automatically selected according to the NEs selected in this step.

12. In **Connection Configuration: Server** enter the IP Address of the TNMS Server the TNMS Mediation you are installing will connect to.
13. Only displayed if you chose to install Node Manager.

    In **FTP/SFTP Configuration** enter the settings Node Manager will use to communicate with NEs.

    These FTP/SFTP settings are the same as the ones that TNMS will also use.

    > **NOTICE:** These settings must match those that you will configure later on, as described in 7.4 SFTP and FTP Configuration. The TNMS Installation Checklist provides fields for the recording of these settings.

14. Only displayed if you chose to install Node Manager.

    In the **Server Preparation: Database Connection** enter the required information for the TNMS Database connection:

    - **Database IP Address:** TNMS database IP address.
    - **Database Port:** Database server port number (Default is `1521`).
    - **Database User Name:** TNMS database user name created in the TNMS Server installation.
    - **Database User Password:** password of the TNMS database user created in the TNMS Server installation.
    - **Database Name (SID):** name of the TNMS database you entered in the TNMS Server installation (DB instance).
    - **Database User 'sys' Password:** Password defined in TNMS Database Installation and Configuration (p. 37) for the default database administrator user SYS.

15. Only displayed if you chose to install Node Manager in a Large configuration. In **Server Preparation: Database Connection** enter the required information for the Node Manager Database connection:

    - **Database IP Address:** TNMS database IP address.
    - **Database Port:** Database server port number. The default value is `1521`.
    - **Database User Name:** Node Manager database username created in the TNMS Server installation.
    - **Database User Password:** password of the Node Manager database user created in the TNMS Server installation.
    - **Database Name (SID):** name of the Node Manager database you entered in the TNMS Server installation (DB instance).
    - **Database User 'sys' Password:** Password defined in 5.1.1 Installation and Configuration for the default database administrator user SYS.

16. A summary of the installation settings is provided in the **Pre-Installation Summary** step. If PDTs were stored in the `<Product_Installer_Folder>\TNMS_Installer\PUs` folder, the PDT numbers will be displayed for verification. Confirm all configurations are correct and click **Install**.
17. The results of the installation are presented in the **Installation Results** step. Click **Done** to finish the installation.
18. The TNMS environment variables must be updated post installation.

    Execute:

    ```bash
    . /etc/profile.d/ossnms.sh
    ```

19. After a successful installation of TNMS Mediation, navigate to the `<Product_Installer_Folder>`.
20. Delete the TNMS Software zip files and the `<Product_Installer_Folder>`.
21. Consult the Technical Notes from all applicable Priority Updates or Workarounds for updated recommendations or additional requirements.

## 6.7. TNMS Frontend Server Installation

To install eDNA Frontend UI Server (TNMS FE Server):

> **NOTICE:** Every TNMS FE Server supports up to 15 clients, desktop or web clients.

1. Log in as root.
2. Configure the TNMS hosts file to include the TNMS FE Servers, refer to System Hosts (p. 29) for instructions.
3. Go to `<Product_Installer_Folder>`, created during the TNMS Installer Integrity Validation (p. 42) and manually assign Execution permissions.

   Issue:

   ```bash
   cd <path>/TNMS_Installer
   chmod 744 ./TNMS.bin
   ```

4. Start the installation wizard.

   Run:

   ```bash
   ./TNMS.bin
   ```

   The installation wizard opens in **Introduction** and the complete list of installation steps is displayed on the left pane.

5. Read the License Agreement and select **I accept the terms of the License Agreement**.
6. In **Installation Package**, click **TNMS Frontend Server**.
7. In **Server Preparation: Customization**, select items to customize:

   - For each checked item the respective customization step is displayed. Either accept or change the default values.
   - Unchecked items will automatically apply defaults values to the installation.
   - Users and groups checked:

     In **Users and Groups** enter:

     - **TNMS User Name** (default is `tnms`).

       Checking **Create** enables User ID.

     - **TNMS Group** (default is `tnms`).

       Checking **Create** enables Group ID.

     - **SFTP User Name** (default is `tnms_sftp`).

       Checking **Create** enables User ID.

   - Deployment Directories checked:

     In **Deployment Directories** enter the path of the following folders (default paths are provided):

     - **TNMS Installation Directory**

       If you choose a directory other than the default, the path cannot contain spaces.

       > **Note:** Throughout the customer documentation this folder will be referred to as `<Product_Installation_Folder>`. Take note of the location of this folder for future reference.

     - **TNMS Data Directory**

       Make sure that the TNMS data folder is empty. If not, backup and remove the data or select a different folder.

       > **Note:** Throughout the customer documentation this folder will be referred to as `<Product_Data_Folder>`. Take note of the location of this folder for future reference.

8. In **Components: TNMS FE Server**, select the required component:

   To install a TNMS Frontend Server, select **DNA Client Service + DNA FE Server**. To install only the legacy DNA FE Server functionality, select **DNA FE Server**.

9. In **Server Preparation**, enter the TNMS Server IP.
10. A summary of the installation settings is displayed in the **Pre-Installation Summary** step. If PDTs were stored in the `<Product_Installer_Folder>\TNMS_Installer\PUs` folder, the PDT numbers will be displayed for verification. Confirm all configurations are correct and click **Install**.
11. The TNMS environment variables must be updated post installation.

    Execute:

    ```bash
    . /etc/profile.d/ossnms.sh
    ```

12. Only applicable for all TNMS FE Servers that were listed during the TNMS Server installation step **Components: DNA FE Servers**.

    Copy eDNA keystore and truststore to the TNMS FE Server.

    **Step 12a.** In the TNMS Server machine, open the Administration Console.

    Issue:

    ```bash
    cd <Product_Installation_Folder>/server/DNA/EMS/conf/ssl
    scp DNAServer.keystore Truststore.truststore root@<TNMS_DNA_Frontend_Server_IP>:<TNMS_DNA_Frontend_Server_Product_Installation_Folder>/server/DNA/EMS/conf/ssl
    ```

    **Step 12b.** In the TNMS FE Server machine, open the Administration Console.

    Issue:

    ```bash
    scs-service-restart
    ```

13. Only applicable when adding TNMS FE Servers to a network with TNMS Server and eDNA already installed and running.

    > **Note:** Only proceed with the following procedure once all additional TNMS FE Servers have been installed as per steps 1 – 11 above.

    **Step 13a.** Log in as root to the TNMS Server machine.

    **Step 13b.** Add new FE server details in `ems.conf` in eDNA Server.

    Issue:

    ```bash
    cd <Product_Installation_Folder>/server/DNA/EMS/conf
    vi ems.conf
    ```

    Add new entries directly above the line `MANUALMODE_2_SERVICES_ALLOWED=true`:

    ```
    FE_<hostname>.<domain name>_BIND_IP=<IP>
    ```

    **Step 13c.** Execute `reconfigure_dna_cert.sh` in the TNMS server.

    Issue:

    ```bash
    cd <Product_Installation_Folder>/server/DNA/install
    ./reconfigure_dna_cert.sh
    ```

    **Step 13d.** Edit the `product.conf` file in the TNMS server to add the FE Server IPs.

    Issue:

    ```bash
    cd <Product_Installation_Folder>/system/configuration
    vi product.conf
    ```

    Add new entries:

    ```
    # DNA_FE_IP_LIST=<TNMS_DNA_FE_SERVER_IP_#>, <TNMS_DNA_FE_SERVER_IP_#>
    ```

    **Step 13e.** Configure the additional TNMS FE Servers to access the TNMS Database:

    i. Edit the file `/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora`.

    ii. Add the IPs of the new TNMS FE Server machines to the property `TCP.INVITED_NODES`.

    For example:

    ```
    TCP.INVITED_NODES=(127.0.0.1, loghost)
    ```

    should be changed to

    ```
    TCP.INVITED_NODES=(127.0.0.1, loghost, 10.79.32.160,10.46.84.68)
    ```

    where 10.79.32.160 and 10.46.84.68 are the new FE machines.

    iii. Reload the database listner.

    Issue:

    ```bash
    su - oracle
    lsnrctl stop lisner
    lsnrctl start lisner
    exit
    ```

    **Step 13f.** Edit file: `$BICNET_CONFIG_DIR/fe_servers.properties` and add the new TNMS FE Server host.

    For example:

    ```
    <FE Server1 FQDN>=<FE Server IP>
    ...
    <New FE Server FQDN>=<New FE Server IP>
    ```

    **Step 13g.** Restart TNMS Server services.

    Issue:

    ```bash
    scs-service-restart
    ```

    **Step 13h.** Copy the `DNAServer.keystore` and `Truststore.truststore` from the TNMS Server to all TNMS FE Servers in the network.

    Issue:

    ```bash
    cd <Product_Installation_Folder>/server/DNA/EMS/conf/ssl
    scp DNAServer.keystore Truststore.truststore root@<TNMS_DNA_Frontend_Server_IP>:<TNMS_DNA_Frontend_Server_Product_Installation_Folder>/server/DNA/EMS/conf/ssl
    ```

    **Step 13i.** Restart all TNMS FE Servers in the network.

    Log in as root to each TNMS FE Server.

    Issue:

    ```bash
    scs-service-restart
    ```

> **Note:** The TNMS FE Server machines should be resolved through the DNS Servers used on the browser side. Update of the CA and host certificate is also required, see chapter 2.4.8 of the TNMS Administration Manual.
