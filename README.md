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
- Menu interaktif yang akan terus looping sampai opsi exit dipilih
```bash
while true; do
  show_header
  show_menu
  case $opsi in
    1) tambah_penghuni ;;
    2) hapus_penghuni ;;
    3) tampilkan_penghuni ;;
    4) update_status ;;
    5) cetak_laporan ;;
    6) kelola_cron ;;
    7) echo "Bye!"; exit 0 ;;
    *) echo "Pilihan tidak valid!" ;;
  esac
done
```
Output:
<img width="1450" height="537" alt="Screenshot 2026-03-29 202455" src="https://github.com/user-attachments/assets/56585a8b-d92c-4142-ba26-76d5c347dccc" />

**Penjelasan Script**

1. Menu pertama yaitu tambah penghuni kost untuk mendata penghuni yang baru masuk
```bash
tambah_penghuni() {
 clear
  echo "======================================"
  echo "           TAMBAH PENGHUNI            "
  echo "======================================"
  read -p "Masukkan Nama: " nama
  read -p "Masukkan Kamar: " kamar
  read -p "Masukkan Harga Sewa: " harga
  read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal
  read -p "Masukkan Status Awal (Aktif/Menunggak): " status
```
- Validasi tanggal masuk penghuni baru agar tidak melebihi hari ini, jadi penghuni baru tidak mungkin memiliki tanggal masuk di masa depan
```bash
today=$(date +%Y-%m-%d)
  if [[ "$tanggal" > "$today" ]]; then
    echo "[X] Tanggal tidak boleh melebihi hari ini!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi
```
- Validasi harga sewa menggunakan regex `^[0-9]+$` sehingga jika terdapat input huruf/karakter selain itu, ditolak
```bash
if ! [[ "$harga" =~ ^[0-9]+$ ]]; then
    echo "[X] Harga sewa harus angka positif!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi
```
- Validasi agar nomor kamar antar penghuni tidak bentrok dengan mengecek apakah status kamar yang diinput berstatus "Aktif"
```bash
kamar_exist=$(awk -F ',' -v k="$kamar" 'NR>1 && $3==k && $6=="Aktif" { print $3 }' $DATA)
  if [ -n "$kamar_exist" ]; then
    echo "[X] Kamar $kamar sudah ditempati!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi
```
- Mengubah input status penghuni agar tidak case-sensitive dengan mengubah input status menjadi huruf kecil semua
```bash
if [ "${status,,}" == "aktif" ]; then
    status="Aktif"
  else
    status="Menunggak"
  fi
```
- Mengurutkan ID penghuni berdasarkan nilai terbesar dengan `sort -n` dan `tail -1` lalu `+ 1` untuk menghasilkan ID baru
```bash
 last_id=$(awk -F ',' 'NR>1 { print $1 }' $DATA | sort -n | tail -1)
  new_id=$((last_id + 1))

  echo "$new_id,$nama,$kamar,$harga,$tanggal,$status" >> $DATA
  echo "[✓] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
  read -p "Tekan [ENTER] untuk kembali ke menu"
```
2. Fitur hapus penghuni jikalau terdapat penghuni yang pindah
```bash
hapus_penghuni() {
  clear
  echo "======================================"
  echo "           HAPUS PENGHUNI             "
  echo "======================================"
  read -p "Masukkan nama penghuni yang akan dihapus: " nama
```
- Validasi keberadaan penghuni menggunakan `tolower()` agar tidak case-sensitive
```bash
exist=$(awk -F ',' -v n="$nama" 'NR>1 && tolower($2)==tolower(n) { print $0 }' $DATA)
  if [ -z "$exist" ]; then
    echo "[X] Penghuni \"$nama\" tidak ditemukan!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi
```
- Menyimpan data penghuni lama ke file `history_hapus.csv` dengan tambahan kolom tanggal di belakangnya 
```bash
 tanggal_hapus=$(date +%Y-%m-%d)
  awk -F ',' -v n="$nama" -v t="$tanggal_hapus" \
      'NR>1 && tolower($2)==tolower(n) { print $0","t }' $DATA >> $SAMPAH
```
- Menghapus data penghuni lama dengan menyalin semua baris kecuali penghuni yang ingin dihapus ke file sementara `tmp.csv`, lalu overwrite file asli dengan `mv`
```bash
awk -F ',' -v n="$nama" \
      'NR==1 || tolower($2)!=tolower(n) { print $0 }' $DATA > tmp.csv && mv tmp.csv $DATA

  echo "[✓] Data \"$nama\" berhasil diarsipkan ke $HISTORY_FILE dan dihapus dari sistem."
  read -p "Tekan [ENTER] untuk kembali ke menu"
```
3. Opsi daftar penghuni untuk melihat siapa saja yang sedang menyewa kamar
- Menampilkan daftar penghuni dalam bentuk tabel rapi
```bash
 awk -F ',' 'NR==1 {
    printf "%-4s | %-20s | %-6s | %-12s | %s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
    printf "%-4s-+-%-20s-+-%-6s-+-%-12s-+-%s\n", "----", "--------------------", "------", "------------", "----------"
    } NR>1 { printf "%-4s | %-20s | %-6s | Rp%-10s | %s\n", $1, $2, $3, $4, $6 }' $DATA
```
- Menghitung jumlah penghuni berdasar statusnya dengan `count + 0` untuk memastikan output tetap 0 jika tidak ada data penghuni
```bash
 total=$(awk -F ',' 'NR>1 { count++ } END { print count+0 }' $DATA)
  aktif=$(awk -F ',' 'NR>1 && $6=="Aktif" { count++ } END { print count+0 }' $DATA)
  menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" { count++ } END { print count+0 }' $DATA)
```
4. Fitur update status jika terdapat penghuni yang melunasi tagihannya
```bash
update_status() {
  clear
  echo "======================================"
  echo "          UPDATE STATUS               "
  echo "======================================"
  read -p "Masukkan Nama Penghuni: " nama
  read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru
```
- Validasi status enggunakan `${status_baru,,}` untuk mengubah input menjadi huruf kecil
```bash
if [ "${status_baru,,}" == "aktif" ]; then
    status_baru="Aktif"
  elif [ "${status_baru,,}" == "menunggak" ]; then
    status_baru="Menunggak"
  else
    echo "[X] Status tidak valid! Harus Aktif atau Menunggak"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
```
- Validasi keberadaan penghuni menggunakan `tolower()`
```bash
 exist=$(awk -F ',' -v n="$nama" 'NR>1 && tolower($2)==tolower(n)' $DATA)
  if [ -z "$exist" ]; then
    echo "[X] Penghuni \"$nama\" tidak ditemukan!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi
```
- Update status penghuni pada file `penghuni.csv`
```bash
awk -F ',' -v n="$nama" -v s="$status_baru" \
      'BEGIN{OFS=","} NR==1 || tolower($2)!=tolower(n) {print $0} tolower($2)==tolower(n) {$6=s; print $0}' \
      $DATA > tmp.csv && mv tmp.csv $DATA
```
5. Fitur cetak laporan keuangan sebagai rekapan keuangan kost yang secara otomatis menghitung total pemasukan dan tunggakan
- Menghitung data keuangan dengan `sum+0` dan `count+0` memastikan output tetap 0 jika tidak ada data yang cocok
```bash
total_pemasukan=$(awk -F ',' 'NR>1 && $6=="Aktif" { sum+=$4 } END { print sum+0 }' $DATA)
  total_tunggakan=$(awk -F ',' 'NR>1 && $6=="Menunggak" { sum+=$4 } END { print sum+0 }' $DATA)
  jumlah_kamar=$(awk -F ',' 'NR>1 { count++ } END { print count+0 }' $DATA)
```
- Menampilkan daftar penghuni menunggak dengan mengambil nama dan nomor kamar penghuni berstatus "Menunggak"
```bash
menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" {print "- "$2" (Kamar "$3")"}' $DATA)
  if [ -z "$menunggak" ]; then
    echo "Tidak ada tunggakan."
  else
    echo "$menunggak"
  fi
```
- Menyimpan laporan keuangan kost ke dalam file `laporan_bulanan.txt`
```bash
if [ -z "$menunggak" ]; then
    echo "Tidak ada tunggakan."
  else
    echo "$menunggak"
  fi
  } > $REKAP
```
6. Fitur cron
```bash
kelola_cron() {
  while true; do
  clear
    echo "======================================"
    echo "         MENU KELOLA CRON             "
    echo "======================================"
    echo "  1. Lihat Cron Job Aktif"
    echo "  2. Daftarkan Cron Job Pengingat"
    echo "  3. Hapus Cron Job Pengingat"
    echo "  4. Kembali"
    echo "======================================"
    read -p "Pilih [1-4]: " cron_option
```
- Menampilkan semua cron job yang aktif dengan `crontab -l`, `2>/dev/null` menyembunyikan pesan error jika belum ada crontab lalu memfilter hanya yang mengandung kata kost_slebew
```bash
echo "=== Cron Job Aktif ==="
crontab -l 2>/dev/null | grep "kost_slebew" || echo "Tidak ada cron job aktif."
```
- Menambahkan crontab baru. `realpath "$0"` mengambil path absolut script yang sedang berjalan agar cron bisa menemukannya saat dijalankan otomatis nanti
```bash
script_path=$(realpath "$0")
existing=$(crontab -l 2>/dev/null | grep "kost_slebew")
```
Kemudian mengecek apakah sebelumnya sudah ada cron job. Jika sudah ada, replace/overwrite cron lama
```bash
 crontab -l 2>/dev/null | grep -v "kost_slebew" |
        { cat; echo "$menit $jam * * * $script_path --check-tagihan >> $LOG 2>&1"; } | crontab -
      else
        (crontab -l 2>/dev/null; echo "$menit $jam * * * $script_path --check-tagihan >> $LOG 2>&1") | crontab -
      fi
```
- Menghapus cron job yang ada dengan membuang baris yang mengandung kost_slebew dengan `grep -v` lalu sisanya dituliskan kembali ke crontab
```bash
crontab -l 2>/dev/null | grep -v "kost_slebew" | crontab -
```
- Handler `--check-tagihan` dijalankan otomatis oleh cron job sesuai waktu yang dijadwalkan
```bash
if [ "$1" == "--check-tagihan" ]; then
  menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" { print $2 }' $DATA)
  if [ -n "$menunggak" ]; then
    echo "[$(date)] Pengingat: Penghuni menunggak: $menunggak" >> $LOG
  fi
  exit 0
fi
```
Saat cron menjalankan script `--check-tagihan`, program mencari penghuni yang berstatus "Menunggak", jika ditemukan, program akan mencatatnya ke file `tagihan.log`

