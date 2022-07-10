# Windows Install Script

Set-ExecutionPolicy RemoteSigned # Execute Scripts

# -------------------- Upgrade --------------------

winget upgrade -h --all

# -------------------- Dependencies --------------------

winget install -e --id Git.Git --accept-package-agreements # Git
winget install -e --id GitHub.cli --accept-package-agreements # GitHub CLI
gh auth login # GitHub Cli Login

# -------------------- Functions --------------------

function ConfirmationPrompt {
    param (
        $Confirmation,
        [string]$Variable = $Confirmation,
        [string]$Question,
        [string]$FirstTerm = 'y',
        [string]$SecondTerm = 'n',
        [string]$FirstResult = $FirstTerm,
        [string]$SecondResult = $SecondTerm
    )
    do {
        $Confirmation = Read-Host "$Question"
        if ($Confirmation -eq "$FirstTerm") {
            $Variable = $FirstResult
        }
        elseif ($confirmation -eq $SecondTerm) {
            $Variable = $SecondResult
        }
        else {
            'You need to pick a valid option'
        }
    } while (
        ($Confirmation -ne "$FirstTerm") -and ($Confirmation -ne "$SecondTerm")
    )
}

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
        if ($confirmationDrive -eq "c") {
            C:\Program Files\7-Zip\7z.exe x -o"$Location" "*.7z" -r
        }
        if ($confirmationDrive -eq "d") {
            D:\7-Zip\7z.exe x -o"$Location" "*.7z" -r
        }
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

ConfirmationPrompt -Confirmation $confirmationLaptopDesktop -Question "Are you installing on a Laptop or Desktop l/d" -FirstTerm 'l' -SecondTerm 'd'
ConfirmationPrompt -Confirmation $confirmationDrive -Variable $InstallDrive -Question "Do you want to install software the C: or D: drive c/d" -FirstTerm 'c' -SecondTerm 'd' -FirstResult "C:\Program Files" -SecondResult "D:"
ConfirmationPrompt -Confirmation $confirmationGames -Question "Do you want to install Games y/n"
ConfirmationPrompt -Confirmation $confirmationEmulators -Question "Do you want to install Emulators y/n"
ConfirmationPrompt -Confirmation $confirmationAmazon -Question "Do you want to install Amazon Send to Kindle y/n"
ConfirmationPrompt -Confirmation $confirmationTex -Question "Do you want to install LaTeX y/n"
ConfirmationPrompt -Confirmation $confirmationMaple -Question "Do you want to install Maple y/n"
ConfirmationPrompt -Confirmation $confirmationMatLab -Question "Do you want to install MatLab y/n"
ConfirmationPrompt -Confirmation $confirmationKmonad -Question "Do you want to install Kmonad y/n"
ConfirmationPrompt -Confirmation $confirmationDocker -Question "Do you want to install Docker y/n"
ConfirmationPrompt -Confirmation $confirmationUbuntu -Question "Do you want to install Ubuntu WSL y/n"
ConfirmationPrompt -Confirmation $confirmationDebian -Question "Do you want to install Debian WSL y/n"

# -------------------- Package Managers --------------------

Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression # Scoop

<# Chocolatey #>
Set-ExecutionPolicy Bypass -Scope Process
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
<# ---------- #>

# -------------------- Personal GitHub Repos --------------------

Set-Location $InstallDrive\
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
    # Battle.net https://www.blizzard.com/en-sg/apps/battle.net/desktop
    # EA Desktop https://www.ea.com/ea-app-beta
    # Epic Games https://store.epicgames.com/en-US/
    # GOG Galaxy https://www.gog.com/galaxy

    GitHubZipToLocation -Name "Playnite" -Repo JosefNemec/Playnite -Pattern "*.zip" -Location "$InstallDrive\Playnite" # Playnite
    winget install -e --id Valve.Steam --location "$InstallDrive\Steam" --accept-package-agreements # Steam

    # Ubisoft Connect https://ubisoftconnect.com/da-DK/?isSso=true&refreshStatus=noLoginData
    # Aliens vs. Predator 2 https://avpunknown.com/avp2aio/
    # Aliens vs. Predator 2 - Primal Hunt https://avpunknown.com/avp2aio/
    # Blur
    # Silent Hill - The Arcade https://collectionchamber.blogspot.com/2015/09/silent-hill-arcade.html
}

