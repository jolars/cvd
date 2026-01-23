#!/bin/bash
# cvd-transform-image.sh
# Transform images for color vision deficiency simulation
# Usage: cvd-transform-image.sh <type> <severity> <input> <output>

set -e

CVD_TYPE="$1"
SEVERITY="$2"
INPUT="$3"
OUTPUT="$4"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ] || [ -z "$CVD_TYPE" ]; then
    echo "Usage: $0 <type> <severity> <input> <output>"
    echo "  type: protanopia, deuteranopia, or tritanopia"
    echo "  severity: 0.0 to 1.0 (1.0 = full simulation)"
    echo "Example: $0 protanopia 1.0 photo.png photo-cvd.png"
    exit 1
fi

# Machado matrices for severity 1.0 (full dichromacy)
case "$CVD_TYPE" in
    protanopia)
        MATRIX="0.152286,0.114503,-0.003882,0.114503,0.786281,-0.048116,-0.003882,-0.048116,1.051998"
        ;;
    deuteranopia)
        MATRIX="0.367322,0.860646,-0.227968,0.280085,0.672501,0.047413,-0.011820,0.042940,0.968881"
        ;;
    tritanopia)
        MATRIX="1.255528,-0.076749,-0.178779,-0.078411,0.930809,0.147602,0.004733,0.691367,0.303900"
        ;;
    *)
        echo "Error: Unknown CVD type '$CVD_TYPE'"
        echo "Valid types: protanopia, deuteranopia, tritanopia"
        exit 1
        ;;
esac

# Check if ImageMagick is available
if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick not found. Please install it:"
    echo "  Ubuntu/Debian: apt install imagemagick"
    echo "  macOS: brew install imagemagick"
    echo "  Fedora: dnf install ImageMagick"
    exit 1
fi

# Use 'magick' command if available (IMv7), otherwise 'convert' (IMv6)
if command -v magick &> /dev/null; then
    CMD="magick"
else
    CMD="convert"
fi

# Transform the image
echo "Transforming $INPUT -> $OUTPUT (${CVD_TYPE}, severity=${SEVERITY})"
$CMD "$INPUT" -color-matrix "$MATRIX" "$OUTPUT"

echo "Done!"
