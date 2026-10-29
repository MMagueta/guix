(add-to-load-path (dirname (current-filename)))

(define-module (guix-home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages terminals)  ;; wezterm is here
  #:use-module (gnu packages version-control) ;; git is here
  #:use-module (gnu packages messaging)  ;; signal-desktop is here
  #:use-module (gnu packages pulseaudio) ;; pavucontrol is here
  #:use-module (gnu packages image-viewers) ;; nsxiv is here
  #:use-module (gnu packages lxde)       ;; pcmanfm is here
  #:use-module (gnu packages admin)      ;; fastfetch is here
  #:use-module (gnu packages pdf)        ;; zathura is here
  #:use-module (gnu packages gimp)       ;; gimp is here
  #:use-module (gnu packages readline)   ;; rlwrap is here
  #:use-module (gnu packages curl)       ;; curl is here
  #:use-module (gnu packages shellutils) ;; direnv is here
  #:use-module (gnu packages compression) ;; unzip is here
  #:use-module (gnu packages gnupg)      ;; gnupg is here
  #:use-module (gnu packages shells)     ;; zsh is here
  #:use-module (gnu packages shellutils)     ;; direnv is here
  #:use-module (gnu packages librewolf)
  #:use-module (nonguix) ;; steam is here
  #:use-module (xyz jackfaller discord)
  ; #:use-module (mmagueta packages themes) ;; neutral-nextstep-cursor is here
  #:use-module (gnu packages package-management) ;; nix is here
  #:use-module (gnu services)
  #:use-module (gnu system shadow)  ;; %default-dotguile is here
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages terminals)
  ;#:use-module (gnu packages autotools)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages video)
  #:use-module (gnu packages imagemagick) ;; scales the Emacs dock icon
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services sound) ;; home-pipewire-service-type
  #:use-module (gnu home services shepherd) ;; home-shepherd-service-type
  #:use-module (gnu services shepherd) ;; shepherd-service
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages tor-browsers)
  #:use-module (windowmaker)) ;; classic icons, GNU-logo xscreensaver

