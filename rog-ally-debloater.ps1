#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ROG Ally Gaming-Optimized Debloat Script
    
.DESCRIPTION
    Removes bloatware and unnecessary apps from Windows 11 while preserving
    all gaming-critical components including Xbox services, Game Bar, and ASUS utilities.
    
    IMPORTANT NOTES:
    - Removes apps for the CURRENT USER only (Remove-AppxPackage without -AllUsers)
    - The -AllUsers parameter is unreliable and often not supported
    - Other user accounts on this device will keep their apps
    - Provisioned packages (for new users) are also removed when found
    - Each package is individually checked against protection rules
    
.PARAMETER DryRun
    Shows what would be removed without actually removing anything
    
.NOTES
    Author: Custom script for ROG Ally optimization
    Requires: PowerShell 5.1+ running as Administrator
    
.EXAMPLE
    .\ROG-Ally-Debloat.ps1
    Run the script normally and remove apps
    
.EXAMPLE
    .\ROG-Ally-Debloat.ps1 -DryRun
    Preview what would be removed without making any changes
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Script configuration
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Color output functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

# Apps to remove - Gaming-safe list
$AppsToRemove = @(
    # Microsoft Office/Productivity (NOT needed for gaming)
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Office.OneNote",
    "Microsoft.Office.Sway",
    "Microsoft.Todos",
    "MicrosoftTeams",
    "MSTeams",
    "Microsoft.Teams",
    "Microsoft.TeamsForSurfaceHub",
    "Microsoft.People",
    "Microsoft.WindowsCommunicationsApps",  # Mail & Calendar
    
    # Bing/News/Weather Apps
    "Microsoft.BingNews",
    "Microsoft.BingFinance",
    "Microsoft.BingFoodAndDrink",
    "Microsoft.BingHealthAndFitness",
    "Microsoft.BingSports",
    "Microsoft.BingTravel",
    "Microsoft.BingWeather",
    "Microsoft.News",
    "Microsoft.BingTranslator",
    
    # Entertainment/Media (can reinstall from Store if needed)
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "SpotifyAB.SpotifyMusic",
    "Microsoft.WindowsSoundRecorder",
    
    # Unnecessary Microsoft Apps
    "Microsoft.549981C3F5F10",  # Cortana (old)
    "Cortana",
    "Microsoft.Clipchamp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsAlarms",
    "Microsoft.MixedReality.Portal",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Print3D",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.3DBuilder",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.OneConnect",
    "Microsoft.Messaging",
    "Microsoft.MicrosoftJournal",
    "Microsoft.SkypeApp",
    
    # Copilot/AI Features
    "Microsoft.Copilot",
    "Microsoft.Windows.Ai.Copilot.Provider",
    
    # Quick Assist (rarely needed on handheld)
    "MicrosoftCorporationII.QuickAssist",
    
    # Family Safety
    "MicrosoftCorporationII.MicrosoftFamily",
    
    # Third-Party Bloatware
    "ACGMediaPlayer",
    "ActiproSoftwareLLC",
    "AdobeSystemsIncorporated.AdobePhotoshopExpress",
    "Amazon.com.Amazon",
    "AmazonVideo.PrimeVideo",
    "Asphalt8Airborne",
    "AutodeskSketchBook",
    "CaesarsSlotsFreeCasino",
    "COOKINGFEVER",
    "CyberLinkMediaSuiteEssentials",
    "DisneyMagicKingdoms",
    "Disney",
    "Dolby",
    "DrawboardPDF",
    "Duolingo-LearnLanguagesforFree",
    "EclipseManager",
    "Facebook",
    "FarmVille2CountryEscape",
    "fitbit",
    "Flipboard",
    "HiddenCity",
    "HULULLC.HULUPLUS",
    "iHeartRadio",
    "Instagram",
    "king.com.BubbleWitch3Saga",
    "king.com.CandyCrushSaga",
    "king.com.CandyCrushSodaSaga",
    "king.com.*",
    "LinkedInforWindows",
    "MarchofEmpires",
    "Netflix",
    "NYTCrossword",
    "OneCalendar",
    "PandoraMediaInc",
    "PhototasticCollage",
    "PicsArt-PhotoStudio",
    "Plex",
    "PolarrPhotoEditorAcademicEdition",
    "RoyalRevolt",
    "Shazam",
    "Sidia.LiveWallpaper",
    "SlingTV",
    "TikTok",
    "TuneInRadio",
    "Twitter",
    "Viber",
    "WinZipUniversal",
    "Wunderlist",
    "XING"
)

