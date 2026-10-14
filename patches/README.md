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
- `0004-system-vold-IVold-samsung-android10-method-order.patch` (apply in `system/vold`): the stock Samsung vold
  of the A605FN has a different `IVold` method order than AOSP 9/10 (Android 10 added `addAppIds` and
  `addSandboxIds`; Samsung added 11 `asec*` calls, `runIdleDefrag` and two `...ServiceSnsDataRedirect`).
  `fdeCheckPassword` is transaction 43 there (29 in AOSP 10, 27 in AOSP 9). Without this vdc_pie called
  `mountAppFuse`/`asecList`. The table was read from `IVold$Stub` in `framework.jar` with `tools/dex_ivold.py`.

  The same patch also presents the recovery as a `user` build (`ro.build.type=user`, `ro.debuggable=0`) while
  vold_decrypt runs (libresetprop override, restored afterwards): Samsung's sKeymaster only gives the Root of Trust
  to the secure world on user builds and otherwise logs "invalid rot just set 0".
  And it mounts the apnhlos partition on `/vendor/firmware_mnt` (read-only, like `init.target.rc`) so the Samsung
  MDFPP keymaster can load its trustlet (`image/skeymast*`); otherwise `QSEECom_start_app` fails with -49.
