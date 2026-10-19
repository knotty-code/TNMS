# TNMS 9.1 install without this repository.
# Copy this file to /tmp with the wizard, the properties file, and the three zip files.
# The shell program is in LIB. Site values are exported into that program.
# The customer mounts the 1 TB disk and creates the 18 GiB swap file.
# stage creates the product directories and the /nokia and /oradata binds.

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
SYS_PASSWORD ?= TnZT5hgW8Zwsp79
SYSTEM_PASSWORD ?= TnZT5hgW8Zwsp79
TNMSDBA_PASSWORD ?= Tnc25xQ36XBUa9
TNMS_SFTP_PASSWORD ?= Tsvb5-Xe8ou3wR9

export THIS_MAKEFILE STAMP
export TNMS_HOSTNAME TNMS_IP TNMS_ADMIN_GROUP TNMS_SID
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
TARGET_ROOT=$$((8 * 1024 * 1024 * 1024))
TARGET_TMP=$$((16 * 1024 * 1024 * 1024))
HOME_HUGE=$$((100 * 1024 * 1024 * 1024))
MIN_DATA=$$((100 * 1000 * 1000 * 1000))

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
  # --target walks up to the filesystem that holds path. Without it,
  # findmnt 2.32 only matches a path that is itself a mountpoint, so
  # /opt/oracle looks missing even though it is on the /opt volume.
  opt_src=$$(findmnt -n -o SOURCE --target /opt)
  src=$$(findmnt -n -o SOURCE --target "$$path" 2>/dev/null || true)
  [[ "$$src" == "$$opt_src" || "$$src" == "$$opt_src"* ]]
}

