#!/usr/bin/env bash
set -euo pipefail

# Usage: ./collector.sh <project_name> <file_pattern1> [file_pattern2 ...]
# Example: ./collector.sh Terraform-Infrastructure "*.tf" "*.sh"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <project_name> <file_pattern1> [file_pattern2 ...]"
  exit 1
fi

PROJECT="$1"
shift

if [ ! -d "$PROJECT" ]; then
  echo "Error: Project directory '$PROJECT' does not exist."
  exit 1
fi

OUTPUT="collected_${PROJECT//\//_}.txt"
: > "$OUTPUT"

for PATTERN in "$@"; do
  echo "Processing pattern $PATTERN..."
  # Use find with -name to match the pattern; quotes prevent expansion by the shell
  find "$PROJECT" -type f -name "$PATTERN" | sort | while read -r file; do
    echo "This is from $file" >> "$OUTPUT"
    cat "$file" >> "$OUTPUT"
    echo -e "\n\n" >> "$OUTPUT"
  done
done

echo "Collected contents written to $OUTPUT"
