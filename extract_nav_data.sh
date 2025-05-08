#!/bin/bash

# Download the NAV data from AMFI India
URL="https://www.amfiindia.com/spages/NAVAll.txt"
OUTPUT_TSV="scheme_assets.tsv"
OUTPUT_JSON="scheme_assets.json"

echo "Downloading data from AMFI India..."
curl -s "$URL" -o nav_data.txt

# Extract Scheme Name and Asset Value (Cr), save as TSV
echo -e "Scheme Name\tAsset Value (Cr)" > "$OUTPUT_TSV"
awk -F ';' '{print $4 "\t" $5}' nav_data.txt | sed 's/"//g' | tail -n +2 >> "$OUTPUT_TSV"

# Optional: Convert TSV to JSON
if command -v jq &> /dev/null; then
    echo "Converting TSV to JSON..."
    awk 'BEGIN {FS="\t"; OFS="\t"} NR==1 {for (i=1; i<=NF; i++) header[i]=$i} NR>1 {for (i=1; i<=NF; i++) printf "\"%s\":\"%s\"%s", header[i], $i, (i<NF ? "," : "")} {print ""}' "$OUTPUT_TSV" | 
    jq -sR 'split("\n") | map(select(. != "")) | map("{" + . + "}") | join(",") | "[" + . + "]"' > "$OUTPUT_JSON"
else
    echo "Warning: 'jq' not installed. JSON conversion skipped."
fi

echo "Data extraction complete:"
echo "- TSV: $OUTPUT_TSV"
echo "- JSON: $OUTPUT_JSON (if jq installed)"

# Yes, JSON is often a better choice for this data, especially if you plan to: Use it in web applications or APIs , Process it with modern programming languages (Python, JavaScript, etc.).
