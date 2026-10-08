Source: installation_manual_linux.pdf, chapter 2, pages 11–17.

# 2. Preparation

Before installing TNMS, read the following sections to ensure that all requirements are met.

> **Tip:** To avoid unnecessary usage of disk space, it is recommended to:
>
> - Store the installation zip files in a partition other than the one used for the software installation.
> - Delete the unzipped zip files after software installation.

> **Note:** Configuration is done with standard Unix tools provided with Linux. Check their available man files for detailed information.

> **Note:** TNMS supports Rocky Linux, Oracle Linux and Red Hat Enterprise Linux (RHEL) as listed in the Licensed Software chapter of the Release Notes Appendix. This chapter contains instructions for RHEL installation only. All subsequent Linux instructions, hardening and commands in this manual are also based on RHEL and must be adapted for Rocky Linux or Oracle Linux if required.

## 2.1. Before you Begin

Complete the following steps before installing:

- If Hot-Standby is planned to be used, consider using two redundant communication links between Primary and Secondary sites. Enable redundancy on the ethernet interfaces by configuring NIC bonding.
- Check the system requirements.
- Determine the file system to be used, the partition to be used by the installation and the components to install.
- Determine how the network, IP addresses and TCP/IP name management will be handled.
- Ensure that the host IP addresses are static. Do not use DHCP dynamic addresses.
- Verify that the machine where TNMS will be installed does not already have any version of TNMS, Transcend eDNA Frontend Server or Transcend Controller installed (only one role per machine is permitted). For upgrades of installed versions, see the TNMS Upgrade Manual.
- Create a management-console (ILO) account to HP Server.
- It is mandatory to install the database in the TNMS Server machine.
- If TMF CORBA NBI is required contact Technical Support before proceeding.
- Consult the Dimensioning Heuristics chapter, in the TNMS Dimensioning Guidelines manual, for dimensioning configurations of systems:
  - that exceed the certified system parameters and/or
  - where default system parameters are inadequate to process the required workloads.

### 2.1.1. TNMS Installation Checklist

In order to take note and keep track of relevant parameters and configurations, it is recommended that the attached TNMS Installation Checklist (Linux) spreadsheet is filled in when installing your Operating System, Pre-requisites Software and TNMS.

The blank template extracted from the PDF is [tnms-installation-checklist-linux.xlsx](tnms-installation-checklist-linux.xlsx) in this directory. It contains Nokia example values. Filled copies hold secrets and must stay on encrypted storage.

> **NOTICE:** This file is confidential and the information that is filled in is highly sensitive in nature.

The TNMS Installation Checklist is a basic template structured with the following sections:

- Read Me First
- Table of Contents
- System Configuration
- Initial Configuration
- Software Pre-requisites
- TNMS Installation
- Final Configuration
- General Notes
- Print Instructions

The configuration settings and parameter fields that are provided can be edited and expanded upon, based on the operator's needs. The information that is filled out in the TNMS Installation Checklist (Linux) should be saved so that it can be referred back to whenever needed.

**Saving the TNMS Installation Checklist**

To save the TNMS Installation Checklist (Linux):

- If Adobe Reader displays the message **Protected View: This file originated from a potentially unsafe location, and most features have been disabled to avoid potential security risks.**, click **Enable All Features**. The PDF shows this as a yellow bar above the attachment panel.

- Open the **Attachments** tab situated below the **Bookmarks** tab.
- Select the TNMS Installation Checklist file and click the **Save Attachment** icon.
- Choose a directory to save the TNMS Installation Checklist (Linux) file.

> **NOTICE:** When saving this file, the following security measures are strongly advised:
>
> - Save the file on an encrypted storage or disk (internal or external).
> - Restrict storage or disk access to the internal network (no Internet access).
> - Restrict storage or disk access to Administrators and authorized authenticated users.
> - Password protect the file from unauthorized users.

The checklist spreadsheet is now ready to be populated with your configuration settings, parameters and notes.

## 2.2. Installation and Cabling

Before installation, make sure that the components are not damaged in any way, and the delivery is complete and in accordance with the delivery units specified in the delivery note (hardware, software, licenses and documentation).

Do not start the installation without checking if:

- The Client and Server are cabled and set up according to project specifications.
- Uninterruptible power supply is available.
- Any other applicable recommendations are observed.

## 2.3. Hardware Requirements

The table below gives an overview of the hardware requirements for deploying TNMS.

The Hardware Requirements listed in Table 3: Hardware requirements for installations of TNMS (p. 14) should suffice for most deployments, however TNMS may require different specifications depending on parameters such as network architecture (number of TNMS Clients) or operation policies (backup, logs).

The final hardware specifications and configuration must be planned specifically for each customer. Contact Technical Sales for more information.

> **Tip:** It is highly recommended to take note of relevant configurations using the TNMS Installation Checklist (Linux) spreadsheet.