### Revisi
#### Bagian 1
**Soal 1**

Pada soal nomor 1, seharusnya script dijalankan melalui awk dengan format `awk -f KANJ.sh passenger.csv a/b/c/d/e`, tetapi pada script yang saya buat, saya membuatnya melalui menu-menu yang bisa dipilih user. Berikut revisinya:
```bash
BEGIN {
    opsi = ARGV[2]
    delete ARGV[2]
    FS = ","

    if (opsi != "a" && opsi != "b" && opsi != "c" && opsi != "d" && opsi != "e") {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        exit 1
    }
}

NR > 1 && opsi == "a" { count++ }

NR > 1 && opsi == "b" { gsub(/ |\r/, "", $4); gerbong[$4]++ }

NR > 1 && opsi == "c" { if ($2 > max_age) { max_age = $2; oldest = $1 } }

NR > 1 && opsi == "d" { sum += $2 }

NR > 1 && opsi == "e" && $3 ~ /Business/ { business++ }

END {
    if (opsi == "a")
        print "Jumlah seluruh penumpang KANJ adalah", count, "orang"
    else if (opsi == "b")
        print "Jumlah gerbong penumpang KANJ adalah", length(gerbong)
    else if (opsi == "c")
        print oldest, "adalah penumpang kereta tertua dengan usia", max_age, "tahun"
    else if (opsi == "d")
        printf "Rata-rata usia penumpang adalah %d tahun\n", int(sum/(NR-1))
    else if (opsi == "e")
        print "Jumlah penumpang business class ada", business, "orang"
}
```
Karena `awk -f` hanya bisa menjalankan script awk dan tidak bisa menggunakan sintaks bash, maka saya merevisi keseluruhan script.  
Di awk, argumen setelah nama file bisa diakses lewat `ARGV` dengan `ARGV[2]` mengambil argumen ketiga dan dan delete `ARGV[2]` mencegah awk untuk membuka argumen sebagai file

