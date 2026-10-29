;;; common.scm --- Everything shared by every machine.
;;;
;;; laptop.scm and desktop.scm inherit from %base-os and only add their own
;;; kernel/firmware bits, services and disks.

(define-module (common)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (gnu packages bash)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services xorg)
  #:use-module (gnu system pam)
  #:export (%base-os))

;; GDM can retain the session ID "wmaker" in AccountsService.  The upstream
;; package installs "windowmaker.desktop", so provide the matching alias in
;; the system profile and route it through the Guix Home launcher so cursor
;; resources and the declarative Dock state are loaded before Window Maker.
;; Window Maker itself is not propagated: its own windowmaker.desktop runs
;; bare wmaker, and GDM would keep offering (and remembering) that session.
;;
;; Exec/TryExec must point into the store: GDM checks them as the gdm user,
;; which cannot enter the 0700 home directory and would hide the session.
(define windowmaker-gdm-session
  (package
    (name "windowmaker-gdm-session")
    (version "2")
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((xsessions (string-append #$output "/share/xsessions"))
                (launcher (string-append #$output "/bin/windowmaker-session")))
            (mkdir-p (dirname launcher))
            (call-with-output-file launcher
              (lambda (port)
                (format port "#!~a/bin/sh
session=\"$HOME/GNUstep/Library/WindowMaker/start-session\"
if [ -x \"$session\" ]; then
  exec \"$session\"
fi
exec \"$HOME/.guix-home/profile/bin/wmaker\"~%"
                        #$bash-minimal)))
            (chmod launcher #o555)
            (mkdir-p xsessions)
            (call-with-output-file
                (string-append xsessions "/wmaker.desktop")
              (lambda (port)
                (format port
                        ;; Do not advertise GDM session registration: wmaker
                        ;; does not call RegisterSession over D-Bus, so GDM
                        ;; must use its normal startup timeout fallback.
                        "[Desktop Entry]~%Name=Window Maker (Configured)~%Comment=Window Maker session with Guix Home settings~%Exec=~a~%TryExec=~a~%Type=Application~%DesktopNames=WindowMaker~%"
                        launcher launcher)))))))
    (home-page "https://www.windowmaker.org/")
    (synopsis "GDM session entry for Window Maker")
    (description
     "Provide the wmaker.desktop session identifier expected by GDM and start
Window Maker through the user's Guix Home launcher.")
    (license gpl2+)))

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
                       (specification->package "font-sarasa-gothic")
                       ;; GDM session entry for the saved "wmaker" session ID;
                       ;; Window Maker itself comes from Guix Home.
                       windowmaker-gdm-session)
                      %base-packages))

    (services
     (append
      (list
       (service tor-service-type)
       (service cups-service-type)
       (service gnome-desktop-service-type)
       (simple-service 'xscreensaver-pam
                       pam-root-service-type
                       (list (unix-pam-service "xscreensaver")))

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
