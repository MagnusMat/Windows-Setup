# Windows Install Script

Set-ExecutionPolicy RemoteSigned # Execute Scripts

# Prompt for Install Drive
do {
    $ConfirmationDrive = Read-Host "Do you want to install software the C: or D: drive c/d"
    if ($ConfirmationDrive -eq 'c') {
        $InstallDrive = "C:\Program Files"
    }
    elseif ($ConfirmationDrive -eq 'd') {
        $InstallDrive = "D:"
    }
    else {
        "You need to pick a valid option"
    }
} while (
    ($ConfirmationDrive -ne "c") -and ($ConfirmationDrive -ne "d")
)

# -------------------- Functions --------------------

function Set-Confirmation {
    param (
        $Confirmation,
        [string]$Question,
        [string]$FirstTerm = 'y',
        [string]$SecondTerm = 'n'
    )
    do {
        $Confirmation = Read-Host "$Question"
        if (($Confirmation -ne "$FirstTerm") -and ($Confirmation -ne "$SecondTerm")) {
            "You need to pick a valid option"
        }
    } while (
        ($Confirmation -ne "$FirstTerm") -and ($Confirmation -ne "$SecondTerm")
    )
}

function Install-Zip {
    param (
        [string]$Name,
        [string]$Location,
        [string]$URL
    )
    Invoke-WebRequest $URL -OutFile "$Name.zip"
    Expand-Archive "$Name.zip" $Location
    Remove-Item "$Name.zip"
}

function Install-MSI {
    param (
        [string]$Name,
        [string]$Location = "$InstallDrive\",
        [string]$URL
    )
    Invoke-WebRequest $URL -OutFile "$Name.msi"
    Start-Process msiexec.exe -Wait -ArgumentList "/package `"$Name.msi`"", "INSTALLDIR=`"$Location`"", "TARGETDIR=`"$Location`"", "/passive", "/norestart"
    Remove-Item "$Name.msi"
}

function Install-EXE {
    param (
        [string]$Name,
        [string]$Arguments = "/S",
        [string]$Location = "$InstallDrive\",
        [string]$URL
    )
    Invoke-WebRequest $URL -OutFile "$Name.exe"
    ".\$Name.exe $Arguments"
    Remove-Item "$Name.exe"
}

