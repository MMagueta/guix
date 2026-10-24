#!/bin/sh
# Usage: ./guix.sh laptop|desktop
set -e
machine="$1"
case "$machine" in
  laptop|desktop) ;;
  *) echo "usage: $0 laptop|desktop" >&2; exit 1 ;;
esac

substitute_urls="https://substitutes.nonguix.org https://bordeaux.guix.gnu.org https://ci.guix.gnu.org"
# Leave memory for large C++ builds such as WebKit and Qt.
set -- --cores=4 --max-jobs=1 --substitute-urls="$substitute_urls"

sudo guix archive --authorize < nonguix-substitute.pub
guix pull "$@"
sudo guix system reconfigure "$@" "$machine.scm"
guix home reconfigure "$@" home.scm
