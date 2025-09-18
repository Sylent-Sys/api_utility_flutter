# Validation & Notification Features

## Overview
Aplikasi API Utility Flutter sekarang memiliki sistem validasi dan notifikasi yang komprehensif untuk memastikan konfigurasi API yang valid sebelum processing data. Sistem ini terintegrasi dengan multi-tab interface dan memberikan feedback real-time kepada user.

## 🎯 Fitur Validasi

### 1. **Real-time Validation Status**
- **Lokasi**: Configuration Screen
- **Tampilan**: Card dengan warna hijau (valid) atau merah (invalid)
- **Fitur**:
  - ✅ **Valid**: Menampilkan "Configuration Valid" dengan ikon centang hijau
  - ❌ **Invalid**: Menampilkan "Configuration Invalid" dengan ikon error merah
  - 📝 **Error Details**: Daftar error yang spesifik dan actionable
  - 🔄 **Auto-update**: Status ter-update otomatis saat user mengubah field

### 2. **Visual Indicators**
- **Processing Screen**: Ikon status di tab info section
  - ✅ **Hijau**: Konfigurasi valid
  - ❌ **Merah**: Konfigurasi invalid
- **Tab Bar**: Status indicator untuk setiap tab
- **Configuration Screen**: Real-time validation card
- **Cross-screen Consistency**: Status yang konsisten di semua screen

### 3. **Snackbar Notifications**

#### **Save Configuration**
- **Success**: Snackbar hijau "Configuration saved successfully!"
- **Error**: Snackbar merah dengan daftar error validasi
- **Duration**: 2 detik untuk success, 5 detik untuk error
- **Action**: Tombol "Dismiss" untuk error messages

#### **Start Processing**
- **Error**: Snackbar merah dengan pesan "Cannot start processing: Configuration is invalid"
- **Action**: Tombol "Go to Config" untuk beralih ke configuration screen
- **Context**: Error message menampilkan error spesifik yang perlu diperbaiki

### 4. **Pre-processing Validation**
- **Automatic Check**: Validasi otomatis sebelum memulai processing
- **Block Invalid Processing**: Mencegah processing dengan konfigurasi invalid
- **Clear Error Messages**: Pesan error yang informatif dan actionable
- **Quick Navigation**: Tombol untuk langsung ke configuration screen

## 🔍 Validasi yang Dilakukan

### **Required Fields**
- ✅ **Base URL**: Tidak boleh kosong
- ✅ **Endpoint Path**: Tidak boleh kosong

### **URL Validation**
- ✅ **Base URL Format**: Harus berupa URL yang valid
- ✅ **Flexible Format**: Mendukung berbagai format URL:
  - `localhost:7071` ✅
  - `http://localhost:7071` ✅
  - `https://api.example.com` ✅
  - `192.168.1.100:8080` ✅
- ✅ **Scheme Validation**: Validasi scheme dan authority

### **Authentication Validation**
- ✅ **Bearer Token**: Token tidak boleh kosong jika auth method = "bearer"
- ✅ **API Key**: API Key tidak boleh kosong jika auth method = "api_key"
- ✅ **Basic Auth**: Username dan Password tidak boleh kosong jika auth method = "basic"
- ✅ **None**: Tidak ada validasi tambahan jika auth method = "none"

### **Numeric Validation**
- ✅ **Timeout**: Harus > 0 (positive number)
- ✅ **Batch Size**: Harus > 0 (positive number)
- ✅ **Rate Limit**: Tidak boleh negatif (≥ 0)
- ✅ **Max Retries**: Tidak boleh negatif (≥ 0)

### **Field-specific Validation**
- ✅ **String Fields**: Validasi format comma-separated values
- ✅ **Request Method**: Validasi pilihan GET/POST
- ✅ **Authentication Method**: Validasi pilihan auth method

## 🎨 User Experience

### **Configuration Screen**
1. **Real-time Feedback**: Status validasi ter-update otomatis saat user mengubah field
2. **Clear Error Messages**: Error message yang spesifik dan mudah dipahami
3. **Visual Cues**: Warna dan ikon yang jelas untuk status valid/invalid
4. **Save Protection**: Tidak bisa save konfigurasi yang invalid
5. **Field Highlighting**: Field yang error bisa di-highlight (future enhancement)

### **Processing Screen**
1. **Pre-processing Check**: Validasi dilakukan sebelum memulai processing
2. **Clear Error Display**: Error message yang informatif dengan action button
3. **Quick Navigation**: Tombol "Go to Config" untuk memperbaiki konfigurasi
4. **Context Awareness**: Error message sesuai dengan tab yang aktif

### **Tab Management**
1. **Per-tab Validation**: Setiap tab memiliki status validasi independen
2. **Visual Indicators**: Status validasi terlihat di tab info section
3. **Context-aware**: Error message sesuai dengan tab yang aktif
4. **Cross-tab Consistency**: Validasi yang konsisten di semua tab

## 📝 Error Messages

### **Common Validation Errors**
```
• Base URL is required
• Base URL must be a valid URL
• Endpoint Path is required
• Bearer Token is required
• API Key is required
• Username is required for Basic Auth
• Password is required for Basic Auth
• Timeout must be greater than 0
• Batch Size must be greater than 0
• Rate Limit cannot be negative
• Max Retries cannot be negative
```

### **Processing Errors**
```
Cannot start processing: Configuration is invalid
• Base URL is required
• Bearer Token is required
• ... and 2 more errors
[Go to Config]
```

