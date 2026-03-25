#!/bin/bash

file="gsxtrack.json"

OUTPUT="titik-penting.txt"
> "$OUTPUT"

id=$(awk -F ':' '/"id"/ { gsub(/[",]/,"",$2); print $2 }' $file)
site_names=$(awk -F ': ' '/"site_name"/ { gsub(/[",]/,"",$2); print $2 }' $file)
latitudes=$(awk -F ': ' '/"latitude"/ { gsub(/,/,"",$2); print $2 }' $file)
longitudes=$(awk -F ': ' '/"longitude"/ { gsub(/,/,"",$2); print $2 }' $file)

id_arr=($id)
names_arr=()

while IFS= read -r line; do
  names_arr+=("$line")
done <<< "$site_names"

lat_arr=($latitudes)
long_arr=($longitudes)

for i in 0 1 2 3; do
  echo "${id_arr[$i]}, ${names_arr[$i]}, ${lat_arr[$i]}, ${long_arr[$i]}" >> $OUTPUT
done

echo "Parsing selesai! Hasil disimpan di" $OUTPUT

