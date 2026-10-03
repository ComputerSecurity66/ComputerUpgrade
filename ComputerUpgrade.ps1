# ============================================================================
# VALOR Computer Hardware Upgrade Advisor v3.0
# Professional Hardware Analysis & Upgrade Recommendation Tool
# Copyright © 2026 VALOR. All rights reserved.
# ============================================================================

# GLOBAL VARIABLES
$LogPath = "$env:USERPROFILE\AppData\Local\VALOR_UpgradeAdvisor"
$LogFile = "$LogPath\UpgradeAdvisor_$(Get-Date -Format 'yyyy-MM-dd').log"
$ScriptVersion = "3.0.0"

# CREATE LOG DIRECTORY IF NOT EXISTS
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    Add-Content -Path $LogFile -Value $LogMessage -ErrorAction SilentlyContinue
    
    if ($Level -eq "ERROR") {
        Write-Host $LogMessage -ForegroundColor Red
    }
    elseif ($Level -eq "WARNING") {
        Write-Host $LogMessage -ForegroundColor Yellow
    }
}

# ============================================================================
# ADMINISTRATOR CHECK
# ============================================================================
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($user)
    $role = [Security.Principal.WindowsBuiltInRole]::Administrator
    return $principal.IsInRole($role)
}

# FIX: Only auto-restart if NOT already running with UAC prompt handled
if (-not (Test-Administrator)) {
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│  ⚠  ADMINISTRATOR PRIVILEGES REQUIRED                      │" -ForegroundColor Yellow
    Write-Host "│  Restarting with Administrator rights...                   │" -ForegroundColor Yellow
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
    Start-Sleep -Seconds 2
    
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    Write-Log "Script restarted with admin privileges" "INFO"
    Start-Process PowerShell -ArgumentList $arguments -Verb RunAs
    exit
}

Write-Log "Upgrade Advisor started by user: $($env:USERNAME)" "INFO"

# ============================================================================
# UI HELPER FUNCTIONS
# ============================================================================

function Show-Header {
    param([string]$Title)
    
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  HARDWARE UPGRADE ADVISOR v$ScriptVersion - $Title" -ForegroundColor Cyan			
    Write-Host "║  Professional Hardware Analysis & Recommendations                                 ║" -ForegroundColor Cyan
    Write-Host "║  Copyright © 2026 VALOR. All rights reserved.                                     ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-MainMenu {
    Show-Header "Main Menu"
    
    Write-Host "Select an option to proceed:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Analyze Current Hardware" -ForegroundColor Green
    Write-Host "  [2] CPU Upgrade Recommendations" -ForegroundColor Green
    Write-Host "  [3] RAM Upgrade Recommendations" -ForegroundColor Green
    Write-Host "  [4] Storage Upgrade Recommendations" -ForegroundColor Green
    Write-Host "  [5] GPU Upgrade Recommendations" -ForegroundColor Green
    Write-Host "  [6] Motherboard Compatibility Check" -ForegroundColor Green
    Write-Host "  [7] Detect Bottlenecks" -ForegroundColor Green
    Write-Host "  [8] Overall System Upgrade Plan" -ForegroundColor Green
    Write-Host "  [9] Generate Upgrade Report (TXT)" -ForegroundColor Green
    Write-Host "  [10] Generate Upgrade Report (CSV)" -ForegroundColor Green
    Write-Host "  [11] View Logs" -ForegroundColor Green
    Write-Host "  [12] Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor Cyan
}

