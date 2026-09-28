#!/bin/sh
# Check: port.txt holds the random_number port, within its declared range.

# --- common helpers (POSIX sh: task scripts are run with `sh -c`) -----------
# labvar NAME: read a LAB_* value from this shell's environment, falling back
# to the container's PID 1 environment (where sandbox.hcl put it).
labvar() {
  eval "_lv=\${$1:-}"
  if [ -z "$_lv" ] && [ -r /proc/1/environ ]; then
    _lv=$(tr '\0' '\n' < /proc/1/environ 2>/dev/null | sed -n "s/^$1=//p" | head -n 1)
  fi
  printf '%s' "$_lv"
}

# vault ARGS...: run redis-cli against the vault, authenticated via
# REDISCLI_AUTH so the password never appears in the process list.
vault() {
  _host=$(labvar LAB_VAULT_HOST); [ -n "$_host" ] || _host=vault
  REDISCLI_AUTH="$(labvar LAB_VAULT_PASSWORD)" \
    redis-cli --no-auth-warning -h "$_host" -p "$(labvar LAB_VAULT_PORT)" --raw "$@"
}

# readfile PATH: file content with CR and surrounding whitespace removed.
readfile() {
  tr -d '\r' < "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -e '/^$/d'
}

fail() { echo "FAIL: $*" >&2; exit 1; }
# ---------------------------------------------------------------------------
expected=$(labvar LAB_VAULT_PORT)
[ -n "$expected" ] || fail "LAB_VAULT_PORT is not set on the workstation"

f=/root/workspace/port.txt
[ -f "$f" ] || fail "$f does not exist"
actual=$(readfile "$f")

case "$actual" in
  ''|*[!0-9]*) fail "port.txt must contain only digits (found '$actual')" ;;
esac

# The range declared in sandbox.hcl (minimum/maximum are inclusive per docs).
[ "$actual" -ge 20000 ] && [ "$actual" -le 29999 ] \
  || fail "$actual is outside the random_number range 20000-29999"

[ "$actual" = "$expected" ] || fail "port.txt says $actual but the vault listens on $expected"
exit 0