#### Bagian 2
**Soal 1 Opsi d (Rata-Rata Usia Penumpang)**

Pada soal nomor 1, seharusnya rata-rata setelah dilakukan operasi perhitungan menghasilkan bilangan bulat (integer) dengan pembulatan ke bawah, tetapi pada script, saya melakukan pembulatan ke atas
```bash
else if (opsi == "d")
    printf "Rata-rata usia penumpang adalah %d tahun\n", int(sum/(NR-1))
```
Hal yang diubah yaitu dari `%.0f` menjadi `%d` serta menggunakan fungsi `int()` pada perhitungan rata-rata karena fungsi ini membulatkan angka desimal ke bawah  
Output:
<img width="1457" height="43" alt="image" src="https://github.com/user-attachments/assets/f2344153-8e8a-42fa-91ba-e3f001c5e165" />

#### Bagian 3
**Soal 3**

Pada soal nomor 3, kesalahan saya yaitu setiap saat program dijalankan dan folder-folder yang dibutuhkan belum ada, program saya tidak membuat folder-folder tersebut
```bash
#!/bin/bash

mkdir -p data log rekap sampah
```
Saya menambahkan `mkdir -p` agar setiap program dijalankan, program membuat semua folder sekaligus

#### Bagian 4
**Soal 3**

