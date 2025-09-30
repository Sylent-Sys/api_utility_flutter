# Auto-Update Flow Diagrams

## 🔄 Main Update Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     App Startup / Timer                          │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              UpdateProvider.checkForUpdates()                    │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. Check if auto-check enabled                           │  │
│  │ 2. Check if interval passed (shouldCheckForUpdates)      │  │
│  │ 3. Query GitHub API (releases/latest)                    │  │
│  │ 4. Parse response to UpdateInfo                          │  │
│  │ 5. Compare version (isNewerVersion)                      │  │
│  │ 6. Save last check timestamp                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
                ▼                       ▼
    ┌──────────────────┐    ┌──────────────────┐
    │ No Update Found  │    │  Update Found    │
    └──────────────────┘    └────────┬─────────┘
                                     │
                                     ▼
                        ┌────────────────────────┐
                        │ Update UpdateProvider  │
                        │ State & Notify UI      │
                        └────────────┬───────────┘
                                     │
                                     ▼
                        ┌────────────────────────┐
                        │  UpdateBanner Shows    │
                        │  at Top of Screen      │
                        └────────────┬───────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
                    ▼                                 ▼
        ┌──────────────────┐              ┌──────────────────┐
        │  User Clicks     │              │  User Dismisses  │
        │     "View"       │              │     Banner       │
        └────────┬─────────┘              └──────────────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │  UpdateDialog Opens    │
    │  Shows:                │
    │  - New Version         │
    │  - Release Notes       │
    │  - Download Button     │
    └────────────┬───────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
    ▼                         ▼
┌──────────┐          ┌──────────────┐
│  Later   │          │  Download    │
└──────────┘          └──────┬───────┘
                             │
                             ▼
            ┌────────────────────────────┐
            │ UpdateProvider             │
            │   .downloadUpdate()         │
            │                            │
            │ - HTTP GET request         │
            │ - Stream download          │
            │ - Save to temp directory   │
            │ - Progress callbacks       │
            └──────────┬─────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
    ┌──────────┐            ┌─────────────┐
    │  Failed  │            │  Succeeded  │
    │  (Show   │            │  (Show      │
    │  Error)  │            │  Install)   │
    └──────────┘            └──────┬──────┘
                                   │
                                   ▼
                        ┌──────────────────┐
                        │ User Clicks      │
                        │    "Install"     │
                        └────────┬─────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │ UpdateProvider         │
                    │  .installUpdate()       │
                    │                        │
                    │ - Launch MSIX or       │
                    │ - Extract & Launch ZIP │
                    └────────┬───────────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │  Installer Launched    │
                │  App May Restart       │
                └────────────────────────┘
```

## 🎛️ Settings Configuration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Settings Screen                              │
│                   (Auto Update Section)                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┴───────────────────┐
         │                                       │
         ▼                                       ▼
┌─────────────────────┐              ┌─────────────────────────┐
│  Toggle Auto-Check  │              │  Adjust Check Interval  │
│                     │              │                         │
│ ON  → Enable timer  │              │ Slider: 1-168 hours   │
│ OFF → Disable timer │              │ Default: 24 hours      │
└──────────┬──────────┘              └───────────┬─────────────┘
           │                                     │
           │        ┌────────────────────────────┘
           │        │
           ▼        ▼
    ┌──────────────────────┐
    │ UpdateProvider       │
    │ .setAutoCheckEnabled │
    │ .setCheckInterval    │
    │                      │
    │ Save to SharedPrefs  │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │ If enabled:          │
    │ - Restart timer      │
    │ - Use new interval   │
    │                      │
    │ If disabled:         │
    │ - Cancel timer       │
    └──────────────────────┘

                                   
┌─────────────────────────────────────────────────────────────────┐
│                Manual Check Button Flow                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ User Clicks            │
                │  "Cek Update" Button   │
                └────────────┬───────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Button disabled        │
                │ Shows "Memeriksa..."   │
                └────────────┬───────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ UpdateProvider         │
                │  .checkForUpdates()    │
                │  (silent: false)       │
                └────────────┬───────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ Update Available │      │  No Update       │
    │                  │      │                  │
    │ → Show Dialog    │      │ → Show SnackBar  │
    │                  │      │   "Sudah terbaru"│
    └──────────────────┘      └──────────────────┘
```

## ⏰ Periodic Check Timer Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   UpdateProvider Init                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ _initAutoCheck()       │
                │                        │
                │ 1. Check startup time  │
                │ 2. Setup Timer         │
                └────────────┬───────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
        ┌─────────────────┐   ┌──────────────────┐
        │ shouldCheck     │   │ Timer.periodic() │
        │   = true        │   │                  │
        │                 │   │ Duration:        │
        │ → Check Now     │   │  interval hours  │
        └─────────────────┘   └────────┬─────────┘
                                       │
                              ┌────────┴────────┐
                              │                 │
                   On Each Timer Tick           │
                              │                 │
                              ▼                 │
                    ┌──────────────────┐        │
                    │ checkForUpdates  │        │
                    │  (silent: true)  │        │
                    └────────┬─────────┘        │
                             │                  │
                             │                  │
                    ┌────────┴────────┐         │
                    │                 │         │
                    ▼                 ▼         │
        ┌──────────────────┐   ┌─────────────┐ │
        │ Update Found     │   │ No Update   │ │
        │                  │   │             │ │
        │ → Show Banner    │   │ → Continue  │ │
        └──────────────────┘   └─────────────┘ │
                                               │
                                               │
                          Timer continues ─────┘
                          until app closed
