# TNMS 9.1 Installation Manual (Linux) — working copy

Nokia Transcend Network Management System (TNMS), Release 9.1.

| | |
| --- | --- |
| Title | Installation Manual (IMN, Linux) |
| Document | A50023-K2268-X040-76D1 |
| Revision | Issue 001, August 2026 |
| Source file | [`installation_manual_linux.pdf`](../../installation_manual_linux.pdf) |

This Markdown is a working copy for installers who already have that PDF. The PDF is the source of record. Nokia marks the manual confidential. Use it under the same restrictions as the PDF.

The blank checklist that was attached to the PDF is [tnms-installation-checklist-linux.xlsx](tnms-installation-checklist-linux.xlsx). It contains Nokia's example values. A filled copy holds passwords and addresses. Keep filled copies on encrypted storage, not in git.

## Chapters

1. [Preface](01-preface.md)
2. [Preparation](02-preparation.md)
3. [TNMS Server operating system configuration](03-os-configuration.md)
4. [Initial system configuration](04-initial-system-configuration.md)
5. [Software prerequisites](05-software-prerequisites.md)
6. [TNMS installation](06-tnms-installation.md)
7. [Final system configuration](07-final-system-configuration.md)
8. [Migrating from other systems](08-migration.md)
9. [Update TNMS](09-update.md)
10. [Uninstallation](10-uninstallation.md)
11. [Abbreviations](abbreviations.md)
12. [Glossary](glossary.md)

The customer procedure for the install we are doing (one RHEL host, Small Plus, Server and Mediation together) is [../customer/tnms-9.1-linux-install.md](../customer/tnms-9.1-linux-install.md).

## How this copy was made

Text came from `pdftotext -layout`. Tables that the PDF sets in columns (hardware, disks, bandwidth, latency, NTP, IPv6, fstab examples, patch log, password characters, mediation hardware) were checked against page images. Running headers, footers, and page numbers are removed.

Two places the PDF itself does not yield clean text:

- Table 15, page 41. Both solution cells are cut off at the page edge. The gap is marked in chapter 5.
- Page 12 shows an Adobe Reader Protected View bar. The bar text is written into chapter 2. The attachment screenshot is not reproduced. The spreadsheet file is the attachment.

Shell commands keep the manual's spelling. The listener name is printed `lisner`.
