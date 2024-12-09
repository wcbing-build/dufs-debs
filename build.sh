#!/bin/sh

PACKAGE="dufs"
REPO="sigoden/dufs"

VERSION="$(cat tag)"

ARCH="amd64 arm64"
AMD64_FILENAME="dufs-v$VERSION-x86_64-unknown-linux-musl.tar.gz"
ARM64_FILENAME="dufs-v$VERSION-aarch64-unknown-linux-musl.tar.gz"

get_url_by_arch() {
    case $1 in
    "amd64") echo "https://github.com/$REPO/releases/latest/download/$AMD64_FILENAME" ;;
    "arm64") echo "https://github.com/$REPO/releases/latest/download/$ARM64_FILENAME" ;;
    esac
}

build() {
    # Prepare
    BASE_DIR="$PACKAGE"_"$VERSION"-1_"$1"
    cp -r templates "$BASE_DIR"
    sed -i "s/Architecture: arch/Architecture: $1/" "$BASE_DIR/DEBIAN/control"
    sed -i "s/Version: version/Version: $VERSION-1/" "$BASE_DIR/DEBIAN/control"
    # Download and move file
    curl -sLo "$BASE_DIR/usr/share/doc/dufs/CHANGELOG.md" "https://raw.githubusercontent.com/sigoden/dufs/refs/heads/main/CHANGELOG.md"
    curl -sLo "$PACKAGE-$1.tar.gz" "$(get_url_by_arch $1)"
    tar -xzf "$PACKAGE-$1.tar.gz"
    mv "$PACKAGE" "$BASE_DIR/usr/bin/$PACKAGE"
    chmod 755 "$BASE_DIR/usr/bin/$PACKAGE"
    # Build
    dpkg-deb --build --root-owner-group "$BASE_DIR"
}

for i in $ARCH; do
    echo "Building $i package..."
    build "$i"
done

# Create repo files
apt-ftparchive packages . > Packages
apt-ftparchive release . > Release