### **Save Configuration Errors**
```
Configuration has validation errors:
• Base URL is required
• Bearer Token is required
• Timeout must be greater than 0
[Dismiss]
```

## 🛠️ Implementation Details

### **Validation Logic**
- **Location**: `_getValidationErrors()` method di kedua screen
- **Return**: List of error messages
- **Usage**: Real-time validation dan pre-processing check
- **Consistency**: Logic yang sama di Configuration dan Processing screen

### **UI Components**
- **Validation Status Card**: `_buildValidationStatus()` di config screen
- **Snackbar Notifications**: `ScaffoldMessenger.showSnackBar()`
- **Visual Indicators**: Conditional icons berdasarkan `config.isValid`
- **Error Display**: List widget untuk menampilkan multiple errors

### **State Management**
- **Real-time Updates**: Consumer pattern untuk auto-update
- **Per-tab State**: Setiap tab memiliki konfigurasi independen
- **Validation Cache**: Validation dilakukan on-demand
- **Cross-screen Sync**: Status validasi ter-sync antar screen

### **URL Validation Algorithm**
```dart
// Flexible URL validation
final uri = Uri.tryParse(config.baseUrl);
if (uri == null) {
  // Try adding http:// if no scheme
  final uriWithScheme = Uri.tryParse('http://${config.baseUrl}');
  if (uriWithScheme == null || !uriWithScheme.hasAuthority) {
    errors.add('Base URL must be a valid URL');
  }
} else if (!uri.hasScheme && !uri.hasAuthority) {
  errors.add('Base URL must be a valid URL');
}
```

## 🎯 Benefits

### **User Experience**
1. **Immediate Feedback**: User langsung tahu jika ada error
2. **Clear Guidance**: Error message yang actionable
3. **Prevention**: Mencegah processing dengan konfigurasi invalid
4. **Efficiency**: Tidak perlu trial-and-error
5. **Consistency**: Behavior yang konsisten di semua screen

### **Data Quality**
1. **Validation**: Memastikan semua field required terisi
2. **Format Check**: URL dan numeric values divalidasi
3. **Consistency**: Validasi yang konsisten di semua screen
4. **Error Prevention**: Mencegah error saat runtime
5. **Data Integrity**: Memastikan data yang valid sebelum processing

### **Developer Experience**
1. **Maintainable**: Validation logic terpusat dan reusable
2. **Extensible**: Mudah menambah validasi baru
3. **Testable**: Validation logic bisa di-test secara terpisah
4. **Consistent**: Pattern yang sama di semua screen
5. **Debuggable**: Error messages yang jelas untuk debugging

## 📊 Usage Examples

### **Valid Configuration**
```
✅ Configuration Valid
All required fields are properly configured
```

### **Invalid Configuration**
```
❌ Configuration Invalid
• Base URL is required
• Bearer Token is required
• Timeout must be greater than 0
```

### **Processing with Invalid Config**
```
❌ Cannot start processing: Configuration is invalid
• Base URL is required
• Bearer Token is required
• ... and 1 more errors
[Go to Config]
```

### **Save Configuration Success**
```
✅ Configuration saved successfully!
```

### **Save Configuration Error**
```
❌ Configuration has validation errors:
• Base URL is required
• Bearer Token is required
• Timeout must be greater than 0
[Dismiss]
```

## 🔮 Future Enhancements

### **Advanced Validation**
- **URL Reachability**: Test apakah URL bisa diakses
- **Authentication Test**: Test kredensial sebelum processing
- **Schema Validation**: Validasi format data input/output
- **Connection Test**: Test koneksi ke server
- **Performance Validation**: Validasi berdasarkan performance metrics

### **Enhanced UX**
- **Auto-fix Suggestions**: Saran perbaikan otomatis
- **Validation History**: History error untuk debugging
- **Bulk Validation**: Validasi semua tab sekaligus
- **Field Highlighting**: Highlight field yang error
- **Progressive Validation**: Validasi bertahap saat user mengetik

### **Integration Features**
- **API Testing**: Test endpoint sebelum processing
- **Real-time Validation**: Validasi saat user mengetik
- **Smart Suggestions**: Saran konfigurasi berdasarkan URL
- **Template Validation**: Validasi template konfigurasi
- **Environment Validation**: Validasi konfigurasi per environment

### **Advanced Notifications**
- **Toast Notifications**: Notifikasi yang lebih subtle
- **Progress Notifications**: Notifikasi progress validasi
- **Batch Notifications**: Notifikasi untuk multiple errors
- **Custom Notifications**: Notifikasi yang bisa di-customize
- **Notification History**: History notifikasi untuk debugging

## 🧪 Testing

### **Validation Testing**
- **Unit Tests**: Test validation logic secara terpisah
- **Integration Tests**: Test validasi dengan UI
- **Edge Cases**: Test dengan input yang edge case
- **Error Scenarios**: Test dengan berbagai error scenario

### **UI Testing**
- **Widget Tests**: Test validation UI components
- **User Flow Tests**: Test user flow dengan validasi
- **Error Display Tests**: Test tampilan error messages
- **Notification Tests**: Test notifikasi dan snackbar

### **Performance Testing**
- **Validation Speed**: Test kecepatan validasi
- **Memory Usage**: Test penggunaan memory saat validasi
- **UI Responsiveness**: Test responsivitas UI saat validasi
- **Cross-screen Performance**: Test performance validasi antar screen