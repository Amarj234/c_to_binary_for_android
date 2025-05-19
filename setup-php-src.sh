#!/bin/bash

set -e

# Variables
PHP_VERSION="8.3.6" # You can change to latest stable if needed
PHP_TAR="php-$PHP_VERSION.tar.gz"
PHP_URL="https://www.php.net/distributions/$PHP_TAR"
WORK_DIR="$HOME/php"
SRC_DIR="$WORK_DIR/php-src"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "[*] Downloading PHP $PHP_VERSION..."
if [ ! -f "$PHP_TAR" ]; then
  curl -LO "$PHP_URL"
else
  echo "[*] PHP tarball already exists."
fi

echo "[*] Extracting PHP source..."
rm -rf "$SRC_DIR"
tar -xf "$PHP_TAR"
mv "php-$PHP_VERSION" "$SRC_DIR"

echo "[*] PHP source extracted to: $SRC_DIR"

echo "[*] Preparing build system..."
cd "$SRC_DIR"
./buildconf --force

echo "[*] Done. PHP source ready at $SRC_DIR"