if ($confirmationEmulators -eq 'y') {
    DownloadZipToLocation -Name "Cemu" -URL "https://cemu.info/releases/cemu_1.26.2.zip" -Location "$InstallDrive\Emulators" # Cemu

    # Citra https://citra-emu.org/download/#
    # Dolphin https://da.dolphin-emu.org/download/
    # NoPayStation https://nopaystation.com/
    # PCSX2 https://pcsx2.net/downloads/
    # PCSXR https://emulation.gametechwiki.com/index.php/PCSX-Reloaded
    # PPSSPP https://www.ppsspp.org/downloads.html
    # Project64 https://www.pj64-emu.com/public-releases
    # QCMA https://github.com/codestation/qcma/releases
    # RetroArch https://www.retroarch.com/?page=platforms

    GitHubZipToLocation -Name "RPCS3" -Repo "RPCS3/rpcs3-binaries-win" -Pattern "*.7z" -Location "$InstallDrive\Emulators\RPCS3" -ArchiveType "7z" # RPCS3

    # Ryujinx https://github.com/Ryujinx/release-channel-master/releases/tag/1.1.171
    # SNES9X https://www.snes9x.com/
    # Visual Boy Advance https://www.emulator-zone.com/doc.php/gba/vboyadvance.html
}

# -------------------- Miscellaneous --------------------

if ($confirmationLaptopDesktop -eq 'd') {
    # Aorus Engine https://www.gigabyte.com/Support/Utility
    # Archi Steam Farm https://github.com/JustArchiNET/ArchiSteamFarm/releases/tag/5.2.7.7
    # ROG Xonar Phoebus https://www.asus.com/SupportOnly/ROG_Xonar_Phoebus/HelpDesk_Knowledge/
    # Flawless Widescreen https://www.flawlesswidescreen.org/#Download

    GitHubZipToLocation -Name "GloSC" -Repo "Alia5/GlosSI" -Pattern "*.zip" -Location "$InstallDrive\Global Steam Controller" -Version "0.0.7.0" # Global Steam Controller
    GitHubZipToLocation -Name "Locale Emulator" -Repo "xupefei/Locale-Emulator" -Pattern "*.zip" -Location "$InstallDrive\Locale Emulator" # Locale Emulator

    # Hue Sync https://www.philips-hue.com/en-us/explore-hue/propositions/entertainment/sync-with-pc

    winget install -e --id 9NG4TL7TX1KW --accept-package-agreements # Notes for Game Bar
}

if ($confirmationLaptopDesktop -eq 'l') {
    # HP Support Assistant https://support.hp.com/dk-da/help/hp-support-assistant
}

if ($confirmationAmazon -eq 'y') {
    # Amazon Send to Kindle https://smile.amazon.com/gp/sendtokindle?sa-no-redirect=1
}

if ($confirmationSamsung -eq 'y') {
    # Samsung Magician https://semiconductor.samsung.com/consumer-storage/support/tools/
}

<# 1Password CLI #>
$arch = "64-bit"
switch ($arch) {
    '64-bit' { $opArch = 'amd64'; break }
    '32-bit' { $opArch = '386'; break }
    Default { Write-Error "Sorry, your operating system architecture '$arch' is unsupported" -ErrorAction Stop }
}
$installDir = Join-Path -Path "$InstallDrive\" -ChildPath '1Password CLI'
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

winget install -e --id 7zip.7zip --location "$InstallDrive\7-Zip" --accept-package-agreements # 7-Zip

#gh release download -R microsoft/accessibility-insights-windows --pattern "*.msi" -D "$InstallDrive\" # Accessibility Insights for Windows

winget install -e --id BlenderFoundation.Blender --accept-package-agreements # Blender
winget install -e --id calibre.calibre --accept-package-agreements # Calibre

# CPU-Z https://www.cpuid.com/softwares/cpu-z.html

<# Cryptomator #>
#gh release download -R cryptomator/cryptomator --pattern "*.msi" -D "$InstallDrive\" # Cryptomator
<# ---------- #>

winget install -e --id Discord.Discord --accept-package-agreements # Discord

# Draw.io https://github.com/jgraph/drawio-desktop/releases/tag/v19.0.3
# DroidCam https://www.dev47apps.com/
# eM Client https://www.emclient.com/

winget install -e --id Microsoft.Teams --accept-package-agreements # Microsoft Teams

# FileZilla https://filezilla-project.org/download.php?show_all=1
# Mozilla Firefox https://gmusumeci.medium.com/unattended-install-of-firefox-browser-using-powershell-6841a7742f9a
# Google Drive https://www.google.com/intl/da/drive/download/
# Inkscape https://inkscape.org/release/1.2/windows/64-bit/

<# Kmonad #>
scoop install stack # install stack
if ($confirmationKmonad -eq 'y') {
    Set-Location $InstallDrive\
    git clone https://github.com/kmonad/kmonad.git
    Set-Location kmonad
    stack build # compile KMonad (this will first download GHC and msys2, it takes a while)
    Set-Location ..
}
<# ---------- #>

# Mathpix https://mathpix.com/
# MegaSync https://mega.io/desktop

