# Windows Install Script

Set-ExecutionPolicy RemoteSigned # Execute Scripts

# -------------------- Upgrade --------------------

winget upgrade -h --all

# -------------------- Dependencies --------------------

winget install -e --id Git.Git --accept-package-agreements # Git
winget install -e --id GitHub.cli --accept-package-agreements # GitHub CLI
gh auth login # GitHub Cli Login

# -------------------- Functions --------------------

function DownloadZipToLocation {
    param (
        [string]$Name,
        [string]$URL,
        [string]$Location
    )
    Invoke-WebRequest $URL -OutFile "$Name.zip"
    Expand-Archive "$Name.zip" $Location
    Remove-Item "$Name.zip"
}

function GitHubZipToLocation {
    param (
        [string]$Name,
        [string]$Repo,
        [string]$Pattern,
        [string]$Location,
        [string]$Version,
        [string]$ArchiveType = "zip"
    )
    gh release download $Version -R $Repo --pattern $Pattern
    Get-ChildItem *.$ArchiveType | Rename-Item -NewName { $_.Name -replace $_.Name, "$Name.$ArchiveType" }
    if ($ArchiveType -eq "7z") {
        D:\7-Zip\7z.exe x -o"$Location" "*.7z" -r
    }
    elseif ($ArchiveType -eq "zip") {
        Expand-Archive "$Name.$ArchiveType" $Location
    }
    else {
        Write-Output "Archive type not supported"
    }
    Remove-Item "$Name.$ArchiveType"
}

# -------------------- Confirmation Specific --------------------

$confirmationLaptopDesktop = Read-Host "Are you installing on a Laptop or Desktop l/d"
$confirmationGames = Read-Host "Do you want to install Games y/n"
$confirmationEmulators = Read-Host "Do you want to install Emulators y/n"
$confirmationAmazon = Read-Host "Do you want to install Amazon Send to Kindle y/n"
$confirmationTex = Read-Host "Do you want to install LaTeX y/n"
$confirmationMaple = Read-Host "Do you want to install Maple y/n"
$confirmationMatLab = Read-Host "Do you want to install MatLab y/n"
$confirmationKmonad = Read-Host "Do you want to install Kmonad y/n"
$confirmationDocker = Read-Host "Do you want to install Docker y/n"
$confirmationUbuntu = Read-Host "Do you want to install Ubuntu WSL y/n"
$confirmationDebian = Read-Host "Do you want to install Debian WSL y/n"

# -------------------- Package Managers --------------------

Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression # install scoop

# Chocolatey
Set-ExecutionPolicy Bypass -Scope Process
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# -------------------- Personal GitHub Repos --------------------

Set-Location D:\
mkdir GitHub
Set-Location GitHub
gh repo clone MagnusMat/Windows-Setup
gh repo clone MagnusMat/Windows-Terminal-Setup
gh repo clone MagnusMat/MagnusMat
gh repo clone MagnusMat/PowerShell-Scripts
gh repo clone MagnusMat/test-repo
Set-Location ~

# -------------------------- Games --------------------

if ($confirmationGames -eq 'y') {
    # Battle.net
    # EA Desktop
    # Epic Games
    # GOG Galaxy
    GitHubZipToLocation -Name "Playnite" -Repo JosefNemec/Playnite -Pattern "*.zip" -Location "D:\Playnite" # Playnite
    winget install -e --id Valve.Steam --location "D:\Steam" --accept-package-agreements # Steam
    # Twitch
    # Ubisoft Connect
    # Aliens vs. Predator 2
    # Aliens vs. Predator 2 - Primal Hunt
    # Blur
    # Silent Hill - The Arcade
}