(define home-config
  (home-environment
    (packages
      (append
        (list discord
              windowmaker/dock-keeps-side
              windowmaker-classic-icons
              xscreensaver/gnu-logo
              ;; VA-API driver for the Iris Xe GPU, so LibreWolf decodes
              ;; video in hardware instead of on the CPU; see start-session.
              intel-media-driver)
        (specifications->packages
          (list "emacs"
                "alacritty"
                ;; Window Maker itself is windowmaker/dock-keeps-side, above.
                ;; Dockapps.
                "wmclock"
                "wmbattery"
                "wmcpuload"
                "wmnd"
                "wmamixer"
                ;; Lets libX11 theme wmaker's cursors; see start-session.
                "libxcursor"
                "xrdb"
                "xss-lock"
                ;; Spots fullscreen windows; see dotfiles/windowmaker/fullscreen-inhibit.
                "xprop"
                ;; Turns off the X bell; see dotfiles/windowmaker/autostart.
                "xset"
                ;; Closes windows gracefully; see dotfiles/windowmaker/power-off.
                "wmctrl"
                ;; Notification toasts; see dotfiles/dunst/dunstrc.
                "dunst"
                "libnotify"
                ;; Fn-row keys; see dotfiles/windowmaker/xbindkeysrc.
                "xbindkeys"
                "brightnessctl"
                ;; Launcher on Super+Space.
                "rofi"
                "xrandr"
                ;; Region screenshots; see dotfiles/windowmaker/screenshot.
                "maim"
                "xclip"
                "glib:bin"
                "nsxiv"
                "signal-desktop"
                "git"
                "pavucontrol"
                "pcmanfm"
                "fastfetch"
                "gimp"
                "librewolf"
                ;; Thunderbird, as Guix ships it; see the Dock and mimeapps.list.
                "icedove"
                ;"zathura"
                ;"zathura-ps"
                ;"zathura-pdf-poppler"
                ;"zathura-djvu"
                ;"zathura-cb"
                "htop"
                "rlwrap"
                "curl"
                "direnv"
                "unzip"
                "gnupg"
                "zsh"
		"nix"
		;"steam"
		;"arandr"
                ;"postgresql"
                "pinentry-gnome3"
		"openssh"
                "direnv"
                ;"obs"
                ;"libvterm"
		;"libtool"
                ;"emacs-vterm"
                ;"cmake"
                ;"gcc-toolchain"
		;"torbrowser"
))))
    (services
      (append
         (list
          (service home-files-service-type
           `((".guile" ,%default-dotguile)
             (".Xresources" ,(local-file "./dotfiles/windowmaker/Xresources"))
             (".xbindkeysrc" ,(local-file "./dotfiles/windowmaker/xbindkeysrc"))
             ("GNUstep/Defaults/WindowMaker"
              ,(local-file "./dotfiles/windowmaker/WindowMaker"))
             ("GNUstep/Defaults/WMWindowAttributes"
              ,(local-file "./dotfiles/windowmaker/WMWindowAttributes"))
             ("GNUstep/Defaults/WMRootMenu"
              ,(local-file "./dotfiles/windowmaker/WMRootMenu"))
             ;; Scripts need #:recursive? #t to keep their executable bit;
             ;; otherwise wmaker skips autostart and the GDM session launcher
             ;; cannot run start-session.
             ("GNUstep/Library/WindowMaker/autostart"
              ,(local-file "./dotfiles/windowmaker/autostart" #:recursive? #t))
             ("GNUstep/Library/WindowMaker/menu"
              ,(local-file "./dotfiles/windowmaker/menu"))
             ("GNUstep/Library/WindowMaker/power-off"
              ,(local-file "./dotfiles/windowmaker/power-off" #:recursive? #t))
             ("GNUstep/Library/WindowMaker/display-mode"
              ,(local-file "./dotfiles/windowmaker/display-mode" #:recursive? #t))
             ("GNUstep/Library/WindowMaker/fullscreen-inhibit"
              ,(local-file "./dotfiles/windowmaker/fullscreen-inhibit" #:recursive? #t))
             ("GNUstep/Library/WindowMaker/screenshot"
              ,(local-file "./dotfiles/windowmaker/screenshot" #:recursive? #t))
             ("GNUstep/Library/WindowMaker/start-session"
              ,(local-file "./dotfiles/windowmaker/start-session" #:recursive? #t))
             ;; WMState is live state rewritten by wmaker, so start-session
             ;; merges this Dock definition into it on every login.
             ("GNUstep/Library/WindowMaker/Dock"
              ,(local-file "./dotfiles/windowmaker/Dock"))
             ;; Emacs icon (GPLv3, see dotfiles/windowmaker/icons/COPYING),
             ;; scaled to the 60px of the classic set.  ~/GNUstep/Library/Icons
             ;; comes first on IconPath.
             ("GNUstep/Library/Icons/emacs-gnu.png"
              ,(computed-file
                "emacs-gnu.png"
                #~(system* #$(file-append imagemagick "/bin/convert")
                           #$(local-file "./dotfiles/windowmaker/icons/emacs-gnu.png")
                           "-filter" "Lanczos" "-resize" "60x60"
                           #$output)))
             ;; Signal's own icon, scaled down from its 1024px original.
             ("GNUstep/Library/Icons/signal-desktop.png"
              ,(computed-file
                "signal-desktop.png"
                #~(system* #$(file-append imagemagick "/bin/convert")
                           #$(file-append (specification->package "signal-desktop")
                                          "/share/icons/hicolor/1024x1024/apps/signal-desktop.png")
                           "-filter" "Lanczos" "-resize" "60x60"
                           #$output)))
             ("GNUstep/Library/Icons/COPYING"
              ,(local-file "./dotfiles/windowmaker/icons/COPYING"))))

          ;; xscreensaver-settings saves to ~/.xscreensaver, so seed it once as
          ;; a writable file (replacing the read-only store link earlier
          ;; generations installed) and leave it to the GUI afterwards.
          (simple-service
           'xscreensaver-initial-settings
           home-activation-service-type
           #~(let ((settings (string-append (getenv "HOME") "/.xscreensaver")))
               (when (or (not (file-exists? settings))
                         (eq? 'symlink (stat:type (lstat settings))))
                 (when (false-if-exception (lstat settings))
                   (delete-file settings))
                 (copy-file #$(local-file "./dotfiles/windowmaker/xscreensaver")
                            settings)
                 (chmod settings #o644))))

      (service home-gpg-agent-service-type
      (home-gpg-agent-configuration
       (ssh-support? #t)
       (pinentry-program
        (file-append pinentry-gnome3 "/bin/pinentry-gnome3"))

       ;; Optional but useful:
       (default-cache-ttl 28800)
       (max-cache-ttl 86400)
       (default-cache-ttl-ssh 28800)
       (max-cache-ttl-ssh 86400)))

    (simple-service 'gpg-sshcontrol
                    home-files-service-type
                    `((".gnupg/sshcontrol"
                       ,(plain-file "sshcontrol"
                          "9AA3054F8732794A8B33510B5B9E5F9D7211E7B1\n"))))

(service home-bash-service-type
      (home-bash-configuration
       (bashrc
        (list
         (plain-file "gpg-agent-ssh-bashrc"
           "
# Use gpg-agent as ssh-agent
export GPG_TTY=\"$(tty)\"
export SSH_AUTH_SOCK=\"$(gpgconf --list-dirs agent-ssh-socket)\"
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
")))))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("git/config" ,(local-file "./dotfiles/git/config"))
             ("librewolf/librewolf/librewolf.overrides.cfg" ,(local-file "./dotfiles/librewolf/librewolf.overrides.cfg"))
             ("mimeapps.list" ,(local-file "./dotfiles/mimeapps.list"))
             ("fastfetch/config.jsonc" ,(local-file "./dotfiles/fastfetch/config.jsonc"))
	     ("alacritty/alacritty.toml" ,(local-file "./dotfiles/alacritty/alacritty.toml"))
             ("dunst/dunstrc" ,(local-file "./dotfiles/dunst/dunstrc"))
             ("nano/nanorc" ,%default-nanorc)
	     ("nix/nix.conf" ,(local-file "./nix.conf"))
             ("guix/channels.scm" ,(local-file "./channels.scm"))))

          (simple-service 'windowmaker-terminal
                          home-environment-variables-service-type
                          '(("TERMINAL" . "alacritty")
                            ("XCURSOR_THEME" . "Adwaita")
                            ("XCURSOR_SIZE" . "32")))

          ;(simple-service 'hidpi-scale-vars
          ;               home-environment-variables-service-type
          ;               '(("GDK_SCALE"                  . "1")     ;; GTK integer base (prevents double-scale)
          ;                 ("GDK_DPI_SCALE"               . "1.25")  ;; GTK font/DPI fractional scale
          ;                 ("QT_SCALE_FACTOR"             . "1.25")  ;; Qt apps
          ;                 ("QT_AUTO_SCREEN_SCALE_FACTOR" . "0")     ;; disable Qt auto-detection
          ;                 ("XCURSOR_SIZE"                . "30")))

          ;; home-pipewire's shepherd services declare (requirement '(dbus)).
          ;; On GNOME the session bus is already provided by the GDM/GNOME
          ;; session (DBUS_SESSION_BUS_ADDRESS is inherited by this shepherd),
          ;; so we must NOT run home-dbus-service-type -- that would start a
          ;; second bus and override DBUS_SESSION_BUS_ADDRESS, splitting the
          ;; session.  Instead expose a virtual 'dbus service that just marks
          ;; the (inherited) session bus as available.
          (simple-service
           'session-dbus-placeholder
           home-shepherd-service-type
           (list (shepherd-service
                  (documentation
                   "Virtual 'dbus provision: the session bus is supplied by \
the GNOME session; this only satisfies home-pipewire's requirement.")
                  (provision '(dbus))
                  (start #~(const #t))
                  (stop #~(const #f)))))

          ;; PipeWire (with WirePlumber + pipewire-pulse) replaces the classic
          ;; PulseAudio daemon.  Required for Wayland screen sharing: GNOME's
          ;; ScreenCast portal hands the captured video to PipeWire, so without
          ;; a running PipeWire the "pick a screen" dialog does nothing.
          (service home-pipewire-service-type)

)

        %base-home-services))))

home-config
