#!/bin/bash

input="titik-penting.txt"
output="posisipusaka.txt"

lat1=$(sed -n '1p' "$input" | awk -F ',' '{ print $3 }')
long1=$(sed -n '1p' "$input" | awk -F ',' '{ print $4 }')
lat2=$(sed -n '3p' "$input" | awk -F ',' '{ print $3 }')
long2=$(sed -n '3p' "$input" | awk -F ',' '{ print $4 }')

lat_pusaka=$(echo "scale=6; ($lat1 + $lat2) / 2" | bc)
long_pusaka=$(echo "scale=6; ($long1 + $long2) / 2" | bc)

echo "Koordinat pusat:"
echo "($lat_pusaka, $long_pusaka)" > "$output"
cat "$output"
