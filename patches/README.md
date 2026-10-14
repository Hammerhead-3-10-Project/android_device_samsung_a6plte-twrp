# Patches for the TWRP source tree

Apply from the TWRP 9.0 tree root (`git -C bootable/recovery apply ...`) before building.

- `0001-bootable-recovery-accept-samsung-fde-footer-magic.patch`: the Samsung/Qualcomm ICE
  FDE of the a6plte writes the crypto footer magic `0xD0B5B1C5` (AOSP uses `0xD0B5B1C4`), so
  TWRP discarded `/data` with "Bad magic for real block device" and never started the stock vold.
- `0003-partitionmanager-remove-stale-userdata-dm-before-vold.patch`: TWRP first tries its own dm-crypt
  decryption, which fails on this QCOM ICE (`req-crypt`) device but leaves an empty `userdata` dm device
  behind; the stock vold then sees an unmanaged device with that name and hangs. Delete it before vold_decrypt.
- `0002-vold_decrypt-run-vdc_pie-with-stock-android10-linker-and-apex.patch`: on an Android 10 system TWRP's
  Android 9 `vdc_pie` could not find the stock vold (the Android 10 servicemanager expects a work-source header
  that the Android 9 libbinder does not send, so `checkService("vold")` returned null and vdc looped for 50 s).
  vold_decrypt now bind-mounts the flattened runtime APEX (`/apex/com.android.runtime`, unmounted afterwards) and
  runs `vdc_pie` through `/apex/com.android.runtime/bin/linker` with the stock `/system/lib` libs.
- `0004-system-vold-IVold-add-android10-methods.patch` (apply in `system/vold`): Android 10 added `addAppIds` and
  `addSandboxIds` before `fdeCheckPassword`; without them vdc_pie called method 27 (`mountAppFuse` in the stock
  vold) instead of 29 (`fdeCheckPassword`).
