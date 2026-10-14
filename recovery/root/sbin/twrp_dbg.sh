#!/sbin/sh
# Debug helper: collect status/dmesg/recovery.log into /tmp and write it RAW into the
# (empty, 4 MiB) "backup" partition mmcblk0p23 so Android can read it with root afterwards:
#   adb shell su -c 'dd if=/dev/block/mmcblk0p23 bs=1048576 count=4' | tr -d '\000'
# At the end clear the BCB in misc (mmcblk0p24) and reboot to Android.
RAW=/dev/block/mmcblk0p23
OUT=/tmp/dbg.txt
mkdir -p /dbg
{
  echo "== twrp_dbg started $(date)"
  echo "-- mount cache attempt:"
  ls -l /dev/block/mmcblk0p43 /dev/block/mmcblk0p23 /dev/block/mmcblk0p24 2>&1
  mount -t ext4 /dev/block/mmcblk0p43 /dbg 2>&1; echo "mount rc=$?"
} > $OUT 2>&1
i=0
while [ $i -lt 15 ]; do
  {
    cat $OUT | head -c 2000
    echo "== iteration $i $(date)"
    getprop | grep -E "usb|adb|ro.boot|init.svc|sys.boot|ro.hardware"
    echo "-- udc / android_usb"
    ls /sys/class/udc /sys/class/android_usb
    cat /sys/class/android_usb/android0/state /sys/class/android_usb/android0/enable /sys/class/android_usb/android0/functions
    echo "-- graphics / backlight"
    ls /dev/graphics
    cat /sys/class/leds/lcd-backlight/brightness /sys/class/leds/lcd-backlight/max_brightness
    echo "-- processes"
    ps -A | grep -E "recovery|adbd|twrp"
    echo "-- recovery.log"
    [ -f /tmp/recovery.log ] && tail -c 60000 /tmp/recovery.log
    echo "-- dmesg"
    dmesg | tail -c 300000
  } > /tmp/dbg_full.txt 2>&1
  head -c 3900000 /tmp/dbg_full.txt | dd of=$RAW bs=1024 conv=notrunc 2>/dev/null
  sync
  i=$((i+1))
  sleep 3
done
# Self-healing end of test: clear the BCB in misc and reboot to Android
dd if=/dev/zero of=/dev/block/mmcblk0p24 bs=1024 count=2 2>/dev/null
sync
setprop sys.powerctl reboot
sleep 5
reboot