For more information regarding this checklist refer to chapter [TNMS Installation Checklist](#211-tnms-installation-checklist) (p. 12).

In all recommended configurations, TNMS Server and TNMS Mediation(s) must be installed on the same machine.

Refer to chapter TNMS Special Deployment (p. 50) for instructions about TNMS Server and TNMS Mediation installations.

**Table 3: Hardware requirements for installations of TNMS**

| Components | Hardware | Small | Small Plus | Medium | Large |
| --- | --- | --- | --- | --- | --- |
| TNMS Server + TNMS Mediation | CPU | 8C/16T/16 vcpus, Max Turbo 3.7 GHz | 16C/32T/32 vcpus, Max Turbo 3.7 GHz | 32C/64T/64 vcpus, Max Turbo 3.7 GHz | 80C/160T/160 vcpus, Max Turbo 3.7 GHz |
| TNMS Server + TNMS Mediation | RAM | 16 GB DDR4-2666 | 32 GB DDR4-2666 | 64 GB DDR4-2666 | 256 GB DDR4-2666 |
| TNMS Server + TNMS Mediation | Disk | (1x) 1 TB HDD | (2x) 600 GB SSD | (2x) 1 TB SSD | (1x) 960 GB SSD + (3x) 1.2 TB SSD |
| TNMS Server + TNMS Mediation | Disks with redundancy | (2x) 1 TB HD (Raid-1) | (4x) 600 GB SSD (Raid-1) | (4x) 1 TB SSD (Raid-1) | (2x) 960 GB SSD (Raid-1) + (6x) 1.2 TB SSD (Raid-6) |
| TNMS FE Server | CPU | 24C/48T/48 vcpus, Max Turbo 3.7 GHz | 24C/48T/48 vcpus, Max Turbo 3.7 GHz | 24C/48T/48 vcpus, Max Turbo 3.7 GHz | 24C/48T/48 vcpus, Max Turbo 3.7 GHz |
| TNMS FE Server | RAM | 100 GB DDR4-2666 | 100 GB DDR4-2666 | 100 GB DDR4-2666 | 100 GB DDR4-2666 |
| TNMS FE Server | Disk | (1x) 400 GB SSD | (1x) 400 GB SSD | (1x) 400 GB SSD | (1x) 400 GB SSD |
| TNMS FE Server | Disks with redundancy | (2x) 400 GB SSD (Raid-1) | (2x) 400 GB SSD (Raid-1) | (2x) 400 GB SSD (Raid-1) | (2x) 400 GB SSD (Raid-1) |
| TNMS Client (Windows) | CPU | 4 core / 8 threads / 8 vcpus 3.20 GHz. Recommended GPUs: Intel Core i3/i5/i7-3000 series or newer; AMD A4/A6/A8/A10 5000 series or newer; GPUs with support for OpenGL ES 3.0 or newer. | 4 core / 8 threads / 8 vcpus 3.20 GHz. Recommended GPUs: Intel Core i3/i5/i7-3000 series or newer; AMD A4/A6/A8/A10 5000 series or newer; GPUs with support for OpenGL ES 3.0 or newer. | 4 core / 8 threads / 8 vcpus 3.20 GHz. Recommended GPUs: Intel Core i3/i5/i7-3000 series or newer; AMD A4/A6/A8/A10 5000 series or newer; GPUs with support for OpenGL ES 3.0 or newer. | 4 core / 8 threads / 8 vcpus 3.20 GHz. Recommended GPUs: Intel Core i3/i5/i7-3000 series or newer; AMD A4/A6/A8/A10 5000 series or newer; GPUs with support for OpenGL ES 3.0 or newer. |
| TNMS Client (Windows) | RAM | 8 GB DDR4-2666 | 8 GB DDR4-2666 | 8 GB DDR4-2666 | 8 GB DDR4-2666 |
| TNMS Client (Windows) | Disk | 500 GB | 500 GB | 500 GB | 500 GB |

Footnote: RAM: DDR4-2666 is the minimum requirement. Higher speeds or DDR5 can also be used.

TNMS FE Server and TNMS Client (Windows) values apply to every tier (Small, Small Plus, Medium, and Large). The PDF merges those cells across the tier columns.

> **Note:** In all configurations, AMD64/x86_64 processor architectures must be used.

> **Note:** Usage of the former disk configuration with 600GB disks in a Medium configuration, is only supported if the number of 15min PMPs is under 20000.

> **NOTICE:** Transcend eDNA and Node Manager are supported in a medium or large configuration only.

Contact Technical Support for more information.

> **Note:** Small configurations in production environments require pre-approval by a TNMS Product Line Manager, and are only supported for networks with:
>
> - Only one of the following mediators:
>   - Generic Mediator
>   - MultiVendor Mediator
> - The bare minimum of TNMS components and NBIs installed, only if strictly necessary.

> **NOTICE:** Node Manager and eDNA are not supported in a Small configuration in a production environment.

> **NOTICE:** If Transcend Controller is to be included in the network, utilizing the TNMS database, the TNMS Server machine requires 256 GB of extra for the Medium configuration. The extra disk space is required in the `ora2` filesystem.

> **Note:** To enhance TNMS machine High Availability, use hardware with more Ethernet physical ports to support link aggregation. The aggregation of Ethernet ports can provide higher system throughput and availability by using load balancing and fail over mechanisms, respectively.

To perform link aggregation, consider using the Network Bonding solution of the RHEL OS.

### 2.3.1. Virtualization

The current version of TNMS has been tested on several virtualization technologies. There should be no technical reason to impede the correct functioning of the TNMS server on a virtual machine, if all system requirements (hardware requirements, configurations and supported operating systems) described in this document are followed.

> **Note:** The system requirements outlined in this document apply to the specifications of the virtual machine not the virtual host/hypervisor.

## 2.4. Supported Operating Systems

Throughout this and the following chapters the designation of the several operating systems is often abbreviated to allow for better readability. Always refer to the current section for the exact versions supported for TNMS.

> **Tip:** It is highly recommended to take note of relevant configurations using the TNMS Installation Checklist (Linux). For more information regarding this checklist refer to chapter [TNMS Installation Checklist](#211-tnms-installation-checklist) (p. 12) spreadsheet.

> **Note:** Refer to the Release Notes Appendix, Licensed Software chapter for an updated list of supported Linux versions for the Server machine.

> **Note:** For networks that include 7100 Nano FP13.0.1 and earlier NEs, contact Technical Support.

> **Note:** Minimum display resolution is 1024x768.

> **Note:** English must be the Operating System language for the Server machine. If you must use another language, contact Nokia.

## 2.5. Software Prerequisites by Component

The following table describes which software is required for each component. Attend to the fact that the table also shows the order in which the components should be installed. After installing the operating system, the system should be commissioned as follows:

**Table 4: TNMS software prerequisites and their installation sequence**

| Software | Server | Client |
| --- | --- | --- |
| Dedicated PDF Reader | — | Mandatory to open the manuals. |
| Software Prerequisites Installation (Oracle 19c installation package) | Mandatory | — |

## 2.6. Latency and Bandwidth Requirements

Verify that your network complies with the values in the following tables:

**Table 5: Minimum bandwidth**

| From \ To | NEs | TNMS Mediation | TNMS Server | TNMS Clients |
| --- | --- | --- | --- | --- |
| NEs | n/a | 10 Mb/s | n/a | n/a |
| TNMS Mediation | 100 Mb/s | n/a | 100 Mb/s | n/a |
| TNMS Server | n/a | 100 Mb/s | 50 Mb/s (to Standby Server) | 100 Mb/s |
| TNMS Clients | n/a | n/a | 10 Mb/s | n/a |

**Table 6: Maximum latency (Round-trip delay time)**

| From \ To | NEs | TNMS Mediation | TNMS Server | TNMS Clients |
| --- | --- | --- | --- | --- |
| NEs | n/a | 50 ms | n/a | n/a |
| TNMS Mediation | 50 ms | n/a | 50 ms | n/a |
| TNMS Server | n/a | 50 ms | 50 ms (to Standby Server) | 50 ms |
| TNMS Clients | n/a | n/a | 50 ms | n/a |

## 2.7. Installation Software

Nokia delivers the following software:

- TNMS Server for Linux.
- TNMS Server and Mediation for Linux.
- TNMS Mediation for Linux.
- TNMS Client for Windows.

> **Note:** The versions of the software to install must be the ones from the original product.

> **Note:** Only required software must be installed on either the Server or Client machines. Installing additional software may cause TNMS not to function correctly.

> **Note:** Read the Release Notes before installing TNMS.

## 2.8. Configuring the BIOS

This chapter describes the recommended configurations for the system's BIOS.

> **NOTICE:** The instructions in this chapter refer to HP machines with iLO 6 and may differ depending on hardware configurations.

To access the BIOS, boot the machine and press F9 at the startup screen.

- Disable the boot from the network: Go to **System Configuration > BIOS (RBSU) > Network Options > Network Boot Options > PCle Slot Network Boot** and set all Network Interface Cards to **Disabled**.
- Processor options:
  - Go to **System Configuration > BIOS (RBSU) > Virtualization Options > Intel Virtualization Technology (intel VT)** and set to **Disabled**.
  - Go to **System Configuration > BIOS (RBSU) > Virtualization Options > Intel VT-d**, and set to **Disabled**.
- Power management options:
  - Go to **System Configuration > BIOS/Platform Configuration (RBSU)** and in the **Workload Profiles** dropdown Select **Transactional Application Processing**. Press F12 to apply the changes and exit the BIOS.

Once the reboot is complete, go to **Power & Thermal > Power Settings** tab. If the **Power Regulator Setting** is not set to **Static High Performance Mode**, then select it and then click **Apply**. Reboot if requested.