function Install-GitHub {
    param (
        [string]$Name,
        [string]$Repo,
        [string]$Pattern = "*.zip",
        [string]$Location = "$InstallDrive\",
        [string]$Version,
        [string]$FileType = "zip"
    )
    gh release download $Version -R $Repo --pattern $Pattern
    Get-ChildItem *.$FileType | Rename-Item -NewName { $_.Name -replace $_.Name, "$Name.$FileType" }
    if ($FileType -eq "7z") {
        if ($confirmationDrive -eq "c") {
            C:\Program Files\7-Zip\7z.exe x -o"$Location" "*.7z" -r
        }
        if ($confirmationDrive -eq "d") {
            D:\7-Zip\7z.exe x -o"$Location" "*.7z" -r
        }
    }
    elseif ($FileType -eq "zip") {
        Expand-Archive "$Name.$FileType" $Location
    }
    elseif ($FileType -eq "msi") {
        Start-Process msiexec.exe -Wait -ArgumentList "/package `"$Name.$FileType`"", "INSTALLDIR=`"$Location`"", "TARGETDIR=`"$Location`"", "INSTALL_DIRECTORY_PATH=`"$Location`"" , "/passive", "/norestart"
    }
    else {
        Write-Output "Archive type not supported"
    }
    Remove-Item "$Name.$FileType"
}

# -------------------- Confirmations --------------------

Set-Confirmation -Confirmation $confirmationLaptopDesktop -Question "Are you installing on a Laptop or Desktop l/d" -FirstTerm 'l' -SecondTerm 'd'
Set-Confirmation -Confirmation $confirmationGames -Question "Do you want to install Games y/n"
Set-Confirmation -Confirmation $confirmationEmulators -Question "Do you want to install Emulators y/n"
Set-Confirmation -Confirmation $confirmationAmazon -Question "Do you want to install Amazon Send to Kindle y/n"
Set-Confirmation -Confirmation $confirmationTex -Question "Do you want to install LaTeX y/n"
Set-Confirmation -Confirmation $confirmationMaple -Question "Do you want to install Maple y/n"
Set-Confirmation -Confirmation $confirmationMatLab -Question "Do you want to install MatLab y/n"
Set-Confirmation -Confirmation $confirmationKmonad -Question "Do you want to install Kmonad y/n"
Set-Confirmation -Confirmation $confirmationDocker -Question "Do you want to install Docker y/n"
Set-Confirmation -Confirmation $confirmationUbuntu -Question "Do you want to install Ubuntu WSL y/n"
Set-Confirmation -Confirmation $confirmationDebian -Question "Do you want to install Debian WSL y/n"

# -------------------- Upgrade --------------------

winget upgrade -h --all

# -------------------- Dependencies --------------------

winget install -e --id Git.Git --accept-package-agreements # Git
winget install -e --id GitHub.cli --accept-package-agreements # GitHub CLI
gh auth login # GitHub Cli Login
# Msys2 - MinGW-w64 # Download installer

<# DotNet #>
Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -OutFile 'dotnet-install.ps1';
./dotnet-install.ps1 -Channel "Current" -Runtime "dotnet"

Install-EXE -Name "DesktopRuntime" -Arguments "/install /quiet /norestart" -URL "https://download.visualstudio.microsoft.com/download/pr/dc0e0e83-0115-4518-8b6a-590ed594f38a/65b63e41f6a80decb37fa3c5af79a53d/windowsdesktop-runtime-6.0.7-win-x64.exe" # .Net Desktop Runtime Maybe

# Invoke-WebRequest "https://download.visualstudio.microsoft.com/download/pr/dc0e0e83-0115-4518-8b6a-590ed594f38a/65b63e41f6a80decb37fa3c5af79a53d/windowsdesktop-runtime-6.0.7-win-x64.exe" -OutFile "desktopRuntime.exe"
# ./desktopRuntime.exe /install /quiet /norestart
<# ---------- #>

<# Visual Studio https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022 #>¨
Install-EXE -Name "VSEnterprise" -Arguments "--installPath $Location --passive --norestart" -Location "(Join-Path -Path "$InstallDrive" -ChildPath "Visual Studio" -AdditionalChildPath "Visual Studio 2022")" -URL "https://aka.ms/vs/17/release/vs_enterprise.exe"

Install-EXE -Name "BuildTools" -Arguments "--installPath $Location --passive --norestart" -Location "(Join-Path -Path "$InstallDrive" -ChildPath "Visual Studio" -AdditionalChildPath "Build Tools 2022")" -URL "https://download.visualstudio.microsoft.com/download/pr/d59287e5-e208-462b-8894-db3142c39eca/c6d14e46b035dd68b0e813768ca5d8d4fb712a2930cc009a2fc68873e37f0e42/vs_BuildTools.exe"

# Invoke-WebRequest "https://aka.ms/vs/17/release/vs_enterprise.exe" -OutFile VSEnterprise.exe
# .\VSEnterprise.exe --installPath (Join-Path -Path "$InstallDrive" -ChildPath "Visual Studio" -AdditionalChildPath "Visual Studio 2022") --passive --norestart
# Remove-Item VSEnterprise.exe
# Invoke-WebRequest "https://download.visualstudio.microsoft.com/download/pr/d59287e5-e208-462b-8894-db3142c39eca/c6d14e46b035dd68b0e813768ca5d8d4fb712a2930cc009a2fc68873e37f0e42/vs_BuildTools.exe" -OutFile BuildTools.exe
# .\BuildTools.exe --installPath (Join-Path -Path "$InstallDrive" -ChildPath "Visual Studio" -AdditionalChildPath "Build Tools 2022") --passive --norestart
# Remove-Item BuildTools.exe
<# ---------- #>

choco install -y python3 # Python

# -------------------- Package Managers --------------------

Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression # Scoop

<# Chocolatey #>
Set-ExecutionPolicy Bypass -Scope Process
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
<# ---------- #>

# -------------------- Personal GitHub Repos --------------------

Set-Location $InstallDrive\
New-Item GitHub -ItemType Directory
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

    Install-MSI -Name "Epic Games" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Game Launchers" -AdditionalChildPath "Epic Games") -URL "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-13.3.0.msi?launcherfilename=EpicInstaller-13.3.0.msi" # Epic Games

    # GOG Galaxy https://www.gog.com/galaxy

    Install-GitHub -Name "Playnite" -Repo JosefNemec/Playnite -Location (Join-Path -Path "$InstallDrive" -ChildPath "Game Launchers" -AdditionalChildPath "Playnite") # Playnite
    winget install -e --id Valve.Steam --location (Join-Path -Path "$InstallDrive" -ChildPath "Game Launchers" -AdditionalChildPath "Steam") --accept-package-agreements # Steam

    # Ubisoft Connect https://ubisoftconnect.com/da-DK/?isSso=true&refreshStatus=noLoginData
    # Aliens vs. Predator 2 https://avpunknown.com/avp2aio/
    # Aliens vs. Predator 2 - Primal Hunt https://avpunknown.com/avp2aio/
    # Silent Hill - The Arcade https://collectionchamber.blogspot.com/2015/09/silent-hill-arcade.html
}

if ($confirmationEmulators -eq 'y') {
    Install-Zip -Name "Cemu" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Cemu") -URL "https://cemu.info/releases/cemu_1.26.2.zip" # Cemu

    # Citra https://citra-emu.org/download/ https://github.com/citra-emu/citra/wiki/Building-For-Windows

    Install-MSI -Name "Dolphin" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Dolphin") -URL "https://dl.dolphin-emu.org/builds/0c/ca/dolphin-master-5.0-16793-x64.7z" # Dolphin

    <# NoPayStation #>
    Invoke-WebRequest "https://nopaystation.com/vita/npsReleases/NPS_Browser_0.94.exe" -OutFile NoPayStation.exe
    Move-Item NoPayStation.exe (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "NoPayStation")
    gh release download -R mmozeiko/pkg2zip --pattern "pkg2zip_64bit.zip"
    Expand-Archive "pkg2zip_64bit.zip" (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "NoPayStation")
    <# ---------- #>

    Install-Zip -Name "PCSXR" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "PCSXR") -URL "https://doc-04-7k-docs.googleusercontent.com/docs/securesc/ecq0a8qqs25h8o2tcb0lnareatt3292s/vjg8o6edbh6iucm8c59hk0bdpp5i3fp7/1657727400000/06771232046367458076/05057713440002365443/1mLmNoRIeswoPy2GT78PKk0uig2a65jyC?e=download&ax=ACxEAsbeLFMyQwcpa6aKRjY2QhwN9qLhb72MeXCppKHIVJmNOzXeL6keX0E9I2kuasSz-rIWhmTqSGU-WkJiDGS1yiO5_8V9EpDoqUleyJ6h9oY4fWmED1jcwgcYvm9iEBzuvn5ft-Kr6feB3UB6F7bbQ5pRe0FAFXQlXqDbGDpfRu-1HBv_VGUnHDcn2Pt4ytDQ_Sp25KNTnZ5GM3qJjwStz_iNlxF3vbwhF4lbwtmkRmaF8SjYwrw5ljKRhJpW7hXMmxs0W82MqBPdkDbqyUA7A9c5B6UXidB1LXNQUqDzjc0Ew6hZh3BKhIeeeC4h_HEmo99QZjfF2kdjuHK8NKCQLI1jwygeDGPDvJq0Y86FgjN5tewgiVCfDGvAytkwgYRT_R7fUirk8-boCLVwX-Nr-97loYKJkMgjQp3PBY0hg2cQxeqzdcJZHB4wTOEjIWnh9ow_l9yqva1utHMr04F_GrMObxj5POO4XhxFIzTl52d6Ciqa86BN2WzwuP1b2eTg-iaMFEKXssYgSUOW-bYEPz7_YnKTYbfu5FOnsUR5worM2VQQ27C6KTPcBaycrf1pwdTNkz8eRoBPBH-uHyhMRsksBSWOzRbCwqVDQkB72WBKvXrop54qk4J8jZMTUjxuSdFJCkgsoPu16ZhwPXGzL-5RJnAo9bO9zItma-hCoDTwn-HKRzplAeOPxXV5WZcQjm71D-qPsr2tOgktF7RihlrGLM9crtIfwxRE6PZS-_-1K6I000RHmNa_BMciv9tnCeoR5v04Pjrr69s3RqGAKyc&uuid=4b06f5cb-861d-4546-a5f4-e4f90058e466&authuser=0&nonce=8vp23uqdplcoa&user=05057713440002365443&hash=q4k56sa03ibsqu7lp3rcgd5eu32va0au" # PCSXR
    Install-GitHub -Name "PCSX2" -Repo "PCSX2/pcsx2" -Pattern "*.7z" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "PCSX2") -FileType "7z" # PCSX2
    Install-Zip -Name "PPSSPP" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "PPSSPP") -URL "https://www.ppsspp.org/files/1_12_3/ppsspp_win.zip" # PPSSPP
    Install-Zip -Name "Project64" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Project64") -URL "https://www.pj64-emu.com/file/project64-3-0-0-5632-f83bee9/" # Project64

    # QCMA https://github.com/codestation/qcma/releases

    Install-Zip -Name "RetroArch" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "RetroArch") -URL "https://buildbot.libretro.com/stable/1.10.3/windows/x86_64/RetroArch.7z" # RetroArch
    Install-GitHub -Name "RPCS3" -Repo "RPCS3/rpcs3-binaries-win" -Pattern "*.7z" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPaths "RPCS3") -FileType "7z" # RPCS3
    Install-GitHub -Name "Ryujinx" -Repo "Ryujinx/release-channel-master" -Pattern "ryujinx-*-win_x64.zip" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPaths "Ryujinx") # Ryujinx

    Install-Zip -Name "SNES9X" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "SNES9X") -URL "https://dl.emulator-zone.com/download.php/emulators/snes/snes9x/snes9x-1.60-win32-x64.zip" # SNES9X
    Install-Zip -Name "Visual Boy Advance" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Visual Boy Advance") -URL "https://dl.emulator-zone.com/download.php/emulators/gba/vboyadvance/VisualBoyAdvance-1.8.0-beta3.zip" # Visual Boy Advance
}

# -------------------- Miscellaneous --------------------

if ($confirmationLaptopDesktop -eq 'd') {
    # Aorus Engine https://www.gigabyte.com/Support/Utility

    Install-GitHub -Name "Archi Steam Farm" -Repo "JustArchiNET/ArchiSteamFarm" -Pattern "ASF-win-x64.zip" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Archi Steam Farm") # Archi Steam Farm

    # ROG Xonar Phoebus https://www.asus.com/SupportOnly/ROG_Xonar_Phoebus/HelpDesk_Knowledge/

    Install-GitHub -Name "GloSC" -Repo "Alia5/GlosSI" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Global Steam Controller") -Version "0.0.7.0" # Global Steam Controller
    Install-GitHub -Name "Locale Emulator" -Repo "xupefei/Locale-Emulator" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Locale Emulator") # Locale Emulator

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
$installDir = Join-Path -Path "$InstallDrive" -ChildPath '1Password CLI'
Invoke-WebRequest -Uri "https://cache.agilebits.com/dist/1P/op2/pkg/v2.4.1/op_windows_$($opArch)_v2.4.1.zip" -OutFile op.zip
Expand-Archive -Path op.zip -DestinationPath $installDir -Force
$envMachinePath = [System.Environment]::GetEnvironmentVariable('PATH', 'machine')
if ($envMachinePath -split ';' -notcontains $installDir) {
    [Environment]::SetEnvironmentVariable('PATH', "$envMachinePath; $installDir", 'Machine')
}
Remove-Item -Path op.zip
<# ---------- #>

Install-EXE -Name "1Password" -Arguments "/S" -URL "https://downloads.1password.com/win/1PasswordSetup-latest.exe" # 1Password Maybe

winget install -e --id 7zip.7zip --location (Join-Path -Path "$InstallDrive" -ChildPath "7-Zip") --accept-package-agreements # 7-Zip
Install-GitHub -Name "Accessibility Insights for Windows" -Repo "microsoft/accessibility-insights-windows" -Pattern "* .msi" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Accessibility Insights for Windows") -FileType "msi"
winget install -e --id BlenderFoundation.Blender --accept-package-agreements # Blender
winget install -e --id calibre.calibre --accept-package-agreements # Calibre
Install-Zip -Name "CPU-Z" -Location (Join-Path -Path "$InstallDrive" -ChildPath "CPU-Z") -URL "https://download.cpuid.com/cpu-z/cpu-z_2.01-en.zip" # CPU-Z
Install-GitHub -Name "Cryptomator" -Repo "cryptomator/cryptomator" -Pattern "*.msi" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Cryptomator") -FileType "msi" # Cryptomator
winget install -e --id Discord.Discord --accept-package-agreements # Discord
Install-GitHub -Name "DrawIO" -Repo "jgraph/drawio-desktop" -Pattern "*.msi" -Location (Join-Path -Path "$InstallDrive" -ChildPath "DrawIO") -FileType "msi" # Draw.io

# DroidCam https://www.dev47apps.com/

Install-MSI -Name "EM Client" -Location (Join-Path -Path "$InstallDrive" -ChildPath "EM Client") -URL "https://cdn-dist.emclient.com/dist/v9.0.1708/setup.msi?sp=r&st=2020-05-06T07:52:16Z&se=3000-05-07T07:52:00Z&sv=2019-10-10&sr=c&sig=XTseyj3q1sYO2avsYPMzj5b8MMTOWRpL1KN92wU5HR4%3D" # eM Client
winget install -e --id Microsoft.Teams --accept-package-agreements # Microsoft Teams
Install-Zip -Name "FileZilla" -Location (Join-Path -Path "$InstallDrive" -ChildPath "FileZilla") -URL "https://dl3.cdn.filezilla-project.org/client/FileZilla_3.60.1_win64.zip?h=vDeiZ54lWjJOb0sS_f8mWg&x=1657730266" # FileZilla
Install-MSI -Name "Mozilla Firefox" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Mozilla Firefox") -URL "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=da" # Mozilla Firefox

<# Google Drive #>
Install-EXE -Name "Google Drive" -Arguments "--silent --gsuite_shortcuts=false" -URL "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe" # Google Drive Maybe

# Invoke-WebRequest "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe" -OutFile GoogleDrive.exe
# .\GoogleDrive.exe --silent --gsuite_shortcuts=false
# Remove-Item GoogleDrive.exe
<# ---------- #>

Install-GitHub -Name "HandBrake" -Repo "HandBrake/HandBrake" -Pattern "*-x86_64-Win_GUI.zip" # Handbrake
Install-MSI -Name "Inkscape" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Inkscape") -URL "https://media.inkscape.org/dl/resources/file/inkscape-1.2_2022-05-15_dc2aedaf03-x64_5iRsplS.msi" # Inkscape

<# Kmonad #>
scoop install stack # install stack
if ($confirmationKmonad -eq 'y') {
    Set-Location $InstallDrive\
    git clone https://github.com/kmonad/kmonad.git
    Set-Location kmonad
    stack build # compile KMonad (this will first download GHC and msys2, it takes a while)
    Set-Location ~
}
<# ---------- #>

# Mathpix https://mathpix.com/ https://github.com/lukas-blecher/LaTeX-OCR
# MegaSync https://mega.io/desktop

winget install -e --id 9WZDNCRF0083 --accept-package-agreements # Messenger

# MiniBin https://minibin.en.uptodown.com/windows/download
# Notion https://www.notion.so/desktop
# Nvidia Geforce Experience https://www.nvidia.com/da-dk/geforce/geforce-experience/
# Nvidia RTX Voice https://www.nvidia.com/da-dk/geforce/guides/nvidia-rtx-voice-setup-guide/

Install-GitHub -Name "OBS Studio" -Repo "obsproject/obs-studio" -Pattern "*-x64.zip" -Location (Join-Path -Path "$InstallDrive" -ChildPath "OBS Studio") # OBS Studio

<# Open Hardware Monitor #>
Install-Zip -Name "Open Hardware Monitor" -URL "https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip"
Rename-Item (Join-Path -Path "$InstallDrive" -ChildPath "OpenHardWareMonitor") "Open Hardware Monitor"
<# ---------- #>

# ProtonVPN https://protonvpn.com/

Install-GitHub -Name "Shotcut" -Repo "mltframework/shotcut" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Shotcut") # Shotcut
Install-Zip -Name "TeamViewer" -Location (Join-Path -Path "$InstallDrive" -ChildPath "TeamViewer") -URL "https://download.teamviewer.com/download/TeamViewerPortable.zip" # TeamViewer

# TeraCopy https://www.codesector.com/downloads
# Tor https://www.torproject.org/
# Unity Hub Visual Studio?

Install-MSI -Name "VeraCrypt" -Location (Join-Path -Path "$InstallDrive" -ChildPath "VeraCrypt") -URL "https://launchpad.net/veracrypt/trunk/1.25.9/+download/VeraCrypt_Setup_x64_1.25.9.msi" # VeraCrypt
Install-Zip -Name "WizTree" -Location (Join-Path -Path "$InstallDrive" -ChildPath "WizTree") -URL "https://antibodysoftware-17031.kxcdn.com/files/wiztree_4_08_portable.zip" # WizTree

<# Yubikey Manager #>
Install-EXE -Name "Yubikey Manager" -Arguments "/S" -URL "https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-win32.exe" # Yubikey Manager Maybe

# Invoke-WebRequest "https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-win32.exe" -OutFile Yubikey.exe
# .\Yubikey.exe /S
# Remove-Item Yubikey.exe
<# ----------#>

# PhotoShop # Download from Drive

# -------------------- Progressive Web Apps --------------------

Start-Process https://app.dinero.dk/ # Dinere
Start-Process https://calendar.proton.me/ # Proton Calendar
Start-Process https://photos.google.com/ # Google Photos
Start-Process https://www.overleaf.com/ # Overleaf
Start-Process https://remove.bg/ # Remove.bg
Start-Process https://snapdrop.net/ # Snapdrop
Start-Process https://music.youtube.com/ # Youtube Music
Start-Process https://mail.proton.me/ # Proton Mail

# -------------------- Tools & Tweaks --------------------

# Figma https://www.figma.com/downloads/
# Mendeley https://www.mendeley.com/search/

Install-GitHub -Name "Onion Share" -Repo "onionshare/onionshare" -Pattern "*.msi" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Onion Share") -FileType "msi" # Onion Share

<# Pandoc #>
Install-GitHub -Name "Pandoc" -Repo "jgm/pandoc" -Pattern "*_64.zip"
Get-ChildItem $InstallDrive\pandoc-* | Rename-Item -NewName { $_.Name -replace $_.Name, "Pandoc" }
<# ---------- #>

Install-GitHub -Name "ShareX" -Repo "ShareX/ShareX" -Location (Join-Path -Path "$InstallDrive" -ChildPath "ShareX") # ShareX
Install-GitHub -Name "Transmission" -Repo "transmission/transmission" -Pattern "*-x64.msi" -Location (Join-Path -Path "$InstallDrive" -ChildPath "Transmission") -FileType "msi" # Transmission
gh release download -R yt-dlp/yt-dlp --pattern 'yt-dlp.exe' -D (Join-Path -Path "$InstallDrive" -ChildPath "YT-DLP") # YT-DLP

# -------------------- Development Tools --------------------

if ($confirmationMatLab -eq 'y') {
    # MatLab https://www.mathworks.com/products/matlab.html https://se.mathworks.com/help/install/ug/install-noninteractively-silent-installation.html
}

if ($confirmationMaple -eq 'y') {
    # Maple https://www.maplesoft.com/products/Maple/
}

if ($confirmationTex -eq 'y') {
    <# TexLive #> # ELEVATED
    Install-Zip -Name "Tex Live" -Location ".\" -URL "https://mirrors.mit.edu/CTAN/systems/texlive/tlnet/install-tl.zip"
    Get-ChildItem "install-tl-*" | Rename-Item -NewName { $_.Name -replace $_.Name, "install-tl" }
    .\install-tl\install-tl-windows.bat -no-gui -texdir (Join-Path -Path "$InstallDrive" -ChildPath "Tex Live") -no-interaction
    Remove-Item "install-tl", "install-tl.zip" -Recurse -Force -Confirm:$false
    <# ----------#>
}

if ($confirmationDocker -eq 'y') {
    winget install -e --id Docker.DockerDesktop --location (Join-Path -Path "$InstallDrive" -ChildPath "Docker") --accept-package-agreements
}

<# ffmpeg #>
Install-GitHub -Name "ffmpeg" -Repo "GyanD/codexffmpeg" -Pattern "*-full_build.zip"
Get-ChildItem $InstallDrive\*-full_build | Rename-Item -NewName { $_.Name -replace $_.Name, "ffmpeg" }
<# ---------- #>

Install-Zip -Name "JDK" -Location (Join-Path -Path "$InstallDrive" -ChildPath "JDK") -URL "https://objects.githubusercontent.com/github-production-release-asset-2e65be/372925194/624fbac8-d836-4208-8186-3d54c73e74f1?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220709%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220709T142037Z&X-Amz-Expires=300&X-Amz-Signature=1b5498f3c26397b1a8e86af9f65b2c7cb0d92ec0da0f2e239ecd597788c8e821&X-Amz-SignedHeaders=host&actor_id=26505751&key_id=0&repo_id=372925194&response-content-disposition=attachment%3B%20filename%3DOpenJDK17U-jdk_x64_windows_hotspot_17.0.3_7.zip&response-content-type=application%2Foctet-stream" # JDK
winget install -e --id GitHub.GitHubDesktop --location (Join-Path -Path "$InstallDrive" -ChildPath "Github" -AdditionalChildPaths "Desktop") --accept-package-agreements

# Insomnia https://insomnia.rest/download

choco install -y nvm # nvm #ELEVATED
nvm install latest # npm & node.jsnvm install latest #ELEVATED

# R https://mirrors.dotsrc.org/cran/

# -------------------- Fonts --------------------

New-Item Fonts -ItemType Directory

<# Fira Code #>
Install-GitHub -Name "FiraCode" -Repo "tonsky/FiraCode" -Location ".\"
Get-ChildItem -Path FiraCode\ttf -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode -Recurse -Force -Confirm:$false
<# ---------- #>

<# Fira Code iScript #>
gh repo clone kencrocken/FiraCodeiScript
Get-ChildItem -Path FiraCodeiScript -File | Move-Item -Destination Fonts
Remove-Item FiraCodeiScript -Recurse -Force -Confirm:$false
<# ---------- #>

<# Fira Code Nerd Font #>
Install-GitHub -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraCode.zip" -Location ".\"
Install-GitHub -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraMono.zip" -Location ".\"
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
# [Environment]::SetEnvironmentVariable(INCLUDE, $env:Path + ; $InstallDrive\YT-DLP, [System.EnvironmentVariableTarget]::User)
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
winget install -e --id 9NBLGGH30XJ3 --accept-package-agreements # Xbox Accessories

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
