# ROG Ally Gaming-Optimized Debloat Script

> [!WARNING]
> **Use at Your Own Risk!**
> 
> This script makes system-level changes to your Windows installation. While great care has been taken to protect gaming-critical components, **you are responsible for:**
> - Running the script in **DRY RUN mode first** (`-DryRun`) to preview changes
> - Verifying that nothing you need will be removed
> - Creating a system restore point before making changes
> - Understanding that app removal may have unintended consequences
> 
> **If something breaks:** You can use System Restore to revert changes, or reinstall most apps from the Microsoft Store.
> 
> ⚠️ **ALWAYS run with `-DryRun` first to see what will be removed!**

## 🎮 What This Script Does

This PowerShell script removes Windows bloatware from your ROG Ally while **preserving all gaming-critical components**:

- ✅ **KEEPS:** Xbox services, Game Bar, ASUS utilities, Microsoft Store
- ✅ **KEEPS:** All gaming overlays and Xbox Identity Provider
- ✅ **KEEPS:** Armoury Crate and all ROG/ASUS apps
- ✅ **KEEPS:** Realtek audio drivers and AMD/NVIDIA components
- ❌ **REMOVES:** Office apps, Bing apps, third-party bloatware, AI/Copilot features

## 📋 Prerequisites

> [!IMPORTANT]
> **Before You Begin:**
> 1. ✅ **MUST DO:** Run with `-DryRun` parameter first
> 2. ✅ **MUST DO:** Review what will be removed
> 3. ✅ **HIGHLY RECOMMENDED:** Create a system restore point
> 4. ✅ **RECOMMENDED:** Close all running games and apps
> 
> Skipping these steps may result in removing apps you need or breaking functionality!

- **ROG Ally or ROG Ally X** running Windows 11
- **Administrator access** required
- **15-20 minutes** of time
- **(Recommended)** System Restore enabled

## 🚀 How to Use

### Dry Run First (Highly Recommended!)

**Preview what will be removed before making any changes:**

1. **Download the script**
   - Save `ROG-Ally-Debloat.ps1` to your Desktop or Downloads folder

2. **Open PowerShell as Administrator**
   - Press the Windows key
   - Type "PowerShell"
   - Right-click "Windows PowerShell"
   - Select "Run as administrator"

3. **Navigate to the script location**
   ```powershell
   cd ~/Desktop
   # Or wherever you saved the script
   ```

4. **Allow script execution (one-time)**
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

5. **Run in DRY RUN mode to preview**
   ```powershell
   .\ROG-Ally-Debloat.ps1 -DryRun
   ```

6. **Review the output**
   - See exactly which apps would be removed
   - Verify gaming services are protected
   - No changes are made to your system!

7. **Run for real if satisfied**
   ```powershell
   .\ROG-Ally-Debloat.ps1
   ```
## 🔍 Understanding Dry Run Mode

**What is Dry Run?**
- Scans your system and shows exactly what would be removed
- **Makes NO changes** to your system
- No apps are uninstalled
- No system restore point needed
- Safe to run as many times as you want

**Why use Dry Run first?**
- ✅ See the complete list of apps that will be removed
- ✅ Verify you don't need any of the listed apps
- ✅ Confirm gaming services are protected
- ✅ Make an informed decision before proceeding
- ✅ No risk - preview everything first!

**Dry Run Output Example:**
```
[DRY RUN] Would remove: Microsoft.BingNews
[DRY RUN] Would remove: Microsoft.Office.OneNote
[DRY RUN] Would remove provisioned: Microsoft.BingWeather
⚠ Skipping protected app: Microsoft.XboxGamingOverlay

MODE: DRY RUN - No changes were made
Would remove: 35 apps (87 total packages)
✓ All Xbox gaming services would be preserved
```

## 🔒 What's Protected (Will NOT Be Removed)

The script includes built-in protection for gaming-critical apps:

### Gaming Services
- Microsoft.GamingApp
- Microsoft.XboxApp
- Microsoft.XboxGameOverlay ⚠️ **Used by Armoury Crate for recording**
- Microsoft.XboxGamingOverlay
- Microsoft.XboxIdentityProvider ⚠️ **Required for many games**
- Microsoft.XboxSpeechToTextOverlay
- Microsoft.Xbox.TCUI

### System Essential
- Microsoft.WindowsStore ⚠️ **Cannot be reinstalled if removed**
- Microsoft.WindowsTerminal
- Microsoft.DesktopAppInstaller

### Hardware/Gaming Specific
- All ASUS/ROG/Armoury Crate apps
- All Realtek audio components
- All AMD drivers and software
- All NVIDIA components

## ⚠️ Important Limitations

### Removal Scope
This script removes apps for the **current user only**. Here's why:

- ✅ **Current User:** Apps removed completely
- ✅ **Provisioned Packages:** Removed (prevents installation for new users)
- ❌ **Other Users:** Their apps remain untouched
- ❌ **System-wide:** Not all apps can be removed system-wide

**Why not use `-AllUsers`?**
- The `-AllUsers` parameter is unreliable across Windows versions
- It's not supported on many systems
- It often appears to work but doesn't actually remove apps
- Current user removal is more consistent and reliable

**For a single-user ROG Ally:** This limitation doesn't matter - you'll get full debloat benefits.

**For shared devices:** Each user would need to run the script under their account.

## 🗑️ What Gets Removed

### Microsoft Bloatware
- Office Hub, OneNote, Sway, Teams
- Mail & Calendar
- Bing News, Weather, Finance, Sports
- Cortana, Clipchamp, Copilot
- Solitaire, Sticky Notes, Maps
- Mixed Reality Portal
- And many more...

