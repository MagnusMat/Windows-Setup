# Windows Install Script

Set-ExecutionPolicy RemoteSigned # Execute Scripts

# -------------------- Upgrade --------------------

winget upgrade -h --all

# -------------------- Dependencies --------------------

winget install -e --id Git.Git --accept-package-agreements # Git
winget install -e --id GitHub.cli --accept-package-agreements # GitHub CLI
gh auth login # GitHub Cli Login

# -------------------- Confirmation Specific --------------------

$confirmationAISuite = Read-Host "Do you want to install AI Suite 3 y/n"
$confirmationAmazon = Read-Host "Do you want to install Amazon Send to Kindle y/n"
$confirmationAorus = Read-Host "Do you want to install Aorus Engine y/n"
$confirmationArchi = Read-Host "Do you want to install Archi Steam Farm y/n"
$confirmationROG = Read-Host "Do you want to install ROG Xonar Phoebus y/n"
$confirmationAliens = Read-Host "Do you want to install Aliens vs. Predator 2 y/n"
$confirmationBlur = Read-Host "Do you want to install Blur y/n"
$confirmationSilent = Read-Host "Do you want to install Silent Hill - The Arcade y/n"
$confirmationTex = Read-Host "Do you want to install Tex Live y/n"
$confirmationUppaal = Read-Host "Do you want to install Uppaal y/n"
$confirmationMaple = Read-Host "Do you want to install Maple y/n"
$confirmationMatLab = Read-Host "Do you want to install MatLab y/n"
$confirmationFlawless = Read-Host "Do you want to install Flawless Widescreen  y/n"
$confirmationFloating = Read-Host "Do you want to install Floating ISP y/n"
$confirmationISO = Read-Host "Do you want to install ISO to WBFS y/n"
$confirmationKmonad = Read-Host "Do you want to install Kmonad y/n"
$confirmationLocale = Read-Host "Do you want to install Locale Emulator y/n"
$confirmationLunar = Read-Host "Do you want to install LunarIPS y/n"
$confirmationHP = Read-Host "Do you want to install HP Support Assistant y/n"
$confirmationGames = Read-Host "Do you want to install Game Launchers y/n"
$confirmationEmulators = Read-Host "Do you want to install Emulators y/n"
$confirmationDxWnd = Read-Host "Do you want to install DxWnd y/n"
$confirmationHue = Read-Host "Do you want to install Hue Sync y/n"
$confirmationGlosc = Read-Host "Do you want to install GloSC y/n"
$confirmationGameBar = Read-Host "Do you want to install Notes for Gamebar y/n"
$confirmationDocker = Read-Host "Do you want to install Docker y/n"

# -------------------- Package Managers --------------------

Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression # install scoop

# Chocolatey
Set-ExecutionPolicy Bypass -Scope Process
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# -------------------- GitHub Apps (GitHub CLI) --------------------

# Kmonad
scoop install stack # install stack
if ($confirmationKmonad -eq 'y') {
    Set-Location D:\
    git clone https://github.com/kmonad/kmonad.git
    Set-Location kmonad
    stack build # compile KMonad (this will first download GHC and msys2, it takes a while)
    Set-Location ..
}

# -------------------------- Games --------------------

if ($confirmationGames -eq 'y') {
    # Battle.net
    # EA Desktop
    # Epic Games
    # GOG Galaxy
    # Playnite (https://github.com/JosefNemec/Playnite/)
    winget install -e --id Valve.Steam --location "D:\Steam" --accept-package-agreements # Steam
    # Twitch
    # Ubisoft Connect
}

#if ($confirmationEmulators -eq 'y') {
    <# Cemu #>
    Invoke-WebRequest "https://cemu.info/releases/cemu_1.26.2.zip" -OutFile Cemu.zip
    Expand-Archive Cemu.zip D:\Emulators
    Remove-Item Cemu.zip
    <# ---------- #>

    # Citra (https://github.com/citra-emu/citra)
    # Dolphin (https://github.com/dolphin-emu/dolphin)
    # NoPayStation
    # PCSX2 (https://github.com/PCSX2/pcsx2)
    # PCSXR (https://github.com/iCatButler/pcsxr)
    # PPSSPP (https://github.com/hrydgard/ppsspp)
    # Project64](https://github.com/project64/project64)
    # QCMA (https://github.com/codestation/qcma)
    # RetroArch (https://github.com/libretro/RetroArch)
    # RPCS3 (https://github.com/RPCS3/rpcs3)
    # Ryujinx
    # SNES9X
    # Visual Boy Advance
#}

#if ($confirmationAliens -eq 'y') {
    # Aliens vs. Predator 2
    # Aliens vs. Predator 2 - Primal Hunt
#}

#if ($confirmationBlur -eq 'y') {
    # Blur
#}

#if ($confirmationSilent -eq 'y') {
    # Silent Hill - The Arcade
#}

# -------------------- Miscellaneous --------------------

#if ($confirmationAISuite -eq 'y') {
    # AI Suite 3
#}
#if ($confirmationAmazon -eq 'y') {
    # Amazon Send to Kindle
#}
#if ($confirmationAorus -eq 'y') {
    # Aorus Engine
#}
#if ($confirmationArchi -eq 'y') {
    # Archi Steam Farm
#}
#if ($confirmationROG -eq 'y') {
    # ROG Xonar Phoebus
#}
#if ($confirmationSamsung -eq 'y') {
    # Samsung Magician
#}

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
Invoke-WebRequest https://downloads.1password.com/win/1PasswordSetup-latest.exe -OutFile 1password.exe
Remove-Item 1password.exe
<# ---------- #>

