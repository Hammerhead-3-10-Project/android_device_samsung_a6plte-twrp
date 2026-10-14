#!/usr/bin/env bash
# Apply the TWRP source patches of the a6plte device tree to a clean twrp-9.0 (omni minimal manifest) tree.
# Usage: bash device/samsung/a6plte/patches/apply.sh [path/to/twrp9]   (default: current directory)
set -euo pipefail
T="${1:-.}"; P="$(cd "$(dirname "$0")" && pwd)"
apply() { # <project dir> <patch file>
  if git -C "$T/$1" apply --check "$P/$2" 2>/dev/null; then git -C "$T/$1" apply "$P/$2" && echo "applied $2"
  elif git -C "$T/$1" apply --check -R "$P/$2" 2>/dev/null; then echo "already applied $2"
  else echo "CANNOT apply $2 in $1"; exit 1; fi
}
apply bootable/recovery 0001-bootable-recovery-accept-samsung-fde-footer-magic.patch
apply bootable/recovery 0002-vold_decrypt-run-vdc_pie-with-stock-android10-linker-and-apex.patch
apply bootable/recovery 0003-partitionmanager-remove-stale-userdata-dm-before-vold.patch
apply system/vold      0004-system-vold-IVold-samsung-android10-method-order.patch
apply bootable/recovery 0005-mtp-ffs-honor-TW_MTP_DEVICE-in-MtpDevHandle.patch