if ($confirmationEmulators -eq 'y') {
    DownloadZipToLocation -Name "Cemu" -URL "https://cemu.info/releases/cemu_1.26.2.zip" -Location "D:\Emulators" # Cemu
    # Citra (https://github.com/citra-emu/citra)
    # Dolphin (https://github.com/dolphin-emu/dolphin)
    # NoPayStation
    # PCSX2 (https://github.com/PCSX2/pcsx2)
    # PCSXR (https://github.com/iCatButler/pcsxr)
    # PPSSPP (https://github.com/hrydgard/ppsspp)
    # Project64](https://github.com/project64/project64)
    # QCMA (https://github.com/codestation/qcma)
    # RetroArch (https://github.com/libretro/RetroArch)
    GitHubZipToLocation -Name "RPCS3" -Repo "RPCS3/rpcs3-binaries-win" -Pattern "*.7z" -Location "D:\Emulators\RPCS3" -ArchiveType "7z" # RPCS3
    # Ryujinx
    # SNES9X
    # Visual Boy Advance
}

# -------------------- Miscellaneous --------------------

if ($confirmationLaptopDesktop -eq 'd') {
    # AI Suite 3
    # Aorus Engine
    # Archi Steam Farm
    # ROG Xonar Phoebus
    # DxWnd
    # Flawless Widescreen
    # Floating ISP (Patch bps Roms) (https://github.com/Alcaro/Flips)
    GitHubZipToLocation -Name "GloSC" -Repo "Alia5/GlosSI" -Pattern "*.zip" -Location "D:\Global Steam Controller" -Version "0.0.7.0" # Global Steam Controller
    # ISO to WBFS
    GitHubZipToLocation -Name "Locale Emulator" -Repo "xupefei/Locale-Emulator" -Pattern "*.zip" -Location "D:\Locale Emulator" # Locale Emulator
    # Lunar IPS
    # Hue Sync
    winget install -e --id 9NG4TL7TX1KW --accept-package-agreements # Notes for Game Bar
}

if ($confirmationLaptopDesktop -eq 'l') {
    # HP Support Assistant
}

if ($confirmationAmazon -eq 'y') {
    # Amazon Send to Kindle
}

if ($confirmationSamsung -eq 'y') {
    # Samsung Magician
}

<# 1Password CLI #>
$arch = "64-bit"
switch ($arch) {
    '64-bit' { $opArch = 'amd64'; break }
    '32-bit' { $opArch = '386'; break }
    Default { Write-Error "Sorry, your operating system architecture '$arch' is unsupported" -ErrorAction Stop }
}
$installDir = Join-Path -Path "D:\" -ChildPath '1Password CLI'
Invoke-WebRequest -Uri "https://cache.agilebits.com/dist/1P/op2/pkg/v2.4.1/op_windows_$($opArch)_v2.4.1.zip" -OutFile op.zip
Expand-Archive -Path op.zip -DestinationPath $installDir -Force
$envMachinePath = [System.Environment]::GetEnvironmentVariable('PATH', 'machine')
if ($envMachinePath -split ';' -notcontains $installDir) {
    [Environment]::SetEnvironmentVariable('PATH', "$envMachinePath;$installDir", 'Machine')
}
Remove-Item -Path op.zip
<# ---------- #>

<# 1Password #>
#Invoke-WebRequest https://downloads.1password.com/win/1PasswordSetup-latest.exe -OutFile 1password.exe
#Needs to do something
#Remove-Item 1password.exe
<# ---------- #>

winget install -e --id 7zip.7zip --location "D:\7-Zip" --accept-package-agreements # 7-Zip
#gh release download -R microsoft/accessibility-insights-windows --pattern "*.msi" -D "D:\" # Accessibility Insights for Windows
winget install -e --id BlenderFoundation.Blender --accept-package-agreements # Blender
winget install -e --id calibre.calibre --accept-package-agreements # Calibre

# CPU-Z

<# Cryptomator #>
#gh release download -R cryptomator/cryptomator --pattern "*.msi" -D "D:\" # Cryptomator
<# ---------- #>

