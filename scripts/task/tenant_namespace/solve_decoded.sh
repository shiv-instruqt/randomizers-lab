#!/bin/sh
# Solve: decode base64 to hex.

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
mkdir -p /root/workspace
b64=$(labvar LAB_TENANT_B64)
if [ -n "$b64" ]; then
  norm=$(printf '%s' "$b64" | tr -- '-_' '+/')
  while [ $(( ${#norm} % 4 )) -ne 0 ]; do norm="$norm="; done
  printf '%s' "$norm" | base64 -d | od -An -v -tx1 | tr -d ' \n' > /root/workspace/tenant-decoded.txt
else
  labvar LAB_TENANT_HEX > /root/workspace/tenant-decoded.txt
fi
echo >> /root/workspace/tenant-decoded.txt
