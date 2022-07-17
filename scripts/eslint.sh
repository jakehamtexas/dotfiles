#!/bin/bash

eslint_cache_invalidating_files=("yarn.lock" "package.json" ".eslintrc.*")
dirs="$(find . -maxdepth 1 -type d)"

files=$(find . -maxdepth 1 -type f -name "*.ts" -or -name "*.tsx" -or -name "*.js" -or -name "*.jsx" -or -name "package.json" -not -path '*/.*')

cur_dir=$(pwd)
eslint_outdir=/tmp/cache/eslint$cur_dir
mkdir -p "$eslint_outdir"

eslint_cache_location=$eslint_outdir/cache

eslint_mtimes_dir=$eslint_outdir/mtimes
mkdir -p "$eslint_mtimes_dir"

eslint_outfile=$eslint_outdir/out
touch "$eslint_outfile"

eslint_cache_needs_invalidating=0
for file in "${eslint_cache_invalidating_files[@]}"; do
  while read -r f; do
    resolved_path=$(realpath "$f")
    file_path=$eslint_mtimes_dir/${resolved_path:1}
    dir_path=$(dirname "$file_path")
    mkdir -p "$dir_path"

    new_time=$(stat -f %m "$f")

    old_time='0'
    test -f "$file_path" && old_time=$(cat "$file_path")
    if [ "$old_time" -lt "$new_time" ]; then
      echo "Clearing eslint cache due to changes in $f"
      eslint_cache_needs_invalidating=1
    fi

    echo "$new_time" >"$file_path"
  done <<<"$(find . -name "$file" -not -path "*/node_modules/*" -not -path "node_modules/*" -not -path ".next/*" -not -path "*/.next/*")"
done

if [ $eslint_cache_needs_invalidating -eq 1 ]; then
  test -f "$eslint_cache_location" && rm "$eslint_cache_location"
fi

eslint_d \
  -o "$eslint_outfile" \
  --ext .js,.ts,.tsx \
  --cache \
  --cache-location "$eslint_cache_location" \
  --no-error-on-unmatched-pattern \
  --report-unused-disable-directives \
  --fix \
  $dirs $files
eslint_exit_code=$?

cat $eslint_outfile |
  # Remove colorized ANSI output
  sed -r "s/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g" |
  grep "$cur_dir" |
  while read -r f; do
    touch "$f"
  done

exit $eslint_exit_code
