#!/bin/bash
cd "$(dirname "$0")"
python3 -m http.server 8080 &
echo "Web GUI running at http://localhost:8080"
echo "Press Ctrl+C to stop"
