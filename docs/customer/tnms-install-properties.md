# TNMS 9.1 — attributes in tnms-install.properties.in

Open `tnms-install.properties.in` before the first `make` and read each line below. On the server the file is `/tmp/tnms-install.properties.in` until `stage` copies it to `/opt/tnms-install/tnms-install.properties.in`. The wizard reads that copy.

The file delivered with this procedure is a new install of TNMS Server and Mediation at the Small Plus tier. It selects Ethernet Manager, ASON Manager, Optical Manager, and Optical Spectrum Insight, and Generic SNMP as the only network element. Change a line only when the site choice is different. A value marked **fixed** is checked by `make` or required by the wizard script. Leave those as written.

`1` means selected. `0` means not selected.

## Installation package

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `CHOSEN_INSTALL_SET` | `Server+NetServer` | **Fixed** for this procedure. Server and Mediation on one machine. `NetServer` is the mediation package. |

## Transport Controller

Leave the connection off unless this server must reach a Transport Controller. The ports are unused while the connection is off.

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `ENABLE_SDN_CONNECTION` | `0` | Transport Controller connection. Off. |
| `SDN_IP_ADDRESS` | empty | Address of that controller. |
| `TRANSPORT_CONT_PORT` | `12443` | Controller port. |
| `TRANSPORT_CONT_GATEWAY_PORT` | `12351` | Controller gateway port. |

## Hardware

Set exactly one of these to `1`. The delivered file is Small Plus. The other three stay `0`. Pick the tier that matches the VM in [prepare.md](prepare.md). The wizard script makes `lsmem` report 32G only when the machine has less than 32G and the file says Small Plus. Another tier needs a machine that already meets that tier.

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `HW_TINY_CONFIG` | `0` | Small. |
| `HW_SMALL_PLUS_CONFIG` | `1` | Small Plus. |
| `HW_MEDIUM_CONFIG` | `0` | Medium. |
| `HW_LARGE_CONFIG` | `0` | Large. |

## Users, groups, and directories

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `USERS_SELECTED` | `0` | **Fixed.** Leave the installer defaults: user `tnms`, group `tnms`, SFTP user `tnms_sftp`, Oracle user `oracle`, DBA group `dba`. |
| `DIRECTORIES_SELECTED` | `0` | **Fixed.** Use the five directory lines below. |

These five lines are **fixed**. `stage` stops when any line is missing or different. `make` creates these paths.

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `USER_INSTALL_DIR` | `/opt/nokia/tnms` | Product install directory. |
| `USER_INSTALL_DIR_TMP` | `/opt/nokia/tnms` | Same path. On Linux the installer measures free space with this name. |
| `USER_DATA_DIR` | `/nokia/tnms` | Data directory. Traces and the SFTP tree go here. |
| `ORACLE_INSTALL_DIR` | `/opt/oracle` | Oracle software directory. |
| `ORACLE_DATA_DIR` | `/oradata` | Oracle data directory. `ora1`, `ora2`, and `ora3` are under this path. |

## Network addresses

Each of these is **fixed** as the text `@TNMS_IP@`. There are seven of them. `stage` stops when the count is not 7. The wizard replaces every placeholder with `TNMS_IP` from the Makefile. Do not type an address into this file. Set `TNMS_IP` in `/root/tnms-install.local.mk` when the detected NIC address is wrong. That variable is in [using-make.md](using-make.md).

| Attribute | Meaning |
| --- | --- |
| `SERVER_FRONTEND_IP` | Server address used by clients. |
| `SERVER_BACKEND_IP` | Server address used on the back side. |
| `MEDIATION_NORTH_IP` | Mediation address toward the server. |
| `MEDIATION_SOUTH_IP` | Mediation address toward the network elements. |
| `CLIENT_CONNECT_ADDRESS` | Address the client uses to reach the server. |
| `FESERVER_FRONTEND_IP` | Front-end server address. Empty front-end list below means this stays the same server address. |
| `FESERVER_BACKEND_IP` | Front-end server back-side address. |

## Database

