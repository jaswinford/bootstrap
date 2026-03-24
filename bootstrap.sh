#!/usr/bin/env bash
set -euo pipefail

# 1. Ensure Ansible is installed
if ! command -v ansible-playbook &>/dev/null; then
  echo "[install] ansible not found — installing via apt"
  sudo apt-get update -qq
  sudo apt-get install -y ansible
else
  echo "[skip]    ansible already installed"
fi

# 2. Ensure Tailscale is installed and up
if ! command -v tailscale &>/dev/null; then
  echo "[install] tailscale not found — installing via official script"
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "[skip]    tailscale already installed"
fi

if ! ip link show tailscale0 &>/dev/null; then
  echo "[up]      tailscale0 not found — bringing Tailscale up"
  sudo tailscale up
else
  echo "[skip]    tailscale0 already up"
fi

# 3. Install missing Galaxy collections
./install-collections.sh

# 4. Apply the bootstrap playbook, forwarding any extra arguments
ansible-playbook site.yml "$@"
