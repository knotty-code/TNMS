# TNMS 9.1 Linux installation

Nokia installation manual, release 9.1 (A50023-K2268-X040-76D1), and the procedure we are following on one Small Plus RHEL machine.

- Vendor manual, chapter by chapter: [docs/nokia-imn/README.md](docs/nokia-imn/README.md). The PDF in this directory is the source of record.
- New VM, before the install: [docs/customer/pre-install.md](docs/customer/pre-install.md). Same resources as this server. The 1 TB disk is mounted on `/opt`.
- Install when the server does not have this repository: [docs/customer/install-without-repo.md](docs/customer/install-without-repo.md). Before section 1, copy `install-tnms-wizard.sh`, `tnms-install.properties.in`, and the three zip files to `/tmp`. **Move the files out of /tmp** moves them into `/opt/tnms-install` and sets the permissions.
- Ordered commands from the install on this host: [docs/customer/install-log.md](docs/customer/install-log.md).
- Manual-aligned notes for the same install: [docs/customer/tnms-9.1-linux-install.md](docs/customer/tnms-9.1-linux-install.md). Oracle 19c and TNMS 9.1.0.593.0 Server and Mediation are installed. `scs_daemon` is running and NGINX answers on port 8444.
