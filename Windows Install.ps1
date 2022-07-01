# Windows Install Script

Set-ExecutionPolicy RemoteSigned # Execute Scripts

# -------------------- Dependencies --------------------

winget install --id Git.Git --accept-package-agreements # Git
winget install --id GitHub.cli --accept-package-agreements # GitHub CLI
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
    winget install --id Valve.Steam --location "D:\Steam" --accept-package-agreements # Steam
    # Twitch
    # Ubisoft Connect
}

if ($confirmationEmulators -eq 'y') {
    # Cemu
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
}

if ($confirmationAliens -eq 'y') {
    # Aliens vs. Predator 2
    # Aliens vs. Predator 2 - Primal Hunt
}

if ($confirmationBlur -eq 'y') {
    # Blur
}

if ($confirmationSilent -eq 'y') {
    # Silent Hill - The Arcade
}

# -------------------- Miscellaneous --------------------

if ($confirmationAISuite -eq 'y') {
    # AI Suite 3
}
if ($confirmationAmazon -eq 'y') {
    # Amazon Send to Kindle
}
if ($confirmationAorus -eq 'y') {
    # Aorus Engine
}
if ($confirmationArchi -eq 'y') {
    # Archi Steam Farm
}
if ($confirmationROG -eq 'y') {
    # ROG Xonar Phoebus
}
if ($confirmationSamsung -eq 'y') {
    # Samsung Magician
}

# 1Password CLI
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

# 1Password
Invoke-WebRequest https://downloads.1password.com/win/1PasswordSetup-latest.exe -OutFile 1password.exe
Remove-Item 1password.exe

winget install -e --id 7zip.7zip --location "D:\7-Zip" --accept-package-agreements # 7-Zip
gh release download -R microsoft/accessibility-insights-windows --patters "*.msi" -D "D:\" # Accessibility Insights for Windows
winget install -e --id BlenderFoundation.Blender --accept-package-agreements # Blender
winget install -e --id calibre.calibre --accept-package-agreements # Calibre
# CPU-Z
gh release download -R cryptomator/cryptomator --pattern "*.msi" -D "D:\" # Cryptomator
winget install --id Discord.Discord --accept-package-agreements # Discord
# Draw.io
# DroidCam
# eM Client
# Microsoft Teams

if ($confirmationDxWnd -eq 'y') {
    # DxWnd
}

# FileZilla
# Mozilla Firefox
# Google Drive

if ($confirmationHue -eq 'y') {
    # Hue Sync
}

# Inkscape

if ($confirmationMaple -eq 'y') {
    # Maple
}

# Mathpix
# MegaSync
# Messenger
# MiniBin
# Notion
# Nvidia Geforce Experience
# Nvidia RTX Voice
# OBS Studio
# Open Hardware Monitor
# ProtonVPN
# Shotcut
# TeamViewer
# TeraCopy
# Tor
# Unity Hub
# VeraCrypt
# WizTree
# Yubikey Manager
# PhotoShop

# -------------------- Progressive Web Apps --------------------

Start-Process https://app.dinero.dk/
Start-Process https://calendar.google.com/
Start-Process https://photos.google.com/
Start-Process https://www.overleaf.com/
Start-Process https://remove.bg/
Start-Process https://snapdrop.net/
Start-Process https://music.youtube.com/
Start-Process https://mail.proton.me/

# -------------------- Tools & Tweaks --------------------

if ($confirmationFlawless -eq 'y') {
    # Flawless Widescreen
}

if ($confirmationFloating -eq 'y') {
    # Floating ISP (Patch bps Roms) (https://github.com/Alcaro/Flips)
}

if ($confirmationGlosc -eq 'y') {
    # GloSC (Global Steam Controller) (https://github.com/Alia5/GloSC)
}

if ($confirmationISO -eq 'y') {
    # ISO to WBFS
}

if ($confirmationLocale -eq 'y') {
    # Locale Emulator (https://github.com/xupefei/Locale-Emulator)
}

if ($confirmationLunar -eq 'y') {
    # Lunar IPS
}

# Figma
# Mendeley
# Onion Share (https://github.com/onionshare/onionshare)
winget install pandoc --accept-package-agreements
# PSX2PSP
# Reduce PDF Size
# ScreenToGif
# Transmission (https://github.com/transmission/transmission)

gh release download -R yt-dlp/yt-dlp --pattern 'yt-dlp.exe' -D "D:\YT-DLP" # YT-DLP

# -------------------- Development Tools --------------------

if ($confirmationMatLab -eq 'y') {
    # MatLab
}

if ($confirmationTex -eq 'y') {
    # TexLive
}

if ($confirmationUppaal -eq 'y') {
    # Uppaal
}

if ($confirmationDocker -eq 'y') {
    winget install --id Docker.DockerDesktop --location "D:\Docker" --accept-package-agreements
}

# ffmpeg
# JDK
winget install --id GitHub.GitHubDesktop --location "D:\GitHub\Desktop" --accept-package-agreements
# Insomnia
# Msys2 - MinGW-w64
choco install -y nvm # nvm
nvm install latest # npm & node.js
# R
# Visual Studio
winget install -e --id WiresharkFoundation.Wireshark --location "D:\Wireshark" --accept-package-agreements # Wireshark

# -------------------- Fonts --------------------

# Fira Code (https://github.com/tonsky/FiraCode)
# Fira Code iScript (https://github.com/kencrocken/FiraCodeiScript)
# FiraCode Nerd Font (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode

# -------------------- Paths --------------------

# [Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1')
# [Environment]::SetEnvironmentVariable("INCLUDE", $env:Path + ";D:\YT-DLP", [System.EnvironmentVariableTarget]::User)
# C:\Program Files\CMake\bin
# D:\NodeJS
# D:\NVM
# D:\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin
# D:\FFMPEG\bin

# -------------------- Windows Store Apps (winget) --------------------

if ($confirmationHP -eq 'y') {
    # HP Support Assistant (Laptop only)
}

if ($confirmationGameBar -eq 'y') {
    winget install --id 9NG4TL7TX1KW --accept-package-agreements # Notes for Game Bar
}

winget install --id 9MSPC6MP8FM4 --accept-package-agreements # Microsoft Whiteboard
winget install --id 9N95Q1ZZPMH4 --accept-package-agreements # MPEG-2
winget install --id 9NF8H0H7WMLT --accept-package-agreements # Nvidia Control Panel
winget install --id Microsoft.PowerToys --accept-package-agreements # Powertoys
winget install --id Microsoft.Powershell --source winget # PowerShell 7
winget install --id QL-Win.QuickLook --accept-package-agreements # QuickLook
winget install --id Microsoft.VisualStudioCode --accept-package-agreements # Visual Studio Code
winget install --id 9N26S50LN705 --accept-package-agreements # Windows File Recovery
choco install -y python3 # Python
# 3d Viewer
# Wikipedia

# -------------------- Configurations --------------------

# OneDrive backups

# -------------------- WSL --------------------
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --install
wsl --install -d Debian
wsl --set-default-version 2
