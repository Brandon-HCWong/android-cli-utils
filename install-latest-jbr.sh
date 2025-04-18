#!/bin/bash

set -e

# Example: INSTALL_DIR=~/Downloads/jbr ./install-latest-jbr.sh
INSTALL_DIR="${INSTALL_DIR:-$HOME/.jbr}"
GITHUB_API="https://api.github.com/repos/JetBrains/JetBrainsRuntime/releases/latest"

# Options
# - linux-aarch64
# - linux-x64
# - osx-aarch64
# - osx-x64
# - windows-aarch64
# - windows-x64
# Example: EXPECTED_OS_TAG=linux-x64 ./install-latest-jbr.sh
EXPECTED_OS_TAG="${EXPECTED_OS_TAG:-osx-aarch64}"

# ===================================================
# Fetch latest releases
# ===================================================
echo "🔍 [Fetch latest releases] Fetching..."
RELEASES=$(curl -s "$GITHUB_API" \
  | jq -r '.body | strings' \
  | grep 'https://cache-redirector.jetbrains.com/intellij-jbr/jbrsdk-.*\.tar\.gz' \
  | grep -v '_diz' \
  | grep -v 'fastdebug')

if [ -z "$RELEASES" ]; then
    echo "❌ Failed to fetch JetBrains Runtime releases."
    exit 1
fi

echo "✅ [Fetch latest releases] Fetched results:"
while IFS= read -r input; do
    [[ -z "$input" ]] && continue

    # Split line by "|"
    IFS='|' read -ra parts <<< "$input"

    # Extract and trim platform (2nd column)
    platform=$(echo "${parts[1]}" | xargs)

    # Extract URL from 3rd column (inside parentheses)ß
    url=$(echo "${parts[3]}" | grep -Eo 'https://[^ )]+\.tar\.gz')

    echo "    - $platform => $url"
done <<< "$RELEASES"

# ===================================================
# Extract download URL
# ===================================================
echo "🔍 [Extract download URL] Extracting URL for OS $EXPECTED_OS_TAG ..."
expected_download_url=""
while IFS= read -r input; do
    [[ -z "$input" ]] && continue

    # Split line by "|"
    IFS='|' read -ra parts <<< "$input"

    # Extract URL from 3rd column (inside parentheses)
    url=$(echo "${parts[3]}" | grep -Eo 'https://[^ )]+\.tar\.gz')
    if [[ "$url" == *"$EXPECTED_OS_TAG"* ]]; then
        expected_download_url="$url"
        break
    fi
done <<< "$RELEASES"

if [[ -n "$expected_download_url" ]]; then
    echo "✅ [Extract download URL] Found matching download URL: $expected_download_url"
else
    echo "❌ [Extract download URL] No matching download URL found for $EXPECTED_OS_TAG"
    exit 1
fi

# ===================================================
# Installation
# ===================================================
echo "📦 [Install] Check if JetBrains Runtime existed at: $INSTALL_DIR"

if [ -d "$INSTALL_DIR" ] && [ "$(ls -A "$INSTALL_DIR")" ]; then
    echo "    - Existing JetBrains Runtime found at $INSTALL_DIR"
    read -p "    - Do you want to delete it and install a new one? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "    - Removing existing installation..."
        rm -rf "$INSTALL_DIR"/*
    else
        echo "🚫 [Install] Installation canceled by user."
        exit 0
    fi
fi

echo "📦 [Install] Installing to: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
curl -L "$expected_download_url" | tar -xz -C "$INSTALL_DIR" --strip-components=1

echo "✅ [Install] JetBrains Runtime installed successfully!"
