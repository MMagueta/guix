;;; common.scm --- Everything shared by every machine.
;;;
;;; laptop.scm and desktop.scm inherit from %base-os and only add their own
;;; kernel/firmware bits, services and disks.

(define-module (common)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services xorg)
  #:export (%base-os))

(define %base-os
  (operating-system
    (locale "en_US.utf8")
    (timezone "America/Sao_Paulo")
    (host-name "tane")

    (kernel linux)
    (firmware (list linux-firmware))
    (keyboard-layout
     (keyboard-layout "us" #:options '("ctrl:swapcaps")))

    (users (cons* (user-account
                    (name "mmagueta")
                    (comment "Marcos Magueta")
                    (group "users")
                    (home-directory "/home/mmagueta")
                    (supplementary-groups '("wheel" "netdev" "audio" "video" "kvm")))
                  %base-user-accounts))

    (packages (append (list
                       ;; Fonts to cover all languages.
                       (specification->package "font-google-noto")
                       (specification->package "font-google-noto-emoji")
                       (specification->package "font-sarasa-gothic"))
                      %base-packages))

    (services
     (append
      (list
       (service tor-service-type)
       (service cups-service-type)
       (service gnome-desktop-service-type)

       ;; Offer fractional display scales in GNOME's Wayland session.
       (simple-service 'gnome-fractional-scaling
                       dconf-service-type
                       (list
                        (dconf-profile
                         (name "user")
                         (keyfile
                          (dconf-keyfile
                           (name "00-fractional-scaling")
                           (content
                            '("[org/gnome/mutter]"
                              "experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']")))))))

       (simple-service 'nonguix-substitutes
                       guix-service-type
                       (guix-extension
                        (authorized-keys
                         (list
                          (local-file "./nonguix-substitute.pub")))
                        (substitute-urls
                         (list "https://substitutes.nonguix.org"))))

       (set-xorg-configuration
        (xorg-configuration
         (keyboard-layout keyboard-layout))))

      %desktop-services))

    (bootloader (bootloader-configuration
                  (bootloader grub-efi-bootloader)
                  (targets (list "/boot/efi"))
                  (keyboard-layout keyboard-layout)))

    ;; Placeholder; every machine overrides this with its own disks.
    (file-systems %base-file-systems)))
