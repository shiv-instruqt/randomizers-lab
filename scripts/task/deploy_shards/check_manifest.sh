#!/bin/sh
# Check: manifest.env carries the public values and leaks no secret.

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
f=/root/workspace/manifest.env
[ -f "$f" ] || fail "$f does not exist"

has() {
  # has KEY VALUE: accepts KEY=v, KEY="v", KEY='v', optionally prefixed by export
  tr -d '\r' < "$f" | grep -Eq "^[[:space:]]*(export[[:space:]]+)?$1=[\"']?$2[\"']?[[:space:]]*$" \
    || fail "manifest.env has no line $1=$2"
}

has VAULT_HOST "$(labvar LAB_VAULT_HOST)"
has VAULT_PORT "$(labvar LAB_VAULT_PORT)"
has SESSION_ID "$(labvar LAB_SESSION_ID)"
has TENANT_ID  "$(labvar LAB_TENANT_HEX)"

pw=$(labvar LAB_VAULT_PASSWORD)
pin=$(labvar LAB_VAULT_PIN)
if [ -n "$pw" ] && grep -qF -- "$pw" "$f"; then
  fail "manifest.env contains the vault password - secrets must never go in a manifest"
fi
if [ -n "$pin" ] && grep -Eq "(^|[^0-9])$pin([^0-9]|\$)" "$f"; then
  fail "manifest.env contains the vault PIN - secrets must never go in a manifest"
fi
exit 0
