#!/bin/bash
# Downsamples all retina ...@2x.png images.

echo "Downsampling retina images..."

for f in $(find ./resources -name '*@2x.png'); do
  echo "Converting $f..."
  convert "$f" -resize '50%' "$(dirname $f)/$(basename -s '@2x.png' $f).png"
done