winget install -e --id 7zip.7zip --location "D:\7-Zip" --accept-package-agreements # 7-Zip
gh release download -R microsoft/accessibility-insights-windows --patters "*.msi" -D "D:\" # Accessibility Insights for Windows
winget install -e --id BlenderFoundation.Blender --accept-package-agreements # Blender
winget install -e --id calibre.calibre --accept-package-agreements # Calibre
# CPU-Z
gh release download -R cryptomator/cryptomator --pattern "*.msi" -D "D:\" # Cryptomator
# Cryptomator
winget install -e --id Discord.Discord --accept-package-agreements # Discord
# Draw.io
# DroidCam
# eM Client
winget install -e --id Microsoft.Teams --accept-package-agreements # Microsoft Teams

#if ($confirmationDxWnd -eq 'y') {
# DxWnd
#}

# FileZilla
# Mozilla Firefox https://gmusumeci.medium.com/unattended-install-of-firefox-browser-using-powershell-6841a7742f9a
# Google Drive

#if ($confirmationHue -eq 'y') {
# Hue Sync
#}

# Inkscape

#if ($confirmationMaple -eq 'y') {
# Maple
#}

# Mathpix
# MegaSync
winget install -e --id 9WZDNCRF0083 --accept-package-agreements # Messenger
# MiniBin
# Notion
# Nvidia Geforce Experience
# Nvidia RTX Voice
# OBS Studio
# Open Hardware Monitor # Download file and unzip
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

#if ($confirmationFlawless -eq 'y') {
# Flawless Widescreen
#}

#if ($confirmationFloating -eq 'y') {
# Floating ISP (Patch bps Roms) (https://github.com/Alcaro/Flips)
#}

#if ($confirmationGlosc -eq 'y') {
# GloSC (Global Steam Controller) (https://github.com/Alia5/GloSC)
#}

#if ($confirmationISO -eq 'y') {
# ISO to WBFS
#}

#if ($confirmationLocale -eq 'y') {
# Locale Emulator (https://github.com/xupefei/Locale-Emulator) # Download and Unzip
#}

#if ($confirmationLunar -eq 'y') {
# Lunar IPS
#}

# Figma
# Mendeley
# Onion Share (https://github.com/onionshare/onionshare)
# Pandoc # Download and unzip
# PSX2PSP
# Reduce PDF Size
# ScreenToGif
# Transmission (https://github.com/transmission/transmission) # Download installer
# gh release download -R yt-dlp/yt-dlp --pattern 'yt-dlp.exe' -D "D:\YT-DLP" # YT-DLP # Check folder structrue

# -------------------- Development Tools --------------------

#if ($confirmationMatLab -eq 'y') {
# MatLab
#}

#if ($confirmationTex -eq 'y') {
# TexLive
#}

#if ($confirmationUppaal -eq 'y') {
# Uppaal
#}

#if ($confirmationDocker -eq 'y') {
#winget install -e --id Docker.DockerDesktop --location "D:\Docker" --accept-package-agreements
#}

# ffmpeg # Download and unzip
# JDK
winget install -e --id GitHub.GitHubDesktop --location "D:\GitHub\Desktop" --accept-package-agreements
# Insomnia
# Msys2 - MinGW-w64 # Download installer
#choco install -y nvm # nvm
#nvm install latest # npm & node.js
# R
# Visual Studio
choco install -y python3 # Python

# -------------------- Fonts --------------------

<# Fira Code #>
# (https://github.com/tonsky/FiraCode) https://blog.simontimms.com/2021/06/11/installing-fonts/
# Move all files in folder https://stackoverflow.com/questions/38063424/powershell-move-all-files-from-folders-and-subfolders-into-single-folder
# Folder delete https://stackoverflow.com/questions/43611350/how-can-i-delete-files-with-powershell-without-confirmation
# Fira Code iScript (https://github.com/kencrocken/FiraCodeiScript)
# FiraCode Nerd Font (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode
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

#if ($confirmationHP -eq 'y') {
# HP Support Assistant (Laptop only)
#}

if ($confirmationGameBar -eq 'y') {
    winget install -e --id 9NG4TL7TX1KW --accept-package-agreements # Notes for Game Bar
}

#winget install -e --id 9MSPC6MP8FM4 --accept-package-agreements # Microsoft Whiteboard
#winget install -e --id 9N95Q1ZZPMH4 --accept-package-agreements # MPEG-2
#winget install -e --id 9NF8H0H7WMLT --accept-package-agreements # Nvidia Control Panel
#winget install -e --id Microsoft.PowerToys --accept-package-agreements # Powertoys
#winget install -e --id Microsoft.Powershell --source winget # PowerShell 7
#winget install -e --id QL-Win.QuickLook --accept-package-agreements # QuickLook
#winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements # Visual Studio Code
#winget install -e --id 9N26S50LN705 --accept-package-agreements # Windows File Recovery
#winget install -e --id 9WZDNCRFHWLH --accept-package-agreements # HP Smart
#winget install -e --id 9WZDNCRFHWM4 --accept-package-agreements # Wikipedia
#winget install -e --id 9NBLGGH42THS --accept-package-agreements # 3d Viewer

# -------------------- Configurations --------------------

# OneDrive backups

# -------------------- WSL --------------------

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
#wsl --install # Needs reboot https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script
#wsl --install -d Debian
#wsl --set-default-version 2

# -------------------- Restarts pc --------------------

winget install -e --id WiresharkFoundation.Wireshark --location "D:\Wireshark" --accept-package-agreements # Wireshark
