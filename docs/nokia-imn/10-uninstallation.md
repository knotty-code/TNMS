Source: installation_manual_linux.pdf, chapter 10, pages 67–68.

# 10. Uninstallation

Below you can find instructions on how to uninstall TNMS and its prerequisites.

## 10.1. Uninstalling TNMS

Before uninstalling TNMS and in case you have a standby server assigned, you must first unassign it by doing as follows **in the active server**:

1. Select **Administration > System > Standby Server Configuration** and fill in the available fields.

   The address of the current standby server is filled in automatically.
2. Verify your input and click **Unassign** to start the procedure.

   The progress and result can be followed in the configuration steps, along with the elapsed time.
3. When the unassignment finishes, a notification pops up in the lower right corner with the status of the operation, either success or error.

   Alternatively, it is possible to check in System Event Log that the procedure has ended successfully.

If any error occurs, the logs can be checked in `<Product_Data_Folder>/trace/server/standby/[timestamp]/result.log`

In the **standby server**, perform the following steps:

1. Go to the `$SERVER_DIR/bin/standby/`, run the standby server executable file `standby-server.sh`.
2. Navigate to `$STANDBY_DIR`, via the Administration Console (refer to the Administration Console chapter in the TNMS Administration Manual).
3. Run the standby server executable file:

   ```bash
   standby-server-sh
   ```

4. In the interactive menu select **4. Start as Standalone**

To uninstall TNMS **Server** proceed as follows:

1. Open Administration Console.
2. Issue:

   ```bash
   $SYSTEM_DIR/Uninstall.sh
   ```

3. Press **Y** to confirm uninstallation.
4. Click **Done** on the **Uninstall Complete** panel.
5. To reload the profile, disconnect and reconnect the session.

To uninstall TNMS **Client**:

Refer to chapter 10.1 Uninstalling TNMS in the TNMS Installation Manual Windows.

> **NOTICE:** Using this process will uninstall both the TNMS Client and TNMS Server.

## 10.2. Uninstalling Prerequisites

### Uninstalling the Database

To uninstall the database software do as follows:

1. Login as root.
2. Issue:

   ```bash
   su - oracle
   ```

3. Issue:

   ```bash
   cd $ORACLE_HOME/deinstall
   ./deinstall
   ```

   The uninstaller begins.

   The uninstaller requests some confirmations, such as the database details. Accept the default by pressing **Enter** or change according to your environment.
4. When prompted for the Listener Name, enter **LISNER** and press **Enter**.
5. When prompted for the **Database SID** enter:

   - **Small/Small Plus/Medium/Large** (without Node Manager) configuration - the name of the TNMS database (TNMS is the default name).
   - **Large** (with Node Manager) configuration - the name of the TNMS database (TNMS is the default name) and the name of the Node Manager database (**NMDB** is the default and mandatory name), separated by a comma, for example TNMS,**NMDB**.

   Press **Enter**.
6. When prompted for TNMS database modification, enter "**n**" and press **Enter**. (The details of database(s) TNMS have been discovered automatically. Do you still want to modify the details of TNMS database(s)? [n]: n).
7. When prompted for continuation, enter "**y**" and press **Enter**. (Do you want to continue (y - yes, n - no)? [n]: y).
8. Under the "**Clean Operation Summary**", after this message is displayed: `Oracle Universal Installer cleanup was successful`, follow the instructions in order to delete the remaining installation files.
9. Additionally, as root, delete the content of the ORADATA folders (`/ora1`, `/ora2` and `/ora3`).