# Apps to NEVER remove (Gaming-critical)
$ProtectedApps = @(
    "Microsoft.GamingApp",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.Xbox.TCUI",
    "Microsoft.WindowsStore",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.StorePurchaseApp",
    "Microsoft.WindowsTerminal",
    "*ASUS*",
    "*ROG*",
    "*Armoury*",
    "*Realtek*",
    "*AMD*",
    "*NVIDIA*",
    "*DolbyLaboratories*"
)

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-InstalledApps {
    Write-ColorOutput "Scanning for installed apps..." "Yellow"
    $apps = Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
    return $apps
}

function Test-ProtectedApp {
    param([string]$AppName)
    
    foreach ($protected in $ProtectedApps) {
        if ($AppName -like $protected) {
            return $true
        }
    }
    return $false
}

function Remove-AppxPackageSafely {
    param(
        [Parameter(Mandatory=$true)]
        [Object[]]$Packages,
        [string]$SearchPattern,
        [int]$TotalCount,
        [int]$CurrentIndex,
        [bool]$IsDryRun = $false
    )
    
    $progressPercent = [math]::Round(($CurrentIndex / $TotalCount) * 100)
    $status = if ($IsDryRun) { "Scanning" } else { "Removing" }
    Write-Progress -Activity "$status Apps" -Status "$SearchPattern ($CurrentIndex of $TotalCount)" -PercentComplete $progressPercent
    
    $removedCount = 0
    $protectedCount = 0
    
    foreach ($package in $Packages) {
        # Check if THIS specific package is protected (test against actual package name)
        if (Test-ProtectedApp -AppName $package.Name) {
            Write-Warning "Protected (skipping): $($package.Name)"
            $protectedCount++
            continue
        }
        
        if ($IsDryRun) {
            Write-ColorOutput "  [DRY RUN] Would remove: $($package.Name)" "Cyan"
            $removedCount++
        }
        else {
            try {
                # Remove without -AllUsers parameter for compatibility
                Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
                Write-Success "Removed: $($package.Name)"
                $removedCount++
            }
            catch {
                Write-Warning "Could not remove: $($package.Name) - $($_.Exception.Message)"
            }
        }
    }
    
    if ($removedCount -eq 0 -and $protectedCount -eq 0) {
        Write-ColorOutput "  Not found: $SearchPattern" "DarkGray"
        return @{ Status = "NotFound"; Count = 0 }
    }
    elseif ($removedCount -eq 0 -and $protectedCount -gt 0) {
        return @{ Status = "Protected"; Count = 0 }
    }
    else {
        $status = if ($IsDryRun) { "WouldRemove" } else { "Removed" }
        return @{ Status = $status; Count = $removedCount }
    }
}

function Remove-ProvisionedPackage {
    param(
        [string]$AppName,
        [bool]$IsDryRun = $false
    )
    
    $count = 0
    $provisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$AppName*" }
    
    foreach ($package in $provisionedPackages) {
        if ($IsDryRun) {
            Write-ColorOutput "  [DRY RUN] Would remove provisioned: $($package.DisplayName)" "Cyan"
            $count++
        }
        else {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction Stop | Out-Null
                Write-Success "Removed provisioned package: $($package.DisplayName)"
                $count++
            }
            catch {
                Write-Warning "Could not remove provisioned package: $($package.DisplayName)"
            }
        }
    }
    
    return $count
}

function Show-SystemInfo {
    Write-Header "ROG Ally System Information"
    
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $mem = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    $cpu = Get-CimInstance -ClassName Win32_Processor
    
    Write-ColorOutput "OS: $($os.Caption) $($os.Version)" "White"
    Write-ColorOutput "RAM: $([math]::Round($mem.Sum / 1GB, 2)) GB" "White"
    Write-ColorOutput "CPU: $($cpu.Name)" "White"
    Write-Host ""
}

function Show-ProtectedAppsList {
    Write-Header "Protected Apps (Will NOT be removed)"
    Write-ColorOutput "The following gaming-critical apps are protected:" "Yellow"
    Write-Host ""
    Write-ColorOutput "✓ All Xbox Gaming Services" "Green"
    Write-ColorOutput "✓ Xbox Game Bar & Overlays" "Green"
    Write-ColorOutput "✓ Microsoft Store" "Green"
    Write-ColorOutput "✓ Windows Terminal" "Green"
    Write-ColorOutput "✓ All ASUS/ROG/Armoury Crate apps" "Green"
    Write-ColorOutput "✓ All Realtek audio drivers" "Green"
    Write-ColorOutput "✓ All AMD/NVIDIA drivers" "Green"
    Write-Host ""
}

