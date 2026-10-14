# Device tree TWRP — Samsung Galaxy A6+ (SM-A605FN, `a6plte`) — branch `twrp-9.0`

TWRP 3.7.0_9-0 (omni `twrp-9.0` minimal manifest), built in an Ubuntu 18.04 container (Python 2, OpenJDK 8).

## Status (tested on A605FNXXU8CVA1, Android 10 stock, bootloader unlocked)
- Boots, display (backlight node `/sys/class/leds/lcd-backlight`, max 365), touch, adb (root), **MTP** (verified by the user).
- **`/data` decrypts** with the default password (Samsung/Qualcomm ICE FDE, ODE key manager, MDFPP keymaster).
- Kernel: Samsung 3.18.124 built from the A605G opensource release with `SEC_FORCE_PERMISSIVE`
  (`prebuilt/kernel`, SELinux always permissive: the stock kernel keeps enforcing and SIGABRTs TWRP).
- Header: base 0x80000000, kernel 0x8000, ramdisk 0x2000000, tags 0x1e00000, header v0, board `SRPQL20D008RU`, 2021-12.
  Image must stay under 30 MiB (heimdall 2.1.0 fails on this bootloader beyond the first 30 MiB sequence) and
  carries the 528 byte stock `SEANDROIDENFORCE` trailer when flashed.

## Why decryption works (all of it is needed)
1. `patches/0001`: TWRP accepts the Samsung FDE footer magic `0xD0B5B1C5`.
2. `patches/0002`: vold_decrypt mounts the runtime APEX (`/apex/com.android.runtime`) and `apnhlos` on
   `/vendor/firmware_mnt` (keymaster trustlets), runs `vdc_pie` through the stock Android 10 linker, and presents
   the recovery as a `user` build while decrypting.
3. `patches/0003`: removes the empty `userdata` dm device left by TWRP's own failed dm-crypt attempt.
4. `patches/0004` (system/vold): `IVold.aidl` with the Samsung method order (`fdeCheckPassword` = transaction 43).
5. `recovery/root/init.recovery.qcom.rc`: `ro.hardware.keystore/gatekeeper=mdfpp`, `ro.board.platform`, knox props.
6. MTP: `TW_MTP_DEVICE := /dev/usb_mtp_gadget` (Samsung's mtpg node) + `patches/0005` (ffs `MtpDevHandle` honors it).
7. `BoardConfig.mk`: `TW_CRYPTO_USE_SYSTEM_VOLD := qseecomd hwservicemanager servicemanager keymaster-3-0 gatekeeper-1-0 cryptfshw-1-0`,
   `TW_CRYPTO_SYSTEM_VOLD_MOUNT := vendor`, `TWRP_INCLUDE_LOGCAT := true` (+ `recovery/root/init.recovery.vold_decrypt.*.rc`).

Apply the patches with `bash patches/apply.sh <twrp9 tree>`, then `lunch omni_a6plte-eng && mka recoveryimage`.

## Notes
- The phone must run with dm-verity disabled in `boot` (Magisk patch with `KEEPVERITY=false`): TWRP mounts `system`
  read-write and that otherwise triggers `Kernel panic - not syncing: dmv corrupt` on the next Android boot.
- `adb reboot` from this recovery re-enters recovery; use `adb reboot download` + `heimdall print-pit`.
- `recovery/root/sbin/twrp_dbg.sh` is a debug helper (not started by default; it reboots the phone after ~50 s).
