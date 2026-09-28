#!/bin/sh
# Workstation entrypoint. Deliberately forgiving: nothing here may stop the
# container from reaching the final `exec`, or the sandbox would fail to start.

mkdir -p /root/workspace 2>/dev/null

# Install the lab-values helper on PATH (a wrapper, so the read-only volume's
# file mode bits don't matter).
cat > /usr/local/bin/lab-values 2>/dev/null <<'EOF'
#!/bin/sh
exec sh /opt/lab/bin/lab-values "$@"
EOF
chmod 755 /usr/local/bin/lab-values 2>/dev/null

# Personalise the shell: the prompt shows your random_creature name.
if ! grep -q 'operation-randomize' /root/.bashrc 2>/dev/null; then
  cat >> /root/.bashrc 2>/dev/null <<'EOF'

# --- operation-randomize ---
PS1='\[\e[1;35m\]${LAB_CREATURE:-workstation}\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
cd /root/workspace 2>/dev/null || true
echo ""
echo "  Operation Randomize - workstation ready."
echo "  Run 'lab-values' to see the random values generated for this sandbox."
echo ""
EOF
fi

exec sleep infinity
