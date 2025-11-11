#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"

PACKAGES_LIST="${SCRIPT_DIR}/config/packages.list"

mkdir -p "$SOURCES_DIR"

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

log "Downloading source packages..."

while read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    
    name=$(echo "$line" | awk '{print $1}')
    version=$(echo "$line" | awk '{print $2}')
    url=$(echo "$line" | awk '{print $3}')
    
    filename=$(basename "$url")
    
    if [[ -f "$SOURCES_DIR/$filename" ]]; then
        log "Already exists: $filename"
        continue
    fi
    
    log "Downloading: $filename"
    wget -q --show-progress -P "$SOURCES_DIR" "$url" || {
        log "Failed to download: $url"
        continue
    }
done < "$PACKAGES_LIST"

log "Download completed"
