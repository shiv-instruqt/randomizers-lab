#!/bin/sh
# Check: exactly LAB_SHARD_COUNT shard keys, each holding the vault host.

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
short=$(labvar LAB_SESSION_SHORT)
n=$(labvar LAB_SHARD_COUNT)
host=$(labvar LAB_VAULT_HOST)
[ -n "$short" ] && [ -n "$n" ] || fail "LAB_SESSION_SHORT / LAB_SHARD_COUNT are not set"

count=$(vault --scan --pattern "shard:$short:*" | grep -c .)
[ "$count" = "$n" ] || fail "found $count keys matching shard:$short:*, expected exactly $n"

i=1
while [ "$i" -le "$n" ]; do
  got=$(vault GET "shard:$short:$i")
  [ "$got" = "$host" ] || fail "shard:$short:$i is '$got', expected '$host'"
  i=$((i + 1))
done
exit 0
