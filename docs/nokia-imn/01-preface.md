Source: installation_manual_linux.pdf, chapter 1, pages 7–10.

# 1. Preface

Transcend Network Management System (TNMS) is a Nokia standalone application that manages the physical structure of the transport network as well as the logical end-to-end connections and services.

The TNMS Installation Manual describes the installation and uninstallation procedures of TNMS, with a TNMS Server running on Linux.

The contents of this manual apply only to TNMS 9.1.

## 1.1. Intended audience

This document is intended for TNMS installers and administrators with knowledge of UNIX and Linux.

## 1.2. Symbols and Conventions

The following symbols and mark-up conventions are used in this document:

**Table 1: List of symbols and conventions**

A safety message indicates a dangerous situation where personal injury is possible. The keywords denote hazard levels with the following meaning:

**DANGER!**
: DANGER! Indicates a hazardous situation which, if not avoided, will result in death or serious (irreversible) personal injury.

**WARNING!**
: WARNING! Indicates a hazardous situation which, if not avoided, could result in death or serious (irreversible) personal injury.

**CAUTION!**
: CAUTION! Indicates a hazardous situation which, if not avoided, may result in minor or moderate (reversible) personal injury.

**NOTICE:**
: A property damage message indicates a hazard that may result in equipment damage, data loss, traffic interruption, and so on.

**Note:**
: A note provides important information related to the topic, for example, not obvious exceptions to a rule or side effects.

**Tip:**
: A tip provides additional information related to the topic which is not essential in the context, but given for convenience.

**Bold**
: - All names of graphical user interface (GUI) objects, such as windows, field names, buttons, and so on. Example: Select the **Full Screen** check box and press **OK**.
  - Terms and abbreviations which are linked to an entry in the glossary and list of abbreviations respectively.
  - Important key words.

**Italic**
: - Files, folders, and file system paths. Example: `/usr/etc/sbin/ftpd.exe`
  - Emphasized words.
  - Document titles. Example: Refer to *WebGUI User Guide*

**typewriter**
: - Input to be typed in a command line or a GUI field. Examples: `ping -t 192.168.0.1`. Enter `World` in the **Domain** field.
  - Output from a command, error messages, content of a status line, and so on.
  - File content, such as program sources, scripts, logs, and settings.

**`<angle brackets>`**
: Placeholders, for example as part of a file name or field value. Examples: `<picture name>.png` or `<ip address>:<port number>`

**`[square brackets]`**
: A key to be pressed on a PC keyboard, for example `[F11]`. Keys to be pressed simultaneously are concatenated with a "+" sign, for example `[CTRL]+[ALT]+[DEL]`. Keys to be pressed one after another are concatenated with spaces, for example `[ESC] [SPACE] [M]`.

**`>`**
: The greater than symbol `>` is used to concatenate a series of GUI items in order to depict a GUI path. This is an abridged presentation of a procedure to be carried out in order to perform an action or display a window or dialog box. Examples: A simple menu path: **File > Save as ...**. A more complex GUI path: **> Main window > File menu > Change Password command > Change Password dialog box**.

**x (in card names)**
: For convenience, card names are sometimes listed with a lower case x variable, in order to concisely represent multiple cards. Example: CHMx (is to be interpreted as CHM1 and CHM2).

Please read the relevant documents carefully before use.

Screenshots of the graphical user interface are examples only to illustrate principles. This especially applies to a software version number visible in a screenshot.

## 1.3. TNMS and Components Documentation

The operational documents listed below are available in the `TNMS_Prerequisites > Documentation` folder, `<Product_Installation_Folder>\TNMS\client\help` or via the TNMS help menu (select manuals).

**Transcend NMS Documentation**

- TNMS Administration Manual
- TNMS Communication Matrix
- TNMS Dimensioning Guidelines
- TNMS Installation Manual Linux
- TNMS Installation Manual Windows
- TNMS List of Configurable Parameters and Default Values
- TNMS System Description and Operation Guidelines
- TNMS Troubleshooting Manual
- TNMS Upgrade Manual
- TNMS Online Help (via F1 or the help button in the TNMS Client GUI)
- Transcend Client Help

**Transcend Node Manager Documentation**

- TNMS Node Manager Documentation Update
- TNMS 5500 Node Manager User Manual
- TNMS 7090 Node Manager User Manual
- TNMS 7100 and mTera Node Manager User Manual

## 1.4. Other Documents

**Legacy products and Network Elements**

This manual concerns TNMS only. For more detailed information on other legacy products or the managed network elements (NEs), see the corresponding documentation.

**Release notes**

Where applicable, contains installation hints, patch descriptions, list of supported NEs, list of supported cards and any relevant last minute information.

## 1.5. Documentation Feedback

To comment on this document, go to the [Online Comment Form](https://documentation.nokia.com/comments/) or e-mail your comments to the [Comments Hotline](mailto:comments@nokia.com).

## 1.6. History of Changes

This chapter describes the main changes for the current document and since the last version.

**Table 2: History of Changes**

| Document number | Issue date | Remarks |
| --- | --- | --- |
| A50023-K2268-X040-76D1 | August 2026 | Chapter Setting Up the FTP Service (p. 61) was updated.<br>Chapter TNMS Server and Mediation Installation (p. 43) was updated.<br>Chapter TNMS Frontend Server Installation (p. 55) was updated.<br>Chapter Hardware Requirements (p. 13) was updated.<br>Chapter Disk Configuration (p. 19) was updated.<br>Chapter TNMS Installer Integrity Validation (p. 42) was updated.<br>Chapter Glossary (p. 76) was updated.<br>Chapter Linux 8.X (p. 23) was updated.<br>Chapter Linux 9.X (p. 25) was updated.<br>Chapter TNMS Database Installation and Configuration (p. 37) was updated.<br>Chapter Virtualization (p. 15) was updated.<br>Chapter Before you Begin (p. 11) was updated. |
