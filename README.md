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
1. a. Memastikan berapa total penumpang yang naik pada hari itu  
- Inisiasi file `passenger.csv` untuk kepraktisan kode  
```bash
FILE="passenger.csv"
```
- Menu interaktif yang memberikan kebebasan kepada user untuk memilih perintah apa yang akan dijalankan
```bash
echo "Pilih opsi soal:"
echo "a. Jumlah seluruh penumpang KANJ"
echo "b. Jumlah gerbong penumpang KANJ"
echo "c. Penumpang dengan usia tertua"
echo "d. Rata-rata usia penumpang"
echo "e. Jumlah penumpang business class"
read -p "Masukkan opsi soal (a/b/c/d/e): " opsi
```
