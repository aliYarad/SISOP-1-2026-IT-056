# SISOP-1-2026-IT-056
## Laporan Resmi
**Praktikum Sistem Operasi 2026 Modul 1**  

---
**Nama : Aliya Rahmadina**  
**NRP : 5027251056**   

---

### _Soal 1_
 **Deskripsi Soal**  
 
Pada soal 1 diperintahkan untuk menyusun laporan lengkap mengenai penumpang kereta sekaligus menganalisis data penumpang dari file `passenger.csv`  
- Inisiasi file `passenger.csv` 
```bash
FILE="passenger.csv"
```
- Menu yang memberikan kebebasan kepada user untuk memilih perintah apa yang akan dijalankan
```bash
echo "Pilih opsi soal:"
echo "a. Jumlah seluruh penumpang KANJ"
echo "b. Jumlah gerbong penumpang KANJ"
echo "c. Penumpang dengan usia tertua"
echo "d. Rata-rata usia penumpang"
echo "e. Jumlah penumpang business class"
read -p "Masukkan opsi soal (a/b/c/d/e): " opsi
```
- Terdapat juga kondisi dimana user memilih nomor soal selain opsi di atas, maka akan keluar output:
<img width="1455" height="187" alt="Screenshot 2026-03-27 135448" src="https://github.com/user-attachments/assets/e754366c-3db8-482b-9a30-c57133f47388" />

**Penjelasan Script**
1. a. Memastikan berapa total penumpang yang naik pada hari itu
```bash
if [ "$opsi" == "a" ]; then
  awk -F ',' 'NR > 1 { count_passenger++ }
       END { print "Jumlah seluruh penumpang KANJ adalah", count_passenger, "orang" }' $FILE
```
1. b. Menghitung jumlah gerbong yang digunakan
```bash
elif [ "$opsi" == "b" ]; then
  awk -F ',' 'NR > 1{ gsub(/ |\r/, "", $4); gerbong[$4]++ }
      END { print "Jumlah gerbong penumpang KANJ adalah", length(gerbong) }' $FILE
```
1. c. Mencari penumpang penumpang dengan usia tertua beserta namanya
```bash
elif [ "$opsi" == "c" ]; then
  awk -F ',' 'NR > 1 { if ($2 > max_age) { max_age = $2; oldest = $1 }}
      END { print oldest, "adalah penumpang kereta tertua dengan usia", max_age, "tahun" }' $FILE
```
1. d. Menghitung rata-rata usia penumpang 
```bash
elif [ "$opsi" == "d" ]; then
  awk -F ',' 'NR > 1 { sum += $2; average_age = sum/NR }
      END { printf "Rata-rata usia penumpang adalah %.0f tahun\n", average_age }' $FILE
```
1. e. Memeriksa jumlah penumpang business class
```bash
elif [ "$opsi" == "e" ]; then
  awk -F ',' '$3 ~ /Business/ { business_passenger++ }
      END { print "Jumlah penumpang business class ada", business_passenger, "orang" }' $FILE
```

### _Soal 2_
**Deskripsi Soal**  

Pada soal 2 diperintahkan untuk menemukan koordinat (lattitude, longitude) tempat pusaka disembunyikan dengan menghitung titik tengah dari 4 titik lokasi yang didapatkan melalui file `gsxtrack.json`

**Penjelasan Script**  

Setelah meng-clone `peta-ekspedisi-amba.pdf` diminta untuk parsing data dengan format id, site_name, lattitude, longitude dan simpan hasilnya di file `titik-penting.txt` 
- Inisiasi file `gsxtrack.json` ke dalam variabel `file`, hal serupa dilakukan pada file `titik-penting.txt`
```bash
file="gsxtrack.json"

OUTPUT="titik-penting.txt"
> "$OUTPUT"
```
Hasil parsing akan dimasukkan ke dalam file `titik-penting.txt` yang menampilkan data secara berurutan sesuai dengan id lokasi
- Ekstrak nilai id, site_names, dan lattitude lalu simpan ke variabel
```bash
id=$(awk -F ':' '/"id"/ { gsub(/[",]/,"",$2); print $2 }' $file)
site_names=$(awk -F ': ' '/"site_name"/ { gsub(/[",]/,"",$2); print $2 }' $file)
latitudes=$(awk -F ': ' '/"latitude"/ { gsub(/,/,"",$2); print $2 }' $file)
```
- Hasil ekstrak disimpan ke dalam array
```bash
id_arr=($id)
names_arr=()

while IFS= read -r line; do
  names_arr+=("$line")
done <<< "$site_names"

lat_arr=($latitudes)
long_arr=($longitudes)
```
- Loop untuk mencetak hasil data ke file `titik-penting.txt`
```bash
for i in 0 1 2 3; do
  echo "${id_arr[$i]}, ${names_arr[$i]}, ${lat_arr[$i]}, ${long_arr[$i]}" >> $OUTPUT
done
```

Setelah data koordinat sudah dirapikan, menyelesaikan rumus titik tengah untuk mendapatkan koordinat pusat lokasi pusaka
- Mengambil lattitude dan longitude dari file `titik-penting.txt`
```bash
input="titik-penting.txt"
output="posisipusaka.txt"

lat1=$(sed -n '1p' "$input" | awk -F ',' '{ print $3 }')
long1=$(sed -n '1p' "$input" | awk -F ',' '{ print $4 }')
lat2=$(sed -n '3p' "$input" | awk -F ',' '{ print $3 }')
long2=$(sed -n '3p' "$input" | awk -F ',' '{ print $4 }')
```
- Menghitung titik tengah diagonal menggunakan rumus titik tengah persegi
```bash
lat_pusaka=$(echo "scale=6; ($lat1 + $lat2) / 2" | bc)
long_pusaka=$(echo "scale=6; ($long1 + $long2) / 2" | bc)
```
- Menampilkan hasil perhitungan dan menyimpannya ke dalam file `posisipusaka.txt`
```bash
echo "Koordinat pusat:"
echo "($lat_pusaka, $long_pusaka)" > "$output"
cat "$output"
```

### _Soal 3_
**Deskripsi Soal**

Pada soal 3 diperintahkan untuk menciptakan program manajemen kost berbasis CLI interaktif
- Menu interaktif yang akan terus looping
