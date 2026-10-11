# TNMS 9.1 install without this repository.
# Copy this file to /tmp with the wizard, the properties file, and the three zip files.
# The shell program is in LIB. Site values are exported into that program.
# make scan reads the host. make prepare applies the disk layout after CONFIRM=yes.

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.DELETE_ON_ERROR:
.NOTPARALLEL:
.DEFAULT_GOAL := all

THIS_MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
STAMP := /var/lib/tnms-install

-include /root/tnms-install.answers
-include /root/tnms-install.local.mk

TNMS_HOSTNAME ?= TNMS
TNMS_IP ?=
TNMS_ADMIN_GROUP ?= azureuser
TNMS_SID ?= TNMS
TNMS_DATA_DISK ?=
SYS_PASSWORD ?= TnZT5hgW8Zwsp79
SYSTEM_PASSWORD ?= TnZT5hgW8Zwsp79
TNMSDBA_PASSWORD ?= Tnc25xQ36XBUa9
TNMS_SFTP_PASSWORD ?= Tsvb5-Xe8ou3wR9

export THIS_MAKEFILE STAMP
export TNMS_HOSTNAME TNMS_IP TNMS_ADMIN_GROUP TNMS_SID TNMS_DATA_DISK
export SYS_PASSWORD SYSTEM_PASSWORD TNMSDBA_PASSWORD TNMS_SFTP_PASSWORD

define LIB
set -euo pipefail
export LC_ALL=C

ROOT=/opt/tnms-install
MEDIA=/opt/tnms-install/resources
PROPS=/opt/tnms-install/tnms-install.properties.in
WIZARD=/opt/tnms-install/install-tnms-wizard.sh
CRED=/root/tnms-db-credentials
SYSCTL_FILE=/etc/sysctl.d/99-tnms.conf
MIN_ROOT_BYTES=$$((4531 * 1000 * 1000))
SWAP_BYTES=$$((18 * 1024 * 1024 * 1024))

WIZARD_NAME=install-tnms-wizard.sh
PROPS_NAME=tnms-install.properties.in
ZIPS=(
  LINUX.X64_193000_db_home_and_patches.zip
  TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip
  TNMS_LUX_R9.1.0.593.0_1904.zip
)
ORACLE_ZIPS=(
  LINUX.X64_193000_db_home.zip
  p30869156_190000_Linux-x86-64.zip
  p30894985_190000_Linux-x86-64.zip
  p35775632_190000_Linux-x86-64.zip
)
PACKAGES=(
  epel-release attr bc elfutils-libelf-devel fontconfig-devel gcc gcc-c++
  jemalloc ksh libaio libaio-devel libnsl libXtst libzip make psmisc sysstat
  unzip perl binutils glibc-devel
)

require_root() {
  if [[ "$$(id -u)" -ne 0 ]]; then
    echo "Run make as root." >&2
    exit 1
  fi
}

stamp() {
  mkdir -p "$$STAMP"
  touch "$$STAMP/$$1"
}

resolve_domain() {
  awk '/^search / { print $$2; exit }' /etc/resolv.conf
}

