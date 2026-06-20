# OCR an Image to Text

Extract text from an image file using Tesseract OCR.

## Prerequisites

- `tesseract` installed on the system
- Image file to process

## Usage

Call this skill when the user wants to read text from an image/screenshot. Phrases like "leer imagen", "ocr", "extraer texto de imagen", "read image", "convert image to text".

## Steps

### 1. Run OCR script
```bash
./scripts/ocr.sh <path/to/image>
```

This outputs the recognized text to a `.txt` file next to the image and prints it to stdout.

### 2. Read the result
If the output is long, view it with:
```bash
cat <path/to/image_without_extension>.txt
```
