Source: installation_manual_linux.pdf, chapter 7, pages 59–63.

# 7. Final System Configuration

> **Note:** It is highly recommended that system security hardening be carried out before starting TNMS in a production environment, refer to TNMS Administration Manual, Linux Security Hardening chapter for more information.

The first installation of TNMS has a trial license of 90 days. During this period you have permissions to access all TNMS features. After the 90 days expire you need to acquire and install license keys.

For the below post-installation configuration procedures (that can be performed at any time), refer to the TNMS Administration Manual:

- Login (Chapter TNMS Login)
- Single Sign-on (Chapter Single Sign-on Configuration)
- Standby Server (Chapter Standby Server)

> **Note:** Optical Manager licenses require a TNMS Server restart after importing.

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. All Linux instructions, hardening and commands in this manual are based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 7.1. Configuring NGINX Service

NGINX service default port (8444) is configurable, in case any other software installed is already using port 8444. Follow the procedures below to configure the NGINX port.

### 7.1.1. Configure NGINX in TNMS Mediation

1. Stop the TNMS nginx service.

   Issue:

   ```bash
   scs-service-stop nginx
   ```

2. Open the file:

   `<Product_Installation_Folder>/system/oper/nginx/conf/nginx.conf`

3. Edit the file, replacing the port number in `listen 0.0.0.0:8444 ssl;` with the new port number to be used
4. Save and restart TNMS nginx service.

### 7.1.2. Configure NGINX in TNMS Client

1. Close TNMS Client.
2. Open the file:

   `<Product_Installation_Folder>/client/application.properties`

3. Add the new port number, edit the file:

   ```text
   gctManager.NGINX_NET_SERVER_PORT=8444
   gctManager.NGINX_TNMS_SERVER_PORT=8444
   ```

   > **NOTICE:** Ensure the line `gctManager.NGINX_TNMS_SERVER_PORT=8444` is uncommented.

4. Save and open TNMS Client.

> **Note:** In the scenario of a standalone server with external mediations, the NGINX port must be updated in the server machine, using the same procedure for mediation.

Always refer to the TNMS Communication Matrix for the required ports to operate TNMS.

## 7.2. Enabling Real-time Planning and Provisioning

To enable Real-time Planning and Provisioning in TNMS or to access Real-time Planning and Provisioning during the 90 day trial license, refer to the TNMS Administration Manual for more information on how to manage licenses and configure the required certificates.

## 7.3. Enabling a Web Map Service

To enable a web map to be displayed in Real-time Planning and Provisioning, a Map Server must first be installed and then firewall ports configured to enable communicate with each TNMS Client.

After Map Server installation in TNMS go to **Administration** > **System Preferences** > **Network Map** > **Web Configurations** > to configure the web map service connection and preferences. See System Preferences Online Help for more information.

## 7.4. Configuring NTI Notification Service Address

If TMF CORBA NBI is installed and TNMS is running in a machine with two or more network interfaces, the Notification Service configuration must be updated by specifying the IP to which the Notification Service should bind to.

> **NOTICE:** The specified IP must be the same IP that was selected in chapter TNMS Server and (p. 43) Mediation Installation (p. 43), Step 10.

To do so, follow the instructions below:

1. Edit the file:

   `<Product_Installation_Folder>/server/NOSE/etc/jacorb.properties`

2. Update the `OAIAddr` property:

   ```text
   # IP address on multi-homed host (this gets encoded in
   # object references). Note that adresses like 127.0.0.X
   # will only be accessible from the same machine!
   # OAIAddr=1.2.3.4
   ```

   You must uncomment the `OAIAddr` property and define it as such:

   ```text
   OAIAddr=<IP for the Notification Service>
   ```

3. Delete the cache files:

   `<Product_Data_Folder>/var/server/NOSE`

4. Restart the Notification Service.

   Issue:

   ```bash
   scs-service-restart nose
   ```

## 7.5. SFTP and FTP Configuration

### 7.5.1. Setting Up the FTP Service

The FTP service default user name is `tnms_sftp` and its home folder is the same as SFTP’s: `<Product_Data_Folder>/nedata`.