disk_ok() {
  local bad=0 path
  storage_ok || bad=1
  for path in /opt/oracle /opt/nokia /opt/tnms-install /nokia /oradata; do
    on_data_disk "$$path" || { echo "disk: $$path is not on the /opt volume" >&2; bad=1; }
  done
  for path in /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3 "$$MEDIA"; do
    [[ -d "$$path" ]] || { echo "disk: missing $$path" >&2; bad=1; }
  done
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

dir_not_hiding() {
  local path=$$1
  [[ -e "$$path" ]] || return 0
  if [[ ! -d "$$path" ]]; then
    echo "dirs: $$path exists and is not a directory" >&2
    return 1
  fi
  if findmnt -n "$$path" >/dev/null; then
    return 0
  fi
  if find "$$path" -mindepth 1 -print -quit | grep -q .; then
    echo "dirs: $$path is not a mount and is not empty. It was not covered with a bind." >&2
    return 1
  fi
}

ensure_bind() {
  local src=$$1 dest=$$2 kind=$$3 src_now
  install -d -o root -g root -m 755 "$$src"
  dir_not_hiding "$$dest" || return 1
  if findmnt -n "$$dest" >/dev/null; then
    on_data_disk "$$dest" || { echo "dirs: $$dest is not on the /opt volume" >&2; return 1; }
  else
    install -d -o root -g root -m 755 "$$dest"
    echo "dirs: mount --bind $$src $$dest"
    mount --bind "$$src" "$$dest"
  fi
  src_now=$$(findmnt -n -o SOURCE "$$dest" 2>/dev/null || true)
  if [[ "$$kind" == nokia && "$$src_now" != *"[/tnms-data]"* ]]; then
    echo "dirs: $$dest source is '$${src_now:-empty}'" >&2
    return 1
  fi
  if [[ "$$kind" == oradata && "$$src_now" != *"[/oradata]"* ]]; then
    echo "dirs: $$dest source is '$${src_now:-empty}'" >&2
    return 1
  fi
  if ! fstab_has "$$kind" ""; then
    echo "dirs: appending $$src $$dest to /etc/fstab"
    printf '%s %s none bind,nofail 0 0\n' "$$src" "$$dest" >> /etc/fstab
    FSTAB_CHANGED=1
  fi
}

ensure_dirs() {
  local rc=0
  FSTAB_CHANGED=0
  echo "dirs: /opt/oracle /opt/nokia /opt/tnms-data /opt/oradata"
  install -d -o root -g root -m 755 /opt/oracle /opt/nokia /opt/tnms-data
  install -d -o root -g root -m 755 /opt/oradata/ora1 /opt/oradata/ora2 /opt/oradata/ora3
  ensure_bind /opt/tnms-data /nokia nokia || rc=1
  if [[ "$$rc" -eq 0 ]]; then
    ensure_bind /opt/oradata /oradata oradata || rc=1
  fi
  if [[ "$$FSTAB_CHANGED" -eq 1 ]]; then
    systemctl daemon-reload
  fi
  [[ "$$rc" -eq 0 ]] || return 1
  echo "dirs: restorecon /opt /opt/oracle /opt/nokia /opt/tnms-data /opt/oradata"
  restorecon -F /opt /opt/oracle /opt/nokia
  restorecon -RF /opt/tnms-data /opt/oradata
  if [[ -f /opt/swapfile ]]; then
    chcon -t swapfile_t /opt/swapfile
  fi
  echo "dirs: done"
}

stage_main() {
  require_root
  preflight_ok || exit 1
  print_storage
  if ! storage_base_ok; then
    echo "storage: the data disk is not ready. Finish prepare.md, including the /opt line in /etc/fstab. No directory was created." >&2
    exit 1
  fi
  ensure_dirs || exit 1
  if ! storage_ok; then
    echo "storage: product directories and binds are in place. Finish the swap file in prepare.md. No install file was copied." >&2
    exit 1
  fi
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
  print_storage
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
  print_storage
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
  for name in stage host packages kernel unpack credentials oracle wizard lsmem sftp sudo service; do
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
  local dir
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
  printf '%b\n' '\043 UUID=abc /opt xfs defaults,nofail 0 0' > "$$dir/fstab"
  if fstab_has opt abc "$$dir/fstab"; then
    echo "self-test: a comment was treated as an fstab mount" >&2
    exit 1
  fi
  printf '%s\n' 'UUID=abc /opt xfs defaults,nofail 0 0' '/opt/tnms-data /nokia none bind,nofail 0 0' >> "$$dir/fstab"
  fstab_has opt abc "$$dir/fstab"
  fstab_has nokia "" "$$dir/fstab"
  if home_is_huge 1073741824; then
    echo "self-test: 1 GiB home was huge" >&2
    exit 1
  fi
  home_is_huge "$$HOME_HUGE" || { echo "self-test: huge home was accepted" >&2; exit 1; }
  mkdir -p "$$dir/empty" "$$dir/full"
  touch "$$dir/full/x"
  dir_not_hiding "$$dir/empty"
  if dir_not_hiding "$$dir/full" 2>/dev/null; then
    echo "self-test: a non-empty directory was accepted for a bind" >&2
    exit 1
  fi
  rm -rf "$$dir"
  echo "self-test: ok"
}

lv_bytes() {
  local raw
  raw=$$(lvs --noheadings --nosuffix --units b -o lv_size "$$1" 2>/dev/null | awk '{ print $$1 }') || return 1
  [[ $$raw =~ ^[0-9]+$$ ]] || return 1
  printf '%s\n' "$$raw"
}

home_is_huge() {
  local b=$$1
  [[ $$b =~ ^[0-9]+$$ ]] || return 1
  [[ $$b -ge $$HOME_HUGE ]]
}

swap_is_ready() {
  local page usable
  # swapon --bytes reports the usable size. mkswap keeps the first page
  # for the header, so an 18 GiB file shows 4096 bytes less.
  page=$$(getconf PAGESIZE 2>/dev/null || printf '%s\n' 4096)
  [[ $$page =~ ^[0-9]+$$ ]] || page=4096
  usable=$$((SWAP_BYTES - page))
  swapon --show=NAME,SIZE --bytes --noheadings 2>/dev/null | awk -v n="/opt/swapfile" -v full="$$SWAP_BYTES" -v usable="$$usable" '
    $$1 == n && ($$2 == full || $$2 == usable) { found = 1 }
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
  if [[ -f /opt/swapfile ]]; then
    context_has /opt/swapfile swapfile_t || return 1
  fi
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

print_mount_row() {
  local path=$$1 src size avail
  src=$$(findmnt -n -o SOURCE "$$path" 2>/dev/null || true)
  size=$$(df -h --output=size "$$path" 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  avail=$$(df -h --output=avail "$$path" 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  printf '  %-10s %-40s %8s %8s free\n' "$$path" "$${src:-missing}" "$${size:-unknown}" "$${avail:-unknown}"
}

print_storage() {
  local swap
  echo "storage:"
  print_mount_row /
  print_mount_row /tmp
  print_mount_row /home
  print_mount_row /opt
  print_mount_row /nokia
  print_mount_row /oradata
  swap=$$(swapon --show=NAME,SIZE --noheadings 2>/dev/null | awk '$$1 == "/opt/swapfile" { print $$2; exit }' || true)
  if [[ -n $$swap ]]; then
    printf '  %-10s %-40s %8s\n' swap /opt/swapfile "$$swap"
  else
    printf '  %-10s %-40s %8s\n' swap missing missing
  fi
}

storage_base_ok() {
  local bad=0 src bytes root_b tmp_b home_b opts uuid
  src=$$(findmnt -n -o SOURCE /opt 2>/dev/null || true)
  if [[ $$src != /dev/mapper/datavg-optlv ]]; then
    echo "storage: /opt source is '$${src:-empty}'. Required /dev/mapper/datavg-optlv." >&2
    bad=1
  fi
  bytes=$$(df -B1 --output=size /opt 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  if [[ ! $$bytes =~ ^[0-9]+$$ || $$bytes -lt $$MIN_DATA ]]; then
    echo "storage: /opt is $${bytes:-unknown} bytes. Required at least 100 GB." >&2
    bad=1
  fi
  root_b=$$(lv_bytes /dev/rootvg/rootlv || true)
  if [[ ! $$root_b =~ ^[0-9]+$$ || $$root_b -lt $$TARGET_ROOT ]]; then
    echo "storage: rootlv is '$${root_b:-unknown}'. Required at least 8 GiB." >&2
    bad=1
  fi
  tmp_b=$$(lv_bytes /dev/rootvg/tmplv || true)
  if [[ ! $$tmp_b =~ ^[0-9]+$$ || $$tmp_b -lt $$TARGET_TMP ]]; then
    echo "storage: tmplv is '$${tmp_b:-unknown}'. Required at least 16 GiB." >&2
    bad=1
  fi
  opts=$$(findmnt -no OPTIONS /tmp 2>/dev/null || true)
  if [[ $$opts == *noexec* ]]; then
    echo "storage: /tmp is mounted noexec." >&2
    bad=1
  fi
  if [[ ! -d /opt/nokia/tnms/server ]]; then
    bytes=$$(df -B1 --output=avail / 2>/dev/null | tail -n 1 | tr -d ' ' || true)
    if [[ ! $$bytes =~ ^[0-9]+$$ || $$bytes -lt $$MIN_ROOT_BYTES ]]; then
      echo "storage: / has $${bytes:-unknown} bytes free. TNMS.bin needs about 4531 MB." >&2
      bad=1
    fi
  fi
  src=$$(findmnt -n -o SOURCE /home 2>/dev/null || true)
  if [[ $$src == *datavg* ]]; then
    echo "storage: /home is on $${src}. The data disk was added to the home volume." >&2
    bad=1
  fi
  home_b=$$(df -B1 --output=size /home 2>/dev/null | tail -n 1 | tr -d ' ' || true)
  if [[ $$home_b =~ ^[0-9]+$$ ]] && home_is_huge "$$home_b"; then
    echo "storage: /home is $$home_b bytes. A terabyte-scale /home means the data disk was added to homelv." >&2
    bad=1
  fi
  uuid=$$(blkid -s UUID -o value /dev/datavg/optlv 2>/dev/null || true)
  if ! fstab_has opt "$$uuid"; then
    echo "storage: /etc/fstab has no /opt line for datavg." >&2
    bad=1
  fi
  return "$$bad"
}

storage_ok() {
  local bad=0 src uuid
  storage_base_ok || bad=1
  if [[ "$$bad" -ne 0 ]]; then
    return 1
  fi
  src=$$(findmnt -n -o SOURCE /nokia 2>/dev/null || true)
  if [[ $$src != *"[/tnms-data]"* ]]; then
    echo "storage: /nokia source is '$${src:-empty}'. Required the bind from /opt/tnms-data." >&2
    bad=1
  fi
  src=$$(findmnt -n -o SOURCE /oradata 2>/dev/null || true)
  if [[ $$src != *"[/oradata]"* ]]; then
    echo "storage: /oradata source is '$${src:-empty}'. Required the bind from /opt/oradata." >&2
    bad=1
  fi
  if ! swap_is_ready; then
    echo "storage: /opt/swapfile is not an 18 GiB swap." >&2
    bad=1
  fi
  uuid=$$(blkid -s UUID -o value /dev/datavg/optlv 2>/dev/null || true)
  if ! fstab_has nokia "$$uuid"; then
    echo "storage: /etc/fstab has no /nokia bind." >&2
    bad=1
  fi
  if ! fstab_has oradata "$$uuid"; then
    echo "storage: /etc/fstab has no /oradata bind." >&2
    bad=1
  fi
  if ! fstab_has swap "$$uuid"; then
    echo "storage: /etc/fstab has no /opt/swapfile line." >&2
    bad=1
  fi
  if ! labels_ok; then
    echo "storage: SELinux labels are not usr_t on /opt and swapfile_t on /opt/swapfile." >&2
    bad=1
  fi
  return "$$bad"
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
  self-test) self_test ;;
  *)
    echo "Unknown installer command: $${cmd:-empty}" >&2
    exit 2
    ;;
esac
endef
export LIB

.PHONY: all help status script self-test stage host packages kernel disk unpack credentials oracle wizard lsmem sftp sudo service check

all: check

help:
	cat <<-'EOF'
	TNMS 9.1 install. Run as root after prepare.md.

	  dnf -y install make
	  make -C /tmp -f Makefile

	  make status       read-only report of storage and the install conditions
	  make disk         read-only storage check
	  make check        finish any step that is not done, then run the checks
	  make <target>     run through that step

	Install targets:
	  stage host packages kernel disk unpack credentials oracle wizard lsmem sftp sudo service check

	stage creates /opt/tnms-data, /opt/oradata, the ora directories, and the
	/nokia and /oradata binds when /opt is the 1 TB datavg volume. It stops
	before creating a directory when that volume, /tmp, or / is not ready.
	It creates the directories and then stops before copying install files
	when the 18 GiB swap file is missing. Stamps live in /var/lib/tnms-install.
	disk, check, and status always run. The other stamped targets skip work
	that is already done. Oracle and the TNMS wizard still run only when the
	product is absent.

	Overrides (command line or /root/tnms-install.local.mk):
	  TNMS_HOSTNAME TNMS_IP TNMS_ADMIN_GROUP TNMS_SID
	  SYS_PASSWORD SYSTEM_PASSWORD TNMSDBA_PASSWORD TNMS_SFTP_PASSWORD

	self-test checks the sshd edit and the fstab comment skip.
	EOF

script:
	printf '%s\n' "$$LIB"

self-test:
	printf '%s\n' "$$LIB" | bash -s -- self-test

status:
	echo '=== status (read-only) ==='
	printf '%s\n' "$$LIB" | bash -s -- status

disk:
	echo '=== disk (read-only) ==='
	printf '%s\n' "$$LIB" | bash -s -- disk

$(STAMP)/stage:
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