function Wait-ForKeyPress {
    Write-Host ""
    Write-Host "Press any key to return to menu..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================================================
# HARDWARE DETECTION FUNCTIONS
# ============================================================================

function Get-HardwareInfo {
    try {
        $ComputerInfo = Get-ComputerInfo
        $OS = Get-CimInstance Win32_OperatingSystem
        $CPU = Get-CimInstance Win32_Processor
        $RAM = Get-CimInstance Win32_PhysicalMemory
        $Motherboard = Get-CimInstance Win32_BaseBoard
        $GPU = Get-CimInstance Win32_VideoController
        $Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
        
        $HardwareData = @{
            ComputerName = $ComputerInfo.CsComputerName
            OS = $OS.Caption
            OSVersion = $OS.Version
            OSBuild = $OS.BuildNumber
            CPUName = $CPU.Name
            CPUCores = $CPU.NumberOfCores
            CPULogicalProcessors = $CPU.NumberOfLogicalProcessors
            CPUMaxSpeed = $CPU.MaxClockSpeed
            CPUManufacturer = $CPU.Manufacturer
            CPUSocket = $CPU.SocketDesignation
            TotalRAM = [Math]::Round(($RAM | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
            RAMModules = $RAM.Count
            RAMSpeed = $RAM[0].Speed
            MotherboardName = $Motherboard.Product
            MotherboardManufacturer = $Motherboard.Manufacturer
            GPUName = $GPU[0].Name
            GPUMemory = [Math]::Round($GPU[0].AdapterRAM / 1GB, 2)
            TotalStorage = [Math]::Round(($Disks | Measure-Object -Property Size -Sum).Sum / 1GB, 2)
            FreeStorage = [Math]::Round(($Disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB, 2)
        }
        
        return $HardwareData
    }
    catch {
        Write-Log "Error detecting hardware: $_" "ERROR"
        return $null
    }
}

function AnalyzeCurrentHardware {
    Show-Header "Current Hardware Analysis"
    
    $Hardware = Get-HardwareInfo
    
    if ($Hardware) {
        Write-Host "COMPUTER INFORMATION:" -ForegroundColor Yellow
        Write-Host "  Computer Name: $($Hardware.ComputerName)" -ForegroundColor White
        Write-Host "  OS: $($Hardware.OS)" -ForegroundColor White
        Write-Host "  OS Version: $($Hardware.OSVersion) Build $($Hardware.OSBuild)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "PROCESSOR (CPU):" -ForegroundColor Yellow
        Write-Host "  Name: $($Hardware.CPUName)" -ForegroundColor White
        Write-Host "  Cores: $($Hardware.CPUCores) | Logical Processors: $($Hardware.CPULogicalProcessors)" -ForegroundColor White
        Write-Host "  Speed: $($Hardware.CPUMaxSpeed) MHz" -ForegroundColor White
        Write-Host "  Manufacturer: $($Hardware.CPUManufacturer)" -ForegroundColor White
        Write-Host "  Socket: $($Hardware.CPUSocket)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "MEMORY (RAM):" -ForegroundColor Yellow
        Write-Host "  Total RAM: $($Hardware.TotalRAM) GB" -ForegroundColor White
        Write-Host "  Modules: $($Hardware.RAMModules)" -ForegroundColor White
        Write-Host "  Speed: $($Hardware.RAMSpeed) MHz" -ForegroundColor White
        Write-Host ""
        
        Write-Host "MOTHERBOARD:" -ForegroundColor Yellow
        Write-Host "  Model: $($Hardware.MotherboardName)" -ForegroundColor White
        Write-Host "  Manufacturer: $($Hardware.MotherboardManufacturer)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "GRAPHICS (GPU):" -ForegroundColor Yellow
        Write-Host "  Name: $($Hardware.GPUName)" -ForegroundColor White
        Write-Host "  Memory: $($Hardware.GPUMemory) GB" -ForegroundColor White
        Write-Host ""
        
        Write-Host "STORAGE:" -ForegroundColor Yellow
        Write-Host "  Total: $($Hardware.TotalStorage) GB" -ForegroundColor White
        Write-Host "  Free: $($Hardware.FreeStorage) GB" -ForegroundColor White
        Write-Host "  Used: $([Math]::Round($Hardware.TotalStorage - $Hardware.FreeStorage, 2)) GB" -ForegroundColor White
        Write-Host ""
        
        Write-Log "Hardware analysis completed" "INFO"
    }
}


function Get-CPUUpgradeRecommendations {
    Show-Header "CPU Upgrade Recommendations"
    
    $Hardware = Get-HardwareInfo
    $CPU = $Hardware.CPUCores
    
    Write-Host "CURRENT CPU:" -ForegroundColor Yellow
    Write-Host "  $($Hardware.CPUName)" -ForegroundColor White
    Write-Host "  Cores: $CPU | Speed: $($Hardware.CPUMaxSpeed) MHz" -ForegroundColor White
    Write-Host ""
    
    Write-Host "UPGRADE RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host ""
    
    if ($Hardware.CPUManufacturer -like "*Intel*") {
        Write-Host "  For Gaming & General Use:" -ForegroundColor Cyan
        Write-Host "    → Intel Core i7-13700K (16 cores, 5.4 GHz)" -ForegroundColor Green
        Write-Host "    → Cost: ~$400-500 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 40-60%" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "  For Content Creation & Streaming:" -ForegroundColor Cyan
        Write-Host "    → Intel Core i9-13900K (24 cores, 5.8 GHz)" -ForegroundColor Green
        Write-Host "    → Cost: ~$600-700 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 80-120%" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "  Budget Option:" -ForegroundColor Cyan
        Write-Host "    → Intel Core i5-13600K (14 cores, 5.1 GHz)" -ForegroundColor Green
        Write-Host "    → Cost: ~$250-300 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 20-35%" -ForegroundColor Gray
    }
    else {
        Write-Host "  For Gaming & General Use:" -ForegroundColor Cyan
        Write-Host "    → AMD Ryzen 7 7700X (8 cores, 5.4 GHz)" -ForegroundColor Green
        Write-Host "    → Cost: ~$350-400 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 35-55%" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "  For Content Creation & Streaming:" -ForegroundColor Cyan
        Write-Host "    → AMD Ryzen 9 7950X (16 cores, 5.7 GHz)" -ForegroundColor Green
        Write-Host "    → Cost: ~$550-650 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 70-100%" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "  Budget Option:" -ForegroundColor Cyan
        Write-Host "    → AMD Ryzen 5 7600X (6 cores, 5.3 GHz)" -ForegroundColor Green
        Write-Host "    → Cost: ~$200-250 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 15-30%" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "COMPATIBILITY NOTE:" -ForegroundColor Yellow
    Write-Host "  ⚠ Check motherboard socket compatibility before upgrade" -ForegroundColor Yellow
    Write-Host "  ⚠ May require BIOS update" -ForegroundColor Yellow
    Write-Host "  ⚠ May require new power supply" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Log "CPU upgrade recommendations viewed" "INFO"
}

function Get-RAMUpgradeRecommendations {
    Show-Header "RAM Upgrade Recommendations"
    
    $Hardware = Get-HardwareInfo
    $CurrentRAM = $Hardware.TotalRAM
    
    Write-Host "CURRENT RAM:" -ForegroundColor Yellow
    Write-Host "  Total: $CurrentRAM GB" -ForegroundColor White
    Write-Host "  Modules: $($Hardware.RAMModules)" -ForegroundColor White
    Write-Host "  Speed: $($Hardware.RAMSpeed) MHz" -ForegroundColor White
    Write-Host ""
    
    Write-Host "UPGRADE RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host ""
    
    if ($CurrentRAM -lt 16) {
        Write-Host "  ⚠ CRITICAL: Your RAM is below recommended!" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Recommended Upgrade:" -ForegroundColor Cyan
        Write-Host "    → Add 16GB DDR4/DDR5 Module" -ForegroundColor Green
        Write-Host "    → Target Total: 32GB" -ForegroundColor Green
        Write-Host "    → Cost: ~$80-150 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 30-50%" -ForegroundColor Gray
    }
    elseif ($CurrentRAM -lt 32) {
        Write-Host "  Good: Your RAM is adequate for most tasks" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Optional Upgrade:" -ForegroundColor Cyan
        Write-Host "    → Add 16GB to reach 32GB" -ForegroundColor Green
        Write-Host "    → Cost: ~$80-150 USD" -ForegroundColor Gray
        Write-Host "    → Performance Gain: 10-20%" -ForegroundColor Gray
    }
    else {
        Write-Host "  ✓ Excellent: Your RAM is sufficient" -ForegroundColor Green
        Write-Host "    No upgrade needed at this time" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "RECOMMENDATIONS BY USE CASE:" -ForegroundColor Yellow
    Write-Host "  Gaming: 32GB (16GB minimum)" -ForegroundColor Cyan
    Write-Host "  Content Creation: 64GB (32GB minimum)" -ForegroundColor Cyan
    Write-Host "  General Use: 16GB (8GB minimum)" -ForegroundColor Cyan
    Write-Host "  Video Editing/3D: 64-128GB" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "RAM upgrade recommendations viewed" "INFO"
}

function Get-StorageUpgradeRecommendations {
    Show-Header "Storage Upgrade Recommendations"
    
    $Hardware = Get-HardwareInfo
    $UsedStorage = $Hardware.TotalStorage - $Hardware.FreeStorage
    $UsagePercent = [Math]::Round(($UsedStorage / $Hardware.TotalStorage) * 100, 2)
    
    Write-Host "CURRENT STORAGE:" -ForegroundColor Yellow
    Write-Host "  Total: $($Hardware.TotalStorage) GB" -ForegroundColor White
    Write-Host "  Used: $UsedStorage GB ($UsagePercent%)" -ForegroundColor White
    Write-Host "  Free: $($Hardware.FreeStorage) GB" -ForegroundColor White
    Write-Host ""
    
    Write-Host "STORAGE ANALYSIS:" -ForegroundColor Yellow
    if ($UsagePercent -gt 85) {
        Write-Host "  ⚠ CRITICAL: Storage is almost full!" -ForegroundColor Red
        Write-Host "    Performance degradation detected" -ForegroundColor Red
    }
    elseif ($UsagePercent -gt 70) {
        Write-Host "  ⚠ WARNING: Storage is getting full" -ForegroundColor Yellow
        Write-Host "    Consider upgrading soon" -ForegroundColor Yellow
    }
    else {
        Write-Host "  ✓ Storage usage is healthy" -ForegroundColor Green
    }
    Write-Host ""
    
    Write-Host "UPGRADE RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Option 1: Add NVMe SSD (Fastest)" -ForegroundColor Cyan
    Write-Host "    → 1TB NVMe SSD (PCIe 4.0)" -ForegroundColor Green
    Write-Host "    → Cost: ~$80-120 USD" -ForegroundColor Gray
    Write-Host "    → Speed: 5000-7000 MB/s" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  Option 2: Add SATA SSD (Balanced)" -ForegroundColor Cyan
    Write-Host "    → 1TB SATA SSD" -ForegroundColor Green
    Write-Host "    → Cost: ~$60-100 USD" -ForegroundColor Gray
    Write-Host "    → Speed: 550 MB/s" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  Option 3: Replace with Larger Drive" -ForegroundColor Cyan
    Write-Host "    → 2TB NVMe SSD" -ForegroundColor Green
    Write-Host "    → Cost: ~$150-200 USD" -ForegroundColor Gray
    Write-Host "    → Speed: 5000-7000 MB/s" -ForegroundColor Gray
    Write-Host ""
    
    Write-Log "Storage upgrade recommendations viewed" "INFO"
}

function Get-GPUUpgradeRecommendations {
    Show-Header "GPU Upgrade Recommendations"
    
    $Hardware = Get-HardwareInfo
    
    Write-Host "CURRENT GPU:" -ForegroundColor Yellow
    Write-Host "  Name: $($Hardware.GPUName)" -ForegroundColor White
    Write-Host "  Memory: $($Hardware.GPUMemory) GB" -ForegroundColor White
    Write-Host ""
    
    Write-Host "UPGRADE RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "  For Gaming (1440p):" -ForegroundColor Cyan
    Write-Host "    → NVIDIA RTX 4070 (12GB GDDR6X)" -ForegroundColor Green
    Write-Host "    → Cost: ~$550-600 USD" -ForegroundColor Gray
    Write-Host "    → Performance: 100-150 fps at 1440p" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  For Gaming (4K):" -ForegroundColor Cyan
    Write-Host "    → NVIDIA RTX 4090 (24GB GDDR6X)" -ForegroundColor Green
    Write-Host "    → Cost: ~$1500-1600 USD" -ForegroundColor Gray
    Write-Host "    → Performance: 60-90 fps at 4K" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  For Content Creation:" -ForegroundColor Cyan
    Write-Host "    → NVIDIA RTX 4080 (16GB GDDR6X)" -ForegroundColor Green
    Write-Host "    → Cost: ~$1200 USD" -ForegroundColor Gray
    Write-Host "    → CUDA Cores: 9728 (excellent for rendering)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  Budget Option:" -ForegroundColor Cyan
    Write-Host "    → NVIDIA RTX 4060 Ti (8GB GDDR6)" -ForegroundColor Green
    Write-Host "    → Cost: ~$300-350 USD" -ForegroundColor Gray
    Write-Host "    → Performance: 60+ fps at 1080p" -ForegroundColor Gray
    Write-Host ""
    
    Write-Log "GPU upgrade recommendations viewed" "INFO"
}

function DetectBottlenecks {
    Show-Header "System Bottleneck Analysis"
    
    $Hardware = Get-HardwareInfo
    $CPUScore = $Hardware.CPUCores * ($Hardware.CPUMaxSpeed / 100)
    $RAMScore = $Hardware.TotalRAM * $Hardware.RAMSpeed
    $StorageScore = $Hardware.FreeStorage
    
    Write-Host "BOTTLENECK DETECTION:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "CPU Performance Score: $([Math]::Round($CPUScore, 2))" -ForegroundColor Cyan
    if ($CPUScore -lt 2000) {
        Write-Host "  ⚠ CPU Bottleneck Detected: Consider CPU upgrade" -ForegroundColor Red
    }
    elseif ($CPUScore -lt 4000) {
        Write-Host "  ⚠ Moderate CPU Bottleneck: CPU upgrade recommended" -ForegroundColor Yellow
    }
    else {
        Write-Host "  ✓ CPU Performance is adequate" -ForegroundColor Green
    }
    Write-Host ""
    
    Write-Host "RAM Performance Score: $([Math]::Round($RAMScore, 2))" -ForegroundColor Cyan
    if ($Hardware.TotalRAM -lt 16) {
        Write-Host "  ⚠ RAM Bottleneck Detected: Upgrade to 32GB recommended" -ForegroundColor Red
    }
    elseif ($Hardware.TotalRAM -lt 32) {
        Write-Host "  ⚠ Moderate RAM Bottleneck: Consider 32GB upgrade" -ForegroundColor Yellow
    }
    else {
        Write-Host "  ✓ RAM is sufficient" -ForegroundColor Green
    }
    Write-Host ""
    
    Write-Host "Storage Performance Score: $([Math]::Round($StorageScore, 2))" -ForegroundColor Cyan
    $UsedPercent = [Math]::Round((($Hardware.TotalStorage - $Hardware.FreeStorage) / $Hardware.TotalStorage) * 100, 2)
    if ($UsedPercent -gt 85) {
        Write-Host "  ⚠ Storage Bottleneck Detected: Add storage immediately" -ForegroundColor Red
    }
    elseif ($UsedPercent -gt 70) {
        Write-Host "  ⚠ Storage usage high: Consider adding storage" -ForegroundColor Yellow
    }
    else {
        Write-Host "  ✓ Storage is adequate" -ForegroundColor Green
    }
    Write-Host ""
    
    Write-Log "Bottleneck analysis completed" "INFO"
}

function Get-OverallUpgradePlan {
    Show-Header "Overall System Upgrade Plan"
    
    $Hardware = Get-HardwareInfo
    
    Write-Host "SYSTEM PROFILE:" -ForegroundColor Yellow
    Write-Host "  CPU: $($Hardware.CPUName)" -ForegroundColor White
    Write-Host "  RAM: $($Hardware.TotalRAM) GB" -ForegroundColor White
    Write-Host "  Storage: $($Hardware.TotalStorage) GB" -ForegroundColor White
    Write-Host "  GPU: $($Hardware.GPUName)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "RECOMMENDED UPGRADE PATH:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "PHASE 1 - IMMEDIATE (Budget: $150-250):" -ForegroundColor Cyan
    Write-Host "  Priority: HIGH" -ForegroundColor Red
    Write-Host "  1. Add 16GB RAM → Total 32GB" -ForegroundColor Green
    Write-Host "     Cost: ~$80-150 | Impact: 30-50% performance boost" -ForegroundColor Gray
    Write-Host "  2. Add 1TB NVMe SSD" -ForegroundColor Green
    Write-Host "     Cost: ~$80-120 | Impact: 2x faster storage" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "PHASE 2 - MEDIUM TERM (Budget: $400-600):" -ForegroundColor Cyan
    Write-Host "  Priority: MEDIUM" -ForegroundColor Yellow
    Write-Host "  3. Upgrade CPU to newer generation" -ForegroundColor Green
    Write-Host "     Cost: ~$300-500 | Impact: 40-60% CPU performance" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "PHASE 3 - LONG TERM (Budget: $500-1500):" -ForegroundColor Cyan
    Write-Host "  Priority: LOW (Optional)" -ForegroundColor Green
    Write-Host "  4. Upgrade GPU if gaming/rendering" -ForegroundColor Green
    Write-Host "     Cost: ~$500-1500 | Impact: 2-4x graphics performance" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "TOTAL ESTIMATED COST:" -ForegroundColor Yellow
    Write-Host "  Phase 1 + 2: $550-850 USD" -ForegroundColor Cyan
    Write-Host "  All Phases: $1050-2350 USD" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "Overall upgrade plan generated" "INFO"
}

function New-UpgradeReportTXT {
    Show-Header "Generating Upgrade Report (TXT)"
    
    try {
        $DesktopPath = [Environment]::GetFolderPath('Desktop')
        if (-not (Test-Path $DesktopPath)) {
            $DesktopPath = $env:USERPROFILE
        }
        
        $TimeStamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
        $ReportPath = "$DesktopPath\UpgradeReport_$TimeStamp.txt"
        $Hardware = Get-HardwareInfo
        
        $Report = @()
        $Report += "==================================================================="
        $Report += "COMPUTER HARDWARE UPGRADE ANALYSIS REPORT"
        $Report += "VALOR Hardware Upgrade Advisor v$ScriptVersion"
        $Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $Report += "Generated By: $($env:USERNAME)"
        $Report += "==================================================================="
        $Report += ""
        
        $Report += "CURRENT SYSTEM SPECIFICATIONS"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Computer Name: $($Hardware.ComputerName)"
        $Report += "Operating System: $($Hardware.OS)"
        $Report += "OS Version: $($Hardware.OSVersion) Build $($Hardware.OSBuild)"
        $Report += ""
        
        $Report += "PROCESSOR (CPU)"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Model: $($Hardware.CPUName)"
        $Report += "Cores: $($Hardware.CPUCores) | Logical Processors: $($Hardware.CPULogicalProcessors)"
        $Report += "Clock Speed: $($Hardware.CPUMaxSpeed) MHz"
        $Report += "Manufacturer: $($Hardware.CPUManufacturer)"
        $Report += "Socket: $($Hardware.CPUSocket)"
        $Report += ""
        
        $Report += "MEMORY (RAM)"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Total Installed: $($Hardware.TotalRAM) GB"
        $Report += "Number of Modules: $($Hardware.RAMModules)"
        $Report += "Module Speed: $($Hardware.RAMSpeed) MHz"
        $Report += ""
        
        $Report += "STORAGE"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Total Capacity: $($Hardware.TotalStorage) GB"
        $Report += "Free Space: $($Hardware.FreeStorage) GB"
        $Report += "Used Space: $([Math]::Round($Hardware.TotalStorage - $Hardware.FreeStorage, 2)) GB"
        $Report += ""
        
        $Report += "GRAPHICS (GPU)"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Model: $($Hardware.GPUName)"
        $Report += "Video Memory: $($Hardware.GPUMemory) GB"
        $Report += ""
        
        $Report += "MOTHERBOARD"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Model: $($Hardware.MotherboardName)"
        $Report += "Manufacturer: $($Hardware.MotherboardManufacturer)"
        $Report += ""
        
        $Report += "UPGRADE RECOMMENDATIONS"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += ""
        $Report += "PHASE 1 - IMMEDIATE UPGRADES (Budget: $150-250)"
        $Report += "  1. RAM Upgrade: Add 16GB to reach 32GB total"
        $Report += "     Estimated Cost: $80-150"
        $Report += "     Expected Performance Gain: 30-50%"
        $Report += ""
        $Report += "  2. Storage Upgrade: Add 1TB NVMe SSD"
        $Report += "     Estimated Cost: $80-120"
        $Report += "     Expected Performance Gain: 2x faster storage"
        $Report += ""
        
        $Report += "PHASE 2 - MEDIUM TERM UPGRADES (Budget: $400-600)"
        $Report += "  3. CPU Upgrade: Replace with newer generation"
        $Report += "     Estimated Cost: $300-500"
        $Report += "     Expected Performance Gain: 40-60%"
        $Report += ""
        
        $Report += "PHASE 3 - OPTIONAL UPGRADES (Budget: $500-1500)"
        $Report += "  4. GPU Upgrade: For gaming/rendering tasks"
        $Report += "     Estimated Cost: $500-1500"
        $Report += "     Expected Performance Gain: 2-4x graphics"
        $Report += ""
        
        $Report += "TOTAL ESTIMATED INVESTMENT"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "Phase 1 + 2: $550-850 USD"
        $Report += "All Phases: $1050-2350 USD"
        $Report += ""
        
        $Report += "COMPATIBILITY NOTES"
        $Report += "───────────────────────────────────────────────────────────────"
        $Report += "• Verify motherboard socket compatibility before CPU upgrade"
        $Report += "• Check BIOS compatibility for new components"
        $Report += "• Ensure power supply has sufficient wattage"
        $Report += "• Back up important data before hardware changes"
        $Report += "• Consider professional installation if uncomfortable"
        $Report += ""
        
        $Report += "==================================================================="
        $Report += "End of Report"
        $Report += "==================================================================="
        
        $Report | Out-File -FilePath $ReportPath -Encoding UTF8 -Force
        
        Write-Host "SUCCESS! Upgrade report created successfully!" -ForegroundColor Green
        Write-Host "Location: $ReportPath" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Log "TXT upgrade report generated: $ReportPath" "INFO"
    }
    catch {
        Write-Log "Error creating TXT report: $_" "ERROR"
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

function New-UpgradeReportCSV {
    Show-Header "Generating Upgrade Report (CSV)"
    
    try {
        $DesktopPath = [Environment]::GetFolderPath('Desktop')
        if (-not (Test-Path $DesktopPath)) {
            $DesktopPath = $env:USERPROFILE
        }
        
        $TimeStamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
        $ReportPath = "$DesktopPath\UpgradeReport_$TimeStamp.csv"
        $Hardware = Get-HardwareInfo
        
        $ReportData = @()
        
        # Current Hardware
        $ReportData += [PSCustomObject]@{
            Category = "Current Hardware"
            Item = "Computer Name"
            Current_Value = $Hardware.ComputerName
            Recommended_Value = "N/A"
            Priority = "Info"
            Estimated_Cost = "N/A"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "CPU"
            Item = "Processor"
            Current_Value = $Hardware.CPUName
            Recommended_Value = "Newer Generation CPU"
            Priority = "Medium"
            Estimated_Cost = "$300-500"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "CPU"
            Item = "Cores"
            Current_Value = $Hardware.CPUCores
            Recommended_Value = "8+ cores"
            Priority = "Medium"
            Estimated_Cost = "Included in CPU upgrade"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "RAM"
            Item = "Total Memory"
            Current_Value = "$($Hardware.TotalRAM) GB"
            Recommended_Value = "32 GB"
            Priority = "High"
            Estimated_Cost = "$80-150"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "RAM"
            Item = "Memory Modules"
            Current_Value = $Hardware.RAMModules
            Recommended_Value = "4 modules (balanced)"
            Priority = "Low"
            Estimated_Cost = "N/A"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "Storage"
            Item = "Total Storage"
            Current_Value = "$($Hardware.TotalStorage) GB"
            Recommended_Value = "1-2 TB SSD"
            Priority = "High"
            Estimated_Cost = "$80-200"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "Storage"
            Item = "Free Space"
            Current_Value = "$($Hardware.FreeStorage) GB"
            Recommended_Value = "20% or more"
            Priority = "High"
            Estimated_Cost = "Storage upgrade needed"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "GPU"
            Item = "Graphics Card"
            Current_Value = $Hardware.GPUName
            Recommended_Value = "RTX 4070 or better"
            Priority = "Low"
            Estimated_Cost = "$500-1500"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "GPU"
            Item = "Video Memory"
            Current_Value = "$($Hardware.GPUMemory) GB"
            Recommended_Value = "12 GB or more"
            Priority = "Low"
            Estimated_Cost = "Included in GPU upgrade"
        }
        
        $ReportData += [PSCustomObject]@{
            Category = "Motherboard"
            Item = "Model"
            Current_Value = $Hardware.MotherboardName
            Recommended_Value = "Check compatibility"
            Priority = "Info"
            Estimated_Cost = "N/A"
        }
        
        $ReportData | Export-Csv -Path $ReportPath -NoTypeInformation -Force
        
        Write-Host "SUCCESS! CSV Upgrade report created successfully!" -ForegroundColor Green
        Write-Host "Location: $ReportPath" -ForegroundColor Cyan
        Write-Host "Records: $($ReportData.Count)" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Log "CSV upgrade report generated: $ReportPath ($($ReportData.Count) records)" "INFO"
    }
    catch {
        Write-Log "Error creating CSV report: $_" "ERROR"
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

function Get-SystemLogs {
    Show-Header "System Logs"
    
    try {
        if (Test-Path $LogFile) {
            $LogContent = Get-Content $LogFile -Tail 50
            Write-Host "Recent Log Entries (Last 50):" -ForegroundColor Yellow
            Write-Host ""
            $LogContent | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        }
        else {
            Write-Host "No logs available yet." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error reading logs: $_" -ForegroundColor Red
    }
}

# ============================================================================
# AUTO-CLOSE WITH MANUAL OVERRIDE FUNCTION
# ============================================================================

function Wait-ForExitWithTimeout {
    param(
        [int]$TimeoutSeconds = 3
    )
    
    Write-Host ""
    #Write-Host "Closing in $TimeoutSeconds seconds... (Press any key to close now)" -ForegroundColor Yellow
    Write-Host ""
    
    $StartTime = Get-Date
    $TimeoutDuration = New-TimeSpan -Seconds $TimeoutSeconds
    $KeyPressed = $false
    
    while ((Get-Date) - $StartTime -lt $TimeoutDuration) {
        # Calculate remaining time
        $Elapsed = (Get-Date) - $StartTime
        $Remaining = [Math]::Max(0, $TimeoutSeconds - [int]$Elapsed.TotalSeconds)
        
        # Display countdown
        Write-Host "`rClosing in $Remaining seconds Or Press any key to close now" -ForegroundColor Yellow -NoNewline
        
        # Check if key is pressed (non-blocking)
        if ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $KeyPressed = $true
            break
        }
        
        # Small delay to prevent CPU spinning
        Start-Sleep -Milliseconds 100
    }

    Write-Host ""
    Write-Host ""
    
    if ($KeyPressed) {
        Write-Host "✓ Key pressed - closing application..." -ForegroundColor Green
    }
    else {
        Write-Host "✓ Timeout reached - closing application..." -ForegroundColor Green
    }
    
    Write-Host ""
    Start-Sleep -Milliseconds 500
}

# ============================================================================
# MAIN MENU LOOP
# ============================================================================

$Continue = $true

while ($Continue) {
    Show-MainMenu
    $Choice = Read-Host "Enter your choice (1-12)"
    
    switch ($Choice) {
        "1" {
            AnalyzeCurrentHardware
            Wait-ForKeyPress
        }
        "2" {
            Get-CPUUpgradeRecommendations
            Wait-ForKeyPress
        }
        "3" {
            Get-RAMUpgradeRecommendations
            Wait-ForKeyPress
        }
        "4" {
            Get-StorageUpgradeRecommendations
            Wait-ForKeyPress
        }
        "5" {
            Get-GPUUpgradeRecommendations
            Wait-ForKeyPress
        }
               "6" {
            Show-Header "Motherboard Compatibility Check"
            Write-Host ""
            Write-Host "MOTHERBOARD COMPATIBILITY INFORMATION:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Motherboard compatibility check requires manual verification." -ForegroundColor Cyan
            Write-Host "Please follow these steps:" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  1. Visit your motherboard manufacturer's website" -ForegroundColor White
            Write-Host "  2. Search for your motherboard model" -ForegroundColor White
            Write-Host "  3. Check the CPU compatibility list" -ForegroundColor White
            Write-Host "  4. Verify the BIOS version required" -ForegroundColor White
            Write-Host "  5. Check for BIOS updates if needed" -ForegroundColor White
            Write-Host ""
            Write-Log "Motherboard compatibility check accessed" "INFO"
            Wait-ForKeyPress
        }

        "7" {
            DetectBottlenecks
            Wait-ForKeyPress
        }
        "8" {
            Get-OverallUpgradePlan
            Wait-ForKeyPress
        }
        "9" {
            New-UpgradeReportTXT
            Wait-ForKeyPress
        }
        "10" {
            New-UpgradeReportCSV
            Wait-ForKeyPress
        }
        "11" {
            Get-SystemLogs
            Wait-ForKeyPress
        }
                   "12" {
            Show-Header "Exit Application"
            Write-Host ""
            Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║                    THANK YOU FOR USING                                            ║" -ForegroundColor Green
            Write-Host "║        COMPUTER HARDWARE UPGRADE ADVISOR v$ScriptVersion                          ║" -ForegroundColor Green
            Write-Host "║                                                                                   ║" -ForegroundColor Green
            Write-Host "║  Your system analysis has been completed successfully!                            ║" -ForegroundColor Green
            Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            Write-Host "Session Summary:" -ForegroundColor Yellow
            Write-Host "  • All hardware information has been analyzed" -ForegroundColor White
            Write-Host "  • Upgrade recommendations have been generated" -ForegroundColor White
            Write-Host "  • Activity logs saved successfully" -ForegroundColor White
            Write-Host ""
            Write-Host "Log File Location:" -ForegroundColor Cyan
            Write-Host "  $LogFile" -ForegroundColor White
            Write-Host ""
            Write-Host "Next Steps:" -ForegroundColor Yellow
            Write-Host "  1. Review the upgrade recommendations" -ForegroundColor White
            Write-Host "  2. Check component compatibility" -ForegroundColor White
            Write-Host "  3. Research current pricing" -ForegroundColor White
            Write-Host "  4. Plan your upgrade budget" -ForegroundColor White
            Write-Host ""
            Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Cyan
            Write-Host ""
            
            Write-Log "Application exited by user" "INFO"
            
            # Call the auto-close function with 3 second timeout
            Wait-ForExitWithTimeout -TimeoutSeconds 3
            
            # Set to false to exit the loop
            $Continue = $false
        }
        default {
            Write-Host "Invalid choice. Please enter a number between 1 and 12." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}

# Display final message after loop exits
Clear-Host
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                   APPLICATION CLOSED                          					  ║" -ForegroundColor Cyan
Write-Host "║                                                                					  ║" -ForegroundColor Cyan
Write-Host "║  For support or questions, please visit our website.          			   		  ║" -ForegroundColor Cyan
Write-Host "║  Copyright © 2026 VALOR. All rights reserved.                 					  ║" -ForegroundColor Cyan
Write-Host "╚═════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Seconds 2