function Confirm-Execution {
    param([bool]$IsDryRun = $false)
    
    Write-Header "IMPORTANT - Please Read"
    
    if ($IsDryRun) {
        Write-ColorOutput "DRY RUN MODE ENABLED" "Cyan"
        Write-Host ""
        Write-ColorOutput "This will scan and show what would be removed WITHOUT making any changes." "Cyan"
        Write-ColorOutput "No apps will be uninstalled. No system restore point needed." "Cyan"
    }
    else {
        Write-Warning "This script will remove bloatware while preserving gaming functionality."
        Write-Warning "A system restore point is HIGHLY RECOMMENDED before proceeding."
    }
    
    Write-Host ""
    Write-ColorOutput "Apps to be scanned/removed: $($AppsToRemove.Count)" "Yellow"
    Write-Host ""
    
    if ($IsDryRun) {
        $response = Read-Host "Continue with dry run? (Y/n)"
        return ($response -ne "n" -and $response -ne "N")
    }
    else {
        $response = Read-Host "Do you want to continue? (YES/no)"
        return ($response -eq "YES")
    }
}

function Create-RestorePoint {
    Write-Header "System Restore Point"
    $response = Read-Host "Would you like to create a system restore point? (Y/n)"
    
    if ($response -ne "n" -and $response -ne "N") {
        try {
            Write-ColorOutput "Creating restore point..." "Yellow"
            Checkpoint-Computer -Description "Before ROG Ally Debloat" -RestorePointType "MODIFY_SETTINGS"
            Write-Success "Restore point created successfully!"
        }
        catch {
            Write-Warning "Could not create restore point. You may need to enable System Protection first."
            Write-ColorOutput "To enable: Control Panel → System → System Protection → Configure" "Yellow"
            $continue = Read-Host "Continue anyway? (y/N)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                exit
            }
        }
    }
}

function Show-Summary {
    param(
        [int]$RemovedCount,
        [int]$SkippedCount,
        [int]$ProtectedCount,
        [int]$TotalPackages,
        [int]$TotalProvisionedPackages = 0,
        [bool]$IsDryRun = $false
    )
    
    if ($IsDryRun) {
        Write-Header "Dry Run Summary"
        Write-ColorOutput "MODE: DRY RUN - No changes were made" "Cyan"
        Write-Host ""
        Write-ColorOutput "Would remove:" "Yellow"
        Write-ColorOutput "  • $RemovedCount app families" "Yellow"
        Write-ColorOutput "  • $TotalPackages installed packages (current user)" "Yellow"
        if ($TotalProvisionedPackages -gt 0) {
            Write-ColorOutput "  • $TotalProvisionedPackages provisioned packages (new users)" "Yellow"
        }
        Write-Host ""
        Write-ColorOutput "Would skip (not found): $SkippedCount app families" "Yellow"
        Write-ColorOutput "Protected (gaming): $ProtectedCount app families" "Green"
        Write-Host ""
        Write-Success "✓ All Xbox gaming services would be preserved"
        Write-Success "✓ ASUS Armoury Crate would be preserved"
        Write-Success "✓ Microsoft Store would be preserved"
        Write-Host ""
        Write-ColorOutput "To actually remove these apps, run the script without -DryRun parameter" "Yellow"
    }
    else {
        Write-Header "Debloat Summary"
        Write-Success "Successfully removed:"
        Write-Success "  • $RemovedCount app families"
        Write-Success "  • $TotalPackages installed packages (current user)"
        if ($TotalProvisionedPackages -gt 0) {
            Write-Success "  • $TotalProvisionedPackages provisioned packages (new users)"
        }
        Write-Host ""
        Write-ColorOutput "Skipped (not found): $SkippedCount app families" "Yellow"
        Write-ColorOutput "Protected (gaming): $ProtectedCount app families" "Green"
        Write-Host ""
        Write-ColorOutput "✓ All Xbox gaming services preserved" "Green"
        Write-ColorOutput "✓ ASUS Armoury Crate preserved" "Green"
        Write-ColorOutput "✓ Microsoft Store preserved" "Green"
        Write-Host ""
        Write-ColorOutput "Note: Packages removed for current user only." "Yellow"
        Write-ColorOutput "Other user accounts on this device still have their apps." "Yellow"
        Write-Host ""
        Write-Warning "A system restart is recommended to complete the debloat process."
    }
}

