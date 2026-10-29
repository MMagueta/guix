;;; windowmaker.scm --- Window Maker session artwork not packaged by Guix.

(define-module (windowmaker)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnustep)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages xdisorg)
  #:export (windowmaker/dock-keeps-side
            windowmaker-classic-icons
            xscreensaver/gnu-logo))

(define (wmaker-data-origin suffix hash)
  (origin
    (method url-fetch)
    (uri (string-append "mirror://debian/pool/main/w/wmaker-data/"
                        "wmaker-data_0.9~4.orig" suffix ".tar.gz"))
    ;; '~' is not allowed in store file names.
    (file-name (string-append "wmaker-data-0.9.4" suffix ".tar.gz"))
    (sha256 (base32 hash))))

(define gnu-head
  (origin
    (method url-fetch)
    (uri "https://www.gnu.org/graphics/heckert_gnu.svg")
    (sha256
     (base32 "046awm6x6m79yidn1pj4xy4vlgff1mm5xvibwr9rlkx09h69qabw"))))

;; The 1997-era icon sets collected in Debian's wmaker-data (Vinny, Paul
;; Emsley, Marcelo Magallon, ...) plus the Heckert GNU head, rendered at the
;; same size as the others.  Everything lands in
;; share/WindowMaker/Icons/classic, so Window Maker resolves it as
;; "classic/<name>" once the profile is on IconPath.
(define windowmaker-classic-icons
  (package
    (name "windowmaker-classic-icons")
    (version "0.9.4")
    (source (wmaker-data-origin
             "" "1p86xcc35rsh6kywdinsmi03p4hvqbxjp714pj6isfvxphqamd4n"))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((icons (string-append #$output
                                      "/share/WindowMaker/Icons/classic"))
                (doc (string-append #$output
                                    "/share/doc/windowmaker-classic-icons")))
            (setenv "PATH" (string-append #$gzip "/bin"))
            (mkdir-p "src")
            (for-each (lambda (tarball)
                        (invoke #$(file-append tar "/bin/tar")
                                "xzf" tarball "-C" "src"))
                      (list #$source
                            #$(wmaker-data-origin
                               "-iconsMarcelo"
                               "0sfbfxkfc5ywfy9h4q5s0nax8znn1aavcc812bw818nijnnwba5r")
                            #$(wmaker-data-origin
                               "-iconsPaul"
                               "1id0vj3cdlmy7xgzw0nzmqmsdb6cpg36mga9lx7vcz7wmrzvqxbd")))
            (for-each (lambda (tif) (install-file tif icons))
                      (find-files "src" "\\.tif$"))
            ;; The sets are drawn at 48px, which leaves a wide margin in a
            ;; 64px IconSize tile.  Window Maker shrinks icons but never
            ;; enlarges them, so enlarge them here to the 61px it shrinks
            ;; bigger ones to, rounded down to 60.
            (apply invoke #$(file-append imagemagick "/bin/mogrify")
                   "-filter" "Lanczos" "-resize" "60x60"
                   (find-files icons "\\.tif$"))
            (invoke #$(file-append librsvg "/bin/rsvg-convert")
                    "--keep-aspect-ratio" "--width" "60" "--height" "60"
                    #$gnu-head "--output" (string-append icons "/gnu-head.png"))
            (install-file (car (find-files "src" "^copyright$")) doc)))))
    (home-page "https://packages.debian.org/sid/wmaker-data")
    (synopsis "Classic late-1990s Window Maker icons")
    (description
     "This package provides the icon sets from Debian's wmaker-data, drawn
for Window Maker and AfterStep in the late 1990s, together with the GNU
head.")
    (license (list license:gpl2 license:gpl1+ license:cc-by-sa2.0))))

;; xscreensaver always draws its logo (a flame on a monitor) in the lock
;; dialog, compiled in from XPM images; no setting hides it.  Regenerate
;; those images as the GNU head in white.  Its parser only accepts one
;; character per pixel, so use two colours: white and transparent.
(define xscreensaver/gnu-logo
  (package/inherit xscreensaver
    (arguments
     (substitute-keyword-arguments (package-arguments xscreensaver)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'unpack 'use-white-gnu-head-logo
              (lambda _
                (for-each
                 (lambda (size)
                   (let ((xpm (string-append "utils/images/logo-" size ".xpm")))
                     (invoke #$(file-append librsvg "/bin/rsvg-convert")
                             "--keep-aspect-ratio" "--width" size "--height" size
                             #$gnu-head "--output" "gnu-head.png")
                     (invoke #$(file-append imagemagick "/bin/convert")
                             "gnu-head.png" "-background" "none"
                             "-gravity" "center"
                             "-extent" (string-append size "x" size)
                             "-channel" "A" "-threshold" "50%" "+channel"
                             "-fill" "white" "-colorize" "100%" xpm)
                     ;; logo.c includes these by their original names.
                     (substitute* xpm
                       (("^static const char \\*[^[]*\\[\\]")
                        (string-append "static const char * const logo_"
                                       size "_xpm[]")))))
                 '("50" "180" "360"))))))))))

;; Window Maker restarts on every screen change, such as plugging in an
;; external display, and puts the Dock back on whichever side of the new
;; screen (or primary head, with KeepDockOnPrimaryHead) its old absolute x
;; position is nearer to.  Growing the screen or moving the primary head
;; thus throws a right-hand Dock to the left.  Keep it on the right always.
(define windowmaker/dock-keeps-side
  (package/inherit windowmaker
    (arguments
     (substitute-keyword-arguments (package-arguments windowmaker)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'unpack 'keep-dock-on-the-right
              (lambda _
                (substitute* "src/dock.c"
                  (("if \\(dock->x_pos < midpoint\\)")
                   "if (False)"))))))))))
