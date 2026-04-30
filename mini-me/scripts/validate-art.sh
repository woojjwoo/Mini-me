#!/usr/bin/env bash
# Validates a pixel art PNG against Mini Me art spec.
# Usage: bash mini-me/scripts/validate-art.sh <image.png>
# Exits 0 = PASS, 1 = FAIL.
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Usage: validate-art.sh <image.png>" >&2
    exit 1
fi

PASS=true

# sips outputs: "<filepath>\n  key: value" — use tail + awk to extract value only
sips_get() { sips -g "$1" "$2" 2>/dev/null | tail -1 | awk '{print $2}'; }

# --- Format check ---
FMT=$(sips_get format "$FILE")
if [[ "$FMT" != "png" ]]; then
    echo "❌  Format: expected png, got $FMT"
    PASS=false
else
    echo "✅  Format: png"
fi

# --- Dimension check ---
# Allowed sizes (paired):
#   Furniture / room items: 32×32, 64×64, 128×128
#   Mini Me character poses (widget pivot): 192×320
#   Scene backgrounds (widget pivot):       246×246
W=$(sips_get pixelWidth  "$FILE")
H=$(sips_get pixelHeight "$FILE")
DIMS_OK=false
DIM_KIND=""
if   [[ "$W" == "32"  && "$H" == "32"  ]]; then DIMS_OK=true; DIM_KIND="furniture (32×32)"
elif [[ "$W" == "64"  && "$H" == "64"  ]]; then DIMS_OK=true; DIM_KIND="furniture (64×64)"
elif [[ "$W" == "128" && "$H" == "128" ]]; then DIMS_OK=true; DIM_KIND="furniture (128×128)"
elif [[ "$W" == "192" && "$H" == "320" ]]; then DIMS_OK=true; DIM_KIND="character pose (192×320)"
elif [[ "$W" == "246" && "$H" == "246" ]]; then DIMS_OK=true; DIM_KIND="scene background (246×246)"
fi

if $DIMS_OK; then
    echo "✅  Dimensions: ${W}×${H} — $DIM_KIND"
else
    echo "❌  Dimensions: ${W}×${H} — expected 32×32, 64×64, 128×128 (furniture),"
    echo "              192×320 (character pose), or 246×246 (scene background)"
    PASS=false
fi

# --- Transparency check (PNG with alpha channel) ---
SPACE=$(sips_get space "$FILE")
if [[ "$SPACE" == *RGBA* || "$SPACE" == *rgba* ]]; then
    echo "✅  Alpha channel: present ($SPACE)"
else
    echo "⚠️  Alpha channel: not detected ($SPACE) — check for transparent background"
fi

# --- Approximate color count via Python ---
COLOR_COUNT=$(python3 - "$FILE" <<'PYEOF'
import sys
try:
    import struct, zlib

    with open(sys.argv[1], 'rb') as f:
        data = f.read()

    # Find IDAT chunks and decompress
    i = 8  # skip PNG signature
    pixels = bytearray()
    width = height = depth = color_type = 0

    while i < len(data):
        length = struct.unpack('>I', data[i:i+4])[0]
        chunk_type = data[i+4:i+8].decode('ascii', errors='ignore')
        chunk_data = data[i+8:i+8+length]

        if chunk_type == 'IHDR':
            width = struct.unpack('>I', chunk_data[0:4])[0]
            height = struct.unpack('>I', chunk_data[4:8])[0]
            depth = chunk_data[8]
            color_type = chunk_data[9]
        elif chunk_type == 'IDAT':
            pixels += chunk_data

        i += 12 + length

    raw = zlib.decompress(pixels)

    if color_type == 6:  # RGBA
        bpp = 4
    elif color_type == 2:  # RGB
        bpp = 3
    else:
        print("?")
        sys.exit(0)

    stride = width * bpp + 1
    unique = set()
    for row in range(height):
        base = row * stride + 1
        for col in range(width):
            px = tuple(raw[base + col*bpp : base + col*bpp + bpp])
            if len(px) == 4 and px[3] == 0:  # transparent
                continue
            unique.add(px[:3])

    print(len(unique))
except Exception as e:
    print("?")
PYEOF
)

if [[ "$COLOR_COUNT" == "?" ]]; then
    echo "⚠️  Color count: could not parse (manual check needed)"
elif [[ "$COLOR_COUNT" -le 12 ]]; then
    echo "✅  Color count: $COLOR_COUNT (≤12)"
elif [[ "$COLOR_COUNT" -le 20 ]]; then
    echo "⚠️  Color count: $COLOR_COUNT (spec says ≤12 — review palette)"
else
    echo "❌  Color count: $COLOR_COUNT — too many colors, likely has anti-aliasing or gradients"
    PASS=false
fi

# --- Result ---
echo ""
if $PASS; then
    echo "✅  PASS: $(basename "$FILE")"
    exit 0
else
    echo "❌  FAIL: $(basename "$FILE") — fix issues above before injecting"
    exit 1
fi
