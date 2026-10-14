# Patches for the TWRP source tree

Apply from the TWRP 9.0 tree root (`git -C bootable/recovery apply ...`) before building.

- `0001-bootable-recovery-accept-samsung-fde-footer-magic.patch`: the Samsung/Qualcomm ICE
  FDE of the a6plte writes the crypto footer magic `0xD0B5B1C5` (AOSP uses `0xD0B5B1C4`), so
  TWRP discarded `/data` with "Bad magic for real block device" and never started the stock vold.
- `0002-vold_decrypt-use-twrp-libs-for-vdc_pie-on-android10.patch`: TWRP runs `vdc_pie` (Android 9
  bionic, `/sbin/linker`) with `LD_LIBRARY_PATH=/system/lib64:/system/lib`; on an Android 10 system
  the stock `libc.so` lives in the runtime APEX and cannot be loaded by that linker. For sdk >= 29 use `/sbin`.
- `0003-partitionmanager-remove-stale-userdata-dm-before-vold.patch`: TWRP first tries its own dm-crypt
  decryption, which fails on this QCOM ICE (`req-crypt`) device but leaves an empty `userdata` dm device
  behind; the stock vold then sees an unmanaged device with that name and hangs. Delete it before vold_decrypt.
