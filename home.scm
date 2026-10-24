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
  ;; #:use-module (evil packages discord)
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
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services sound) ;; home-pipewire-service-type
  #:use-module (gnu home services shepherd) ;; home-shepherd-service-type
  #:use-module (gnu services shepherd) ;; shepherd-service
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages tor-browsers))

(define home-config
  (home-environment
    (packages
      (append
        (list discord)
        (specifications->packages
          (list "emacs"
                "alacritty"
                "signal-desktop"
                "git"
                "pavucontrol"
                ;"nsxiv"
                ;"pcmanfm"
                "fastfetch"
                ;"gimp"
                "librewolf"
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
           `((".guile" ,%default-dotguile)))

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
             ("fastfetch/config.jsonc" ,(local-file "./dotfiles/fastfetch/config.jsonc"))
	     ("alacritty/alacritty.toml" ,(local-file "./dotfiles/alacritty/alacritty.toml"))
             ("nano/nanorc" ,%default-nanorc)
	     ("nix/nix.conf" ,(local-file "./nix.conf"))
             ("guix/channels.scm" ,(local-file "./channels.scm"))))

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