```

## 📥 Download & Install Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                  User Clicks Download                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ UpdateProvider         │
                │  .downloadUpdate()      │
                └────────────┬───────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ HTTP GET Request       │
                │ - URL from UpdateInfo  │
                │ - Stream response      │
                └────────────┬───────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Save to Temp Directory │
                │                        │
                │ While downloading:     │
                │ - Update progress      │
                │ - Notify UI (0-100%)   │
                │ - Show progress bar    │
                └────────────┬───────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
        ┌──────────────────┐   ┌─────────────────┐
        │ Download Failed  │   │ Download Success│
        │                  │   │                 │
        │ → Show Error     │   │ → Show Install  │
        │ → Can Retry      │   │    Button       │
        └──────────────────┘   └────────┬────────┘
                                        │
                                        ▼
                            ┌────────────────────┐
                            │ User Clicks        │
                            │   "Install"        │
                            └────────┬───────────┘
                                     │
                                     ▼
                        ┌────────────────────────┐
                        │ UpdateProvider         │
                        │  .installUpdate()       │
                        └────────┬───────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
        ┌──────────────────┐      ┌──────────────────┐
        │ File is .msix    │      │ File is .zip     │
        │                  │      │                  │
        │ → Launch MSIX    │      │ → Extract ZIP    │
        │   installer      │      │ → Launch .exe    │
        └────────┬─────────┘      └────────┬─────────┘
                 │                         │
                 └────────────┬────────────┘
                              │
                              ▼
                ┌─────────────────────────┐
                │ Installer Running       │
                │                         │
                │ User follows prompts:   │
                │ 1. Accept permissions   │
                │ 2. Choose location      │
                │ 3. Complete install     │
                └────────────┬────────────┘
                             │
                             ▼
                ┌─────────────────────────┐
                │ App Restarts            │
                │ New Version Running     │
                └─────────────────────────┘
```

## 🔄 State Management

```
┌─────────────────────────────────────────────────────────────────┐
│                      UpdateProvider                              │
│                                                                   │
│  State Properties:                                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - _availableUpdate: UpdateInfo?                            │ │
│  │ - _isChecking: bool                                        │ │
│  │ - _isDownloading: bool                                     │ │
│  │ - _downloadProgress: double                                │ │
│  │ - _error: String?                                          │ │
│  │ - _autoCheckTimer: Timer?                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Getters:                                                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - availableUpdate                                          │ │
│  │ - isChecking                                               │ │
│  │ - isDownloading                                            │ │
│  │ - downloadProgress                                         │ │
│  │ - error                                                    │ │
│  │ - hasUpdate                                                │ │
│  │ - currentVersion                                           │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Methods:                                                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - checkForUpdates(silent)                                  │ │
│  │ - downloadUpdate()                                         │ │
│  │ - installUpdate(filePath)                                  │ │
│  │ - dismissUpdate()                                          │ │
│  │ - isAutoCheckEnabled()                                     │ │
│  │ - setAutoCheckEnabled(enabled)                             │ │
│  │ - getCheckIntervalHours()                                  │ │
│  │ - setCheckIntervalHours(hours)                             │ │
│  └────────────────────────────────────────────────────────────┘ │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ notifyListeners()
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │                                       │
        ▼                                       ▼
┌─────────────────┐                  ┌─────────────────┐
│  UpdateBanner   │                  │  UpdateDialog   │
│                 │                  │                 │
│  Consumes:      │                  │  Consumes:      │
│  - hasUpdate    │                  │  - update info  │
│  - update info  │                  │  - isDownloading│
│                 │                  │  - progress     │
└─────────────────┘                  └─────────────────┘
                            │
                            ▼
                  ┌─────────────────┐
                  │  AppSettings    │
                  │   Screen        │
                  │                 │
                  │  Consumes:      │
                  │  - all state    │
                  │  - settings     │
                  └─────────────────┘
```

## 🔐 Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    External Sources                              │
└─────────────────┬───────────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
┌──────────────┐    ┌──────────────────┐
│ GitHub API   │    │ SharedPreferences│
│              │    │                  │
│ releases/    │    │ Settings:        │
│  latest      │    │ - enabled        │
│              │    │ - interval       │
│ Returns:     │    │ - last_check     │
│ - tag_name   │    └────────┬─────────┘
│ - body       │             │
│ - assets[]   │             │
└──────┬───────┘             │
       │                     │
       │                     │
       └─────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │   UpdateService        │
    │   (Singleton)          │
    │                        │
    │ Business Logic:        │
    │ - API calls            │
    │ - Version compare      │
    │ - Download             │
    │ - Install              │
    │ - Settings I/O         │
    └────────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │   UpdateProvider       │
    │   (ChangeNotifier)     │
    │                        │
    │ State Management:      │
    │ - Update state         │
    │ - Progress tracking    │
    │ - Error handling       │
    │ - Timer management     │
    └────────────┬───────────┘
                 │
                 │ notifyListeners()
                 │
                 ▼
    ┌────────────────────────┐
    │      UI Widgets        │
    │                        │
    │ - UpdateBanner         │
    │ - UpdateDialog         │
    │ - AppSettingsScreen    │
    └────────────────────────┘
```

---

*These diagrams illustrate the complete auto-update flow in API Utility Flutter*
*Version: 2.3.0+*
*Last updated: September 30, 2025*
