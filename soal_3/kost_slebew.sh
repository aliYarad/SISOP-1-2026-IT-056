#!/bin/bash

DATA="data/penghuni.csv"
LOG="/home/aliya/modul_1/soal_3//home/aliya/modul_1/soal_3/log/tagihan"
REKAP="rekap/laporan_bulanan.txt"
SAMPAH="sampah/history_hapus.csv"

if [ ! -f $DATA ]; then
    echo "ID, Nama, Kamar, Harga Sewa, Tanggal Masuk, Status" > $DATA
fi

show_header() {
  clear
  echo ""
  echo "           _             _          "
  echo "          | | _____  ___| |_        "
  echo "          | |/ / _ \/ __| __|       "
  echo "          |   < (_) \__ \ |_        "
  echo "          |_|\_\___/|___/\__|       "
  echo "         _      _                   "
  echo "     ___| | ___| |__   _____      __"
  echo "    / __| |/ _ \ '_ \ / _ \ \ /\ / /"
  echo "    \__ \ |  __/ |_) |  __/\ V  V / "
  echo "    |___/_|\___|_.__/ \___| \_/\_/  "
  echo ""
}

show_menu() {
  echo " ======================================"
  echo "|     SISTEM MANAJEMEN KOST SLEBEW     |"
  echo "|======================================|"
  echo "| ID | OPTION                          |"
  echo "|----|---------------------------------|"
  echo "|  1 | Tambah Penghuni Baru            |"
  echo "|  2 | Hapus Penghuni                  |"
  echo "|  3 | Tampilkan Daftar Penghuni       |"
  echo "|  4 | Update Status Penghuni          |"
  echo "|  5 | Cetak Laporan Keuangan          |"
  echo "|  6 | Kelola Cron (Pengingat Tagihan) |"
  echo "|  7 | Exit Program                    |"
  echo " ======================================"
  echo ""
  read -p "Enter option [1-7]: " opsi
}

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

  #Validasi tanggal tidak melebihi hari ini
  today=$(date +%Y-%m-%d)
  if [[ "$tanggal" > "$today" ]]; then
    echo "[X] Tanggal tidak boleh melebihi hari ini!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi

  #Validasi harga sewa harus angka positif
  if ! [[ "$harga" =~ ^[0-9]+$ ]]; then
    echo "[X] Harga sewa harus angka positif!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi

  #Validasi nomor kamar tidak boleh bentrok
  kamar_exist=$(awk -F ',' -v k="$kamar" 'NR>1 && $3==k && $6=="Aktif" { print $3 }' $DATA)
  if [ -n "$kamar_exist" ]; then
    echo "[X] Kamar $kamar sudah ditempati!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi

  #Validasi status
  if [ "${status,,}" == "aktif" ]; then
    status="Aktif"
  else
    status="Menunggak"
  fi

  last_id=$(awk -F ',' 'NR>1 { print $1 }' $DATA | sort -n | tail -1)
  new_id=$((last_id + 1))

  echo "$new_id,$nama,$kamar,$harga,$tanggal,$status" >> $DATA
  echo "[✓] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
  read -p "Tekan [ENTER] untuk kembali ke menu"
}

hapus_penghuni() {
  clear
  echo "======================================"
  echo "           HAPUS PENGHUNI             "
  echo "======================================"
  read -p "Masukkan nama penghuni yang akan dihapus: " nama

  #Cek apakah nama exist
  exist=$(awk -F ',' -v n="$nama" 'NR>1 && tolower($2)==tolower(n) { print $0 }' $DATA)
  if [ -z "$exist" ]; then
    echo "[X] Penghuni \"$nama\" tidak ditemukan!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi

  #Simpan ke history sebelum dihapus
  tanggal_hapus=$(date +%Y-%m-%d)
  awk -F ',' -v n="$nama" -v t="$tanggal_hapus" \
      'NR>1 && tolower($2)==tolower(n) { print $0","t }' $DATA >> $SAMPAH

  #Hapus dari data utama
  awk -F ',' -v n="$nama" \
      'NR==1 || tolower($2)!=tolower(n) { print $0 }' $DATA > tmp.csv && mv tmp.csv $DATA

  echo "[✓] Data \"$nama\" berhasil diarsipkan ke $HISTORY_FILE dan dihapus dari sistem."
  read -p "Tekan [ENTER] untuk kembali ke menu"
}

tampilkan_penghuni() {
  clear
  echo "======================================"
  echo "     DAFTAR PENGHUNI KOST SLEBEW      "
  echo "======================================"

  awk -F ',' 'NR==1 {
    printf "%-4s | %-20s | %-6s | %-12s | %s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
    printf "%-4s-+-%-20s-+-%-6s-+-%-12s-+-%s\n", "----", "--------------------", "------", "------------", "----------"
    } NR>1 { printf "%-4s | %-20s | %-6s | Rp%-10s | %s\n", $1, $2, $3, $4, $6 }' $DATA

  total=$(awk -F ',' 'NR>1 { count++ } END { print count+0 }' $DATA)
  aktif=$(awk -F ',' 'NR>1 && $6=="Aktif" { count++ } END { print count+0 }' $DATA)
  menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" { count++ } END { print count+0 }' $DATA)
  echo ""
  echo "Total: $total penghuni | Aktif: $aktif | Menunggak: $menunggak"
  echo "==============================================================="
  echo ""
  read -p "Tekan [ENTER] untuk kembali ke menu"
}