winget install -e --id 9WZDNCRF0083 --accept-package-agreements # Messenger

# MiniBin https://minibin.en.uptodown.com/windows/download
# Notion https://www.notion.so/desktop
# Nvidia Geforce Experience https://www.nvidia.com/da-dk/geforce/geforce-experience/
# Nvidia RTX Voice https://www.nvidia.com/da-dk/geforce/guides/nvidia-rtx-voice-setup-guide/
# OBS Studio https://github.com/obsproject/obs-studio/releases/tag/27.2.4

<# Open Hardware Monitor #>
DownloadZipToLocation -Name "Open Hardware Monitor" -URL "https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip" -Location "$InstallDrive\"
Rename-Item $InstallDrive\OpenHardwareMonitor\ "Open Hardware Monitor"
<# ---------- #>

# ProtonVPN https://protonvpn.com/
# Shotcut https://github.com/mltframework/shotcut/releases/tag/v22.06.23
# TeamViewer https://www.teamviewer.com/da/
# TeraCopy https://www.codesector.com/downloads
# Tor https://www.torproject.org/
# Unity Hub https://unity3d.com/get-unity/download
# VeraCrypt https://www.veracrypt.fr/code/VeraCrypt/
# WizTree https://diskanalyzer.com/download
# Yubikey Manager https://docs.yubico.com/software/yubikey/tools/ykman/Install_ykman.html#windows https://www.yubico.com/support/download/yubikey-manager/#h-downloads
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

# Figma https://www.figma.com/downloads/
# Mendeley https://www.mendeley.com/search/
# Onion Share https://github.com/onionshare/onionshare/releases/tag/v2.5

<# Pandoc #>
GitHubZipToLocation -Name "Pandoc" -Repo "jgm/pandoc" -Pattern "*_64.zip" -Location "$InstallDrive\"
Get-ChildItem $InstallDrive\pandoc-* | Rename-Item -NewName { $_.Name -replace $_.Name, "Pandoc" }
<# ---------- #>

# Reduce PDF Size https://okular.kde.org/download/
# ScreenToGif https://github.com/NickeManarin/ScreenToGif https://github.com/ShareX/ShareX/releases/tag/v14.0.1
# Transmission https://github.com/transmission/transmission

gh release download -R yt-dlp/yt-dlp --pattern 'yt-dlp.exe' -D "$InstallDrive\YT-DLP" # YT-DLP

# -------------------- Development Tools --------------------

if ($confirmationMatLab -eq 'y') {
    # MatLab https://www.mathworks.com/products/matlab.html
}

if ($confirmationMaple -eq 'y') {
    # Maple https://www.maplesoft.com/products/Maple/
}

if ($confirmationTex -eq 'y') {
    # TexLive https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop
}

if ($confirmationDocker -eq 'y') { winget install -e --id Docker.DockerDesktop --location "$InstallDrive\Docker" --accept-package-agreements }

<# ffmpeg #>
GitHubZipToLocation -Name "ffmpeg" -Repo "GyanD/codexffmpeg" -Pattern "*-full_build.zip" -Location "$InstallDrive\"
Get-ChildItem $InstallDrive\*-full_build | Rename-Item -NewName { $_.Name -replace $_.Name, "ffmpeg" }
<# ---------- #>

DownloadZipToLocation -Name "JDK" -URL "https://objects.githubusercontent.com/github-production-release-asset-2e65be/372925194/624fbac8-d836-4208-8186-3d54c73e74f1?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220709%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220709T142037Z&X-Amz-Expires=300&X-Amz-Signature=1b5498f3c26397b1a8e86af9f65b2c7cb0d92ec0da0f2e239ecd597788c8e821&X-Amz-SignedHeaders=host&actor_id=26505751&key_id=0&repo_id=372925194&response-content-disposition=attachment%3B%20filename%3DOpenJDK17U-jdk_x64_windows_hotspot_17.0.3_7.zip&response-content-type=application%2Foctet-stream" -Location "$InstallDrive\JDK" # JDK

winget install -e --id GitHub.GitHubDesktop --location "$InstallDrive\GitHub\Desktop" --accept-package-agreements

# Insomnia https://insomnia.rest/download
# Msys2 - MinGW-w64 # Download installer

choco install -y nvm # nvm #ELEVATED
nvm install latest # npm & node.jsnvm install latest #ELEVATED

# R https://mirrors.dotsrc.org/cran/
# Visual Studio https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022

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
# [Environment]::SetEnvironmentVariable("INCLUDE", $env:Path + ";$InstallDrive\YT-DLP", [System.EnvironmentVariableTarget]::User)
# C:\Program Files\CMake\bin
# $InstallDrive\NodeJS
# $InstallDrive\NVM
# $InstallDrive\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin
# $InstallDrive\FFMPEG\bin

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
