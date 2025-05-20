#!/bin/bash

# Android NDK version and download URL
NDK_VERSION="r21e"
NDK_DMG_URL="https://dl.google.com/android/repository/android-ndk-r21e-darwin-x86_64.zip"
NDK_DMG_FILE="android-ndk-${NDK_VERSION}-darwin.dmg"
MOUNT_POINT="/Volumes/NDK"

echo "[*] Downloading Android NDK ${NDK_VERSION}..."
if [ -f "$NDK_DMG_FILE" ]; then
    echo "[*] DMG already exists. Skipping download."
else
    curl -L -o "$NDK_DMG_FILE" "$NDK_DMG_URL"
    if [ $? -ne 0 ]; then
        echo "[!] Download failed. Please check your internet connection or URL."
        exit 1
    fi
fi

echo "[*] Mounting DMG..."
hdiutil attach "$NDK_DMG_FILE" -mountpoint "$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "[!] Failed to mount DMG."
    exit 1
fi

echo "[*] Copying NDK to ~/Library/Android/sdk/ndk/${NDK_VERSION} ..."
mkdir -p ~/Library/Android/sdk/ndk
cp -R "${MOUNT_POINT}/android-ndk-${NDK_VERSION}" ~/Library/Android/sdk/ndk/${NDK_VERSION}

echo "[*] Unmounting DMG..."
hdiutil detach "$MOUNT_POINT"

echo "[*] Adding NDK to your PATH..."
SHELL_CONFIG="$HOME/.zshrc"
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

NDK_PATH="$HOME/Library/Android/sdk/ndk/${NDK_VERSION}"
echo "" >> "$SHELL_CONFIG"
echo "# Android NDK ${NDK_VERSION}" >> "$SHELL_CONFIG"
echo "export ANDROID_NDK_HOME=\"$NDK_PATH\"" >> "$SHELL_CONFIG"
echo "export PATH=\"\$ANDROID_NDK_HOME:\$PATH\"" >> "$SHELL_CONFIG"

echo "[*] Setup complete! Restart your terminal or run: source $SHELL_CONFIG"