This is a new database. A migration is a different procedure.

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `DATABASE_MIGRATION_NO` | `1` | **Fixed.** Build a new database. |
| `DATABASE_MIGRATION` | `0` | **Fixed.** Do not migrate an existing database. |
| `DB_HOST` | `127.0.0.1` | Database is on this machine. |
| `DB_PORT` | `1521` | Listener port. |
| `DB_USER` | `tnmsdba` | Application database login. |
| `DB_NAME` | `TNMS` | Database name. It matches `TNMS_SID`. |
| `DB_SYSUSER` | `sys` | Oracle `SYS` account. |
| `DB_DIR` | `/opt/oracle/product/19c/dbhome_1` | Oracle home. |
| `localDB` | `true` | The database runs on this server. |
| `DB_PWD` | encoded | Password for `tnmsdba`. InstallAnywhere encoding. It matches the Makefile default `Tnc25xQ36XBUa9`. |
| `DB_SYSPWD` | encoded | Password for `SYS`. Same encoding. It matches the Makefile default `TnZT5hgW8Zwsp79`. `SYSTEM` uses that same plaintext. |

Leave `DB_PWD` and `DB_SYSPWD` as delivered. Typing a plaintext password into either line does not change the database password. `installation.sh` reads the plaintext from `/root/tnms-install.local.mk` or from the Makefile defaults. The wizard logs in with the encoded lines. The two sides match only while both stay at those defaults.

## Advisory message

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `SHOW_ADVISORY_MESSAGE` | `false` | No advisory page. |
| `TEXT_ADVISORY_MESSAGE` | empty | Text for that page. Unused while the flag is false. |

## Managers

`TO_INSTALL=1` installs that manager. `TO_MIGRATE=0` on every row because this is not an upgrade. `NEW_MANAGERS` and `ALL_MANAGERS` repeat the same selection. If you change a `TO_INSTALL` flag, change those two lines so they list the same managers.

| Attribute | Delivered `TO_INSTALL` | Meaning |
| --- | --- | --- |
| `Ethernet_Manager` | `1` | Ethernet Manager. |
| `ASON_Manager` | `1` | ASON Manager. |
| `Optical_Manager` | `1` | Optical Manager. |
| `Optical_Spectrum_Insight` | `1` | Optical Spectrum Insight. |
| `ZTC_Manager` | `0` | ZTC Manager. Left out. |

## Front-end servers

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `TNMS_FE_IPS_LIST` | empty | No separate front-end servers. |

## Northbound interfaces

Every interface stays off. `ALL_NBIS` repeats that. A migration flag stays `0`.

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `NTI_TO_INSTALL` | `0` | NTI. |
| `NTI_WM_LEGACY_OPTION` | `0` | Legacy NTI option. |
| `NTI_TO_MIGRATE` | `0` | Do not migrate NTI. |
| `SNMP_NBI` | `0` | SNMP northbound interface. |
| `SNMP_NBI_TO_MIGRATE` | `0` | Do not migrate SNMP NBI. |
| `REST_NBI_TO_INSTALL` | `0` | REST northbound interface. |
| `REST_NBI_TO_MIGRATE` | `0` | Do not migrate REST NBI. |
| `ALL_NBIS` | all `0` | Same selection, one line. |
| `NTI_WM_LEGACY` | `false` | Legacy NTI mode. Off. |

## Network elements

One mediator is selected. The other channel lists are empty. `TOTAL_NODES_TO_ADD` repeats the same lists. If you add a mediator, change that summary line too.

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `EM-GM_TO_INSTALL` | empty | Generic Mediator. None. |
| `EM-MVM_TO_INSTALL` | `Generic SNMP;` | MultiVendor Mediator. Generic SNMP only. |
| `UNO_TO_INSTALL` | empty | UNO. None. |
| `EM-NMS_TO_INSTALL` | empty | NMS element manager. None. |
| `EM-IntelligentPluggableManager_TO_INSTALL` | empty | Intelligent Pluggable Manager. None. |
| `Transcend-REST-Channel_TO_INSTALL` | empty | Transcend REST channel. None. |
| `EM-WaveSuite-Channel_TO_INSTALL` | empty | WaveSuite channel. None. |

## Installer replay lines

Each `-fileOverwrite_...=Yes` line tells InstallAnywhere it may replace that path. Leave every one as `Yes`.

## Registered variables

| Attribute | Delivered value | Meaning |
| --- | --- | --- |
| `ORACLE_USER` | `oracle` | Oracle OS account. |
| `DBA_GROUP` | `dba` | Oracle DBA group. |
| `INSTALLER_UI` | `silent` | **Fixed.** The wizard runs `TNMS.bin` without a screen. |
| `RPP_SERVICE_MODE` | `IQNOS` | Service mode recorded by the replay. |
| `UPGRADE` | `false` | **Fixed** for a new install. |