resolve_ip() {
  local ip
  ip=$${TNMS_IP:-}
  if [[ -z "$$ip" ]]; then
    ip=$$(ip -4 route get 1.1.1.1 | awk '{
      for (i = 1; i <= NF; i++) if ($$i == "src") { print $$(i + 1); exit }
    }')
  fi
  if [[ ! "$$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$$ ]]; then
    echo "Could not determine an IPv4 address. Set TNMS_IP." >&2
    return 1
  fi
  printf '%s\n' "$$ip"
}

mode_is() {
  local path=$$1 mode=$$2 user=$$3 group=$$4 got
  got=$$(stat -c '%a %U %G' "$$path" 2>/dev/null) || return 1
  [[ "$$got" == "$$mode $$user $$group" ]]
}

oracle_present() {
  [[ -f /etc/oratab ]] || return 1
  grep -q "^$${TNMS_SID}:" /etc/oratab
}

oracle_log_path() {
  local newest
  shopt -s nullglob
  local logs=(/home/oracle/ossnms_installation_log/oracle_installation_*.log)
  shopt -u nullglob
  if [[ -z $${logs[*]+x} ]]; then
    return 1
  fi
  newest=$$(ls -1t "$${logs[@]}")
  newest=$${newest%%$$'\n'*}
  printf '%s\n' "$$newest"
}

preflight_ok() {
  local bad=0 rel
  if [[ "$$(id -u)" -ne 0 ]]; then
    echo "preflight: run as root" >&2
    bad=1
  fi
  if ! getent group "$$TNMS_ADMIN_GROUP" >/dev/null; then
    echo "preflight: group $$TNMS_ADMIN_GROUP does not exist" >&2
    bad=1
  fi
  if ! getenforce 2>/dev/null | grep -qx 'Enforcing'; then
    echo "preflight: SELinux is not Enforcing" >&2
    bad=1
  fi
  rel=$$(cat /etc/redhat-release 2>/dev/null || true)
  if [[ "$$rel" != *"release 8"* ]]; then
    echo "preflight: /etc/redhat-release is '$${rel:-missing}'. Expected release 8." >&2
    bad=1
  fi
  return "$$bad"
}

layout_ok() {
  local bad=0 name n g=$$TNMS_ADMIN_GROUP got
  mode_is /opt/oracle 755 root root || { echo "stage: /opt/oracle mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/nokia 755 root root || { echo "stage: /opt/nokia mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/tnms-data 755 root root || { echo "stage: /opt/tnms-data mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/oradata 755 root root || { echo "stage: /opt/oradata mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/oradata/ora1 755 root root || { echo "stage: /opt/oradata/ora1 mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/oradata/ora2 755 root root || { echo "stage: /opt/oradata/ora2 mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/oradata/ora3 755 root root || { echo "stage: /opt/oradata/ora3 mode is not 755 root root" >&2; bad=1; }
  mode_is /opt/tnms-install/resources 750 root "$$g" || { echo "stage: resources mode is not 750 root $$g" >&2; bad=1; }
  got=$$(stat -c '%a %U %G' /opt/tnms-install 2>/dev/null || true)
  if [[ "$$got" != "750 root $$g" && "$$got" != "751 root $$g" ]]; then
    echo "stage: /opt/tnms-install mode is '$${got:-missing}'. Expected 750 or 751 root $$g." >&2
    bad=1
  fi
  mode_is "$$WIZARD" 740 root "$$g" || { echo "stage: $$WIZARD mode is not 740 root $$g" >&2; bad=1; }
  mode_is "$$PROPS" 640 root "$$g" || { echo "stage: $$PROPS mode is not 640 root $$g" >&2; bad=1; }
  for name in "$${ZIPS[@]}"; do
    mode_is "$$MEDIA/$$name" 640 root "$$g" || { echo "stage: $$MEDIA/$$name mode is not 640 root $$g" >&2; bad=1; }
  done
  if [[ -f "$$PROPS" ]]; then
    n=$$(grep -c '@TNMS_IP@' "$$PROPS" || true)
    if [[ "$$n" != 7 ]]; then
      echo "stage: @TNMS_IP@ count is $${n:-0}, expected 7" >&2
      bad=1
    fi
    grep -Fxq 'USER_INSTALL_DIR=/opt/nokia/tnms' "$$PROPS" || { echo "stage: USER_INSTALL_DIR is missing" >&2; bad=1; }
    grep -Fxq 'USER_INSTALL_DIR_TMP=/opt/nokia/tnms' "$$PROPS" || { echo "stage: USER_INSTALL_DIR_TMP is missing" >&2; bad=1; }
    grep -Fxq 'USER_DATA_DIR=/nokia/tnms' "$$PROPS" || { echo "stage: USER_DATA_DIR is missing" >&2; bad=1; }
    grep -Fxq 'ORACLE_INSTALL_DIR=/opt/oracle' "$$PROPS" || { echo "stage: ORACLE_INSTALL_DIR is missing" >&2; bad=1; }
    grep -Fxq 'ORACLE_DATA_DIR=/oradata' "$$PROPS" || { echo "stage: ORACLE_DATA_DIR is missing" >&2; bad=1; }
  else
    echo "stage: $$PROPS is missing" >&2
    bad=1
  fi
  return "$$bad"
}

host_ok() {
  local bad=0 ip domain fqdn line got
  ip=$$(resolve_ip) || return 1
  domain=$$(resolve_domain)
  if [[ -z "$$domain" ]]; then
    echo "host: /etc/resolv.conf has no search domain" >&2
    return 1
  fi
  fqdn="$${TNMS_HOSTNAME}.$${domain}"
  got=$$(hostnamectl --static 2>/dev/null || true)
  if [[ "$$got" != "$$TNMS_HOSTNAME" ]]; then
    echo "host: static hostname is '$${got:-empty}', expected $$TNMS_HOSTNAME" >&2
    bad=1
  fi
  if ! grep -qE '^preserve_hostname:[[:space:]]*true[[:space:]]*$$' /etc/cloud/cloud.cfg 2>/dev/null; then
    echo "host: preserve_hostname is not true" >&2
    bad=1
  fi
  if ! grep -qx 'LANG=en_US.UTF-8' /etc/locale.conf 2>/dev/null; then
    echo "host: /etc/locale.conf does not set LANG=en_US.UTF-8" >&2
    bad=1
  fi
  if ! awk -v ip="$$ip" -v fqdn="$$fqdn" -v short="$$TNMS_HOSTNAME" '
    $$1 == ip && $$2 == fqdn && $$3 == short { found = 1 }
    END { exit !found }
  ' /etc/hosts; then
    echo "host: /etc/hosts has no line '$$ip  $$fqdn $$TNMS_HOSTNAME'" >&2
    bad=1
  fi
  got=$$(hostname --fqdn 2>/dev/null || true)
  if [[ "$$got" != "$$fqdn" ]]; then
    echo "host: hostname --fqdn is '$${got:-empty}', expected $$fqdn" >&2
    bad=1
  fi
  if ! getent -s files hosts "$$TNMS_HOSTNAME" | awk -v ip="$$ip" -v fqdn="$$fqdn" -v short="$$TNMS_HOSTNAME" '
    $$1 == ip && $$2 == fqdn && $$3 == short { found = 1 }
    END { exit !found }
  '; then
    echo "host: getent -s files hosts $$TNMS_HOSTNAME did not return $$ip $$fqdn $$TNMS_HOSTNAME" >&2
    bad=1
  fi
  if nisdomainname >/dev/null 2>&1; then
    echo "host: nisdomainname is set" >&2
    bad=1
  fi
  return "$$bad"
}

packages_ok() {
  if rpm -q "$${PACKAGES[@]}" >/dev/null 2>&1; then
    return 0
  fi
  echo "packages: rpm -q is missing one of: $${PACKAGES[*]}" >&2
  rpm -q "$${PACKAGES[@]}" >&2 || true
  return 1
}

kernel_file_text() {
  printf '%s\n' 'vm.swappiness = 1' 'vm.dirty_ratio = 15' 'vm.dirty_background_ratio = 3' 'vm.min_free_kbytes = 1048576'
}

kernel_ok() {
  local bad=0 have want en ac
  want=$$(kernel_file_text)
  have=$$(grep -v '^[[:space:]]*$$' "$$SYSCTL_FILE" 2>/dev/null || true)
  if [[ "$$have" != "$$want" ]]; then
    echo "kernel: $$SYSCTL_FILE does not match the four TNMS settings" >&2
    bad=1
  fi
  [[ "$$(sysctl -n vm.swappiness 2>/dev/null || true)" == 1 ]] || { echo "kernel: vm.swappiness is not 1" >&2; bad=1; }
  [[ "$$(sysctl -n vm.dirty_ratio 2>/dev/null || true)" == 15 ]] || { echo "kernel: vm.dirty_ratio is not 15" >&2; bad=1; }
  [[ "$$(sysctl -n vm.dirty_background_ratio 2>/dev/null || true)" == 3 ]] || { echo "kernel: vm.dirty_background_ratio is not 3" >&2; bad=1; }
  [[ "$$(sysctl -n vm.min_free_kbytes 2>/dev/null || true)" == 1048576 ]] || { echo "kernel: vm.min_free_kbytes is not 1048576" >&2; bad=1; }
  en=$$(systemctl is-enabled firewalld 2>/dev/null || true)
  ac=$$(systemctl is-active firewalld 2>/dev/null || true)
  if [[ "$$en" != disabled || "$$ac" != inactive ]]; then
    echo "kernel: firewalld is $$en/$$ac, expected disabled/inactive" >&2
    bad=1
  fi
  ac=$$(systemctl is-active chronyd 2>/dev/null || true)
  if [[ "$$ac" != active ]]; then
    echo "kernel: chronyd is '$$ac', expected active" >&2
    bad=1
  fi
  return "$$bad"
}

on_data_disk() {
  local path=$$1 opt_src src
  opt_src=$$(findmnt -n -o SOURCE /opt)
  src=$$(findmnt -n -o SOURCE "$$path" 2>/dev/null || true)
  [[ "$$src" == "$$opt_src" || "$$src" == "$$opt_src"* ]]
}

disk_ok() {
  local bad=0 opts src bytes
  src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  if [[ "$$src" != /dev/mapper/datavg-optlv ]]; then
    echo "disk: /opt source is '$${src:-empty}'" >&2
    bad=1
  fi
  for path in / /tmp /home /opt; do
    findmnt -n "$$path" >/dev/null || { echo "disk: $$path is not a mount" >&2; bad=1; }
  done
  opts=$$(findmnt -no OPTIONS /tmp 2>/dev/null || true)
  if [[ "$$opts" == *noexec* ]]; then
    echo "disk: /tmp is mounted noexec" >&2
    bad=1
  fi
  bytes=$$(df -B1 --output=size /tmp 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  if [[ -z "$$bytes" || "$$bytes" -lt $$((15 * 1000 * 1000 * 1000)) ]]; then
    echo "disk: /tmp filesystem is smaller than 15 GB" >&2
    bad=1
  fi
  if ! swapon --show=NAME,SIZE --bytes --noheadings 2>/dev/null | awk -v n="/opt/swapfile" -v s="$$SWAP_BYTES" '
    $$1 == n && $$2 == s { found = 1 }
    END { exit !found }
  '; then
    echo "disk: /opt/swapfile is not an $${SWAP_BYTES}-byte swap" >&2
    swapon --show >&2 || true
    bad=1
  fi
  for path in /opt/oracle /opt/nokia /opt/tnms-install /nokia /oradata; do
    on_data_disk "$$path" || { echo "disk: $$path is not on the /opt volume" >&2; bad=1; }
  done
  src=$$(findmnt -n -o SOURCE /nokia 2>/dev/null || true)
  [[ "$$src" == *"[/tnms-data]"* ]] || { echo "disk: /nokia source is '$${src:-empty}'" >&2; bad=1; }
  src=$$(findmnt -n -o SOURCE /oradata 2>/dev/null || true)
  [[ "$$src" == *"[/oradata]"* ]] || { echo "disk: /oradata source is '$${src:-empty}'" >&2; bad=1; }
  for path in /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3 "$$MEDIA"; do
    [[ -d "$$path" ]] || { echo "disk: missing $$path" >&2; bad=1; }
  done
  if [[ ! -d /opt/nokia/tnms/server ]]; then
    bytes=$$(df -B1 --output=avail / | tail -n 1 | tr -d ' ')
    if [[ "$$bytes" -lt "$$MIN_ROOT_BYTES" ]]; then
      echo "disk: / has $$bytes bytes free. TNMS.bin needs about 4531 MB before the wizard." >&2
      bad=1
    fi
  fi
  return "$$bad"
}

unpack_ok() {
  local bad=0 name mode
  mode=$$(stat -c '%a' /opt/tnms-install/installer/TNMS_Installer/TNMS.bin 2>/dev/null || true)
  if [[ "$$mode" != 744 ]]; then
    echo "unpack: TNMS.bin mode is '$${mode:-missing}', expected 744" >&2
    bad=1
  fi
  if [[ ! -x /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle/installation/installation.sh ]]; then
    echo "unpack: installation.sh is not executable" >&2
    bad=1
  fi
  for name in "$${ORACLE_ZIPS[@]}"; do
    if [[ ! -f "/opt/oracle/oramedia/$$name" ]]; then
      echo "unpack: missing /opt/oracle/oramedia/$$name" >&2
      bad=1
    fi
  done
  return "$$bad"
}

cred_values_ok() {
  [[ -f "$$CRED" ]] || return 1
  grep -Fxq "SYS_PASSWORD=$${SYS_PASSWORD}" "$$CRED" || return 1
  grep -Fxq "SYSTEM_PASSWORD=$${SYSTEM_PASSWORD}" "$$CRED" || return 1
  grep -Fxq "TNMSDBA_PASSWORD=$${TNMSDBA_PASSWORD}" "$$CRED" || return 1
}

credentials_ok() {
  local got
  if [[ ! -f "$$CRED" ]]; then
    echo "credentials: $$CRED is missing" >&2
    return 1
  fi
  got=$$(stat -c '%a %U:%G' "$$CRED")
  if [[ "$$got" != "600 root:root" ]]; then
    echo "credentials: $$CRED mode is '$$got', expected 600 root:root" >&2
    return 1
  fi
  if ! cred_values_ok; then
    echo "credentials: $$CRED does not match SYS_PASSWORD, SYSTEM_PASSWORD, and TNMSDBA_PASSWORD. The file was not replaced." >&2
    return 1
  fi
}

oracle_installed() {
  local log
  grep -qx "$${TNMS_SID}:/opt/oracle/product/19c/dbhome_1:Y" /etc/oratab 2>/dev/null || return 1
  log=$$(oracle_log_path) || return 1
  grep -F -q 'Final status of the execution: Success' "$$log"
}

listener_port_open() {
  ss -ltn | grep -E -q '[:.]1521[[:space:]]'
}

listener_ok() {
  local bad=0
  if ! listener_port_open; then
    echo "oracle: listener port 1521 is not open" >&2
    bad=1
  fi
  if ! grep -qE '^LISNER[[:space:]]*=' /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora 2>/dev/null; then
    echo "oracle: listener.ora has no LISNER entry" >&2
    bad=1
  fi
  return "$$bad"
}

oracle_ok() {
  local log
  if ! oracle_installed; then
    log=$$(oracle_log_path || true)
    echo "oracle: oratab or the newest success log does not match$${log:+ ($$log)}" >&2
    return 1
  fi
  listener_ok
}

wizard_configure_ok() {
  local cfg=/nokia/tnms/trace/system/install/system_configure.log line bad=0
  [[ -f "$$cfg" ]] || return 1
  grep -q 'Product configuration ended' "$$cfg" || return 1
  while IFS= read -r line; do
    [[ "$$line" == *"Exiting with "* ]] || continue
    [[ "$$line" == *"Exiting with 0"* ]] || bad=1
  done < "$$cfg"
  [[ "$$bad" -eq 0 ]]
}

wizard_ok() {
  local en bad=0
  [[ -d /opt/nokia/tnms/server && -d /nokia/tnms ]] || { echo "wizard: product directories are missing" >&2; bad=1; }
  en=$$(systemctl is-enabled scs_daemon 2>/dev/null || true)
  if [[ "$$en" != enabled ]]; then
    echo "wizard: scs_daemon is '$$en', expected enabled" >&2
    bad=1
  fi
  if ! wizard_configure_ok; then
    echo "wizard: system_configure.log is missing, unfinished, or a configure script did not exit 0" >&2
    bad=1
  fi
  return "$$bad"
}

lsmem_ok() {
  local desc
  if [[ -e /usr/bin/lsmem.real ]]; then
    echo "lsmem: /usr/bin/lsmem.real still exists" >&2
    return 1
  fi
  desc=$$(file -b /usr/bin/lsmem 2>/dev/null || true)
  if [[ "$$desc" != *ELF* ]]; then
    echo "lsmem: /usr/bin/lsmem is not an ELF binary ('$$desc')" >&2
    return 1
  fi
}

match_file_ok() {
  local file=$$1
  awk '
    $$1 == "Match" && $$2 == "User" && $$3 == "tnms_sftp" { inb = 1; next }
    inb && $$1 == "Match" { inb = 0 }
    inb && $$1 == "ChrootDirectory" && $$2 == "/nokia" { ch = 1 }
    inb && $$1 == "ForceCommand" && $$2 == "internal-sftp" { fc = 1 }
    inb && $$1 == "PasswordAuthentication" && $$2 == "yes" { pa = 1 }
    inb && $$1 == "X11Forwarding" && $$2 == "no" { x = 1 }
    inb && $$1 == "AllowTcpForwarding" && $$2 == "no" { at = 1 }
    END { exit !(ch && fc && pa && x && at) }
  ' "$$file"
}

subsystem_ok() {
  local file=$$1
  grep -qE '^[[:space:]]*Subsystem[[:space:]]+sftp[[:space:]]+internal-sftp[[:space:]]*$$' "$$file" || return 1
  if grep -qE '^[[:space:]]*Subsystem[[:space:]]+sftp[[:space:]]+/usr/libexec/openssh/sftp-server[[:space:]]*$$' "$$file"; then
    return 1
  fi
}

sshd_user_ok() {
  local user=$$1
  local out
  out=$$(sshd -T -C "user=$${user},host=127.0.0.1,addr=127.0.0.1")
  if [[ "$$user" == tnms_sftp ]]; then
    grep -qx 'passwordauthentication yes' <<<"$$out" || return 1
    grep -qx 'forcecommand internal-sftp' <<<"$$out" || return 1
    grep -qx 'chrootdirectory /nokia' <<<"$$out" || return 1
  else
    grep -qx 'passwordauthentication no' <<<"$$out" || return 1
    grep -qx 'chrootdirectory none' <<<"$$out" || return 1
  fi
}

sftp_password_ok() {
  local state
  state=$$(passwd -S tnms_sftp 2>/dev/null | awk '{ print $$2 }')
  [[ "$$state" == PS ]]
}

sftp_ok() {
  local bad=0 shell state got
  shell=$$(getent passwd tnms_sftp | awk -F: '{ print $$7 }')
  if [[ "$$shell" != /sbin/nologin ]]; then
    echo "sftp: tnms_sftp shell is '$${shell:-missing}'" >&2
    bad=1
  fi
  state=$$(passwd -S tnms 2>/dev/null | awk '{ print $$2 }')
  if [[ "$$state" != LK ]]; then
    echo "sftp: tnms password state is '$${state:-missing}', expected LK" >&2
    bad=1
  fi
  if ! sftp_password_ok; then
    echo "sftp: tnms_sftp password is not set" >&2
    bad=1
  fi
  if ! grep -Fxq "TNMS_SFTP_PASSWORD=$${TNMS_SFTP_PASSWORD}" "$$CRED" 2>/dev/null; then
    echo "sftp: TNMS_SFTP_PASSWORD is missing or different in $$CRED" >&2
    bad=1
  fi
  got=$$(stat -c '%a %U:%G' /nokia 2>/dev/null || true)
  if [[ "$$got" != "755 root:root" ]]; then
    echo "sftp: /nokia mode is '$${got:-missing}'" >&2
    bad=1
  fi
  if ! subsystem_ok /etc/ssh/sshd_config || ! match_file_ok /etc/ssh/sshd_config; then
    echo "sftp: sshd_config is missing internal-sftp or the tnms_sftp Match block" >&2
    bad=1
  fi
  if ! sshd -t 2>/dev/null; then
    echo "sftp: sshd -t failed" >&2
    bad=1
  fi
  if ! sshd_user_ok tnms_sftp; then
    echo "sftp: sshd -T for tnms_sftp did not match" >&2
    bad=1
  fi
  if ! sshd_user_ok "$$TNMS_ADMIN_GROUP"; then
    echo "sftp: sshd -T for $$TNMS_ADMIN_GROUP did not match passwordauthentication no and chrootdirectory none" >&2
    bad=1
  fi
  return "$$bad"
}

sudo_ok() {
  local got
  visudo -cf /etc/sudoers.d/tnms_sudo >/dev/null || { echo "sudo: visudo rejected /etc/sudoers.d/tnms_sudo" >&2; return 1; }
  got=$$(stat -c '%a %U:%G' /etc/sudoers.d/tnms_sudo 2>/dev/null || true)
  if [[ "$$got" != "440 root:root" ]]; then
    echo "sudo: mode is '$${got:-missing}', expected 440 root:root" >&2
    return 1
  fi
  if ! sudo -l -U tnms 2>/dev/null | grep -F -q 'NOPASSWD: /usr/bin/systemctl * scs_daemon.service'; then
    echo "sudo: tnms sudoers entry is missing the scs_daemon commands" >&2
    return 1
  fi
}

service_headers_ok() {
  local headers
  headers=$$(curl -k -sI --max-time 5 https://127.0.0.1:8444 || true)
  grep -q 'HTTP/1.1 301' <<<"$$headers" || return 1
  grep -q '/tnms-webclient' <<<"$$headers" || return 1
  grep -q 'Server: openresty' <<<"$$headers" || return 1
}

service_ok() {
  local bad=0 ac label
  ac=$$(systemctl is-active scs_daemon 2>/dev/null || true)
  if [[ "$$ac" != active ]]; then
    echo "service: scs_daemon is '$$ac'" >&2
    bad=1
  fi
  label=$$(ls -Z /opt/nokia/tnms/system/services/bin/scs_daemon 2>/dev/null || true)
  if [[ "$$label" != *bin_t* ]]; then
    echo "service: scs_daemon context is '$${label:-missing}'" >&2
    bad=1
  fi
  if ! ss -ltn | grep -E -q '[:.]8444[[:space:]]'; then
    echo "service: port 8444 is not listening" >&2
    bad=1
  fi
  if ! service_headers_ok; then
    echo "service: https://127.0.0.1:8444 did not return 301 to /tnms-webclient" >&2
    bad=1
  fi
  return "$$bad"
}

find_src() {
  local name=$$1 dir
  dir=$$(dirname "$$THIS_MAKEFILE")
  if [[ -f "/tmp/$$name" ]]; then
    printf '%s\n' "/tmp/$$name"
  elif [[ -f "$$dir/$$name" ]]; then
    printf '%s\n' "$$dir/$$name"
  elif [[ -f "$$dir/resources/$$name" ]]; then
    printf '%s\n' "$$dir/resources/$$name"
  elif [[ -f "$$ROOT/$$name" ]]; then
    printf '%s\n' "$$ROOT/$$name"
  elif [[ -f "$$MEDIA/$$name" ]]; then
    printf '%s\n' "$$MEDIA/$$name"
  else
    return 1
  fi
}

copy_in() {
  local name=$$1 dest=$$2 mode=$$3 src
  src=$$(find_src "$$name") || { echo "stage: missing $$name" >&2; exit 1; }
  echo "stage: $$name -> $$dest"
  if [[ ! "$$src" -ef "$$dest" ]]; then
    install -o root -g root -m "$$mode" "$$src" "$$dest"
  fi
  chgrp "$$TNMS_ADMIN_GROUP" "$$dest"
  chmod "$$mode" "$$dest"
}

do_layout() {
  local inst_mode=750 name
  if oracle_present; then
    inst_mode=751
  fi
  install -d -o root -g root -m 755 /opt/oracle /opt/nokia /opt/tnms-data
  install -d -o root -g root -m 755 /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3
  install -d -o root -g "$$TNMS_ADMIN_GROUP" -m "$$inst_mode" /opt/tnms-install
  install -d -o root -g "$$TNMS_ADMIN_GROUP" -m 750 /opt/tnms-install/resources
  copy_in "$$WIZARD_NAME" "$$WIZARD" 740
  copy_in "$$PROPS_NAME" "$$PROPS" 640
  for name in "$${ZIPS[@]}"; do
    copy_in "$$name" "$$MEDIA/$$name" 640
  done
  restorecon -RF /opt/oracle /opt/nokia /opt/tnms-data /opt/oradata /opt/tnms-install
}

install_makefile() {
  local dest=$$ROOT/Makefile
  if [[ ! -f "$$THIS_MAKEFILE" ]]; then
    echo "stage: THIS_MAKEFILE is not a file" >&2
    exit 1
  fi
  if [[ ! "$$THIS_MAKEFILE" -ef "$$dest" ]]; then
    echo "stage: installing Makefile to $$dest"
    install -o root -g root -m 640 "$$THIS_MAKEFILE" "$$dest"
  fi
  chgrp "$$TNMS_ADMIN_GROUP" "$$dest"
  chmod 640 "$$dest"
}

remove_tmp_copies() {
  local name dest
  for name in "$$WIZARD_NAME" "$$PROPS_NAME" Makefile "$${ZIPS[@]}"; do
    [[ -f "/tmp/$$name" ]] || continue
    case "$$name" in
      Makefile) dest=$$ROOT/Makefile ;;
      *.zip) dest=$$MEDIA/$$name ;;
      *) dest=$$ROOT/$$name ;;
    esac
    if [[ -f "$$dest" && ! "/tmp/$$name" -ef "$$dest" ]]; then
      echo "stage: removing /tmp/$$name"
      rm -f "/tmp/$$name"
    fi
  done
}

do_host() {
  local ip domain fqdn
  ip=$$(resolve_ip)
  domain=$$(resolve_domain)
  [[ -n "$$domain" ]] || { echo "host: /etc/resolv.conf has no search domain" >&2; exit 1; }
  fqdn="$${TNMS_HOSTNAME}.$${domain}"
  echo "host: hostnamectl set-hostname $$TNMS_HOSTNAME"
  hostnamectl set-hostname "$$TNMS_HOSTNAME"
  if grep -q '^preserve_hostname:' /etc/cloud/cloud.cfg; then
    sed -i 's/^preserve_hostname:.*/preserve_hostname: true/' /etc/cloud/cloud.cfg
  else
    printf '%s\n' 'preserve_hostname: true' >> /etc/cloud/cloud.cfg
  fi
  echo "host: localectl set-locale LANG=en_US.UTF-8"
  localectl set-locale LANG=en_US.UTF-8
  if awk -v short="$$TNMS_HOSTNAME" '$$2 == short || $$3 == short { found = 1 } END { exit !found }' /etc/hosts; then
    if ! awk -v ip="$$ip" -v fqdn="$$fqdn" -v short="$$TNMS_HOSTNAME" '
      $$1 == ip && $$2 == fqdn && $$3 == short { found = 1 }
      END { exit !found }
    ' /etc/hosts; then
      echo "host: /etc/hosts already names $$TNMS_HOSTNAME with a different address or order. The line was not changed." >&2
      exit 1
    fi
  else
    printf '%s  %s %s\n' "$$ip" "$$fqdn" "$$TNMS_HOSTNAME" >> /etc/hosts
  fi
}

do_packages() {
  echo "packages: dnf install epel-release"
  dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  echo "packages: dnf install the TNMS package set"
  dnf -y install attr bc elfutils-libelf-devel fontconfig-devel gcc gcc-c++ jemalloc ksh libaio libaio-devel libnsl libXtst libzip make psmisc sysstat unzip perl binutils glibc-devel
}

do_kernel() {
  echo "kernel: writing $$SYSCTL_FILE"
  kernel_file_text > "$$SYSCTL_FILE"
  sysctl --system
  systemctl stop firewalld
  systemctl disable firewalld
}

do_unpack() {
  local name zip
  for name in "$${ZIPS[@]}"; do
    zip="$$MEDIA/$$name"
    echo "unpack: unzip -t $$zip"
    unzip -t "$$zip" | grep -q 'No errors detected'
  done
  mkdir -p /opt/oracle/oramedia /opt/tnms-install/prereq /opt/tnms-install/installer
  echo "unpack: unzip Oracle media"
  unzip -o "$$MEDIA/LINUX.X64_193000_db_home_and_patches.zip" -d /opt/oracle/oramedia
  echo "unpack: unzip prerequisites"
  unzip -o "$$MEDIA/TNMS_LUX_R9.1.0.593.0_1904_Prerequisites.zip" -d /opt/tnms-install/prereq
  echo "unpack: unzip TNMS"
  unzip -o "$$MEDIA/TNMS_LUX_R9.1.0.593.0_1904.zip" -d /opt/tnms-install/installer
  find /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle -type d -exec chmod 755 {} \;
  find /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle -type f -exec chmod 644 {} \;
  find /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle -name '*.sh' -exec chmod 755 {} \;
  chmod 744 /opt/tnms-install/installer/TNMS_Installer/TNMS.bin
}

write_credentials() {
  local tmp
  tmp=$$(mktemp /root/tnms-install.XXXXXX)
  cat > "$$tmp" << EOF
SYS_PASSWORD=$${SYS_PASSWORD}
SYSTEM_PASSWORD=$${SYSTEM_PASSWORD}
TNMSDBA_PASSWORD=$${TNMSDBA_PASSWORD}
EOF
  install -m 600 -o root -g root "$$tmp" "$$CRED"
  rm -f "$$tmp"
}

do_oracle_install() {
  local rsp=/opt/tnms-install/prereq/TNMS_Prerequisites/Oracle/installation/TNMS.rsp tries=0
  chmod o+x /opt/tnms-install
  if id oracle >/dev/null 2>&1; then
    sudo -u oracle test -r "$$rsp"
  else
    echo "oracle: user oracle does not exist yet. installation.sh creates it. /opt/tnms-install is now executable by other so that user can read TNMS.rsp."
  fi
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY || true
  set -a
  . "$$CRED"
  set +a
  echo "oracle: installation.sh"
  (
    cd /opt/tnms-install/prereq/TNMS_Prerequisites/Oracle/installation
    ./installation.sh -silent_mode=Y -configuration_type=SP -oradata=/oradata -orainstaller=/opt/oracle/oramedia -database_name="$$TNMS_SID" -listener_port=1521 -syspwd="$$SYS_PASSWORD" -systempwd="$$SYSTEM_PASSWORD"
  )
  while [[ "$$tries" -lt 12 ]]; do
    if listener_port_open; then
      break
    fi
    tries=$$((tries + 1))
    sleep 5
  done
}

edit_sshd_file() {
  local src=$$1 dest=$$2
  awk '
    /^[[:space:]]*Subsystem[[:space:]]+sftp[[:space:]]+\/usr\/libexec\/openssh\/sftp-server[[:space:]]*$$/ {
      printf "%c%s\n", 35, $$0
      next
    }
    { print }
  ' "$$src" > "$$dest"
  if ! grep -qE '^[[:space:]]*Subsystem[[:space:]]+sftp[[:space:]]+internal-sftp[[:space:]]*$$' "$$dest"; then
    printf '%s\n' 'Subsystem sftp internal-sftp' >> "$$dest"
  fi
  if match_file_ok "$$dest"; then
    return 0
  fi
  if grep -qE '^[[:space:]]*Match[[:space:]]+User[[:space:]]+tnms_sftp([[:space:]]|$$)' "$$dest"; then
    echo "sftp: Match User tnms_sftp is present but incomplete. sshd_config was not changed." >&2
    return 1
  fi
  printf '\n%s\n' 'Match User tnms_sftp' >> "$$dest"
  printf '%s\n' '    ChrootDirectory /nokia' '    ForceCommand internal-sftp' '    X11Forwarding no' '    AllowTcpForwarding no' '    PasswordAuthentication yes' >> "$$dest"
}

do_sftp_config() {
  local tmp before after
  tmp=$$(mktemp /root/tnms-sshd.XXXXXX)
  before=$$(sha256sum /etc/ssh/sshd_config)
  if ! edit_sshd_file /etc/ssh/sshd_config "$$tmp"; then
    rm -f "$$tmp"
    exit 1
  fi
  if ! sshd -t -f "$$tmp"; then
    echo "sftp: sshd -t rejected the new config. sshd_config was not changed." >&2
    rm -f "$$tmp"
    exit 1
  fi
  cat "$$tmp" > /etc/ssh/sshd_config
  rm -f "$$tmp"
  sshd -t
  after=$$(sha256sum /etc/ssh/sshd_config)
  if [[ "$$before" != "$$after" ]]; then
    echo "sftp: restarting sshd"
    systemctl restart sshd
  else
    echo "sftp: sshd_config unchanged"
  fi
  systemctl is-active --quiet sshd
}

wait_for_service() {
  local i headers
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36; do
    if ss -ltn | grep -E -q '[:.]8444[[:space:]]' && service_headers_ok; then
      return 0
    fi
    if [[ $$((i % 6)) -eq 0 ]]; then
      echo "service: waiting for port 8444 ($${i}0s)"
    fi
    sleep 5
  done
  echo "service: port 8444 did not answer within 3 minutes" >&2
  return 1
}

stage_main() {
  require_root
  preflight_ok || exit 1
  if layout_ok; then
    echo "stage: layout already matches"
  else
    do_layout
    layout_ok || exit 1
  fi
  install_makefile
  remove_tmp_copies
  [[ -f "$$ROOT/Makefile" ]] || exit 1
  stamp stage
  echo "stage: done"
}

host_main() {
  require_root
  preflight_ok || exit 1
  if host_ok; then
    echo "host: already matches"
  else
    do_host
    host_ok || exit 1
  fi
  stamp host
  echo "host: done"
}

packages_main() {
  require_root
  preflight_ok || exit 1
  if packages_ok; then
    echo "packages: already installed"
  else
    do_packages
    packages_ok || exit 1
  fi
  stamp packages
  echo "packages: done"
}

kernel_main() {
  require_root
  preflight_ok || exit 1
  if kernel_ok; then
    echo "kernel: already matches"
  else
    do_kernel
    kernel_ok || exit 1
  fi
  stamp kernel
  echo "kernel: done"
}

disk_main() {
  require_root
  preflight_ok || exit 1
  df -h / /tmp /home /opt
  disk_ok || exit 1
  echo "disk: ok"
}

unpack_main() {
  require_root
  preflight_ok || exit 1
  if unpack_ok; then
    echo "unpack: media already unpacked"
  else
    do_unpack
    unpack_ok || exit 1
  fi
  stamp unpack
  echo "unpack: done"
}

credentials_main() {
  require_root
  preflight_ok || exit 1
  if [[ -f "$$CRED" ]]; then
    if cred_values_ok; then
      chmod 600 "$$CRED"
      chown root:root "$$CRED"
    else
      echo "credentials: $$CRED exists and does not match the password variables. It was not replaced." >&2
      exit 1
    fi
  else
    write_credentials
  fi
  credentials_ok || exit 1
  stamp credentials
  echo "credentials: done"
}

oracle_main() {
  require_root
  preflight_ok || exit 1
  if oracle_installed; then
    echo "oracle: already installed. installation.sh was not started."
  else
    if oracle_present; then
      echo "oracle: $$TNMS_SID is already in /etc/oratab but the success log does not match. installation.sh was not started." >&2
      exit 1
    fi
    do_oracle_install
  fi
  oracle_ok || exit 1
  stamp oracle
  echo "oracle: done"
}

wizard_main() {
  require_root
  preflight_ok || exit 1
  if [[ -d /opt/nokia/tnms/server ]]; then
    echo "wizard: /opt/nokia/tnms/server exists. install-tnms-wizard.sh was not started."
  else
    echo "wizard: install-tnms-wizard.sh"
    if [[ -n "$${TNMS_IP:-}" ]]; then
      /opt/tnms-install/install-tnms-wizard.sh --ip "$$TNMS_IP"
    else
      /opt/tnms-install/install-tnms-wizard.sh
    fi
    bash -c 'set +u; . /etc/profile.d/ossnms.sh'
  fi
  wizard_ok || exit 1
  stamp wizard
  echo "wizard: done"
}

lsmem_main() {
  require_root
  preflight_ok || exit 1
  if [[ -e /usr/bin/lsmem.real ]]; then
    echo "lsmem: restoring /usr/bin/lsmem"
    mv -f /usr/bin/lsmem.real /usr/bin/lsmem
  fi
  lsmem_ok || exit 1
  stamp lsmem
  echo "lsmem: done"
}

sftp_main() {
  local state
  require_root
  preflight_ok || exit 1
  if sftp_ok; then
    echo "sftp: already matches"
  else
    getent passwd tnms_sftp >/dev/null || { echo "sftp: user tnms_sftp does not exist" >&2; exit 1; }
    [[ -f "$$CRED" ]] || { echo "sftp: $$CRED is missing" >&2; exit 1; }
    state=$$(passwd -S tnms_sftp | awk '{ print $$2 }')
    if [[ "$$state" != PS ]]; then
      echo "sftp: setting tnms_sftp password"
      printf '%s\n' "$$TNMS_SFTP_PASSWORD" | passwd --stdin tnms_sftp
    fi
    if grep -q '^TNMS_SFTP_PASSWORD=' "$$CRED"; then
      grep -Fxq "TNMS_SFTP_PASSWORD=$${TNMS_SFTP_PASSWORD}" "$$CRED" || {
        echo "sftp: TNMS_SFTP_PASSWORD in $$CRED differs. The file was not changed." >&2
        exit 1
      }
    else
      printf '%s\n' "TNMS_SFTP_PASSWORD=$${TNMS_SFTP_PASSWORD}" >> "$$CRED"
      chmod 600 "$$CRED"
    fi
    usermod -s /sbin/nologin tnms_sftp
    chown root:root /nokia
    chmod 755 /nokia
    do_sftp_config
    sftp_ok || exit 1
  fi
  stamp sftp
  echo "sftp: done"
}

sudo_main() {
  local src=/opt/nokia/tnms/system/install/resources/system/tnms_sudo
  require_root
  preflight_ok || exit 1
  if sudo_ok; then
    echo "sudo: already matches"
  else
    [[ -f "$$src" ]] || { echo "sudo: missing $$src" >&2; exit 1; }
    cp -p "$$src" /etc/sudoers.d/tnms_sudo
    chown root:root /etc/sudoers.d/tnms_sudo
    chmod 440 /etc/sudoers.d/tnms_sudo
    sudo_ok || exit 1
  fi
  stamp sudo
  echo "sudo: done"
}

service_main() {
  local ac
  require_root
  preflight_ok || exit 1
  echo "service: restorecon -RF /opt/nokia"
  restorecon -RF /opt/nokia
  ac=$$(systemctl is-active scs_daemon 2>/dev/null || true)
  if [[ "$$ac" != active ]]; then
    systemctl reset-failed scs_daemon.service || true
    echo "service: systemctl start scs_daemon"
    systemctl start scs_daemon
  else
    echo "service: scs_daemon is already active"
  fi
  wait_for_service
  service_ok || exit 1
  stamp service
  echo "service: done"
}

report() {
  local name=$$1
  shift
  if "$$@"; then
    printf '%-16s ok\n' "$$name"
    return 0
  fi
  printf '%-16s MISSING\n' "$$name" >&2
  return 1
}

status_main() {
  local fail=0 name
  require_root
  scan_collect
  scan_report
  if prepare_ok >/dev/null 2>&1; then
    echo "prepare: nothing to do"
  fi
  report prepare prepare_ok || fail=1
  report preflight preflight_ok || fail=1
  report stage layout_ok || fail=1
  if [[ -f "$$ROOT/Makefile" ]]; then
    printf '%-16s ok\n' makefile
  else
    printf '%-16s not-installed\n' makefile
  fi
  report host host_ok || fail=1
  report packages packages_ok || fail=1
  report kernel kernel_ok || fail=1
  report disk disk_ok || fail=1
  report unpack unpack_ok || fail=1
  report credentials credentials_ok || fail=1
  report oracle oracle_ok || fail=1
  report wizard wizard_ok || fail=1
  report lsmem lsmem_ok || fail=1
  report sftp sftp_ok || fail=1
  report sudo sudo_ok || fail=1
  report service service_ok || fail=1
  for name in prepare stage host packages kernel unpack credentials oracle wizard lsmem sftp sudo service; do
    if [[ -f "$$STAMP/$$name" ]]; then
      printf 'stamp %-12s present\n' "$$name"
    else
      printf 'stamp %-12s absent\n' "$$name"
    fi
  done
  if [[ "$$fail" -ne 0 ]]; then
    exit 1
  fi
  echo "status: install conditions match"
}

check_one() {
  local name=$$1
  shift
  if "$$@"; then
    printf 'ok   %s\n' "$$name"
    return 0
  fi
  printf 'FAIL %s\n' "$$name" >&2
  return 1
}

check_main() {
  local fail=0 domain ip fqdn log
  require_root
  domain=$$(resolve_domain)
  ip=$$(resolve_ip) || exit 1
  fqdn="$${TNMS_HOSTNAME}.$${domain}"
  check_one "hostname --fqdn is $$fqdn" bash -c "[[ \"\$$(hostname --fqdn)\" == \"$$fqdn\" ]]" || fail=1
  check_one "oratab $$TNMS_SID" grep -qx "$${TNMS_SID}:/opt/oracle/product/19c/dbhome_1:Y" /etc/oratab || fail=1
  check_one "listener 1521" bash -c "ss -ltn | grep -E -q '[:.]1521[[:space:]]'" || fail=1
  log=$$(oracle_log_path || true)
  check_one "oracle success log" bash -c "[[ -n \"$$log\" ]] && grep -F -q 'Final status of the execution: Success' \"$$log\"" || fail=1
  check_one "lsmem is the ELF binary" lsmem_ok || fail=1
  echo "check: lsmem --summary"
  lsmem --summary || fail=1
  check_one "source ossnms.sh" bash -c 'set +u; . /etc/profile.d/ossnms.sh' || fail=1
  check_one "tnms password locked" bash -c "[[ \"\$$(passwd -S tnms | awk '{ print \$$2 }')\" == LK ]]" || fail=1
  check_one "tnms_sftp shell nologin" bash -c "[[ \"\$$(getent passwd tnms_sftp | awk -F: '{ print \$$7 }')\" == /sbin/nologin ]]" || fail=1
  check_one "tnms sudo" sudo_ok || fail=1
  check_one "scs_daemon active" bash -c "[[ \"\$$(systemctl is-active scs_daemon)\" == active ]]" || fail=1
  check_one "port 8444" bash -c "ss -ltn | grep -E -q '[:.]8444[[:space:]]'" || fail=1
  check_one "web client 301" service_headers_ok || fail=1
  if [[ "$$fail" -ne 0 ]]; then
    exit 1
  fi
  echo "check: ok"
}

self_test() {
  local dir a b
  fixture_self_test
  dir=$$(mktemp -d)
  printf '%s\n' 'Port 22' 'PasswordAuthentication no' 'Subsystem sftp /usr/libexec/openssh/sftp-server' > "$$dir/sshd"
  edit_sshd_file "$$dir/sshd" "$$dir/out" 
  subsystem_ok "$$dir/out"
  match_file_ok "$$dir/out"
  if grep -qE '^[[:space:]]*Subsystem[[:space:]]+sftp[[:space:]]+/usr/libexec/openssh/sftp-server[[:space:]]*$$' "$$dir/out"; then
    echo "self-test: external sftp line still active" >&2
    exit 1
  fi
  cp "$$dir/out" "$$dir/once"
  edit_sshd_file "$$dir/out" "$$dir/twice"
  cmp -s "$$dir/once" "$$dir/twice"
  printf '%s\n' 'Match User tnms_sftp' '    ChrootDirectory /tmp' > "$$dir/bad"
  if edit_sshd_file "$$dir/bad" "$$dir/badout"; then
    echo "self-test: incomplete Match was accepted" >&2
    exit 1
  fi
  rm -rf "$$dir"
  echo "self-test: ok"
}

LS_NAME=()
LS_TYPE=()
LS_SIZE=()
LS_FS=()
LS_MNT=()
LS_PK=()
OS_DISK=
ANSWERS=/root/tnms-install.answers
TARGET_ROOT=$$((8 * 1024 * 1024 * 1024))
TARGET_TMP=$$((16 * 1024 * 1024 * 1024))
HOME_HUGE=$$((100 * 1024 * 1024 * 1024))
HOME_SMALL=$$((2 * 1024 * 1024 * 1024))
MIN_DATA=$$((100 * 1000 * 1000 * 1000))
GROW_STATE=unknown
GROW_NEED=0
ROOT_B=
TMP_B=
HOME_LV_B=
VG_FREE=
OPT_SRC=
NOKIA_SRC=
ORADATA_SRC=
HOME_SRC=
HOME_B=
TMP_OPTS=
SWAP_SHOW=
HOST_NOW=
PRESERVE=
GLOBAL_N=0
GLOBAL_IPS=
ROUTE_IP=
SSH_USER=
SSH_GROUP=
REL=
SELINUX=
NCPU=
RAM_LINE=
ORACLE_NOTE=
TNMS_NOTE=
ANS_DISK=
ANS_GROW=
ANS_HOST=
ANS_GROUP=
ANS_IP=
ANS_CONFIRM=

ls_field() {
  local key=$$1 line=$$2
  local re='(^|[[:space:]])'"$$key"'="([^"]*)"'
  if [[ $$line =~ $$re ]]; then
    printf '%s' "$${BASH_REMATCH[2]}"
  fi
}

lsblk_load() {
  local text=$$1 line
  LS_NAME=()
  LS_TYPE=()
  LS_SIZE=()
  LS_FS=()
  LS_MNT=()
  LS_PK=()
  while IFS= read -r line; do
    [[ -z $$line ]] && continue
    LS_NAME+=("$$(ls_field NAME "$$line")")
    LS_TYPE+=("$$(ls_field TYPE "$$line")")
    LS_SIZE+=("$$(ls_field SIZE "$$line")")
    LS_FS+=("$$(ls_field FSTYPE "$$line")")
    LS_MNT+=("$$(ls_field MOUNTPOINT "$$line")")
    LS_PK+=("$$(ls_field PKNAME "$$line")")
  done <<<"$$text"
}

ls_index() {
  local want=$$1 i
  for i in "$${!LS_NAME[@]}"; do
    if [[ $${LS_NAME[$$i]} == "$$want" ]]; then
      printf '%s' "$$i"
      return 0
    fi
  done
  return 1
}

ls_under() {
  local name=$$1 ancestor=$$2 pk="" i="" guard=0
  while [[ $$guard -lt 10 ]]; do
    if ! i=$$(ls_index "$$name"); then
      return 1
    fi
    pk=$${LS_PK[$$i]}
    if [[ -z $$pk || $$pk == "$$name" ]]; then
      return 1
    fi
    if [[ $$pk == "$$ancestor" ]]; then
      return 0
    fi
    name=$$pk
    guard=$$((guard + 1))
  done
  return 1
}

ls_disk_of_mount() {
  local mnt=$$1 i="" name="" pk="" guard=0
  for i in "$${!LS_NAME[@]}"; do
    if [[ $${LS_MNT[$$i]} == "$$mnt" ]]; then
      name=$${LS_NAME[$$i]}
      break
    fi
  done
  [[ -n $$name ]] || return 1
  while [[ $$guard -lt 10 ]]; do
    if ! i=$$(ls_index "$$name"); then
      return 1
    fi
    if [[ $${LS_TYPE[$$i]} == disk ]]; then
      printf '%s' "$$name"
      return 0
    fi
    pk=$${LS_PK[$$i]}
    [[ -n $$pk && $$pk != "$$name" ]] || return 1
    name=$$pk
    guard=$$((guard + 1))
  done
  return 1
}

strip_dev() {
  local name=$$1
  if [[ $$name == /dev/* ]]; then
    printf '%s' "$${name:5}"
  else
    printf '%s' "$$name"
  fi
}

data_disk_block_reason() {
  local name="" i="" size="" j=""
  name=$$(strip_dev "$$1")
  if ! i=$$(ls_index "$$name"); then
    echo "is not in the scan"
    return 0
  fi
  if [[ $${LS_TYPE[$$i]} != disk ]]; then
    echo "is not a whole disk"
    return 0
  fi
  if [[ -n $${OS_DISK:-} && $$name == "$$OS_DISK" ]]; then
    echo "is the OS disk"
    return 0
  fi
  if [[ -n $${LS_FS[$$i]} ]]; then
    echo "has a filesystem"
    return 0
  fi
  if [[ -n $${LS_MNT[$$i]} ]]; then
    echo "has a mount"
    return 0
  fi
  for j in "$${!LS_NAME[@]}"; do
    if ls_under "$${LS_NAME[$$j]}" "$$name"; then
      if [[ -n $${LS_MNT[$$j]} ]]; then
        echo "has a child mount ($${LS_NAME[$$j]})"
        return 0
      fi
      if [[ -n $${LS_FS[$$j]} ]]; then
        echo "has a child filesystem ($${LS_NAME[$$j]})"
        return 0
      fi
      echo "has a partition ($${LS_NAME[$$j]})"
      return 0
    fi
  done
  size=$${LS_SIZE[$$i]}
  if [[ ! $$size =~ ^[0-9]+$$ ]]; then
    echo "has no size"
    return 0
  fi
  if [[ $$size -lt $$MIN_DATA ]]; then
    echo "is smaller than 100 GB"
    return 0
  fi
  return 0
}

disk_is_candidate() {
  local reason
  reason=$$(data_disk_block_reason "$$1")
  [[ -z $$reason ]]
}

list_candidates() {
  local i
  for i in "$${!LS_NAME[@]}"; do
    if [[ $${LS_TYPE[$$i]} == disk ]] && disk_is_candidate "$${LS_NAME[$$i]}"; then
      printf '%s\n' "$${LS_NAME[$$i]}"
    fi
  done
}

disk_default() {
  local c n=0 one=""
  while IFS= read -r c; do
    [[ -z $$c ]] && continue
    n=$$((n + 1))
    one=$$c
  done < <(list_candidates)
  if [[ $$n -eq 1 ]]; then
    printf '%s' "$$one"
  fi
}

use_fixture() {
  local text=$$1
  lsblk_load "$$text"
  OS_DISK=$$(ls_disk_of_mount / || true)
}

lv_bytes() {
  local raw
  raw=$$(lvs --noheadings --nosuffix --units b -o lv_size "$$1" 2>/dev/null | awk '{ print $$1 }') || return 1
  [[ $$raw =~ ^[0-9]+$$ ]] || return 1
  printf '%s\n' "$$raw"
}

vg_free_bytes() {
  local raw
  raw=$$(vgs --noheadings --nosuffix --units b -o vg_free rootvg 2>/dev/null | awk '{ print $$1 }') || return 1
  [[ $$raw =~ ^[0-9]+$$ ]] || return 1
  printf '%s\n' "$$raw"
}

show_bytes() {
  local b=$${1:-}
  if [[ ! $$b =~ ^[0-9]+$$ ]]; then
    printf 'unknown'
    return 0
  fi
  awk -v b="$$b" 'BEGIN { printf "%s bytes (%.2f GiB)", b, b/1024/1024/1024 }'
}

home_is_huge() {
  local b=$$1
  [[ $$b =~ ^[0-9]+$$ ]] || return 1
  [[ $$b -ge $$HOME_HUGE ]]
}

swap_is_ready() {
  swapon --show=NAME,SIZE --bytes --noheadings 2>/dev/null | awk -v n="/opt/swapfile" -v s="$$SWAP_BYTES" '
    $$1 == n && $$2 == s { found = 1 }
    END { exit !found }
  '
}

context_has() {
  local path=$$1 type=$$2 ctx
  ctx=$$(stat -c %C "$$path" 2>/dev/null || true)
  [[ $$ctx == *"$$type"* ]]
}

labels_ok() {
  context_has /opt usr_t || return 1
  context_has /opt/tnms-data usr_t || return 1
  context_has /opt/oradata usr_t || return 1
  context_has /opt/swapfile swapfile_t || return 1
}

fstab_has() {
  local kind=$$1 uuid=$$2 file=$${3:-/etc/fstab}
  [[ -f $$file ]] || return 1
  awk -v kind="$$kind" -v uuid="$$uuid" -v h="$$(printf '\043')" '
    $$1 ~ ("^" h) { next }
    kind == "opt" && $$2 == "/opt" && (tolower($$1) == tolower("UUID=" uuid) || $$1 == "/dev/datavg/optlv" || $$1 == "/dev/mapper/datavg-optlv") { found = 1 }
    kind == "nokia" && $$1 == "/opt/tnms-data" && $$2 == "/nokia" { found = 1 }
    kind == "oradata" && $$1 == "/opt/oradata" && $$2 == "/oradata" { found = 1 }
    kind == "swap" && $$1 == "/opt/swapfile" { found = 1 }
    END { exit !found }
  ' "$$file"
}

fstab_target_exists() {
  local target=$$1 file=$${2:-/etc/fstab}
  [[ -f $$file ]] || return 1
  awk -v t="$$target" -v h="$$(printf '\043')" '
    $$1 ~ ("^" h) { next }
    $$2 == t { found = 1 }
    END { exit !found }
  ' "$$file"
}

fstab_source_exists() {
  local source=$$1 file=$${2:-/etc/fstab}
  [[ -f $$file ]] || return 1
  awk -v s="$$source" -v h="$$(printf '\043')" '
    $$1 ~ ("^" h) { next }
    $$1 == s { found = 1 }
    END { exit !found }
  ' "$$file"
}

valid_hostname() {
  [[ $$1 =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$$ ]]
}

valid_group_name() {
  [[ $$1 =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$$ ]]
}

valid_ipv4() {
  local ip=$$1 o
  [[ $$ip =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$$ ]] || return 1
  for o in "$${BASH_REMATCH[@]:1:4}"; do
    [[ $$o -le 255 ]] || return 1
    if [[ $$o == 0* && $$o != 0 ]]; then
      return 1
    fi
  done
  return 0
}

answers_lines() {
  local disk=$${1:-} grow=$${2:-} host=$${3:-} group=$${4:-} ip=$${5:-}
  if [[ -n $$disk ]]; then
    disk=$$(strip_dev "$$disk")
    printf 'TNMS_DATA_DISK=/dev/%s\n' "$$disk"
  fi
  if [[ $$grow == yes ]]; then
    printf 'TNMS_GROW=yes\n'
  fi
  printf 'TNMS_HOSTNAME=%s\n' "$$host"
  printf 'TNMS_ADMIN_GROUP=%s\n' "$$group"
  if [[ -n $$ip ]]; then
    printf 'TNMS_IP=%s\n' "$$ip"
  fi
  printf 'CONFIRM=yes\n'
}

load_answers() {
  local file=$$1 line key val
  ANS_DISK=
  ANS_GROW=
  ANS_HOST=
  ANS_GROUP=
  ANS_IP=
  ANS_CONFIRM=
  [[ -f $$file ]] || return 1
  while IFS= read -r line || [[ -n $$line ]]; do
    [[ -z $$line ]] && continue
    if [[ ! $$line =~ ^([A-Z0-9_]+)=(.*)$$ ]]; then
      continue
    fi
    key=$${BASH_REMATCH[1]}
    val=$${BASH_REMATCH[2]}
    case $$key in
      TNMS_DATA_DISK)
        [[ $$val =~ ^/dev/[A-Za-z0-9._-]+$$ ]] && ANS_DISK=$$val
        ;;
      TNMS_GROW)
        [[ $$val == yes ]] && ANS_GROW=yes
        ;;
      TNMS_HOSTNAME)
        valid_hostname "$$val" && ANS_HOST=$$val
        ;;
      TNMS_ADMIN_GROUP)
        valid_group_name "$$val" && ANS_GROUP=$$val
        ;;
      TNMS_IP)
        valid_ipv4 "$$val" && ANS_IP=$$val
        ;;
      CONFIRM)
        [[ $$val == yes ]] && ANS_CONFIRM=yes
        ;;
    esac
  done < "$$file"
}

commit_answers() {
  local reply=$$1 dest=$$2
  shift 2
  if [[ $$reply != yes ]]; then
    echo "scan: answers were not written."
    return 0
  fi
  local dir tmp
  dir=$$(dirname "$$dest")
  tmp=$$(mktemp "$$dir/tnms-install.answers.XXXXXX")
  answers_lines "$$@" > "$$tmp"
  chmod 600 "$$tmp"
  mv -f "$$tmp" "$$dest"
  echo "scan: wrote $$dest"
}

ssh_account() {
  local d owner n=0 only=""
  if [[ -n $${SUDO_USER:-} && $${SUDO_USER} != root ]]; then
    printf '%s\n' "$$SUDO_USER"
    return 0
  fi
  for d in /home/*; do
    [[ -d $$d ]] || continue
    owner=$$(stat -c %U "$$d" 2>/dev/null || true)
    [[ -z $$owner || $$owner == root ]] && continue
    n=$$((n + 1))
    only=$$owner
  done
  if [[ $$n -eq 1 ]]; then
    printf '%s\n' "$$only"
    return 0
  fi
  return 1
}

opt_has_names() {
  [[ -d /opt ]] || return 1
  find /opt -mindepth 1 -maxdepth 1 -print -quit | grep -q .
}

mountpoint_busy() {
  local path=$$1 src
  [[ -d $$path ]] || return 1
  src=$$(findmnt -n -o SOURCE "$$path" 2>/dev/null || true)
  if [[ -n $$src ]]; then
    return 1
  fi
  find "$$path" -mindepth 1 -maxdepth 1 -print -quit | grep -q .
}

prepare_die() {
  echo "prepare: $$*" >&2
  exit 1
}

scan_die() {
  echo "scan: $$*" >&2
  exit 1
}

home_blocks() {
  if [[ $${HOME_SRC:-} == *datavg* ]]; then
    return 0
  fi
  if [[ $${HOME_B:-} =~ ^[0-9]+$$ ]] && home_is_huge "$$HOME_B"; then
    return 0
  fi
  return 1
}

prepare_ok() {
  local bad=0 src bytes root_b tmp_b home_b opts uuid
  src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  if [[ $$src != /dev/mapper/datavg-optlv ]]; then
    echo "prepare: /opt source is '$${src:-empty}'" >&2
    bad=1
  fi
  src=$$(findmnt -n -o SOURCE /nokia 2>/dev/null || true)
  if [[ $$src != *"[/tnms-data]"* ]]; then
    echo "prepare: /nokia source is '$${src:-empty}'" >&2
    bad=1
  fi
  src=$$(findmnt -n -o SOURCE /oradata 2>/dev/null || true)
  if [[ $$src != *"[/oradata]"* ]]; then
    echo "prepare: /oradata source is '$${src:-empty}'" >&2
    bad=1
  fi
  if ! swap_is_ready; then
    echo "prepare: /opt/swapfile is not an $${SWAP_BYTES}-byte swap" >&2
    bad=1
  fi
  root_b=$$(lv_bytes /dev/rootvg/rootlv || true)
  tmp_b=$$(lv_bytes /dev/rootvg/tmplv || true)
  if [[ ! $$root_b =~ ^[0-9]+$$ || $$root_b -lt $$TARGET_ROOT ]]; then
    echo "prepare: rootlv is '$${root_b:-unknown}', expected at least 8 GiB" >&2
    bad=1
  fi
  if [[ ! $$tmp_b =~ ^[0-9]+$$ || $$tmp_b -lt $$TARGET_TMP ]]; then
    echo "prepare: tmplv is '$${tmp_b:-unknown}', expected at least 16 GiB" >&2
    bad=1
  fi
  opts=$$(findmnt -no OPTIONS /tmp 2>/dev/null || true)
  if [[ $$opts == *noexec* ]]; then
    echo "prepare: /tmp is mounted noexec" >&2
    bad=1
  fi
  src=$$(findmnt -n -o SOURCE /home 2>/dev/null || true)
  if [[ $$src == *datavg* ]]; then
    echo "prepare: /home is on $$src" >&2
    bad=1
  fi
  home_b=$$(df -B1 --output=size /home 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  if [[ $$home_b =~ ^[0-9]+$$ ]] && home_is_huge "$$home_b"; then
    echo "prepare: /home is $$home_b bytes. A terabyte-scale /home means the data disk was added to homelv." >&2
    bad=1
  fi
  uuid=$$(blkid -s UUID -o value /dev/datavg/optlv 2>/dev/null || true)
  if ! fstab_has opt "$$uuid"; then
    echo "prepare: /etc/fstab has no datavg /opt line" >&2
    bad=1
  fi
  if ! fstab_has nokia "$$uuid"; then
    echo "prepare: /etc/fstab has no /nokia bind" >&2
    bad=1
  fi
  if ! fstab_has oradata "$$uuid"; then
    echo "prepare: /etc/fstab has no /oradata bind" >&2
    bad=1
  fi
  if ! fstab_has swap "$$uuid"; then
    echo "prepare: /etc/fstab has no /opt/swapfile line" >&2
    bad=1
  fi
  for path in /opt/oracle /opt/nokia /opt/tnms-data /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3 /nokia /oradata /opt/tnms-install /opt/tnms-install/resources; do
    if [[ ! -d $$path ]]; then
      echo "prepare: missing $$path" >&2
      bad=1
    fi
  done
  if ! labels_ok; then
    echo "prepare: SELinux labels are not usr_t on /opt and swapfile_t on /opt/swapfile" >&2
    bad=1
  fi
  return "$$bad"
}

print_other_disks() {
  local i j name any=0 disk_any=0
  for i in "$${!LS_NAME[@]}"; do
    [[ $${LS_TYPE[$$i]} == disk ]] || continue
    [[ $${LS_NAME[$$i]} == "$${OS_DISK:-}" ]] && continue
    disk_any=1
    name=$${LS_NAME[$$i]}
    echo "  $$name $$(show_bytes "$${LS_SIZE[$$i]}")"
    any=0
    for j in "$${!LS_NAME[@]}"; do
      if ls_under "$${LS_NAME[$$j]}" "$$name"; then
        any=1
        echo "    $${LS_TYPE[$$j]} $${LS_NAME[$$j]} fs=$${LS_FS[$$j]:-none} mount=$${LS_MNT[$$j]:-none}"
      fi
    done
    if [[ $$any -eq 0 ]]; then
      echo "    no partitions"
    fi
  done
  if [[ $$disk_any -eq 0 ]]; then
    echo "  none"
  fi
}

print_roms() {
  local i any=0
  for i in "$${!LS_NAME[@]}"; do
    if [[ $${LS_TYPE[$$i]} == rom ]]; then
      any=1
      echo "ignored $${LS_NAME[$$i]} type rom"
    fi
  done
  if [[ $$any -eq 0 ]]; then
    echo "ignored rom: none"
  fi
}

print_tmp_files() {
  local name
  for name in Makefile "$$WIZARD_NAME" "$$PROPS_NAME" "$${ZIPS[@]}"; do
    if [[ -f /tmp/$$name ]]; then
      echo "  present /tmp/$$name"
    else
      echo "  absent  /tmp/$$name"
    fi
  done
}

print_actions() {
  local def=""
  echo "proposed:"
  if [[ $$GROW_STATE == done ]]; then
    echo "  grow: rootlv and tmplv are already at the target size"
  elif [[ $$GROW_STATE == short ]]; then
    echo "  grow: not offered. rootvg free $${VG_FREE:-0} bytes, grow needs $${GROW_NEED:-0} bytes"
  elif [[ $$GROW_STATE == offer ]]; then
    echo "  grow: extend rootlv to 8 GiB and tmplv to 16 GiB when smaller"
  else
    echo "  grow: rootlv, tmplv, or rootvg free space is unknown"
  fi
  if [[ $${OPT_SRC:-} == /dev/mapper/datavg-optlv ]]; then
    echo "  disk: /opt is already datavg-optlv. prepare will not repartition"
  else
    def=$$(disk_default || true)
    if [[ -n $$def ]]; then
      echo "  disk: default data disk /dev/$$def"
    else
      echo "  disk: no single empty data disk. prepare needs TNMS_DATA_DISK"
    fi
  fi
  if home_blocks; then
    echo "  stop: /home is $${HOME_B:-unknown} bytes on $${HOME_SRC:-unknown}. A terabyte-scale /home means the data disk was added to homelv. prepare will not continue."
  fi
  if [[ $${HOME_B:-} =~ ^[0-9]+$$ && $$HOME_B -lt $$HOME_SMALL ]]; then
    echo "  note: /home is about 1 GB. VS Code Remote SSH stays manual (pre-install section 6)."
  fi
  echo "fixed: / at 8 GB, /tmp at 16 GB, swap 18 GB, SID $${TNMS_SID}. Paths /opt /nokia /oradata /opt/oracle /opt/nokia /opt/tnms-data."
  echo "fixed: passwords stay SYS_PASSWORD, SYSTEM_PASSWORD, TNMSDBA_PASSWORD, and TNMS_SFTP_PASSWORD. scan does not ask for them."
}

scan_collect() {
  local ip line
  REL=$$(cat /etc/redhat-release 2>/dev/null || true)
  SELINUX=$$(getenforce 2>/dev/null || true)
  NCPU=$$(nproc 2>/dev/null || true)
  RAM_LINE=$$(awk '/MemTotal/ { printf "%.0f GB", $$2 / 1024 / 1024 }' /proc/meminfo 2>/dev/null || true)
  lsblk_load "$$(lsblk -P -b -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,PKNAME 2>/dev/null || true)"
  OS_DISK=$$(ls_disk_of_mount / || true)
  ROOT_B=$$(lv_bytes /dev/rootvg/rootlv || true)
  TMP_B=$$(lv_bytes /dev/rootvg/tmplv || true)
  HOME_LV_B=$$(lv_bytes /dev/rootvg/homelv || true)
  VG_FREE=$$(vg_free_bytes || true)
  TMP_OPTS=$$(findmnt -no OPTIONS /tmp 2>/dev/null || true)
  OPT_SRC=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  NOKIA_SRC=$$(findmnt -n -o SOURCE /nokia 2>/dev/null || true)
  ORADATA_SRC=$$(findmnt -n -o SOURCE /oradata 2>/dev/null || true)
  HOME_SRC=$$(findmnt -n -o SOURCE /home 2>/dev/null || true)
  HOME_B=$$(df -B1 --output=size /home 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  SWAP_SHOW=$$(swapon --show=NAME,SIZE --noheadings 2>/dev/null || true)
  HOST_NOW=$$(hostnamectl --static 2>/dev/null || true)
  if [[ -z $$HOST_NOW ]]; then
    HOST_NOW=$$(hostname 2>/dev/null || true)
  fi
  PRESERVE=$$(awk '/^preserve_hostname:/ { print $$2; exit }' /etc/cloud/cloud.cfg 2>/dev/null || true)
  DOMAIN=$$(resolve_domain || true)
  ROUTE_IP=$$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($$i == "src") { print $$(i + 1); exit } }' || true)
  GLOBAL_IPS=
  GLOBAL_N=0
  while IFS= read -r line; do
    [[ -z $$line ]] && continue
    ip=$${line%%/*}
    if [[ -z $$GLOBAL_IPS ]]; then
      GLOBAL_IPS=$$ip
    else
      GLOBAL_IPS="$$GLOBAL_IPS $$ip"
    fi
    GLOBAL_N=$$((GLOBAL_N + 1))
  done < <(ip -4 -o addr show scope global 2>/dev/null | awk '{ print $$4 }' || true)
  SSH_USER=$$(ssh_account || true)
  SSH_GROUP=
  if [[ -n $$SSH_USER ]]; then
    SSH_GROUP=$$(id -gn "$$SSH_USER" 2>/dev/null || true)
  fi
  if oracle_present; then
    ORACLE_NOTE="$$TNMS_SID is in /etc/oratab"
  else
    ORACLE_NOTE="$$TNMS_SID is not in /etc/oratab"
  fi
  if [[ -d /opt/nokia/tnms/server ]]; then
    TNMS_NOTE="/opt/nokia/tnms/server exists"
  else
    TNMS_NOTE="/opt/nokia/tnms/server is absent"
  fi
  GROW_NEED=0
  GROW_STATE=unknown
  if [[ $$ROOT_B =~ ^[0-9]+$$ && $$TMP_B =~ ^[0-9]+$$ && $$VG_FREE =~ ^[0-9]+$$ ]]; then
    if [[ $$ROOT_B -lt $$TARGET_ROOT ]]; then
      GROW_NEED=$$((GROW_NEED + TARGET_ROOT - ROOT_B))
    fi
    if [[ $$TMP_B -lt $$TARGET_TMP ]]; then
      GROW_NEED=$$((GROW_NEED + TARGET_TMP - TMP_B))
    fi
    if [[ $$GROW_NEED -eq 0 ]]; then
      GROW_STATE=done
    elif [[ $$VG_FREE -lt $$GROW_NEED ]]; then
      GROW_STATE=short
    else
      GROW_STATE=offer
    fi
  fi
}

scan_report() {
  echo "release: $${REL:-unknown}"
  echo "selinux: $${SELINUX:-unknown}"
  echo "cpu: $${NCPU:-unknown}"
  echo "ram: $${RAM_LINE:-unknown}"
  echo "os-disk: $${OS_DISK:-unknown}"
  echo "rootlv: $$(show_bytes "$$ROOT_B")"
  echo "tmplv: $$(show_bytes "$$TMP_B")"
  echo "homelv: $$(show_bytes "$$HOME_LV_B")"
  echo "rootvg-free: $$(show_bytes "$$VG_FREE")"
  if [[ $${TMP_OPTS:-} == *noexec* ]]; then
    echo "tmp-noexec: yes"
  else
    echo "tmp-noexec: no"
  fi
  echo "other-disks:"
  print_other_disks
  print_roms
  echo "opt: $${OPT_SRC:-not-mounted}"
  echo "nokia: $${NOKIA_SRC:-not-mounted}"
  echo "oradata: $${ORADATA_SRC:-not-mounted}"
  echo "home: $${HOME_SRC:-not-mounted} $$(show_bytes "$$HOME_B")"
  echo "swap: $${SWAP_SHOW:-none}"
  echo "hostname: $${HOST_NOW:-unknown}"
  echo "preserve_hostname: $${PRESERVE:-unknown}"
  echo "search-domain: $${DOMAIN:-unknown}"
  echo "ipv4-route: $${ROUTE_IP:-none}"
  echo "ipv4-global: $${GLOBAL_IPS:-none}"
  echo "ssh-account: $${SSH_USER:-unknown}"
  echo "ssh-group: $${SSH_GROUP:-unknown}"
  echo "install-files:"
  print_tmp_files
  echo "oracle: $${ORACLE_NOTE:-unknown}"
  echo "tnms: $${TNMS_NOTE:-unknown}"
  print_actions
}

scan_blocked() {
  if home_blocks; then
    return 0
  fi
  if [[ $${TMP_OPTS:-} == *noexec* ]]; then
    return 0
  fi
  return 1
}

interactive_scan() {
  [[ -t 1 && -r /dev/tty && -w /dev/tty ]]
}

prompt_value() {
  local label=$$1 default=$${2:-} reply
  if [[ -n $$default ]]; then
    printf '%s [%s]: ' "$$label" "$$default" >/dev/tty
  else
    printf '%s (no default): ' "$$label" >/dev/tty
  fi
  IFS= read -r reply </dev/tty || return 1
  if [[ -z $$reply ]]; then
    [[ -n $$default ]] || return 1
    printf '%s' "$$default"
  else
    printf '%s' "$$reply"
  fi
}

ip_needs_question() {
  if [[ $${GLOBAL_N:-0} -eq 1 && -n $${ROUTE_IP:-} && $$GLOBAL_IPS == "$$ROUTE_IP" ]]; then
    return 1
  fi
  return 0
}

print_proposed_answers() {
  local disk="" grow="" ip=""
  if [[ $${OPT_SRC:-} != /dev/mapper/datavg-optlv ]]; then
    disk=$$(disk_default || true)
  fi
  if [[ $$GROW_STATE == offer ]]; then
    grow=yes
  fi
  if ip_needs_question; then
    if [[ -n $$ROUTE_IP ]]; then
      ip=$$ROUTE_IP
    elif [[ $$GLOBAL_N -eq 1 ]]; then
      ip=$$GLOBAL_IPS
    fi
  fi
  if [[ -z $$disk && $${OPT_SRC:-} != /dev/mapper/datavg-optlv ]]; then
    echo "Set TNMS_DATA_DISK to one whole disk from the report. There is no default."
  fi
  answers_lines "$$disk" "$$grow" "TNMS" "$${SSH_GROUP:-azureuser}" "$$ip"
}

scan_ask() {
  local disk="" grow="" host="" group="" ip="" reply="" def="" reason="" tries=0 group_default="" ip_default=""
  if [[ $${OPT_SRC:-} != /dev/mapper/datavg-optlv ]]; then
    def=$$(disk_default || true)
    tries=0
    while [[ $$tries -lt 20 ]]; do
      tries=$$((tries + 1))
      if ! reply=$$(prompt_value "Data disk" "$$def"); then
        echo "scan: type the data disk device" >/dev/tty
        def=
        continue
      fi
      reply=$$(strip_dev "$$reply")
      lsblk_load "$$(lsblk -P -b -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,PKNAME 2>/dev/null || true)"
      OS_DISK=$$(ls_disk_of_mount / || true)
      reason=$$(data_disk_block_reason "$$reply")
      if [[ -z $$reason ]]; then
        disk=$$reply
        break
      fi
      echo "scan: /dev/$$reply $$reason" >/dev/tty
      def=
    done
    [[ -n $$disk ]] || scan_die "stopped without a data disk"
  fi
  if [[ $$GROW_STATE == offer ]]; then
    reply=$$(prompt_value "Grow rootlv to 8 GiB and tmplv to 16 GiB" "yes") || reply=no
    if [[ $$reply == yes || $$reply == y || $$reply == YES ]]; then
      grow=yes
    fi
  fi
  tries=0
  while [[ $$tries -lt 20 ]]; do
    tries=$$((tries + 1))
    reply=$$(prompt_value "Short hostname" "TNMS") || reply=
    if valid_hostname "$$reply"; then
      host=$$reply
      break
    fi
    echo "scan: hostname must be a short name" >/dev/tty
  done
  [[ -n $$host ]] || scan_die "stopped without a hostname"
  group_default=$$SSH_GROUP
  if [[ -z $$group_default ]] || ! getent group "$$group_default" >/dev/null; then
    group_default=
  fi
  tries=0
  while [[ $$tries -lt 20 ]]; do
    tries=$$((tries + 1))
    if ! reply=$$(prompt_value "Admin group" "$$group_default"); then
      echo "scan: type the admin group" >/dev/tty
      group_default=
      continue
    fi
    if valid_group_name "$$reply" && getent group "$$reply" >/dev/null; then
      group=$$reply
      break
    fi
    echo "scan: group $$reply does not exist" >/dev/tty
    group_default=
  done
  [[ -n $$group ]] || scan_die "stopped without an admin group"
  if ip_needs_question; then
    ip_default=
    if [[ -n $$ROUTE_IP ]]; then
      ip_default=$$ROUTE_IP
    elif [[ $$GLOBAL_N -eq 1 ]]; then
      ip_default=$$GLOBAL_IPS
    fi
    tries=0
    while [[ $$tries -lt 20 ]]; do
      tries=$$((tries + 1))
      if ! reply=$$(prompt_value "IPv4 address" "$$ip_default"); then
        echo "scan: type an IPv4 address" >/dev/tty
        ip_default=
        continue
      fi
      if valid_ipv4 "$$reply"; then
        ip=$$reply
        break
      fi
      echo "scan: $$reply is not an IPv4 address" >/dev/tty
      ip_default=
    done
    [[ -n $$ip ]] || scan_die "stopped without an IPv4 address"
  fi
  echo "scan: answers to write:"
  answers_lines "$$disk" "$$grow" "$$host" "$$group" "$$ip"
  printf 'Write these answers to %s? Type yes: ' "$$ANSWERS" >/dev/tty
  IFS= read -r reply </dev/tty || reply=
  commit_answers "$$reply" "$$ANSWERS" "$$disk" "$$grow" "$$host" "$$group" "$$ip"
}

scan_main() {
  require_root
  scan_collect
  scan_report
  if prepare_ok >/dev/null 2>&1; then
    echo "prepare: nothing to do"
    return 0
  fi
  if scan_blocked; then
    echo "scan: prepare will not continue. No answers were written."
    exit 1
  fi
  if interactive_scan; then
    scan_ask
    return 0
  fi
  echo "scan: no terminal. The report above is read-only."
  echo "scan: write $$ANSWERS with these lines, then run make prepare."
  print_proposed_answers
  exit 2
}

prepare_load_agreement() {
  local owner
  [[ -f $$ANSWERS ]] || prepare_die "missing $$ANSWERS. Run make scan on a terminal, or write that file, then run make prepare."
  owner=$$(stat -c %U "$$ANSWERS")
  [[ $$owner == root ]] || prepare_die "$$ANSWERS is owned by $$owner"
  chmod 600 "$$ANSWERS"
  load_answers "$$ANSWERS"
  [[ $$ANS_CONFIRM == yes ]] || prepare_die "$$ANSWERS does not contain CONFIRM=yes"
  [[ -n $$ANS_HOST ]] || prepare_die "$$ANSWERS does not contain TNMS_HOSTNAME"
  [[ -n $$ANS_GROUP ]] || prepare_die "$$ANSWERS does not contain TNMS_ADMIN_GROUP"
  echo "prepare: confirmed answers in $$ANSWERS"
}

prepare_prechecks() {
  local home_b opts src
  preflight_ok || exit 1
  src=$$(findmnt -n -o SOURCE /home 2>/dev/null || true)
  if [[ $$src == *datavg* ]]; then
    prepare_die "/home is on $$src. The data disk was added to the home volume."
  fi
  home_b=$$(df -B1 --output=size /home 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  if [[ $$home_b =~ ^[0-9]+$$ ]] && home_is_huge "$$home_b"; then
    prepare_die "/home is $$home_b bytes. A terabyte-scale /home means the data disk was added to homelv."
  fi
  opts=$$(findmnt -no OPTIONS /tmp 2>/dev/null || true)
  if [[ $$opts == *noexec* ]]; then
    prepare_die "/tmp is mounted noexec"
  fi
  if mountpoint_busy /nokia; then
    prepare_die "/nokia is not a bind mount and is not empty"
  fi
  if mountpoint_busy /oradata; then
    prepare_die "/oradata is not a bind mount and is not empty"
  fi
}

prepare_grow() {
  local root_b tmp_b free_b need=0
  root_b=$$(lv_bytes /dev/rootvg/rootlv || true)
  tmp_b=$$(lv_bytes /dev/rootvg/tmplv || true)
  free_b=$$(vg_free_bytes || true)
  if [[ ! $$root_b =~ ^[0-9]+$$ || ! $$tmp_b =~ ^[0-9]+$$ ]]; then
    prepare_die "could not read rootlv and tmplv sizes"
  fi
  if [[ $$root_b -lt $$TARGET_ROOT ]]; then
    need=$$((need + TARGET_ROOT - root_b))
  fi
  if [[ $$tmp_b -lt $$TARGET_TMP ]]; then
    need=$$((need + TARGET_TMP - tmp_b))
  fi
  if [[ $$need -eq 0 ]]; then
    echo "prepare: rootlv and tmplv are already at the target size"
    return 0
  fi
  if [[ ! $$free_b =~ ^[0-9]+$$ || $$free_b -lt $$need ]]; then
    prepare_die "rootvg free $${free_b:-0} bytes, grow needs $$need bytes"
  fi
  if [[ $$ANS_GROW != yes ]]; then
    prepare_die "rootlv or tmplv is below the target and TNMS_GROW is not yes"
  fi
  if [[ $$root_b -lt $$TARGET_ROOT ]]; then
    echo "prepare: lvextend rootlv to 8G"
    lvextend -r -L 8G /dev/rootvg/rootlv
  fi
  if [[ $$tmp_b -lt $$TARGET_TMP ]]; then
    echo "prepare: lvextend tmplv to 16G"
    lvextend -r -L 16G /dev/rootvg/tmplv
  fi
}

partition_node() {
  local dev=$$1
  if [[ -b $${dev}p1 ]]; then
    printf '%s\n' "$${dev}p1"
    return 0
  fi
  if [[ -b $${dev}1 ]]; then
    printf '%s\n' "$${dev}1"
    return 0
  fi
  sleep 2
  udevadm settle || true
  if [[ -b $${dev}p1 ]]; then
    printf '%s\n' "$${dev}p1"
    return 0
  fi
  if [[ -b $${dev}1 ]]; then
    printf '%s\n' "$${dev}1"
    return 0
  fi
  return 1
}

prepare_mount_opt() {
  local src dev reason part align os_dev data_dev
  src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  if [[ $$src == /dev/mapper/datavg-optlv ]]; then
    echo "prepare: /opt is already datavg-optlv"
    return 0
  fi
  if [[ -n $$src ]]; then
    prepare_die "/opt is mounted from $$src"
  fi
  if [[ -e /opt && ! -d /opt ]]; then
    prepare_die "/opt exists and is not a directory"
  fi
  if [[ ! -d /opt ]]; then
    install -d -m 755 /opt
  fi
  if opt_has_names; then
    prepare_die "/opt is not datavg-optlv and is not empty"
  fi
  if [[ -b /dev/datavg/optlv || -b /dev/mapper/datavg-optlv ]]; then
    echo "prepare: mounting existing /dev/datavg/optlv"
    mount /dev/datavg/optlv /opt
    src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
    [[ $$src == /dev/mapper/datavg-optlv ]] || prepare_die "mount did not attach datavg-optlv"
    return 0
  fi
  [[ -n $$ANS_DISK ]] || prepare_die "TNMS_DATA_DISK is empty"
  dev=$$ANS_DISK
  [[ -b $$dev ]] || prepare_die "$$dev is not a block device"
  lsblk_load "$$(lsblk -P -b -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,PKNAME)"
  OS_DISK=$$(ls_disk_of_mount / || true)
  [[ -n $$OS_DISK ]] || prepare_die "could not identify the OS disk. No disk was labeled."
  reason=$$(data_disk_block_reason "$$dev")
  [[ -z $$reason ]] || prepare_die "$$dev $$reason"
  os_dev=$$(readlink -f "/dev/$$OS_DISK")
  data_dev=$$(readlink -f "$$dev")
  if [[ -n $$os_dev && $$data_dev == "$$os_dev" ]]; then
    prepare_die "$$dev is the OS disk"
  fi
  echo "prepare: labeling $$dev"
  parted -s "$$dev" mklabel gpt
  parted -a optimal -s "$$dev" mkpart primary 0% 100%
  parted -s "$$dev" set 1 lvm on
  udevadm settle
  if ! align=$$(parted "$$dev" align-check optimal 1 2>&1); then
    echo "prepare: align-check failed: $$align" >&2
    echo "prepare: no LVM command was run." >&2
    exit 1
  fi
  if [[ $$align != *aligned* ]]; then
    echo "prepare: align-check did not report aligned: $$align" >&2
    echo "prepare: no LVM command was run." >&2
    exit 1
  fi
  echo "prepare: $$align"
  part=$$(partition_node "$$dev") || prepare_die "partition node did not appear. No LVM command was run."
  echo "prepare: pvcreate $$part"
  pvcreate "$$part"
  vgcreate datavg "$$part"
  lvcreate -n optlv -l 100%FREE datavg
  mkfs.xfs /dev/datavg/optlv
  mount /dev/datavg/optlv /opt
  src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  [[ $$src == /dev/mapper/datavg-optlv ]] || prepare_die "mount did not attach datavg-optlv (source $${src:-empty})"
}

prepare_directories() {
  local inst_mode=750
  if oracle_present; then
    inst_mode=751
  fi
  install -d -o root -g root -m 755 /opt/oracle /opt/nokia /opt/tnms-data
  install -d -o root -g root -m 755 /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3
  install -d -o root -g root -m 755 /nokia /oradata
  install -d -o root -g "$$TNMS_ADMIN_GROUP" -m "$$inst_mode" /opt/tnms-install
  install -d -o root -g "$$TNMS_ADMIN_GROUP" -m 750 /opt/tnms-install/resources
}

prepare_binds() {
  local src
  src=$$(findmnt -n -o SOURCE /nokia 2>/dev/null || true)
  if [[ $$src != *"[/tnms-data]"* ]]; then
    if [[ -n $$src ]]; then
      prepare_die "/nokia is mounted from $$src"
    fi
    echo "prepare: bind /opt/tnms-data on /nokia"
    mount --bind /opt/tnms-data /nokia
  fi
  src=$$(findmnt -n -o SOURCE /oradata 2>/dev/null || true)
  if [[ $$src != *"[/oradata]"* ]]; then
    if [[ -n $$src ]]; then
      prepare_die "/oradata is mounted from $$src"
    fi
    echo "prepare: bind /opt/oradata on /oradata"
    mount --bind /opt/oradata /oradata
  fi
}

prepare_swap() {
  local sz src avail
  src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  [[ $$src == /dev/mapper/datavg-optlv ]] || prepare_die "/opt is not datavg-optlv, so the swap file was not created"
  if swap_is_ready; then
    echo "prepare: swap file is already active"
    return 0
  fi
  if [[ -e /opt/swapfile ]]; then
    sz=$$(stat -c %s /opt/swapfile)
    if [[ $$sz != "$$SWAP_BYTES" ]]; then
      prepare_die "/opt/swapfile is $$sz bytes, not $$SWAP_BYTES. It was not replaced."
    fi
  else
    avail=$$(df -B1 --output=avail /opt | tail -n 1 | tr -d ' ')
    if [[ $$avail -lt $$((20 * 1024 * 1024 * 1024)) ]]; then
      prepare_die "/opt has $$avail bytes free. The swap file was not created."
    fi
    echo "prepare: creating 18 GiB /opt/swapfile"
    dd if=/dev/zero of=/opt/swapfile bs=1G count=18 status=progress
    chmod 600 /opt/swapfile
  fi
  chmod 600 /opt/swapfile
  if ! swap_is_ready; then
    mkswap /opt/swapfile
    swapon /opt/swapfile
  fi
  swap_is_ready || prepare_die "swap did not activate"
}

prepare_fstab() {
  local uuid add_opt=0 add_nokia=0 add_ora=0 add_swap=0
  uuid=$$(blkid -s UUID -o value /dev/datavg/optlv 2>/dev/null || true)
  [[ $$uuid =~ ^[0-9a-fA-F-]+$$ ]] || prepare_die "blkid did not return a UUID for /dev/datavg/optlv. /etc/fstab was not changed."
  if fstab_has opt "$$uuid"; then
    :
  elif fstab_target_exists /opt; then
    prepare_die "/etc/fstab already has an /opt entry that is not datavg. No line was added."
  else
    add_opt=1
  fi
  if fstab_has nokia "$$uuid"; then
    :
  elif fstab_target_exists /nokia; then
    prepare_die "/etc/fstab already has a /nokia entry. No line was added."
  else
    add_nokia=1
  fi
  if fstab_has oradata "$$uuid"; then
    :
  elif fstab_target_exists /oradata; then
    prepare_die "/etc/fstab already has an /oradata entry. No line was added."
  else
    add_ora=1
  fi
  if fstab_has swap "$$uuid"; then
    :
  elif fstab_source_exists /opt/swapfile; then
    prepare_die "/etc/fstab already has an /opt/swapfile entry. No line was added."
  else
    add_swap=1
  fi
  if [[ $$add_opt -eq 0 && $$add_nokia -eq 0 && $$add_ora -eq 0 && $$add_swap -eq 0 ]]; then
    echo "prepare: fstab already has the data disk lines"
    mount -a
    return 0
  fi
  {
    if [[ $$add_opt -eq 1 ]]; then
      printf 'UUID=%s /opt xfs defaults,nofail 0 0\n' "$$uuid"
    fi
    if [[ $$add_nokia -eq 1 ]]; then
      printf '%s\n' '/opt/tnms-data /nokia none bind,nofail 0 0'
    fi
    if [[ $$add_ora -eq 1 ]]; then
      printf '%s\n' '/opt/oradata /oradata none bind,nofail 0 0'
    fi
    if [[ $$add_swap -eq 1 ]]; then
      printf '%s\n' '/opt/swapfile none swap sw,nofail 0 0'
    fi
  } >> /etc/fstab
  systemctl daemon-reload
  mount -a
}

prepare_labels() {
  if labels_ok; then
    echo "prepare: SELinux labels already match"
    return 0
  fi
  if [[ -d /opt/nokia/tnms/server ]]; then
    prepare_die "SELinux labels do not match and TNMS is installed. restorecon was not run."
  fi
  echo "prepare: restorecon -RF /opt"
  restorecon -RF /opt
  chcon -t swapfile_t /opt/swapfile
  labels_ok || prepare_die "SELinux labels still do not match"
}

prepare_main() {
  require_root
  if prepare_ok >/dev/null 2>&1; then
    echo "prepare: nothing to do"
    stamp prepare
    echo "prepare: done"
    return 0
  fi
  prepare_load_agreement
  prepare_prechecks
  prepare_grow
  prepare_mount_opt
  prepare_directories
  prepare_binds
  prepare_swap
  prepare_fstab
  prepare_labels
  if ! prepare_ok; then
    echo "prepare: the layout is still incomplete. No stamp was written." >&2
    exit 1
  fi
  stamp prepare
  echo "prepare: done"
}

fixture_one() {
  cat <<'EOF'
NAME="nvme0n1" TYPE="disk" SIZE="68719476736" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="nvme0n1p1" TYPE="part" SIZE="536870912" FSTYPE="xfs" MOUNTPOINT="/boot" PKNAME="nvme0n1"
NAME="nvme0n1p2" TYPE="part" SIZE="67108864000" FSTYPE="LVM2_member" MOUNTPOINT="" PKNAME="nvme0n1"
NAME="rootvg-rootlv" TYPE="lvm" SIZE="2147483648" FSTYPE="xfs" MOUNTPOINT="/" PKNAME="nvme0n1p2"
NAME="rootvg-homelv" TYPE="lvm" SIZE="1073741824" FSTYPE="xfs" MOUNTPOINT="/home" PKNAME="nvme0n1p2"
NAME="nvme0n2" TYPE="disk" SIZE="1099511627776" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="sr0" TYPE="rom" SIZE="645120" FSTYPE="" MOUNTPOINT="" PKNAME=""
EOF
}

fixture_none() {
  cat <<'EOF'
NAME="nvme0n1" TYPE="disk" SIZE="68719476736" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="nvme0n1p2" TYPE="part" SIZE="67108864000" FSTYPE="LVM2_member" MOUNTPOINT="" PKNAME="nvme0n1"
NAME="rootvg-rootlv" TYPE="lvm" SIZE="2147483648" FSTYPE="xfs" MOUNTPOINT="/" PKNAME="nvme0n1p2"
NAME="nvme0n2" TYPE="disk" SIZE="1099511627776" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="nvme0n2p1" TYPE="part" SIZE="1099000000000" FSTYPE="xfs" MOUNTPOINT="/data" PKNAME="nvme0n2"
EOF
}

fixture_two() {
  cat <<'EOF'
NAME="nvme0n1" TYPE="disk" SIZE="68719476736" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="nvme0n1p2" TYPE="part" SIZE="67108864000" FSTYPE="LVM2_member" MOUNTPOINT="" PKNAME="nvme0n1"
NAME="rootvg-rootlv" TYPE="lvm" SIZE="2147483648" FSTYPE="xfs" MOUNTPOINT="/" PKNAME="nvme0n1p2"
NAME="nvme0n2" TYPE="disk" SIZE="1099511627776" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="nvme0n3" TYPE="disk" SIZE="1099511627776" FSTYPE="" MOUNTPOINT="" PKNAME=""
EOF
}

fixture_boundary() {
  cat <<'EOF'
NAME="sda" TYPE="disk" SIZE="68719476736" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="sda1" TYPE="part" SIZE="1000" FSTYPE="xfs" MOUNTPOINT="/" PKNAME="sda"
NAME="sdb" TYPE="disk" SIZE="100000000000" FSTYPE="" MOUNTPOINT="" PKNAME=""
NAME="sdc" TYPE="disk" SIZE="99999999999" FSTYPE="" MOUNTPOINT="" PKNAME=""
EOF
}

expect_eq() {
  local got=$$1 want=$$2
  if [[ $$got != "$$want" ]]; then
    echo "self-test: expected [$$want] got [$$got]" >&2
    exit 1
  fi
}

fixture_self_test() {
  local reason got dir mode out
  local sample='NAME="nvme0n1p2" TYPE="part" SIZE="1" FSTYPE="LVM2_member" MOUNTPOINT="" PKNAME="nvme0n1"'
  expect_eq "$$(ls_field NAME "$$sample")" "nvme0n1p2"
  expect_eq "$$(ls_field PKNAME "$$sample")" "nvme0n1"
  expect_eq "$$(ls_field FSTYPE "$$sample")" "LVM2_member"
  expect_eq "$$(ls_field MOUNTPOINT "$$sample")" ""

  use_fixture "$$(fixture_one)"
  expect_eq "$$OS_DISK" "nvme0n1"
  expect_eq "$$(disk_default)" "nvme0n2"
  expect_eq "$$(list_candidates)" "nvme0n2"
  reason=$$(data_disk_block_reason nvme0n2)
  expect_eq "$$reason" ""
  reason=$$(data_disk_block_reason /dev/nvme0n1)
  [[ $$reason == *OS\ disk* ]] || { echo "self-test: OS disk reason [$$reason]" >&2; exit 1; }
  reason=$$(data_disk_block_reason sr0)
  [[ -n $$reason ]] || { echo "self-test: rom was accepted" >&2; exit 1; }

  use_fixture "$$(fixture_none)"
  expect_eq "$$(disk_default)" ""
  expect_eq "$$(list_candidates)" ""
  reason=$$(data_disk_block_reason nvme0n2)
  [[ $$reason == *child\ mount* ]] || { echo "self-test: non-empty reason [$$reason]" >&2; exit 1; }

  use_fixture "$$(fixture_two)"
  expect_eq "$$OS_DISK" "nvme0n1"
  expect_eq "$$(disk_default)" ""
  got=$$(list_candidates)
  expect_eq "$$got" "nvme0n2
nvme0n3"
  reason=$$(data_disk_block_reason nvme0n2)
  expect_eq "$$reason" ""
  reason=$$(data_disk_block_reason nvme0n3)
  expect_eq "$$reason" ""
  reason=$$(data_disk_block_reason nvme0n1)
  [[ $$reason == *OS\ disk* ]] || { echo "self-test: two-disk OS reason [$$reason]" >&2; exit 1; }

  use_fixture "$$(fixture_boundary)"
  expect_eq "$$(disk_default)" "sdb"
  reason=$$(data_disk_block_reason sdc)
  [[ $$reason == *smaller\ than\ 100\ GB* ]] || { echo "self-test: size reason [$$reason]" >&2; exit 1; }

  valid_hostname TNMS || { echo "self-test: TNMS rejected" >&2; exit 1; }
  valid_hostname TN || { echo "self-test: TN rejected" >&2; exit 1; }
  if valid_hostname "-bad"; then
    echo "self-test: -bad accepted" >&2
    exit 1
  fi
  if valid_hostname "a-"; then
    echo "self-test: a- accepted" >&2
    exit 1
  fi
  valid_ipv4 172.16.0.4 || { echo "self-test: ipv4 rejected" >&2; exit 1; }
  if valid_ipv4 172.16.0.256; then
    echo "self-test: octet 256 accepted" >&2
    exit 1
  fi
  if home_is_huge 1073741824; then
    echo "self-test: 1 GiB home was huge" >&2
    exit 1
  fi
  home_is_huge "$$HOME_HUGE" || { echo "self-test: huge home was accepted" >&2; exit 1; }

  out=$$(answers_lines nvme0n2 yes TNMS azureuser 172.16.0.4)
  [[ $$out == *'CONFIRM=yes'* ]] || { echo "self-test: CONFIRM missing" >&2; exit 1; }
  [[ $$out == *'TNMS_DATA_DISK=/dev/nvme0n2'* ]] || { echo "self-test: disk missing" >&2; exit 1; }
  [[ $$out == *'TNMS_GROW=yes'* ]] || { echo "self-test: grow missing" >&2; exit 1; }
  [[ $$out != *SYS_PASSWORD* && $$out != *TnZT5hgW8Zwsp79* ]] || { echo "self-test: password landed in answers" >&2; exit 1; }

  dir=$$(mktemp -d)
  printf '%s\n' 'CONFIRM=$$(touch pwned)' 'TNMS_HOSTNAME=TNMS' 'TNMS_ADMIN_GROUP=azureuser' > "$$dir/bad"
  load_answers "$$dir/bad"
  [[ $$ANS_CONFIRM != yes ]] || { echo "self-test: unsafe CONFIRM was accepted" >&2; exit 1; }
  [[ ! -e $$dir/pwned ]] || { echo "self-test: answers file was executed" >&2; exit 1; }
  expect_eq "$$ANS_HOST" "TNMS"
  printf '%s\n' 'TNMS_DATA_DISK=/dev/nvme0n2' 'TNMS_GROW=yes' 'TNMS_HOSTNAME=TNMS' 'TNMS_ADMIN_GROUP=azureuser' 'TNMS_IP=172.16.0.4' 'CONFIRM=yes' > "$$dir/good"
  load_answers "$$dir/good"
  expect_eq "$$ANS_CONFIRM" "yes"
  expect_eq "$$ANS_DISK" "/dev/nvme0n2"
  expect_eq "$$ANS_GROW" "yes"
  expect_eq "$$ANS_IP" "172.16.0.4"
  commit_answers no "$$dir/out" nvme0n2 yes TNMS azureuser ""
  [[ ! -e $$dir/out ]] || { echo "self-test: declined answers were written" >&2; exit 1; }
  commit_answers yes "$$dir/out" nvme0n2 yes TNMS azureuser ""
  [[ -f $$dir/out ]] || { echo "self-test: answers were not written" >&2; exit 1; }
  mode=$$(stat -c %a "$$dir/out")
  expect_eq "$$mode" "600"
  grep -q '^CONFIRM=yes$$' "$$dir/out"
  printf '%b\n' '\043 UUID=abc /opt xfs defaults,nofail 0 0' > "$$dir/fstab"
  if fstab_has opt abc "$$dir/fstab"; then
    echo "self-test: a comment was treated as an fstab mount" >&2
    exit 1
  fi
  printf '%s\n' 'UUID=abc /opt xfs defaults,nofail 0 0' '/opt/tnms-data /nokia none bind,nofail 0 0' >> "$$dir/fstab"
  fstab_has opt abc "$$dir/fstab"
  fstab_has nokia "" "$$dir/fstab"
  fstab_target_exists /nokia "$$dir/fstab"
  printf '%s\n' 'TNMS_HOSTNAME=bad name' 'CONFIRM=yes' > "$$dir/host"
  load_answers "$$dir/host"
  expect_eq "$$ANS_HOST" ""
  expect_eq "$$ANS_CONFIRM" "yes"
  use_fixture "$$(fixture_one)"
  OPT_SRC=
  HOME_B=1073741824
  HOME_SRC=/dev/mapper/rootvg-homelv
  GROW_STATE=offer
  VG_FREE=100
  GROW_NEED=10
  TMP_OPTS=
  got=$$(print_actions)
  [[ $$got == *'default data disk /dev/nvme0n2'* ]] || { echo "self-test: action list missed the default disk" >&2; exit 1; }
  [[ $$got == *'about 1 GB'* ]] || { echo "self-test: small home note missing" >&2; exit 1; }
  HOME_B=$$HOME_HUGE
  got=$$(print_actions)
  [[ $$got == *'prepare will not continue'* ]] || { echo "self-test: huge home was not a stop" >&2; exit 1; }
  rm -rf "$$dir"
  echo "self-test: disk fixtures ok"
}

cmd=$${1:-}
case "$$cmd" in
  status) status_main ;;
  stage) stage_main ;;
  host) host_main ;;
  packages) packages_main ;;
  kernel) kernel_main ;;
  disk) disk_main ;;
  unpack) unpack_main ;;
  credentials) credentials_main ;;
  oracle) oracle_main ;;
  wizard) wizard_main ;;
  lsmem) lsmem_main ;;
  sftp) sftp_main ;;
  sudo) sudo_main ;;
  service) service_main ;;
  check) check_main ;;
  scan) scan_main ;;
  prepare) prepare_main ;;
  self-test) self_test ;;
  *)
    echo "Unknown installer command: $${cmd:-empty}" >&2
    exit 2
    ;;
esac
endef
export LIB

.PHONY: all help status script self-test scan prepare stage host packages kernel disk unpack credentials oracle wizard lsmem sftp sudo service check

all: check

help:
	cat <<-'EOF'
	TNMS 9.1 install. Run as root.

	  dnf -y install make
	  make -C /tmp -f Makefile scan
	  make -C /tmp -f Makefile prepare
	  make -C /tmp -f Makefile

	  make scan         read the host and ask before any disk change
	  make prepare      apply the agreed disk layout
	  make status       read-only report of the install conditions
	  make check        finish any step that is not done, then run the checks
	  make <target>     run through that step

	Run scan, then prepare, then the install targets:
	  scan
	  prepare stage host packages kernel disk unpack credentials oracle wizard lsmem sftp sudo service check

	scan only reads. On a terminal it can write /root/tnms-install.answers.
	Without a terminal it prints the answers to write and exits 2.
	prepare records a stamp in /var/lib/tnms-install. disk, check, and status
	always run. The other stamped targets skip work that is already done.
	Oracle and the TNMS wizard still run only when the product is absent.

	Overrides (command line or /root/tnms-install.local.mk):
	  TNMS_HOSTNAME TNMS_IP TNMS_ADMIN_GROUP TNMS_SID TNMS_DATA_DISK
	  SYS_PASSWORD SYSTEM_PASSWORD TNMSDBA_PASSWORD TNMS_SFTP_PASSWORD

	prepare reads TNMS_DATA_DISK, TNMS_GROW, and CONFIRM=yes from
	/root/tnms-install.answers. make scan writes that file after an explicit yes.

	self-test checks the sshd edit and the disk classification fixtures.
	EOF

script:
	printf '%s\n' "$$LIB"

self-test:
	printf '%s\n' "$$LIB" | bash -s -- self-test

scan:
	echo '=== scan (read-only) ==='
	printf '%s\n' "$$LIB" | bash -s -- scan

prepare: $(STAMP)/prepare

status:
	echo '=== status (read-only) ==='
	printf '%s\n' "$$LIB" | bash -s -- status

disk:
	echo '=== disk ==='
	printf '%s\n' "$$LIB" | bash -s -- disk

$(STAMP)/prepare:
	echo '=== prepare ==='
	printf '%s\n' "$$LIB" | bash -s -- prepare

$(STAMP)/stage: $(STAMP)/prepare
	echo '=== stage: directories, media, and modes ==='
	printf '%s\n' "$$LIB" | bash -s -- stage

$(STAMP)/host: $(STAMP)/stage
	echo '=== host: hostname, hosts, and locale ==='
	printf '%s\n' "$$LIB" | bash -s -- host

$(STAMP)/packages: $(STAMP)/host
	echo '=== packages ==='
	printf '%s\n' "$$LIB" | bash -s -- packages

$(STAMP)/kernel: $(STAMP)/packages
	echo '=== kernel: sysctl and firewall ==='
	printf '%s\n' "$$LIB" | bash -s -- kernel

$(STAMP)/unpack: $(STAMP)/kernel disk
	echo '=== unpack ==='
	printf '%s\n' "$$LIB" | bash -s -- unpack

$(STAMP)/credentials: $(STAMP)/unpack
	echo '=== credentials ==='
	printf '%s\n' "$$LIB" | bash -s -- credentials

$(STAMP)/oracle: $(STAMP)/credentials
	echo '=== oracle ==='
	printf '%s\n' "$$LIB" | bash -s -- oracle

$(STAMP)/wizard: $(STAMP)/oracle disk
	echo '=== wizard ==='
	printf '%s\n' "$$LIB" | bash -s -- wizard

$(STAMP)/lsmem: $(STAMP)/wizard
	echo '=== lsmem ==='
	printf '%s\n' "$$LIB" | bash -s -- lsmem

$(STAMP)/sftp: $(STAMP)/lsmem
	echo '=== sftp ==='
	printf '%s\n' "$$LIB" | bash -s -- sftp

$(STAMP)/sudo: $(STAMP)/sftp
	echo '=== sudo ==='
	printf '%s\n' "$$LIB" | bash -s -- sudo

$(STAMP)/service: $(STAMP)/sudo
	echo '=== service ==='
	printf '%s\n' "$$LIB" | bash -s -- service


stage: $(STAMP)/stage
host: $(STAMP)/host
packages: $(STAMP)/packages
kernel: $(STAMP)/kernel
unpack: $(STAMP)/unpack
credentials: $(STAMP)/credentials
oracle: $(STAMP)/oracle
wizard: $(STAMP)/wizard
lsmem: $(STAMP)/lsmem
sftp: $(STAMP)/sftp
sudo: $(STAMP)/sudo
service: $(STAMP)/service

check: $(STAMP)/service disk
	echo '=== check ==='
	printf '%s\n' "$$LIB" | bash -s -- check

