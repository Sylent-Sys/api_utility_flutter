# Auto-Update Feature Documentation

## Overview
Aplikasi API Utility Flutter sekarang dilengkapi dengan fitur auto-update yang memungkinkan pengguna untuk secara otomatis menerima notifikasi tentang versi baru yang tersedia dan melakukan update dengan mudah.

## 🎯 Fitur Utama

### 1. **Automatic Update Check**
- Aplikasi secara otomatis memeriksa update yang tersedia di GitHub Releases
- Pemeriksaan dilakukan secara berkala berdasarkan interval yang dikonfigurasi
- Pemeriksaan pertama dilakukan saat aplikasi dijalankan (jika sudah waktunya)

### 2. **Update Notification Banner**
- Banner notifikasi muncul di bagian atas aplikasi ketika update tersedia
- Menampilkan versi baru yang tersedia
- Tombol "View" untuk melihat detail update
- Tombol "Dismiss" untuk menutup notifikasi

### 3. **Update Dialog**
- Dialog detail yang menampilkan:
  - Versi baru yang tersedia
  - Versi saat ini
  - Release notes lengkap
  - Progress bar saat download
  - Tombol untuk download dan install
- Error handling dengan pesan error yang jelas

### 4. **Download & Install**
- Download otomatis file installer (MSIX atau ZIP)
- Progress bar untuk menunjukkan progress download
- Instalasi otomatis setelah download selesai
- Mendukung format MSIX (Windows Installer) dan ZIP

### 5. **Update Settings**
- Toggle untuk mengaktifkan/menonaktifkan auto-check
- Slider untuk mengatur interval pemeriksaan (1-168 jam)
- Informasi versi saat ini
- Tombol manual check for updates
- Terintegrasi dengan App Settings screen

## 🏗️ Architecture

### **Services**
#### `UpdateService` (`lib/services/update_service.dart`)
Service singleton yang menangani semua operasi terkait update:
- `checkForUpdates()`: Memeriksa update dari GitHub API
- `downloadUpdate()`: Download file installer
- `installUpdate()`: Install update yang sudah didownload
- `isAutoCheckEnabled()`: Cek status auto-check
- `setAutoCheckEnabled()`: Set status auto-check
- `getCheckIntervalHours()`: Get interval pemeriksaan
- `setCheckIntervalHours()`: Set interval pemeriksaan
- `shouldCheckForUpdates()`: Cek apakah waktunya untuk check update

### **Providers**
#### `UpdateProvider` (`lib/providers/update_provider.dart`)
Provider untuk state management update:
- Menyimpan state update yang tersedia
- Mengelola status checking dan downloading
- Auto-check timer untuk periodic checking
- Notifikasi ke UI saat ada perubahan state

### **Widgets**
#### `UpdateBanner` (`lib/widgets/update_banner.dart`)
- Banner notifikasi yang muncul di top of screen
- Hanya muncul ketika ada update tersedia
- Bisa di-dismiss oleh user

#### `UpdateDialog` (`lib/widgets/update_dialog.dart`)
- Dialog detail untuk menampilkan informasi update
- Menangani download dan install process
- Menampilkan progress dan error messages

### **UI Integration**
- `main.dart`: Menambahkan `UpdateProvider` ke MultiProvider
- `tab_home_screen.dart`: Menampilkan `UpdateBanner` di body
- `app_settings_screen.dart`: Menambahkan section untuk update settings

## 📋 How It Works

### Update Check Flow
```
1. App Startup
   ↓
2. UpdateProvider initialized
   ↓
3. Check shouldCheckForUpdates()
   ↓
4. If true → checkForUpdates()
   ↓
5. Query GitHub API (/repos/Sylent-Sys/api_utility_flutter/releases/latest)
   ↓
6. Compare version
   ↓
7. If newer → Store UpdateInfo & Show Banner
   ↓
8. Save last check timestamp
```

### Download & Install Flow
```
1. User clicks "Download" in UpdateDialog
   ↓
2. downloadUpdate() called
   ↓
3. Download file with progress callback
   ↓
4. Save to temporary directory
   ↓
5. User clicks "Install"
   ↓
6. installUpdate() called
   ↓
7. Launch installer (MSIX) or Extract & Launch (ZIP)
   ↓
8. App may restart for installation
```

### Periodic Check Flow
```
1. Timer set based on check interval
   ↓
2. Timer fires → checkForUpdates(silent: true)
   ↓
3. If update found → Show banner
   ↓
4. Timer reset for next check
```

## 🔧 Configuration

### Default Settings
- **Auto Check**: Enabled
- **Check Interval**: 24 hours
- **GitHub Repo**: `Sylent-Sys/api_utility_flutter`
- **Current Version**: `2.3.0` (from pubspec.yaml)

### Storage
Settings disimpan menggunakan `SharedPreferences`:
- `auto_update_check_enabled`: boolean
- `update_check_interval_hours`: integer
- `last_update_check`: timestamp (milliseconds)

## 🎨 User Experience

