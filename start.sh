#!/bin/bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
KEYCLOAK_CONTAINER="keycloak"
KEYCLOAK_URL="http://localhost:2305"

if ! docker ps --filter "name=^${KEYCLOAK_CONTAINER}$" --filter "status=running" --format "{{.Names}}" | grep -q "^${KEYCLOAK_CONTAINER}$"; then
  echo "Keycloak is not running. Start it first with: ./up.sh"
  exit 1
fi

echo "Waiting for Keycloak to be ready..."
until curl -sf "${KEYCLOAK_URL}/realms/master" > /dev/null 2>&1; do
  printf "."
  sleep 3
done
echo " ready."

echo "Running Ansible configuration..."
docker run --rm \
  --network shared_net \
  -v "${DIR}/ansible:/ansible" \
  -e ANSIBLE_CONFIG=/ansible/ansible.cfg \
  alpine/ansible \
  ansible-playbook /ansible/playbooks/configure-keycloak.yml

echo "Done."
