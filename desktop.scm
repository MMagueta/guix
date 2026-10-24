(add-to-load-path (dirname (current-filename)))

(use-modules (gnu) (common)
             (nongnu packages linux)
             (nongnu system linux-initrd))
(use-service-modules nix ssh)

(operating-system
  (inherit %base-os)

  ;; AMD Radeon RX 9060 XT: load CPU microcode early, ship the amdgpu
  ;; firmware and keep the legacy radeon driver from grabbing the card.
  (initrd microcode-initrd)
  (kernel-arguments
   (append '("modprobe.blacklist=radeon")
           %default-kernel-arguments))
  (firmware (list amdgpu-firmware linux-firmware))

  (services
   (append
    (list
     (service nix-service-type
              (nix-configuration
               (extra-config
                (list "experimental-features = nix-command flakes\n"))))

     (service openssh-service-type
              (openssh-configuration
               (port-number 22)
               (permit-root-login #t))))
    (operating-system-user-services %base-os)))

  (mapped-devices (list (mapped-device
                          (source (uuid
                                   "16f00b91-d71a-4062-8c55-e9834ff48b87"))
                          (target "cryptroot")
                          (type luks-device-mapping))))

  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device "/dev/mapper/cryptroot")
                         (type "btrfs")
                         (dependencies mapped-devices))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "C90B-228D" 'fat32))
                         (type "vfat"))
                       %base-file-systems)))