winget install -e --id Discord.Discord --accept-package-agreements # Discord
# Draw.io
# DroidCam
# eM Client
winget install -e --id Microsoft.Teams --accept-package-agreements # Microsoft Teams

# FileZilla
# Mozilla Firefox https://gmusumeci.medium.com/unattended-install-of-firefox-browser-using-powershell-6841a7742f9a
# Google Drive

# Inkscape

<# Kmonad #>
scoop install stack # install stack
if ($confirmationKmonad -eq 'y') {
    Set-Location D:\
    git clone https://github.com/kmonad/kmonad.git
    Set-Location kmonad
    stack build # compile KMonad (this will first download GHC and msys2, it takes a while)
    Set-Location ..
}
<# ---------- #>

# Mathpix
# MegaSync
winget install -e --id 9WZDNCRF0083 --accept-package-agreements # Messenger
# MiniBin
# Notion
# Nvidia Geforce Experience
# Nvidia RTX Voice
# OBS Studio

<# Open Hardware Monitor #>
DownloadZipToLocation -Name "Open Hardware Monitor" -URL "https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip" -Location "D:\"
Rename-Item D:\OpenHardwareMonitor\ "Open Hardware Monitor"
<# ---------- #>

# ProtonVPN
# Shotcut
# TeamViewer
# TeraCopy
# Tor
# Unity Hub
# VeraCrypt
# WizTree
# Yubikey Manager
# PhotoShop # Download from Drive

# -------------------- Progressive Web Apps --------------------

Start-Process https://app.dinero.dk/ # Dinere
Start-Process https://calendar.google.com/ # Google Calendar
Start-Process https://photos.google.com/ # Google Photos
Start-Process https://www.overleaf.com/ # Overleaf
Start-Process https://remove.bg/ # Remove.bg
Start-Process https://snapdrop.net/ # Snapdrop
Start-Process https://music.youtube.com/ # Youtube Music
Start-Process https://mail.proton.me/ # Proton Mail

# -------------------- Tools & Tweaks --------------------

# Figma
# Mendeley
# Onion Share (https://github.com/onionshare/onionshare)

<# Pandoc #>
GitHubZipToLocation -Name "Pandoc" -Repo "jgm/pandoc" -Pattern "*_64.zip" -Location "D:\"
Get-ChildItem D:\pandoc-* | Rename-Item -NewName { $_.Name -replace $_.Name, "Pandoc" }
<# ---------- #>

# PSX2PSP
# Reduce PDF Size
# ScreenToGif
# Transmission
gh release download -R yt-dlp/yt-dlp --pattern 'yt-dlp.exe' -D "D:\YT-DLP" # YT-DLP

# -------------------- Development Tools --------------------

if ($confirmationMatLab -eq 'y') {
    # MatLab
}

if ($confirmationMaple -eq 'y') {
    # Maple
}

if ($confirmationTex -eq 'y') {
    # TexLive
}

if ($confirmationDocker -eq 'y') { winget install -e --id Docker.DockerDesktop --location "D:\Docker" --accept-package-agreements }

<# ffmpeg #>
GitHubZipToLocation -Name "ffmpeg" -Repo "GyanD/codexffmpeg" -Pattern "*-full_build.zip" -Location "D:\"
Get-ChildItem D:\*-full_build | Rename-Item -NewName { $_.Name -replace $_.Name, "ffmpeg" }
<# ---------- #>

<# JDK #>
DownloadZipToLocation -Name "JDK" -URL "https://objects.githubusercontent.com/github-production-release-asset-2e65be/372925194/624fbac8-d836-4208-8186-3d54c73e74f1?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220709%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220709T142037Z&X-Amz-Expires=300&X-Amz-Signature=1b5498f3c26397b1a8e86af9f65b2c7cb0d92ec0da0f2e239ecd597788c8e821&X-Amz-SignedHeaders=host&actor_id=26505751&key_id=0&repo_id=372925194&response-content-disposition=attachment%3B%20filename%3DOpenJDK17U-jdk_x64_windows_hotspot_17.0.3_7.zip&response-content-type=application%2Foctet-stream" -Location "D:\JDK"
<# ---------- #>