### Third-Party Bloatware
- Social media apps (Facebook, Instagram, TikTok, Twitter)
- Games (Candy Crush, Bubble Witch, etc.)
- Streaming apps (Netflix, Spotify, etc.)
- Other pre-installed junk

See the script source for the complete list!

## ⚙️ Post-Debloat Optimization

After running the script, apply these manual optimizations for maximum performance:

### 1. Disable Memory Integrity (BIG FPS Boost!)
```
Settings → Privacy & Security → Windows Security → 
Device Security → Core Isolation Details → 
Turn OFF "Memory Integrity"
```

### 2. Disable Virtual Machine Platform
```
Settings → Apps → Optional Features → 
More Windows Features → 
Uncheck "Virtual Machine Platform"
```

### 3. Optimize VRAM Allocation
```
Armoury Crate Button → Performance → 
GPU Settings → Memory Assigned to GPU → 
Set to 6-10GB (depending on your games)
```

### 4. Clean Startup Programs
```
Press Ctrl+Shift+Esc → Startup Tab → 
Disable everything EXCEPT:
  - ASUS/ROG/Armoury Crate components
  - Realtek Audio
  - AMD Software
```

### 5. Remove Unnecessary Windows Features
```
Settings → Apps → Optional Features → More Windows Features
Uncheck:
  - Internet Explorer mode
  - Windows Hello Face (if you don't use it)
  - Print Management Console
  - Math Recognizer
  - OpenSSH Client
```

## 🔧 Troubleshooting

### Script Won't Run
**Error:** "Execution of scripts is disabled on this system"

**Solution:**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Can't Create Restore Point
**Issue:** System Protection is disabled

**Solution:**
1. Open Control Panel
2. Go to System → System Protection
3. Select your C: drive
4. Click Configure
5. Enable System Protection

### Accidentally Removed Something Important
**Solution:**
1. Restart and press F8 (or hold Shift while clicking Restart)
2. Select Troubleshoot → Advanced Options → System Restore
3. Choose the restore point created before running the script
4. Most apps can also be reinstalled from Microsoft Store

### Xbox Game Bar Not Working
**Verify it's still installed:**
```powershell
Get-AppxPackage -Name "Microsoft.XboxGamingOverlay"
```

**Reinstall if needed:**
```powershell
Get-AppxPackage -Name "Microsoft.XboxGamingOverlay" -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```

## ⚠️ Important Warnings

### DO NOT Remove These Manually
- ❌ Microsoft Store (cannot be reinstalled!)
- ❌ Xbox services (breaks gaming)
- ❌ ASUS/Armoury Crate apps (breaks handheld features)
- ❌ Realtek audio (no sound!)

### Safe to Skip
You can safely skip this script if:
- You're happy with your current setup
- You use Office 365 apps regularly
- You need Outlook/Mail & Calendar
- You're not experiencing performance issues

## 🔄 Reverting Changes

### Reinstall Removed Apps
Most apps can be reinstalled from Microsoft Store:
1. Open Microsoft Store
2. Search for the app name
3. Click Install

### Full System Restore
If you created a restore point:
1. Search "Create a restore point" in Start menu
2. Click "System Restore"
3. Choose your restore point
4. Follow the wizard

### Undo Registry Changes
The Win11Debloat tool includes undo registry files if you used that separately.

## 📝 What This Script Does NOT Do

This script **only removes apps**. It does NOT:
- ❌ Modify registry settings
- ❌ Disable telemetry (use Win11Debloat for that)
- ❌ Change Windows settings
- ❌ Disable Windows Update
- ❌ Remove Windows Defender
- ❌ Modify gaming settings

For comprehensive optimization, combine this with:
- Win11Debloat (for registry tweaks)
- Manual Windows optimization (steps above)

## 🎯 Quick Reference

> [!CAUTION]
> **Never skip the dry run!** Always preview changes before making them.

### Command Options
```powershell
# ⚠️ ALWAYS START HERE - Preview what would be removed (safe, no changes)
.\ROG-Ally-Debloat.ps1 -DryRun

# Only run this after reviewing dry run output
.\ROG-Ally-Debloat.ps1

# Get help
Get-Help .\ROG-Ally-Debloat.ps1 -Full
```

### Recommended Workflow
1. **First run:** `.\ROG-Ally-Debloat.ps1 -DryRun` ← ⚠️ **MANDATORY PREVIEW**
2. **Review output:** Check what would be removed carefully
3. **Verify:** Make sure nothing important is listed
4. **Create restore point:** Safety net in case something goes wrong
5. **If satisfied:** `.\ROG-Ally-Debloat.ps1` ← Actually remove
6. **Restart:** Complete the process
7. **Test:** Verify games, Xbox services, and Armoury Crate work

## 🤝 Contributing

Found a bug or have suggestions? Create an issue or pull request!

## 📜 License

This script is provided as-is. Use at your own risk. Always create a restore point before making system changes.

## ⚖️ Disclaimer

**READ THIS CAREFULLY:**

This script is provided "AS IS" without warranty of any kind. By using this script, you acknowledge that:

1. **You are responsible** for reviewing what will be removed (use `-DryRun`)
2. **You accept the risks** of modifying your Windows installation
3. **You understand** that app removal may cause unexpected issues
4. **You have created** a system restore point (or accept the consequences of not doing so)
5. **The author is not liable** for any damage, data loss, or issues arising from use of this script

**This script has been designed with safety in mind** (protecting Xbox/gaming services, ASUS utilities, etc.), but Windows configurations vary, and what works on one system may cause issues on another.

**ALWAYS run `-DryRun` first. No exceptions.**

If you're not comfortable with these terms, **do not use this script.**
