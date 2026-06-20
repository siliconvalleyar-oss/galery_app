#!/bin/bash
# OCR an image file and output the text to a .txt file.
# Usage: ./scripts/ocr.sh <image_path>
# Output: <image_path>.txt
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <image_path>"
  exit 1
fi

IMAGE="$1"
if [ ! -f "$IMAGE" ]; then
  echo "Error: file not found: $IMAGE"
  exit 1
fi

OUTPUT="${IMAGE%.*}.txt"
tesseract "$IMAGE" "${OUTPUT%.txt}" 2>/dev/null
echo "OCR result written to: $OUTPUT"
cat "$OUTPUT"
