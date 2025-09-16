#!/usr/bin/env bash
views=$(find lib/views -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | paste -sd ',' -)
echo "Paste this into tasks.json options:"
echo "[${views//,/\", \"}]"
