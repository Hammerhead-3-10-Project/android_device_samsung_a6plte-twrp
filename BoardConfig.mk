#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
# Galaxy A6+ (SM-A605FN, a6plte) - TWRP. Valori verificati su firmware A605FNXXU8CVA1
# (header boot.img, PIT A6PLTE_EUR_OPEN.pit, getprop dal telefono). Vedi AGENTS.md.

DEVICE_PATH := device/samsung/a6plte

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Architecture: kernel arm64 ma userspace SOLO 32 bit (abilist armeabi-v7a, niente lib64)
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_USES_64_BIT_BINDER := true


# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := msm8953
TARGET_NO_BOOTLOADER := true

# Platform
TARGET_BOARD_PLATFORM := msm8953
BOARD_USES_QCOM_HARDWARE := true

# Display
TARGET_SCREEN_DENSITY := 420

# Kernel: prebuilt stock = Image.gz-dtb (gzip(Image arm64) + 5 dtb), identico in boot e recovery
# Indirizzi assoluti stock (unpack_bootimg li mostra con base 0): kernel 0x80008000, ramdisk 0x82000000, second 0x80f00000, tags 0x81e00000
# => base 0x80000000 + offset (mkbootimg somma base+offset)
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_SECOND_OFFSET := 0x00f00000
BOARD_KERNEL_TAGS_OFFSET := 0x01e00000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE := console=null androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 enforcing=0 androidboot.selinux=permissive
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
BOARD_BOOT_HEADER_VERSION := 0
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --second_offset $(BOARD_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
# Samsung bootloader may validate these header fields: mirror the stock recovery.img
BOARD_MKBOOTIMG_ARGS += --board SRPQL20D008RU
BOARD_MKBOOTIMG_ARGS += --os_version 10.0.0 --os_patch_level 2021-12
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
# Sorgenti kernel (Samsung opensource, SM-A605G_SEA_QQ) non ancora integrati: per ora solo prebuilt
# TARGET_KERNEL_SOURCE := kernel/samsung/a6plte
# TARGET_KERNEL_CONFIG := a6plte_eur_open_defconfig

# Partitions (da PIT: boot/recovery 32 MiB; system/vendor/odm/cache dimensioni reali)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3313500160
BOARD_VENDORIMAGE_PARTITION_SIZE := 503316480
BOARD_ODMIMAGE_PARTITION_SIZE := 377487360
BOARD_CACHEIMAGE_PARTITION_SIZE := 314572800
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_ODM := odm

# SELinux policy for the recovery domain (permissive)
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# Recovery
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_HAS_NO_SELECT_BUTTON := true


# Hack: prevent anti rollback
PLATFORM_SECURITY_PATCH := 2021-12-01
VENDOR_SECURITY_PATCH := 2021-12-01
PLATFORM_VERSION := 16.1.0

# Crypto: userdata cifrata FDE a blocco (ro.crypto.type=block, AES-256-XTS), keymaster 3.0
# TODO verificare che la decifratura funzioni (serve il blob keymaster e vendor montato)
TW_INCLUDE_CRYPTO := true
# Decrypt /data (FDE, keymaster 3.0 + QSEECom + cryptfs_hw) by running the stock vold and the
# vendor HALs from the recovery. Service names must match the init.recovery.vold_decrypt.<name>.rc
TW_CRYPTO_USE_SYSTEM_VOLD := qseecomd hwservicemanager servicemanager keymaster-3-0 gatekeeper-1-0 cryptfshw-1-0
TW_CRYPTO_SYSTEM_VOLD_MOUNT := vendor
# TODO: needs vendor/qcom cryptfs_hw (libcryptfs_hw), not in the minimal manifest
# TARGET_HW_DISK_ENCRYPTION := true

# TWRP Configuration
TW_THEME := portrait_hdpi
# Keep recovery.img under 30 MiB: heimdall 2.1.0 fails on this bootloader when the upload crosses the first 30 MiB sequence
TW_EXTRA_LANGUAGES := false
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_DEFAULT_LANGUAGE := it
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 365
TW_DEFAULT_BRIGHTNESS := 200
TW_EXCLUDE_DEFAULT_USB_INIT := false
TW_HAS_DOWNLOAD_MODE := true
TW_NO_REBOOT_BOOTLOADER := true
TW_INCLUDE_NTFS_3G := false
RECOVERY_SDCARD_ON_DATA := true
