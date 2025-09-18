# Tab Management Features

## Overview
Aplikasi API Utility Flutter sekarang mendukung fitur **Multi-Tab Interface** yang memungkinkan pengguna untuk:
- Membuat multiple tab dengan konfigurasi API yang berbeda
- Mengelola tab (tambah, hapus, duplikasi, rename)
- Menyimpan konfigurasi per-tab secara terpisah
- Memproses data dengan konfigurasi yang berbeda di setiap tab
- Melacak history processing per tab dengan konteks yang kaya

## 🎯 Fitur Utama

### 1. Tab Management
- **Add New Tab**: Klik tombol "+" untuk membuat tab baru dengan konfigurasi default
- **Close Tab**: Klik tombol "X" pada tab untuk menutupnya (minimal 1 tab harus tetap ada)
- **Rename Tab**: Klik kanan pada tab atau gunakan tombol edit di config screen
- **Duplicate Tab**: Klik kanan pada tab dan pilih "Duplicate" untuk menyalin konfigurasi
- **Switch Tab**: Klik pada tab untuk beralih antar tab dengan konfigurasi yang berbeda

### 2. Per-Tab Configuration
Setiap tab memiliki konfigurasi API yang independen:
- **Base URL** dan **Endpoint Path**
- **Authentication method** (Bearer, API Key, Basic, None)
- **Processing settings** (timeout, batch size, rate limit, retries)
- **String fields** configuration
- **Selected file path** untuk input data
- **Request method** (GET atau POST)

### 3. Tab Persistence
- Konfigurasi tab disimpan otomatis ke file `tabs.json`
- Tab akan di-restore saat aplikasi dibuka kembali
- Setiap perubahan konfigurasi disimpan secara real-time
- Backup otomatis untuk mencegah kehilangan data

### 4. Visual Indicators
- **Tab Status**: Tab aktif ditandai dengan warna yang berbeda
- **Configuration Status**: Status konfigurasi ditampilkan dengan icon (✓ untuk valid, ✗ untuk invalid)
- **Tab Information**: Informasi tab ditampilkan di config dan processing screen
- **Real-time Updates**: Status ter-update otomatis saat konfigurasi berubah

### 5. Tab-Specific History
- **Rich Context**: History entries termasuk informasi tab (nama, ID, tanggal dibuat)
- **Persistent Tracking**: History tetap ada meski tab dihapus
- **Naming Convention**: Format `{tabName}-{tabId}-{timestamp}` untuk ID history
- **Easy Identification**: Bisa tahu history dari tab mana dengan mudah

## 🚀 Cara Penggunaan

### Membuat Tab Baru
1. Klik tombol "+" di sebelah kanan tab bar
2. Tab baru akan dibuat dengan konfigurasi default
3. Konfigurasi tab baru sesuai kebutuhan
4. Tab akan tersimpan otomatis

### Mengelola Tab
1. **Rename**: 
   - Klik kanan pada tab → "Rename"
   - Atau gunakan tombol edit di config screen
   - Masukkan nama baru dan tekan Enter
2. **Duplicate**: 
   - Klik kanan pada tab → "Duplicate"
   - Tab baru akan dibuat dengan konfigurasi yang sama
3. **Close**: 
   - Klik tombol "X" pada tab
   - Tab terakhir tidak bisa dihapus

### Konfigurasi Per-Tab
1. Pilih tab yang ingin dikonfigurasi
2. Buka tab "Configuration"
3. Isi konfigurasi API sesuai kebutuhan:
   - Base URL (misal: `localhost:7071`)
   - Endpoint Path (misal: `/api/v1/process`)
   - Authentication method dan credentials
   - Processing settings
4. Klik "Save Configuration"
5. Konfigurasi akan tersimpan khusus untuk tab tersebut

### Processing dengan Tab
1. Pilih tab yang ingin digunakan
2. Buka tab "Processing"
3. Pilih file input (jika belum dipilih)
4. Klik "Start Processing"
5. Processing akan menggunakan konfigurasi dari tab yang aktif
6. History akan tersimpan dengan konteks tab

### Melihat History Per Tab
1. Buka tab "History"
2. Lihat semua history processing
3. Setiap entry menampilkan:
   - Nama tab yang melakukan processing
   - Waktu processing
   - File yang diproses
   - Status hasil processing
4. Search dan filter berdasarkan tab name atau file name

## 📁 File Structure

### Model Baru
- `lib/models/tab.dart` - Model untuk data tab
- `lib/providers/tab_manager.dart` - Provider untuk mengelola tab
- `lib/providers/tab_app_provider.dart` - Provider utama yang menggabungkan tab management dengan app logic

### Screen Baru
- `lib/screens/tab_home_screen.dart` - Home screen dengan tab interface
- `lib/screens/tab_config_screen.dart` - Config screen yang bekerja dengan tab
- `lib/screens/tab_processing_screen.dart` - Processing screen yang bekerja dengan tab

### Widget Baru
- `lib/widgets/tab_bar_widget.dart` - Widget untuk menampilkan tab bar

### Service Updates
- `lib/services/config_service.dart` - Ditambahkan method untuk save/load tabs
- `lib/services/folder_structure_service.dart` - Ditambahkan path untuk tabs.json
- `lib/services/history_service.dart` - Enhanced dengan tab-specific methods
- `lib/services/processing_service.dart` - Enhanced dengan tab context

## 💾 Data Storage

