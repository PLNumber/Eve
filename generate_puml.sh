#!/bin/bash

mkdir -p puml_output

for file in $(find lib -name "*.dart" ! -path "*gen_l10n*"); do
  filename=$(basename "$file" .dart)
  echo "🔍 Generating $filename.puml from $file"
  dart pub global run dcdg "$file" -o "puml_output/$filename.puml"
done

echo "✅ 모든 .puml 파일이 puml_output 폴더에 생성되었습니다."
