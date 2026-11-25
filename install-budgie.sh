#!/bin/sh
# Build and install Budgie 10.10 on top of the GNOME 51 stack from
# install-gnome51.sh, on a runit Void Linux system.
#
# Usage: ./install-budgie.sh [-n] [-d dir]
#   -n      dry run: print the commands instead of running them
#   -d dir  void-packages checkout on the gnome51 branch to use or create
#           (default: current directory if it is one, else ./void-packages)
#
# Copies the Budgie templates from this repository into the checkout, builds
# them as the calling user, and installs them with sudo or doas. Run
# install-gnome51.sh first (or let xbps-src build the GNOME 51 libraries).

set -eu

REPO=https://github.com/mendescotta/void-packages.git
BRANCH=gnome51

# Build order; budgie-desktop depends on the others at runtime. budgie-session
# comes from Void (same version), pulled in as a dependency.
PKGS="budgie-control-center
 budgie-desktop-view budgie-desktop budgie-extras"
# Template directories to copy, including the -devel symlinks.
TEMPLATES="$PKGS budgie-control-center-devel budgie-desktop-devel"

dry=
dir=

while getopts nd: opt; do
	case $opt in
	n) dry=1 ;;
	d) dir=$OPTARG ;;
	*) sed -n '5,8s/^# \{0,1\}//p' "$0"; exit 1 ;;
	esac
done

run() {
	echo "+ $*"
	[ -n "$dry" ] || "$@"
}

if [ "$(id -u)" -eq 0 ]; then
	echo "Run this as a normal user; xbps-src refuses to build as root." >&2
	exit 1
fi

if command -v sudo >/dev/null; then
	asroot=sudo
elif command -v doas >/dev/null; then
	asroot=doas
else
	echo "Need sudo or doas to install packages." >&2
	exit 1
fi

for cmd in git xbps-install realpath; do
	command -v "$cmd" >/dev/null || { echo "Missing $cmd." >&2; exit 1; }
done

here=$(cd "$(dirname "$0")" && pwd)
for p in $TEMPLATES; do
	[ -e "$here/srcpkgs/$p" ] || {
		echo "Missing $here/srcpkgs/$p; run this from a full clone." >&2
		exit 1
	}
done

if [ -z "$dir" ]; then
	if [ -x ./xbps-src ]; then dir=.; else dir=./void-packages; fi
fi

dir=$(realpath -m "$dir")
if [ -e "$dir/.git" ]; then
	run git -C "$dir" fetch "$REPO" "$BRANCH"
	run git -C "$dir" switch "$BRANCH" ||
		run git -C "$dir" switch -c "$BRANCH" FETCH_HEAD
	run git -C "$dir" merge --ff-only FETCH_HEAD
else
	run git clone --branch "$BRANCH" "$REPO" "$dir"
fi

if [ -d "$dir" ]; then
	cd "$dir"
else
	# A dry-run clone does not create the destination.
	echo "+ cd $dir"
fi
# xbps-src puts packages built on a branch other than master in their own repo.
repo=$dir/hostdir/binpkgs/$BRANCH

for p in $TEMPLATES; do
	run rm -rf "srcpkgs/$p"
	run cp -a "$here/srcpkgs/$p" srcpkgs/
done

# budgie-extras links against libraries budgie-desktop provides; xbps-src needs
# their common/shlibs entries.
shlibs=$here/patches/0008-budgie-desktop-add-shlibs.patch
if [ -n "$dry" ] || ! git apply --reverse --check "$shlibs" 2>/dev/null; then
	run git apply "$shlibs"
fi

[ -d masterdir ] || [ -d masterdir-x86_64 ] || run ./xbps-src binary-bootstrap
for pkg in $PKGS; do
	run ./xbps-src pkg "$pkg"
done

run $asroot xbps-install -S --repository="$repo" budgie-desktop budgie-extras

[ -z "$dry" ] || exit 0
cat <<EOF

Installed. Pick "Budgie Desktop" at the login screen. Budgie 10.10 runs on
Wayland with labwc; it has not been tested in a running session yet.
EOF