function Show-NextSteps {
    Write-Header "Recommended Next Steps"
    Write-Host ""
    Write-ColorOutput "1. DISABLE MEMORY INTEGRITY (Big FPS Boost):" "Cyan"
    Write-Host "   Settings → Privacy & Security → Windows Security →"
    Write-Host "   Device Security → Core Isolation → Turn OFF Memory Integrity"
    Write-Host ""
    Write-ColorOutput "2. DISABLE VIRTUAL MACHINE PLATFORM:" "Cyan"
    Write-Host "   Settings → Apps → Optional Features → More Windows Features →"
    Write-Host "   Uncheck 'Virtual Machine Platform'"
    Write-Host ""
    Write-ColorOutput "3. OPTIMIZE VRAM ALLOCATION:" "Cyan"
    Write-Host "   Armoury Crate → Performance → GPU Settings → Set to 6-10GB"
    Write-Host ""
    Write-ColorOutput "4. CLEAN STARTUP PROGRAMS:" "Cyan"
    Write-Host "   Task Manager (Ctrl+Shift+Esc) → Startup Tab"
    Write-Host "   Disable everything except ASUS/Realtek/AMD components"
    Write-Host ""
}

# ============================================
# MAIN SCRIPT EXECUTION
# ============================================

Clear-Host

# Banner
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                   ║" -ForegroundColor Cyan
Write-Host "║        ROG ALLY GAMING-OPTIMIZED DEBLOAT          ║" -ForegroundColor Cyan
Write-Host "║                                                   ║" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "║              🔍 DRY RUN MODE 🔍                   ║" -ForegroundColor Yellow
    Write-Host "║         (Preview only - no changes)               ║" -ForegroundColor Yellow
}
else {
    Write-Host "║     Removes bloat, preserves gaming services      ║" -ForegroundColor Cyan
}

Write-Host "║                                                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
if (-not (Test-AdminPrivileges)) {
    Write-Error "This script must be run as Administrator!"
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

# Show system info
Show-SystemInfo

# Show protected apps
Show-ProtectedAppsList

# Confirm execution
if (-not (Confirm-Execution -IsDryRun $DryRun)) {
    Write-ColorOutput "`nOperation cancelled by user." "Yellow"
    exit
}

# Offer restore point (skip in dry run mode)
if (-not $DryRun) {
    Create-RestorePoint
}

# Start debloat process
if ($DryRun) {
    Write-Header "Starting Dry Run Scan"
    Write-ColorOutput "Scanning installed apps - no changes will be made..." "Cyan"
}
else {
    Write-Header "Starting Debloat Process"
}

$removedCount = 0
$skippedCount = 0
$protectedCount = 0
$totalPackages = 0
$totalProvisionedPackages = 0
$totalApps = $AppsToRemove.Count
$currentIndex = 0

foreach ($app in $AppsToRemove) {
    $currentIndex++
    
    # Check if the raw app pattern itself is protected (before wildcard expansion)
    if (Test-ProtectedApp -AppName $app) {
        $protectedCount++
        continue
    }
    
    # Build search pattern - only add wildcards if not already present
    $searchPattern = if ($app -match '[\*\?]') { $app } else { "*$app*" }
    
    # Try to find matching packages
    $packages = Get-AppxPackage -Name $searchPattern -ErrorAction SilentlyContinue
    
    if ($packages) {
        $result = Remove-AppxPackageSafely -Packages $packages -SearchPattern $app -TotalCount $totalApps -CurrentIndex $currentIndex -IsDryRun $DryRun
        
        if ($result.Status -eq "Removed" -or $result.Status -eq "WouldRemove") {
            $removedCount++
            $totalPackages += $result.Count
            
            # Also handle provisioned packages
            $provisionedResult = Remove-ProvisionedPackage -AppName $app -IsDryRun $DryRun
            $totalProvisionedPackages += $provisionedResult
        }
    }
    else {
        $skippedCount++
    }
}

$activityText = if ($DryRun) { "Scanning Apps" } else { "Removing Apps" }
Write-Progress -Activity $activityText -Completed

# Show summary
Show-Summary -RemovedCount $removedCount -SkippedCount $skippedCount -ProtectedCount $protectedCount -TotalPackages $totalPackages -TotalProvisionedPackages $totalProvisionedPackages -IsDryRun $DryRun

# Show next steps (only if not dry run)
if (-not $DryRun) {
    Show-NextSteps
}

# Restart prompt (skip in dry run)
if (-not $DryRun) {
    Write-Host ""
    $restart = Read-Host "Would you like to restart now? (y/N)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Write-ColorOutput "`nRestarting in 10 seconds..." "Yellow"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
    else {
        Write-ColorOutput "`nPlease restart your ROG Ally when convenient." "Yellow"
        Write-Host ""
        Read-Host "Press Enter to exit"
    }
}
else {
    Write-Host ""
    Write-ColorOutput "Dry run complete! No changes were made to your system." "Green"
    Write-ColorOutput "To actually remove these apps, run the script again without -DryRun" "Yellow"
    Write-Host ""
    Read-Host "Press Enter to exit"
}
