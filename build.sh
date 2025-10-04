#!/bin/sh

PACKAGE="dufs"
REPO="sigoden/dufs"

# Processing again to avoid errors of remote incoming 
VERSION=$(echo $1 | sed -n 's|[^0-9]*\([^_]*\).*|\1|p')

ARCH="amd64 arm64"
AMD64_FILENAME="dufs-v$VERSION-x86_64-unknown-linux-musl.tar.gz"
ARM64_FILENAME="dufs-v$VERSION-aarch64-unknown-linux-musl.tar.gz"

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
    dpkg-deb -b --root-owner-group -Z xz "$BASE_DIR" output
}

get_url_by_arch() {
    DOWNLOAD_PERFIX="https://github.com/$REPO/releases/latest/download"
    case $1 in
    "amd64") echo "$DOWNLOAD_PERFIX/$AMD64_FILENAME" ;;
    "arm64") echo "$DOWNLOAD_PERFIX/$ARM64_FILENAME" ;;
    esac
}

for i in $ARCH; do
    echo "Building $i package..."
    build "$i"
done

# Create repo files
cd output
apt-ftparchive packages . > Packages
apt-ftparchive release . > Release