1. To enable FTP service on system startup, issue:

   ```bash
   systemctl enable vsftpd
   ```

2. To start FTP service, issue:

   ```bash
   systemctl start vsftpd
   ```

> **Note:** If restriction of the TNMS SFTP User (as described in Restricting the TNMS SFTP User (p. 61)) is required, then a dedicated FTP User is also required.

### 7.5.2. Restricting the TNMS SFTP User

TNMS requires the usage of an application user present in the system for information transfer between the NE network and TNMS applications. By default, this OS user is created with the ability to login and access all TNMS related folders. To enhance security, the TNMS SFTP user can be restricted to access only the application data folders and, additionally, forbidden to log into the system.

To restrict the TNMS SFTP User access to required folders only:

> **Note:** The following instructions use:
>
> - The default TNMS SFTP User name `tnms_sftp`
> - `/nokia` to indicate the parent data directory of the `<Product_Data_Folder>`.

1. In the TNMS Server machine, open the Administration Console and disable the interactive login of user `tnms_sftp`.

   Issue:

   ```bash
   usermod -s /sbin/nologin tnms_sftp
   ```

2. Change permissions on `/nokia`.

   Issue:

   ```bash
   chmod 755 /nokia
   ```

3. Edit the file `/etc/ssh/sshd_config`:

   a. Comment the entry:

      ```text
      # Subsystem sftp /usr/libexec/openssh/sftp-server
      ```

   b. Add new entry

      ```text
      Subsystem sftp internal-sftp
      ```

   c. At the end of the file, add the following section:

      ```text
      Match User tnms_sftp
          ChrootDirectory /nokia
          ForceCommand internal-sftp
          X11Forwarding no
          AllowTcpForwarding no
      ```

4. Apply the new settings in `sshd_config` by restarting the SSH service.

   Issue:

   ```bash
   systemctl restart sshd
   ```

5. Change the SFTP directory for the `tnms_sftp` user.

   a. In TNMS > **System Preferences**:

      i. **SFTP** tab, remove any directory before `/tnms` from the **Path** field, leaving `/tnms/nedata` only.

      ii. **External Communications** tab > **SFTP Settings**, remove any directory before `/tnms` from the **Path** field, leaving `/tnms/nedata` only.

   b. In TNMS > **NE Properties** > **SFTP Settings** tab, remove any directory before `/tnms` from the **Upload path** field, leaving `/tnms/nedata` only.

### 7.5.3. Setting Up the Password for TNMS, SFTP and FTP User

#### TNMS User

This TNMS OS user default name is `tnms`. By default the user is locked and no login is possible using this user.

If remote shell access is required for the TNMS User, the password must be set as follows:

Issue:

```bash
/usr/bin/passwd tnms
```

#### SFTP and FTP User

The SFTP/FTP user default name is `tnms_sftp`. You must now set up its password in Linux, which for security reasons changes. When it does, the TNMS administrator must change it in the TNMS Client, according to the UMN, Administration, SFTP chapter.

To set up the password for the default user `tnms_sftp`, issue:

```bash
/usr/bin/passwd tnms_sftp
```

> **NOTICE:** If you installed Node Manager in a Mediation machine (only for TNMS Special Deployment (p. 50)), these settings must match those defined during the FTP/SFTP Configuration Step of the TNMS Mediation Installation (p. 51).

## 7.6. Configuring TNMS Service Management

The Linux service that manages TNMS must be administered as user root.

In alternative, TNMS user (i.e. `tnms`) can also use the sudo facility to manage Linux.

To configure the sudoers list and allow the TNMS user to manage the system service, proceed as follows:

1. Run:

   ```bash
   cp -p $SYSTEM_INSTALL_DIR/resources/system/tnms_sudo /etc/sudoers.d
   ```

2. Run:

   ```bash
   chown root:root /etc/sudoers.d/tnms_sudo
   ```

3. Confirm the TNMS user is able to manage the service:

   ```bash
   sudo -l -U tnms
   ```

> **NOTICE:** If the OS user configured for TNMS is not the default `tnms`, that user must be configured inside the `tnms_sudo` file, by editing the default.