update_status() {
  clear
  echo "======================================"
  echo "          UPDATE STATUS               "
  echo "======================================"
  read -p "Masukkan Nama Penghuni: " nama
  read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru

  #Validasi status
  if [ "${status_baru,,}" == "aktif" ]; then
    status_baru="Aktif"
  elif [ "${status_baru,,}" == "menunggak" ]; then
    status_baru="Menunggak"
  else
    echo "[X] Status tidak valid! Harus Aktif atau Menunggak"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi

  exist=$(awk -F ',' -v n="$nama" 'NR>1 && tolower($2)==tolower(n)' $DATA)
  if [ -z "$exist" ]; then
    echo "[X] Penghuni \"$nama\" tidak ditemukan!"
    read -p "Tekan [ENTER] untuk kembali ke menu"
    return
  fi

  awk -F ',' -v n="$nama" -v s="$status_baru" \
      'BEGIN{OFS=","} NR==1 || tolower($2)!=tolower(n) {print $0} tolower($2)==tolower(n) {$6=s; print $0}' \
      $DATA > tmp.csv && mv tmp.csv $DATA

  echo "[✓] Status $nama berhasil diubah menjadi: $status_baru"
  read -p "Tekan [ENTER] untuk kembali ke menu"
}

cetak_laporan() {
  clear
  echo "======================================"
  echo "     LAPORAN KEUANGAN KOST SLEBEW     "
  echo "======================================"

  total_pemasukan=$(awk -F ',' 'NR>1 && $6=="Aktif" { sum+=$4 } END { print sum+0 }' $DATA)
  total_tunggakan=$(awk -F ',' 'NR>1 && $6=="Menunggak" { sum+=$4 } END { print sum+0 }' $DATA)
  jumlah_kamar=$(awk -F ',' 'NR>1 { count++ } END { print count+0 }' $DATA)

  echo "Total pemasukan (Aktif)  : Rp$total_pemasukan"
  echo "Total Tunggakan          : Rp$total_tunggakan"
  echo "Jumlah Kamar Terisi      : $jumlah_kamar"
  echo "---------------------------------------------"
  echo "Daftar penghuni menunggak:"
  menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" {print "- "$2" (Kamar "$3")"}' $DATA)
  if [ -z "$menunggak" ]; then
    echo "Tidak ada tunggakan."
  else
    echo "$menunggak"
  fi

  #Simpan ke file rekap
  {
  echo "======================================"
  echo "     LAPORAN KEUANGAN KOST SLEBEW     "
  echo "======================================"
  echo "Total pemasukan (Aktif)  : Rp$total_pemasukan"
  echo "Total Tunggakan          : Rp$total_tunggakan"
  echo "Jumlah Kamar Terisi      : $jumlah_kamar"
  echo "---------------------------------------------"
  echo "Daftar penghuni menunggak:"
  if [ -z "$menunggak" ]; then
    echo "Tidak ada tunggakan."
  else
    echo "$menunggak"
  fi
  } > $REKAP

  echo "=============================================="
  echo ""
  echo "[✓] Laporan berhasil disimpan ke $REKAP"
  read -p "Tekan [ENTER] untuk kembali ke menu"
}

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

  case $cron_option in
    1)
      clear
      echo "=== Cron Job Aktif ==="
      crontab -l 2>/dev/null | grep "kost_slebew" || echo "Tidak ada cron job aktif."
      read -p "Tekan [ENTER] untuk kembali ke menu"
      ;;
    2)
      read -p "Masukkan Jam [0-23]: " jam
      read -p "Masukkan Menit [0-59]: " menit
      script_path=$(realpath "$0")

      #Cek apakah sudah ada cron job
      existing=$(crontab -l 2>/dev/null | grep "kost_slebew")
      if [ -n "$existing" ]; then
      #Overwrite/replace cron lama
        crontab -l 2>/dev/null | grep -v "kost_slebew" |
        { cat; echo "$menit $jam * * * $script_path --check-tagihan >> $LOG 2>&1"; } | crontab -
      else
        (crontab -l 2>/dev/null; echo "$menit $jam * * * $script_path --check-tagihan >> $LOG 2>&1") | crontab -
      fi

      echo "[✓] Cron job pengingat tagihan berhasil didaftarkan."
      read -p "Tekan [ENTER] untuk kembali ke menu"
      ;;
    3)
      crontab -l 2>/dev/null | grep -v "kost_slebew" | crontab -
      echo "[✓] Cron job pengingat tagihan berhasil dihapus."
      read -p "Tekan [ENTER] untuk kembali ke menu"
      ;;
    4)
      break
      ;;
    *)
      echo "Pilihan tidak valid!"
      ;;
  esac
  done
}

if [ "$1" == "--check-tagihan" ]; then
  menunggak=$(awk -F ',' 'NR>1 && $6=="Menunggak" { print $2 }' $DATA)
  if [ -n "$menunggak" ]; then
    echo "[$(date)] Pengingat: Penghuni menunggak: $menunggak" >> $LOG
  fi
  exit 0
fi

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
