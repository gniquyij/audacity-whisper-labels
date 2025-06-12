#!/bin/bash

# Batch transcribe audio files using Whisper and generate Audacity label files

INPUT_DIR="."
OUTPUT_DIR="./labels"

mkdir -p "$OUTPUT_DIR"

echo "Scanning for audio files in: $INPUT_DIR"
echo "Transcribing using Whisper with SRT output..."

for file in "$INPUT_DIR"/*.{wav,mp3,m4a,flac,ogg}; do
    [ -e "$file" ] || continue  # Skip if no matching files

    filename=$(basename "$file")
    name="${filename%.*}"
    srt_file="$OUTPUT_DIR/$name.srt"
    label_file="$OUTPUT_DIR/${name}_labels.txt"

    echo "Processing: $filename"

    # Run Whisper (SRT output)
    whisper "$file" --output_format srt --output_dir "$OUTPUT_DIR"

    # Convert SRT to Audacity label format
    awk '
      /^[0-9]+$/ { next }
      /^[0-9]{2}:/ {
        split($1, s, "[:.,]")
        split($3, e, "[:.,]")
        start = s[1]*3600 + s[2]*60 + s[3] + s[4]/1000
        end = e[1]*3600 + e[2]*60 + e[3] + e[4]/1000
        getline text
        gsub("\r", "", text)
        print start "\t" end "\t" text
      }
    ' "$srt_file" > "$label_file"

    echo "Label file created: $label_file"
done

echo "All done. You can now import the *_labels.txt files into Audacity via File > Import > Labels."
