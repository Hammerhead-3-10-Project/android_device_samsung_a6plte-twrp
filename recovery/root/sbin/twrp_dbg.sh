#!/sbin/sh
# Debug helper: periodically write status into /cache (mmcblk0p43) for post-mortem from Android.
M=/dbg
mkdir -p $M
mount -t ext4 /dev/block/mmcblk0p43 $M
echo "started $(date)" > $M/twrp_started.txt
i=0
while [ $i -lt 15 ]; do
  {
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
  } > $M/twrp_status.txt 2>&1
  dmesg > $M/twrp_dmesg.txt 2>&1
  [ -f /tmp/recovery.log ] && cp /tmp/recovery.log $M/twrp_recovery.log
  sync
  i=$((i+1))
  sleep 3
done

# Self-healing end of test: clear the BCB in misc (mmcblk0p24) and reboot into Android,
# so a failed recovery never leaves the phone looping in recovery.
echo "clearing misc and rebooting $(date)" >> $M/twrp_started.txt
dd if=/dev/zero of=/dev/block/mmcblk0p24 bs=1024 count=2 2>> $M/twrp_started.txt
sync
umount $M
setprop sys.powerctl reboot
sleep 5
reboot
