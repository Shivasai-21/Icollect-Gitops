#!/usr/bin/env bash

# Sets image.tag for one service in one environment.
#
# Usage:
#   scripts/set-image-tag.sh <service> <tag> [env=dev]
#
# Example:
#   scripts/set-image-tag.sh payment-service 93270542 dev
#
# Used by:
#   - Jenkins (jenkins/update-gitops.sh)
#   - Manual updates

set -euo pipefail

[ $# -ge 2 ] || {
  echo "Usage: $0 <service> <tag> [env]" >&2
  exit 1
}

SERVICE="$1"
TAG="$2"
ENVIRONMENT="${3:-dev}"

FILE="envs/${ENVIRONMENT}/${SERVICE}/values.yaml"

[ -f "$FILE" ] || {
  echo "ERROR: File not found: $FILE" >&2
  exit 1
}

echo "Updating ${FILE}"
echo "Setting image.tag=${TAG}"

# Always store tag as string
sed -i.bak -E "s|^([[:space:]]*tag:[[:space:]]*).*$|\1\"${TAG}\"|" "$FILE"

rm -f "$FILE.bak"

# Verify update succeeded
grep -q "^ *tag: \"${TAG}\"$" "$FILE" || {
  echo "ERROR: Failed to update image tag in $FILE" >&2
  exit 1
}

echo "SUCCESS: ${FILE}: image.tag=\"${TAG}\""

echo ""
echo "Updated image section:"
grep -A2 "^image:" "$FILE"