Pada soal nomor 3, terdapat kesalahan saat inisiasi variabel `LOG` yaitu saya menulis path yang salah. Sebelumnya, path `LOG` : `LOG="/home/aliya/modul_1/soal_3//home/aliya/modul_1/soal_3/log/tagihan.log"`, saya ubah menjadi:
```bash
LOG="log/tagihan.log"
```

#### Bagian 5
**Soal 3**

Pada soal nomor 3, terdapat kesalahan saat menjalankan `./kost_slebew.sh --check-tagihan` 
```bash
if [ "$1" == "--check-tagihan" ]; then
  cd "$(dirname "$0")"
  menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" { print $2 }' $DATA)
  if [ -n "$menunggak" ]; then
    echo "[$(date)] Pengingat: Penghuni menunggak: $menunggak" >> $LOG
  fi
  exit 0
fi
```
Revisi yang saya lakukan yaitu menambahkan `cd "$(dirname "$0")"` agar path `$DATA` dan `$LOG` dapat ditemukan dari manapun script dijalankan sehingga cron berjalan pada direktori yang sama. Selain itu, saya menambahkan `else` agar log tetap tertulis meskipun tidak ada penghuni yang menunggak

#### Bagian 6
**Soal 3** 

Pada soal nomor 3, diperintahkan untuk validasi agar nomor kamar tidak bentrok, tapi saat program dijalankan, saya masih menemukan ada nomor kamar yang bentrok
```bash
kamar_exist=$(awk -F ',' -v k="$kamar" 'NR>1 && $3==k { print $3 }' $DATA)
if [ -n "$kamar_exist" ]; then
    echo "[X] Kamar $kamar sudah ditempati!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
fi
```
Hal yang saya ubah yaitu saya menghapus `$6=="Aktif"` karena kondisi ini hanya memvalidasi kamar yang penghuninya berstatus "Aktif" saja
