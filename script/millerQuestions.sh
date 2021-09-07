#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# create CSV output
yq <"$folder"/../data/millerQuestions.yml . | mlr --j2c unsparsify \
  then reshape -r "verbs" -o k,v \
  then cut -x -f k \
  then uniq -a \
  then nest --ivar ";" -f v \
  then put -S '$v=gsub($v,";$","")' \
  then rename v,verbs \
>"$folder"/../output/millerQuestions.csv

# create markdown output
<"$folder"/../output/millerQuestions.csv \
    mlr --c2m put -S '$title="[".$title."]"."(".$URL.")";$title=gsub($title,"[|]","\|")' \
    then put -S 'if(is_string($verbs)) {$verbs=sub($verbs,"^(.+)$","`"."\1"."`")};' \
    then cut -x -f URL \
>"$folder"/../output/millerQuestions.md
