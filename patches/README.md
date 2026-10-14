# Patches for the TWRP source tree

Apply from the TWRP 9.0 tree root (`git -C bootable/recovery apply ...`) before building.

- `0001-bootable-recovery-accept-samsung-fde-footer-magic.patch`: the Samsung/Qualcomm ICE
  FDE of the a6plte writes the crypto footer magic `0xD0B5B1C5` (AOSP uses `0xD0B5B1C4`), so
  TWRP discarded `/data` with "Bad magic for real block device" and never started the stock vold.
