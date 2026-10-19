# TNMS 9.1 Linux installation

This repository holds the Nokia TNMS 9.1 Linux manual and the procedure for one Small Plus RHEL 8 machine. The procedure installs TNMS Server and Mediation together, with a new Oracle 19c database.

## Start here

Read these two guides in order.

1. [docs/customer/pre-install.md](docs/customer/pre-install.md). The disk layout for a new VM. The customer applies sections 2 through 4. Section 6 (VS Code) stays manual.
2. [docs/customer/using-make.md](docs/customer/using-make.md). Copy `Makefile`, `install-tnms-wizard.sh`, `tnms-install.properties.in`, and the three vendor zip files to `/tmp` on the server, then run `make`. The server does not need a clone of this repository.

[docs/customer/install-without-repo.md](docs/customer/install-without-repo.md) describes what each `make` target changes, and the manual GUI path. Follow `using-make.md` for the commands.

The Oracle and TNMS zip files are not in this repository.

`pre-install.md` and `install-without-repo.md` have Word copies in the same directory:

- [docs/customer/TNMS-9.1-RHEL8-pre-install.docx](docs/customer/TNMS-9.1-RHEL8-pre-install.docx)
- [docs/customer/TNMS-9.1-RHEL8-install-without-repo.docx](docs/customer/TNMS-9.1-RHEL8-install-without-repo.docx)

## Rest of the repository

The vendor PDF is [installation_manual_linux.pdf](installation_manual_linux.pdf). That PDF is the source of record. The chapter text is in [docs/nokia-imn/README.md](docs/nokia-imn/README.md).

[scripts/Makefile](scripts/Makefile) runs that install. [scripts/install-tnms-wizard.sh](scripts/install-tnms-wizard.sh) replays the Server and Mediation choices without a screen. [scripts/tnms-install.properties.in](scripts/tnms-install.properties.in) is the response file it fills in. The install guide is the place that says when to run them.

[docs/customer/install-log.md](docs/customer/install-log.md) is the ordered record of an earlier install. [docs/customer/TNMS-9.1-RHEL8-install-log.docx](docs/customer/TNMS-9.1-RHEL8-install-log.docx) is the Word copy. [docs/customer/tnms-9.1-linux-install.md](docs/customer/tnms-9.1-linux-install.md) is the same install written against the Nokia manual. [docs/customer/tnmsdemo-undo-swap.md](docs/customer/tnmsdemo-undo-swap.md) is a cleanup for a different host.
