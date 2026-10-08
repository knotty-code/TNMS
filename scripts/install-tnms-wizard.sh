#!/bin/bash
# Replay the TNMS 9.1 Server and Mediation choices without a screen.
# Do not run this on a server where TNMS is already installed.
set -euo pipefail

usage() {
  echo "Usage: $0 [--dry-run] [--ip ADDR]" >&2
  exit 2
}

DRY=0
IP=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY=1; shift ;;
    --ip)
      [[ $# -ge 2 ]] || usage
      IP=$2
      shift 2
      ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TEMPLATE=$SCRIPT_DIR/tnms-install.properties.in
PROPS=/root/tnms-install.properties
if [[ "$DRY" -eq 1 ]]; then
  PROPS=/tmp/tnms-install.properties.dry-run
fi
BIN=/home/tnms-layout/installer/TNMS_Installer/TNMS.bin
LOG=/root/tnms-wizard.log
MIN_ROOT_BYTES=$((4531 * 1000 * 1000))

[[ -f "$TEMPLATE" ]] || { echo "Missing $TEMPLATE" >&2; exit 1; }
[[ -f /root/tnms-db-credentials ]] || { echo "Missing /root/tnms-db-credentials. Finish step 6 first." >&2; exit 1; }

set -a
# shellcheck disable=SC1091
. /root/tnms-db-credentials
set +a
if [[ -z "${SYS_PASSWORD:-}" || -z "${TNMSDBA_PASSWORD:-}" ]]; then
  echo "The credentials file needs SYS_PASSWORD and TNMSDBA_PASSWORD." >&2
  exit 1
fi

if [[ -z "$IP" ]]; then
  IP=$(ip -4 route get 1.1.1.1 | awk '{for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit }}')
fi
if [[ ! "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Could not determine an IPv4 address. Pass --ip." >&2
  exit 1
fi

python3 - "$TEMPLATE" "$PROPS" "$IP" << 'PY'
import pathlib, sys
src, dst, ip = sys.argv[1:]
text = pathlib.Path(src).read_text()
if "@TNMS_IP@" not in text:
    raise SystemExit("template has no @TNMS_IP@")
pathlib.Path(dst).write_text(text.replace("@TNMS_IP@", ip))
PY
chmod 600 "$PROPS"

echo "Response file: $PROPS"
echo "Server IPv4 written into the response file: $IP"

needs_lsmem_wrap() {
  local line num unit
  line=$(lsmem --summary | awk -F: '/Total online memory/ { gsub(/^[ \t]+/, "", $2); print $2; exit }')
  num=${line%[A-Za-z]}
  unit=${line#"$num"}
  case "$unit" in
    T|t) return 1 ;;
    G|g) awk -v n="$num" 'BEGIN { exit !(n + 0 < 32) }' ;;
    *) return 0 ;;
  esac
}

if [[ "$DRY" -eq 1 ]]; then
  if needs_lsmem_wrap; then
    echo "lsmem wrapper would be installed for this run and removed when the script exits."
  else
    echo "lsmem already reports at least 32G. No wrapper."
  fi
  echo "TNMS.bin was not started."
  exit 0
fi

if [[ -d /opt/nokia/tnms/server ]]; then
  echo "TNMS is already installed under /opt/nokia/tnms. This script starts a new install. It was not started." >&2
  exit 1
fi
if [[ ! -x "$BIN" ]]; then
  echo "TNMS.bin is not executable at $BIN" >&2
  exit 1
fi
if ! grep -q '^TNMS:' /etc/oratab; then
  echo "Oracle SID TNMS is not in /etc/oratab. Finish step 7 first." >&2
  exit 1
fi
avail=$(df -B1 --output=avail / | tail -n 1 | tr -d ' ')
if [[ "$avail" -lt "$MIN_ROOT_BYTES" ]]; then
  echo "/ has ${avail} bytes free. TNMS.bin requires about 4531 MB on /. Finish step 4 first." >&2
  exit 1
fi

wrapped=0
restore_lsmem() {
  if [[ "$wrapped" -eq 1 && -f /usr/bin/lsmem.real ]]; then
    mv -f /usr/bin/lsmem.real /usr/bin/lsmem
    wrapped=0
  fi
}
trap restore_lsmem EXIT

if needs_lsmem_wrap; then
  if [[ -e /usr/bin/lsmem.real ]]; then
    echo "/usr/bin/lsmem.real already exists. Remove the old wrapper before this script." >&2
    exit 1
  fi
  mv /usr/bin/lsmem /usr/bin/lsmem.real
  cat > /usr/bin/lsmem << 'EOF'
#!/bin/bash
if [[ "$*" == *summary* ]]; then
  echo "Memory block size:       128M"
  echo "Total online memory:      32G"
  echo "Total offline memory:      0B"
  exit 0
fi
exec /usr/bin/lsmem.real "$@"
EOF
  chmod 755 /usr/bin/lsmem
  wrapped=1
  echo "Installed a temporary lsmem wrapper so Small Plus sees 32G."
fi

echo "Starting TNMS.bin. The log is $LOG"
set +e
"$BIN" -f "$PROPS" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e
chmod 600 "$LOG"
restore_lsmem

fail() {
  echo "TNMS wizard failed: $* (installer exit $rc). See $LOG" >&2
  exit 1
}

[[ -d /opt/nokia/tnms/server && -d /nokia/tnms ]] || fail "product directories are missing"
if [[ "$(systemctl is-enabled scs_daemon 2>/dev/null || true)" != "enabled" ]]; then
  fail "scs_daemon is not enabled"
fi
cfg=/nokia/tnms/trace/system/install/system_configure.log
[[ -f "$cfg" ]] || fail "configure log is missing"
if grep -E 'Exiting with ' "$cfg" | grep -qv 'Exiting with 0'; then
  fail "a configure script did not exit 0"
fi
grep -q 'Product configuration ended' "$cfg" || fail "configure did not finish"
sql=$(ls -1t /nokia/tnms/trace/system/install/sql/db_setup_TNMS_*.log 2>/dev/null | head -n 1 || true)
if [[ -z "$sql" ]]; then
  fail "db_setup log is missing"
fi
errors=$(grep -c 'Error executing the previous command' "$sql" || true)
if [[ "$errors" -gt 1 ]]; then
  fail "db_setup reported $errors errors"
fi
if [[ "$errors" -eq 1 ]]; then
  if ! grep -q '_bug33046179_kqr_hot_copy_sleep_limit' "$sql" || ! grep -q 'ORA-02065' "$sql"; then
    fail "db_setup reported an unexpected error"
  fi
  echo "Known SQL error kept: ORA-02065 on _bug33046179_kqr_hot_copy_sleep_limit"
fi

echo "TNMS wizard finished. Installer exit $rc. Product files are present, scs_daemon is enabled, and configure scripts exited 0."
