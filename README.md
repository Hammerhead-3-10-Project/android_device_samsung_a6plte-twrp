# Device tree TWRP — Samsung Galaxy A6+ (SM-A605FN, `a6plte`)

Base generata da `twrpdtgen` (recovery stock A605FNXXU8CVA1) e corretta a mano.

- SoC: Snapdragon 450 (msm8953), kernel stock 3.18.124 arm64, **userspace solo 32 bit**
- Kernel: prebuilt stock (`prebuilt/kernel` = Image.gz-dtb con 5 dtb Rev00..Rev04)
- Header boot: base 0x0, kernel 0x80008000, ramdisk 0x82000000, second 0x80f00000, tags 0x81e00000, pagesize 2048, header v0
- Partizioni da `A6PLTE_EUR_OPEN.pit`; boot/recovery = 32 MiB
- Userdata cifrata FDE (AES-256-XTS), decifratura ancora da verificare
- Bootloader sbloccato; flash con Heimdall (`heimdall flash --RECOVERY recovery.img`)

Stato: **non ancora compilato né testato sul dispositivo.**
