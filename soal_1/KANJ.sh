#!/bin/bash

FILE="passenger.csv"

echo "Pilih opsi soal:"
echo "a. Jumlah seluruh penumpang KANJ"
echo "b. Jumlah gerbong penumpang KANJ"
echo "c. Penumpang dengan usia tertua"
echo "d. Rata-rata usia penumpang"
echo "e. Jumlah penumpang business class"
read -p "Masukkan opsi soal (a/b/c/d/e): " opsi

if [ "$opsi" == "a" ]; then
  awk -F ',' 'NR > 1 { count_passenger++ }
       END { print "Jumlah seluruh penumpang KANJ adalah", count_passenger, "orang" }' $FILE

elif [ "$opsi" == "b" ]; then
  awk -F ',' 'NR > 1{ gsub(/ |\r/, "", $4); gerbong[$4]++ }
      END { print "Jumlah gerbong penumpang KANJ adalah", length(gerbong) }' $FILE

elif [ "$opsi" == "c" ]; then
  awk -F ',' 'NR > 1 { if ($2 > max_age) { max_age = $2; oldest = $1 }}
      END { print oldest, "adalah penumpang kereta tertua dengan usia", max_age, "tahun" }' $FILE

elif [ "$opsi" == "d" ]; then
  awk -F ',' 'NR > 1 { sum += $2; average_age = sum/NR }
      END { printf "Rata-rata usia penumpang adalah %.0f tahun\n", average_age }' $FILE

elif [ "$opsi" == "e" ]; then
  awk -F ',' '$3 ~ /Business/ { business_passenger++ }
      END { print "Jumlah penumpang business class ada", business_passenger, "orang" }' $FILE

else
  echo "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
  exit 1
fi
