(add-to-load-path (dirname (current-filename)))

(use-modules (gnu) (common))
(use-service-modules pm)

(operating-system
  (inherit %base-os)

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
     (service thermald-service-type))
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
