Source: installation_manual_linux.pdf, chapter 9, pages 65–66.

# 9. Update TNMS

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 9.1. Upgrade from a Previous TNMS Release

To transfer your data from previous TNMS Server versions to the current TNMS Server running on Linux refer to TNMS Upgrade Manual.

## 9.2. Update the Current TNMS Release

Once the installation of TNMS 9.1 is complete, if specific components were not installed, they can be added via Update.

> **NOTICE:** If components need to be added via Update after a Priority Update installation, copy all post installation PDTs to `<Product_Installer_Folder>/TNMS_Installer/PUs` before proceeding.

To add components to the already installed TNMS 9.1:

> **NOTICE:** If Transcend eDNA is being added, verify that there is no version of Transcend eDNA already installed before proceeding.

1. Log in as root.
2. Go to `<Product_Installer_Folder>`, created during TNMS Installer Integrity Validation (p. 42) and manually assign Execution permissions.

   Issue:

   ```bash
   cd <path>/TNMS_Installer
   chmod 744 ./TNMS.bin
   ```

3. Start the installation wizard.

   Run:

   ```bash
   ./TNMS.bin
   ```

   The installation wizard opens in **Introduction** and the complete list of installation steps is displayed on the left pane.
4. A supported TNMS installation is detected and displayed in a pop up window. The detected version should match the Installer's version.
5. Only displayed if Transcend Controller was not installed in the previous build. In **Server Preparation: Transcend Controller:**

   Click **Enable Connection to Transcend Controller (TC)** to configure the following parameters:

   - **TC IP**: Transcend Controller IP address.
   - **TC OIF Port**: Transcend Controller OIF Port (Default is: 12443).
   - **TC Gateway Port**: Transcend Controller Gateway Port (Default is 12351)

   > **NOTICE:** This is needed for the correct interworking of TNMS and Transcend Controller functionalities (for example Hot Standby, Real-time Planning and Provisioning, etc). Before proceeding, ensure that the Transcend Controller Server IP and FQDN have been configured, refer to chapter 4.1 System Hosts.

6. **In Server Preparation: Advisory Message:**

   - Enable or disable an advisory message before login.
   - If enabled, personalize the advisory message in the box.

7. In **Components:** TNMS, select the new components to be added. Components already installed will be unselectable.
8. *Only displayed if eDNA is installed already or if selected in Step 7.*

   In **Components: Transcend eDNA FE Servers** Insert the Transcend eDNA Frontend Server IPs.
9. In **Components: Northbound Interfaces**, select the new NBIs to be added. NBIs already installed will be unselectable.
10. In **Components: Network Elements**, select the new NEs to be added. NEs already installed will be unselectable.
11. In **Backup Configuration**, the option to backup the database will be presented.
12. A summary of the installation settings is displayed in the **Pre-Installation Summary** step. If PDTs were stored in the `<Product_Installer_Folder>\TNMS_Installer\PUs` folder, the PDT numbers will be displayed for verification. Confirm all configurations are correct, and click **Install**.
13. The results of the Update are presented in the **Install Completes** step. Click **Done** to finish.
