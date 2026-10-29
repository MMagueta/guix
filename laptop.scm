(add-to-load-path (dirname (current-filename)))

(use-modules (gnu) (common)
             (nongnu packages linux))
(use-service-modules pm)

(operating-system
  (inherit %base-os)

  ;; The Alder Lake audio (Sound Open Firmware) needs its own firmware, which
  ;; linux-firmware does not ship; without it no sound card shows up at all.
  (firmware (cons sof-firmware (operating-system-firmware %base-os)))

  (services
   (append
    (list
     ;; Battery life.  TLP's defaults already enable PCIe ASPM, runtime PM,
     ;; Wi-Fi power saving and USB autosuspend on battery; on top of that,
     ;; tell the CPU to favour efficiency and skip turbo boost when unplugged.
     (service tlp-service-type
              (tlp-configuration
               (cpu-energy-perf-policy-on-ac "balance_performance")
               (cpu-energy-perf-policy-on-bat "power")
               (cpu-boost-on-ac? #t)
               (cpu-boost-on-bat? #f)))
     (service thermald-service-type)
     ;; Let the "video" group set the backlight, so brightnessctl works
     ;; unprivileged for the Fn brightness keys.
     (udev-rules-service 'brightnessctl
                         (specification->package "brightnessctl"))
     ;; F9 (the notification-centre key) sends KEY_NOTIFICATION_CENTER,
     ;; whose code is above the 247 that X11 can see.  Remap it to PROG3
     ;; (XF86Launch3), which xbindkeys binds to Do Not Disturb.  0x4b is
     ;; its thinkpad_acpi hotkey scancode.
     (udev-hardware-service
      'thinkpad-notification-key
      (udev-hardware "90-thinkpad-notification-key.hwdb"
                     "evdev:name:ThinkPad Extra Buttons:*
 KEYBOARD_KEY_4b=prog3
")))
    (operating-system-user-services %base-os)))

  (swap-devices (list (swap-space
                        (target (uuid
                                 "96b6d745-6944-4b48-a96a-47e35824354d")))))

  (mapped-devices (list (mapped-device
                          (source (uuid
                                   "ffec6209-3303-45c6-bf23-84256c53a8da"))
                          (target "cryptroot")
                          (type luks-device-mapping))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device "/dev/mapper/cryptroot")
                         (type "btrfs")
                         (dependencies mapped-devices))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "1CCC-14ED"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