winget install -e --id GitHub.GitHubDesktop --location "D:\GitHub\Desktop" --accept-package-agreements
# Insomnia
# Msys2 - MinGW-w64 # Download installer
choco install -y nvm # nvm #ELEVATED
nvm install latest # npm & node.jsnvm install latest #ELEVATED
# R
# Visual Studio
choco install -y python3 # Python

# -------------------- Fonts --------------------

mkdir Fonts

<# Fira Code #>
GitHubZipToLocation -Name "FiraCode" -Repo "tonsky/FiraCode" -Pattern "*.zip" -Location ".\"
Get-ChildItem -Path FiraCode\ttf -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode -Recurse -Force -Confirm:$false
<# ---------- #>

<# Fira Code iScript #>
gh repo clone kencrocken/FiraCodeiScript
Get-ChildItem -Path FiraCodeiScript -File | Move-Item -Destination Fonts
Remove-Item FiraCodeiScript -Recurse -Force -Confirm:$false
<# ---------- #>

<# Fira Code Nerd Font #>
GitHubZipToLocation -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraCode.zip" -Location ".\"
GitHubZipToLocation -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraMono.zip" -Location ".\"
Get-ChildItem -Path FiraCode -Recurse -File | Move-Item -Destination Fonts
Get-ChildItem -Path FiraMono -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode, FiraMono
<# ---------- #>

<# Install all fonts in Fonts folder #>
Set-Location Fonts

$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
foreach ($file in Get-ChildItem "Fira *.ttf") {
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        Write-Output $fileName
        Get-ChildItem $file | ForEach-Object { $fonts.CopyHere($_.fullname) }
    }
}

Set-Location ~
Remove-Item Fonts -Recurse -Force -Confirm:$false
<# ---------- #>

# -------------------- Paths --------------------

# [Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1')
# [Environment]::SetEnvironmentVariable("INCLUDE", $env:Path + ";D:\YT-DLP", [System.EnvironmentVariableTarget]::User)
# C:\Program Files\CMake\bin
# D:\NodeJS
# D:\NVM
# D:\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin
# D:\FFMPEG\bin

# -------------------- Windows Store Apps (winget) --------------------

winget install -e --id 9MSPC6MP8FM4 --accept-package-agreements # Microsoft Whiteboard
winget install -e --id 9N95Q1ZZPMH4 --accept-package-agreements # MPEG-2
winget install -e --id 9NF8H0H7WMLT --accept-package-agreements # Nvidia Control Panel
winget install -e --id Microsoft.PowerToys --accept-package-agreements # Powertoys
winget install -e --id Microsoft.Powershell --source winget --accept-package-agreements # PowerShell 7
winget install -e --id QL-Win.QuickLook --accept-package-agreements # QuickLook
winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements # Visual Studio Code
winget install -e --id 9N26S50LN705 --accept-package-agreements # Windows File Recovery
winget install -e --id 9WZDNCRFHWLH --accept-package-agreements # HP Smart
winget install -e --id 9WZDNCRFHWM4 --accept-package-agreements # Wikipedia
winget install -e --id 9NBLGGH42THS --accept-package-agreements # 3d Viewer

# -------------------- Configurations --------------------

# OneDrive backups

# -------------------- WSL --------------------

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
#wsl --install # Needs reboot https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script
if ($confirmationUbuntu -eq 'y') {
    wsl --install -d Ubuntu
}
if ($confirmationDebian -eq 'y') {
    wsl --install -d Debian
}
wsl --set-default-version 2

# -------------------- Restarts pc --------------------

winget install -e --id WiresharkFoundation.Wireshark --accept-package-agreements # Wireshark
