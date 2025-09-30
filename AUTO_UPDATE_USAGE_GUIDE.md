# Auto-Update Feature - Quick Usage Guide

## 🚀 Quick Start

### First Time Setup

1. **Launch the application**
   - Auto-update is enabled by default
   - First check happens automatically on startup

2. **Configure Update Settings** (Optional)
   - Open **Settings** screen (bottom navigation)
   - Scroll to **Auto Update** section
   - Adjust settings as needed

## 📱 Using Auto-Update

### Scenario 1: Automatic Update Notification

1. **App checks for updates automatically**
   - Happens on startup (if interval passed)
   - Happens periodically in background

2. **Update banner appears**
   - Blue banner at top of screen
   - Shows new version available
   - Two options:
     - **View** - See details and download
     - **Dismiss** - Hide banner temporarily

3. **View update details**
   - Click **View** button
   - Dialog shows:
     - New version number
     - Current version
     - Release notes
   - Three options:
     - **Later** - Close dialog
     - **Download** - Start download
     - **Close** (X) - Close dialog

4. **Download update**
   - Click **Download** button
   - Progress bar shows download status
   - Wait for completion

5. **Install update**
   - After download, click **Install** button
   - Installer launches automatically
   - Follow installer instructions
   - App restarts after installation

### Scenario 2: Manual Update Check

1. **Open Settings**
   - Tap **Settings** in bottom navigation

2. **Go to Auto Update section**
   - Scroll to **Auto Update** card
   - See current version and status

3. **Check for updates**
   - Click **Cek Update** button
   - Wait for check to complete

4. **If update available**
   - Dialog appears automatically
   - Follow steps 3-5 from Scenario 1

5. **If no update**
   - SnackBar shows "Aplikasi sudah versi terbaru"
   - Continue using app

### Scenario 3: Configure Update Settings

1. **Open Settings → Auto Update**

2. **Toggle Auto-check**
   - Switch **Cek Update Otomatis** on/off
   - When off: No automatic checks
   - When on: Checks at configured interval

3. **Adjust Check Interval**
   - Use slider: 1 - 168 hours (1 week)
   - Default: 24 hours
   - Lower = More frequent checks
   - Higher = Less frequent checks

4. **Changes save automatically**
   - No need to click save
   - Settings apply immediately

## 🎯 Best Practices

### For Regular Users

1. **Keep Auto-check Enabled**
   - Ensures you get security updates
   - Get new features quickly
   - No need to manually check

2. **Set Reasonable Interval**
   - 24 hours (default) is recommended
   - Too frequent may be annoying
   - Too infrequent may miss important updates

3. **Review Release Notes**
   - Before downloading, read what's new
   - Check for breaking changes
   - Understand new features

4. **Install When Not Busy**
   - Don't install during active processing
   - Save your work before installing
   - App will restart after install

### For Advanced Users

1. **Disable Auto-check If Needed**
   - If you want full control
   - If internet is limited
   - If stability is critical

2. **Manual Check Before Important Work**
   - Check for updates manually
   - Install updates before critical tasks
   - Ensure latest bug fixes

3. **Backup Before Major Updates**
   - Use Backup feature in Settings
   - Save important configurations
   - Can restore if needed

## ⚠️ Important Notes

### Update Process

- **Internet Required**: Need internet for check and download
- **Admin Rights**: MSIX install may need admin rights
- **App Restart**: App restarts to complete installation
- **Data Safety**: Your data is not affected by updates
- **Background Process**: Download happens in foreground only

### Troubleshooting

#### Update Check Fails
1. Check internet connection
2. Verify GitHub is accessible
3. Check firewall settings
4. Try manual check
5. Wait and retry later

#### Download Fails
1. Check internet stability
2. Check disk space
3. Close other apps
4. Retry download
5. Report issue if persists

#### Install Fails
1. Check admin rights
2. Close antivirus temporarily
3. Download again
4. Try ZIP instead of MSIX
5. Manual install from GitHub

#### Banner Won't Dismiss
1. Click Dismiss button
2. Restart app
3. Clear app data
4. Report bug

## 🔧 Advanced Configuration

### Settings Persistence

Settings are stored in:
```
SharedPreferences:
- auto_update_check_enabled: boolean
- update_check_interval_hours: integer
- last_update_check: timestamp
```

### Check Interval Examples

- **1 hour**: Very frequent, for development
- **6 hours**: Frequent, for active projects
- **24 hours**: Default, recommended for most
- **72 hours** (3 days): Less frequent, stable releases
- **168 hours** (1 week): Minimal, very stable

### Version Comparison

App uses semantic versioning (SemVer):
- Format: MAJOR.MINOR.PATCH
- Example: 2.3.0
- Compares each part numerically
- Newer = Any part is higher

## 📊 Update Status Indicators

### Banner States

1. **No Banner**
   - No update available
   - Update dismissed
   - Auto-check disabled

2. **Blue Banner**
   - Update available
   - Can view or dismiss

3. **Banner After Dismiss**
   - Gone until next check
   - Check again shows banner

### Settings Display

1. **Current Version**
   - Always shows installed version
   - Format: X.Y.Z

2. **Update Status**
   - "Aplikasi sudah versi terbaru" (Up to date)
   - "Update tersedia: vX.Y.Z" (Update available)

3. **Check Button State**
   - "Cek Update" (Ready)
   - "Memeriksa..." (Checking)
   - Disabled while checking

## 🎓 Tips & Tricks

### Power User Tips

1. **Check Before Presentations**
   - Update before demos
   - Ensure latest features
   - Test after update

2. **Set Update Reminder**
   - Check weekly manually
   - Review changelogs
   - Plan update timing

3. **Use Test Mode**
   - Test new version first
   - Verify compatibility
   - Report bugs early

### Developer Tips

1. **Watch GitHub Releases**
   - Subscribe to notifications
   - Follow release schedule
   - Participate in discussions

2. **Beta Testing**
   - Enable prerelease (future feature)
   - Test new features early
   - Provide feedback

3. **Report Issues**
   - Note version numbers
   - Describe update process
   - Share error messages

## 📞 Getting Help

### Common Questions

**Q: How do I know my app is up to date?**
A: Check Settings → Auto Update. Status shows if up to date.

**Q: Can I skip an update?**
A: Yes, dismiss the banner or choose "Later" in dialog.

**Q: Will I lose my data?**
A: No, updates preserve all data and configurations.

**Q: How large are updates?**
A: Typically 20-50 MB for MSIX, varies for ZIP.

**Q: Can I revert to old version?**
A: Not directly, but can download old version from GitHub Releases.

### Support Channels

1. **Documentation**: Check AUTO_UPDATE_FEATURE.md
2. **GitHub Issues**: Report bugs
3. **Discussions**: Ask questions
4. **Email**: Contact maintainers

## 🔮 Coming Soon

### Planned Features

- [ ] Pause/resume download
- [ ] Background downloads
- [ ] Update scheduling
- [ ] Beta channel support
- [ ] Rollback to previous version
- [ ] Update history log
- [ ] Silent updates
- [ ] Update notifications (push)

### Your Feedback

We'd love to hear:
- What works well?
- What could be improved?
- What features do you need?
- Any bugs or issues?

---

*This guide is for API Utility Flutter v2.3.0+*
*Last updated: September 30, 2025*