### Scenario 1: Auto-check finds update
1. App melakukan auto-check saat startup atau interval timer
2. Update tersedia ditemukan
3. Banner notifikasi muncul di top
4. User bisa klik "View" untuk detail atau "Dismiss" untuk close
5. Jika "View" → Dialog detail muncul
6. User bisa download & install

### Scenario 2: Manual check for updates
1. User buka Settings → Auto Update section
2. Klik tombol "Cek Update"
3. Loading indicator muncul
4. Jika update tersedia → Dialog muncul
5. Jika tidak → SnackBar "Aplikasi sudah versi terbaru"

### Scenario 3: Download & Install
1. User klik "Download" di dialog
2. Progress bar menunjukkan download progress
3. Setelah selesai → Prompt untuk install
4. User klik "Install Now"
5. Installer diluncurkan
6. User mengikuti installer wizard
7. App restart setelah instalasi selesai

## 🛡️ Error Handling

### Common Errors
1. **Network Error**: Tidak bisa connect ke GitHub API
2. **Parse Error**: Response dari API tidak valid
3. **Download Error**: Gagal download file
4. **Install Error**: Gagal meluncurkan installer

### Error Display
- Error messages ditampilkan dalam dialog
- SnackBar untuk error yang tidak critical
- User bisa retry operation

## 🔐 Security & Privacy

### Security Considerations
1. **HTTPS Only**: Semua request ke GitHub API menggunakan HTTPS
2. **Official Releases**: Hanya download dari GitHub Releases resmi
3. **Version Verification**: Versi diverifikasi sebelum download
4. **User Consent**: User harus approve download dan install

### Privacy
- Tidak mengumpulkan data user
- Hanya query GitHub API public
- Tidak mengirim telemetry atau analytics

## 🧪 Testing

### Unit Tests
File: `test/update_service_test.dart`

Tests included:
- Singleton pattern verification
- Current version validation
- UpdateInfo JSON parsing
- Asset selection logic (MSIX vs ZIP)
- Error handling

### Manual Testing Checklist
- [ ] Auto-check saat startup
- [ ] Banner muncul saat update tersedia
- [ ] Dialog menampilkan info lengkap
- [ ] Download progress tracking
- [ ] Install launcher berfungsi
- [ ] Settings dapat disimpan
- [ ] Interval timer bekerja
- [ ] Dismiss banner berfungsi
- [ ] Manual check berfungsi
- [ ] Error handling bekerja

## 🚀 Future Enhancements

### Planned Features
1. **Incremental Updates**: Download hanya delta/patch
2. **Background Download**: Download di background
3. **Auto Install**: Install otomatis tanpa konfirmasi (optional)
4. **Update History**: History update yang pernah dilakukan
5. **Rollback**: Kembalikan ke versi sebelumnya
6. **Beta Channel**: Support untuk beta releases
7. **Update Notification**: Push notification untuk update
8. **Silent Update**: Update di background saat app tidak digunakan

### Potential Improvements
1. Better progress indication (MB downloaded, speed, ETA)
2. Pause/resume download
3. Verify download integrity (checksum)
4. Support for different platforms (Linux, macOS)
5. In-app changelog viewer dengan rich text
6. Update scheduling (install at specific time)

## 📚 Related Files

### Core Implementation
- `lib/services/update_service.dart` - Update business logic
- `lib/providers/update_provider.dart` - State management
- `lib/widgets/update_banner.dart` - Notification banner
- `lib/widgets/update_dialog.dart` - Update dialog
- `lib/main.dart` - Provider integration
- `lib/screens/tab_home_screen.dart` - Banner display
- `lib/screens/app_settings_screen.dart` - Settings UI

### Tests
- `test/update_service_test.dart` - Unit tests

### Dependencies
From `pubspec.yaml`:
- `http: ^1.1.0` - HTTP requests
- `shared_preferences: ^2.2.2` - Settings storage
- `path_provider: ^2.1.2` - File paths
- `archive: ^3.6.1` - ZIP extraction
- `provider: ^6.1.1` - State management

## 💡 Best Practices

### For Developers
1. Always test with real GitHub releases
2. Handle all error cases gracefully
3. Provide clear user feedback
4. Don't force updates on users
5. Keep update process simple and fast

### For Users
1. Keep auto-check enabled untuk security updates
2. Review release notes sebelum update
3. Backup data penting sebelum major update
4. Update saat tidak sedang processing data

## 🐛 Known Limitations

1. **Windows Only**: Saat ini hanya support Windows (MSIX/ZIP)
2. **GitHub Releases**: Bergantung pada GitHub Releases
3. **Manual Restart**: App perlu restart manual setelah install
4. **Network Required**: Butuh koneksi internet untuk check & download
5. **Admin Rights**: Install MSIX mungkin butuh admin rights

## 📞 Support

Jika menemukan issue terkait auto-update:
1. Check Settings → Auto Update untuk status
2. Coba manual check untuk error details
3. Check network connection
4. Review GitHub Releases di repository
5. Report issue dengan error message lengkap