### File Tabs
- **Location**: `{AppDocuments}/API_Utility_Flutter/config/tabs.json`
- **Format**: JSON array berisi data semua tab
- **Auto-save**: Setiap perubahan tab disimpan otomatis

### File History
- **Location**: `{AppDocuments}/API_Utility_Flutter/processing_history.json`
- **Format**: JSON array berisi history processing dengan tab context
- **Auto-save**: Setiap processing selesai, history tersimpan otomatis

### Struktur Data Tab
```json
{
  "id": "tab_1",
  "title": "Production API",
  "config": {
    "baseUrl": "https://api.example.com",
    "endpointPath": "/v1/process",
    "authMethod": "bearer",
    "token": "your-token-here",
    "requestMethod": "POST",
    "timeoutSec": 240,
    "batchSize": 10,
    "rateLimitSecond": 0.5,
    "maxRetries": 3,
    "stringKeys": ["id", "name", "email"]
  },
  "selectedFilePath": "/path/to/file.csv",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "lastModified": "2024-01-01T12:00:00.000Z"
}
```

### Struktur Data History
```json
{
  "id": "ProductionAPI-tab_1-20241218-143022",
  "timestamp": "2024-12-18T14:30:22.000Z",
  "inputFileName": "data.csv",
  "inputFilePath": "/path/to/data.csv",
  "outputPath": "/path/to/results.json",
  "totalRows": 200,
  "successCount": 195,
  "errorCount": 5,
  "configName": "https://api.example.com/v1/process",
  "results": [ /* ApiResult array */ ],
  "isTestMode": false,
  "testRows": null,
  "tabId": "tab_1",
  "tabName": "Production API",
  "tabCreatedAt": "2024-01-01T00:00:00.000Z"
}
```

## 🔄 Migration dari Versi Lama

Aplikasi akan otomatis membuat tab default dengan konfigurasi yang ada saat pertama kali dibuka dengan versi baru. Konfigurasi lama akan tetap tersimpan di `api_config.json` sebagai backup.

### Proses Migration
1. **Deteksi Versi Lama**: Aplikasi mendeteksi apakah ada konfigurasi lama
2. **Buat Tab Default**: Konfigurasi lama di-copy ke tab default baru
3. **Preserve Data**: Semua data lama tetap tersimpan
4. **Seamless Transition**: User bisa langsung menggunakan fitur tab

## 💡 Tips Penggunaan

### Organisasi Tab
1. **Nama Deskriptif**: Beri nama tab yang jelas (misal: "Production API", "Test Environment", "Staging")
2. **Environment Separation**: Gunakan tab berbeda untuk environment yang berbeda
3. **Project-based**: Buat tab berdasarkan project atau client

### Konfigurasi Optimal
1. **Environment-specific**: Setiap environment punya konfigurasi yang sesuai
2. **Authentication**: Simpan credentials yang berbeda per environment
3. **Processing Settings**: Sesuaikan timeout dan batch size per environment

### File Management
1. **Per-tab Files**: Setiap tab bisa punya file input yang berbeda
2. **File Organization**: Organisir file berdasarkan project atau environment
3. **Backup Strategy**: Backup file konfigurasi secara berkala

### History Management
1. **Track Progress**: Monitor history untuk melihat progress processing
2. **Error Analysis**: Analisis error dari history untuk debugging
3. **Performance Monitoring**: Monitor success rate dan performance per tab

## 🛠️ Troubleshooting

### Tab Tidak Tersimpan
- **Check Permissions**: Pastikan aplikasi memiliki permission untuk menulis file
- **Check Directory**: Cek folder `{AppDocuments}/API_Utility_Flutter/config/`
- **Check Disk Space**: Pastikan ada ruang disk yang cukup

### Tab Hilang Setelah Restart
- **Check File**: Cek file `tabs.json` apakah ada dan valid
- **File Corruption**: Jika file corrupt, aplikasi akan membuat tab default baru
- **Backup Recovery**: Restore dari backup jika tersedia

### Konfigurasi Tidak Tersimpan
- **Save Action**: Pastikan klik "Save Configuration" setelah mengubah setting
- **Error Messages**: Cek apakah ada error message di layar
- **Validation**: Pastikan konfigurasi valid sebelum save

### History Tidak Muncul
- **Processing Complete**: Pastikan processing sudah selesai
- **File Permissions**: Cek permission untuk file history
- **Tab Context**: Pastikan processing dilakukan dengan tab yang benar

### Performance Issues
- **Tab Limit**: Jangan buat terlalu banyak tab (recommended: max 10-15)
- **Memory Usage**: Restart aplikasi jika memory usage tinggi
- **File Size**: Monitor ukuran file history dan config

## 🔮 Future Enhancements

### Planned Features
- **Tab Groups**: Grouping tab berdasarkan project atau environment
- **Tab Templates**: Template konfigurasi untuk tab baru
- **Tab Import/Export**: Import/export konfigurasi tab
- **Advanced History**: Filter dan search history yang lebih advanced
- **Tab Analytics**: Statistik penggunaan per tab

### UI Improvements
- **Tab Drag & Drop**: Reorder tab dengan drag and drop
- **Tab Colors**: Custom color untuk setiap tab
- **Tab Icons**: Custom icon untuk setiap tab
- **Tab Shortcuts**: Keyboard shortcuts untuk tab management

### Integration Features
- **API Testing**: Test endpoint langsung dari tab
- **Environment Sync**: Sync konfigurasi antar environment
- **Team Collaboration**: Share konfigurasi tab dengan team
- **Cloud Backup**: Backup konfigurasi ke cloud