# Windows Install Script

# Terminate during any and all errors
$ErrorActionPreference = 'Stop'

Start-Process -FilePath powershell.exe -ArgumentList {
    # Execution Permission
    Set-ExecutionPolicy RemoteSigned
} -Verb RunAs

# -------------------- Updates & Package Managers --------------------

# Upgade all packages
winget source update

winget upgrade --all --accept-package-agreements --accept-source-agreements

# Git
winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements

# GitHub CLI
winget install -e --id GitHub.cli --accept-package-agreements --accept-source-agreements

# Reloads profile
. $profile

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

# GitHub Cli Login
& 'C:\Program Files\GitHub CLI\gh.exe' auth login

# Prompt for Install Drive
do {
    $ConfirmationDrive = Read-Host "Do you want to install software the C: or D: drive c/d"
    if ($ConfirmationDrive -eq 'c') {
        $InstallDrive = "C:\Program Files"
        $OneDriveDir = "$env:USERPROFILE\OneDrive"
    }
    elseif ($ConfirmationDrive -eq 'd') {
        $InstallDrive = "D:"
        $OneDriveDir = "D:\OneDrive"
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


function Install-EXE {
    param (
        [string]$Name,
        [string]$ArgumentList,
        [string]$URL
    )
    Invoke-WebRequest $URL -OutFile "$Name.exe"
    Start-Process -FilePath .\"$Name.exe" -Wait -ArgumentList $ArgumentList
    Remove-Item "$Name.exe"
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
    Get-ChildItem *.$FileType | Rename-Item -NewName {
        $_.Name -replace $_.Name, "$Name.$FileType"
    }
    if ($FileType -eq "7z") {
        if ($confirmationDrive -eq "c") {
            & C:\Program Files\7-Zip\7z.exe x -o"$Location" "$Name.7z" -r
        }
        if ($confirmationDrive -eq "d") {
            & D:\7-Zip\7z.exe x -o"$Location" "$Name.7z" -r
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

# -------------------- Set Wallpaper --------------------
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value 10 -Force
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WallParams
{
    [DllImport("User32.dll",CharSet=CharSet.Unicode)]
    public static extern int SystemParametersInfo (Int32 uAction,
                                                   Int32 uParam,
                                                   String lpvParam,
                                                   Int32 fuWinIni);
}
"@

$WallpaperImage = "C:\Windows\Web\Wallpaper\ThemeB\img26.jpg"
$SPI_SETDESKWALLPAPER = 0x0014
$UpdateIniFile = 0x01
$SendChangeEvent = 0x02
$fWinIni = $UpdateIniFile -bor $SendChangeEvent

[WallParams]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $WallpaperImage, $fWinIni)

# -------------------- Confirmations --------------------

# Install Laptop Desktop Prompt
do {
    $confirmationLaptopDesktop = Read-Host "Are you installing on a Laptop or Desktop l/d"
    if (($confirmationLaptopDesktop -ne "l") -and ($confirmationLaptopDesktop -ne "d")) {
        "You need to pick a valid option"
    }
} while (
        ($confirmationLaptopDesktop -ne "l") -and ($confirmationLaptopDesktop -ne "d")
)

# Games Prompt
do {
    $confirmationGames = Read-Host "Do you want to install Games y/n"
    if (($confirmationGames -ne "y") -and ($confirmationGames -ne "n")) {
        "You need to pick a valid option"
    }
} while (
        ($confirmationGames -ne "y") -and ($confirmationGames -ne "n")
)

# Emulator prompt
do {
    $confirmationEmulators = Read-Host "Do you want to install Emulators y/n"
    if (($confirmationEmulators -ne "y") -and ($confirmationEmulators -ne "n")) {
        "You need to pick a valid option"
    }
} while (
        ($confirmationEmulators -ne "y") -and ($confirmationEmulators -ne "n")
)

# Tex Prompt
do {
    $confirmationTex = Read-Host "Do you want to install LaTeX y/n"
    if (($confirmationTex -ne "y") -and ($confirmationTex -ne "n")) {
        "You need to pick a valid option"
    }
} while (
        ($confirmationTex -ne "y") -and ($confirmationTex -ne "n")
)

# Linux Prompt
do {
    $confirmationLinux = Read-Host "Do you want to install Ubuntu or Debian WSL u/d"
    if (($confirmationLinux -ne "u") -and ($confirmationLinux -ne "d")) {
        "You need to pick a valid option"
    }
} while (
        ($confirmationLinux -ne "u") -and ($confirmationLinux -ne "d")
)

# -------------------- Microsoft Store --------------------

# HP Smart
winget install -e --id 9WZDNCRFHWLH --accept-package-agreements --accept-source-agreements

# Microsoft Whiteboard
winget install -e --id 9MSPC6MP8FM4 --accept-package-agreements --accept-source-agreements

# MPEG-2
winget install -e --id 9N95Q1ZZPMH4 --accept-package-agreements --accept-source-agreements

# Nvidia Control Panel
winget install -e --id 9NF8H0H7WMLT --accept-package-agreements --accept-source-agreements

# Powertoys
winget install -e --id Microsoft.PowerToys --accept-package-agreements --accept-source-agreements

# PowerShell 7
winget install -e --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements

Start-Process -FilePath pwsh.exe -ArgumentList {
    # Execution Permission
    Set-ExecutionPolicy RemoteSigned
} -Verb RunAs

# Visual Studio Code
winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements

# Wikipedia
winget install -e --id 9WZDNCRFHWM4 --accept-package-agreements --accept-source-agreements

# Windows File Recovery
winget install -e --id 9N26S50LN705 --accept-package-agreements --accept-source-agreements

# Xbox Accessories
winget install -e --id 9NBLGGH30XJ3 --accept-package-agreements --accept-source-agreements

# 3d Viewer
winget install -e --id 9NBLGGH42THS --accept-package-agreements --accept-source-agreements

# -------------------- Fonts --------------------

New-Item Fonts -ItemType Directory

# Fira Code
Install-GitHub -Name "FiraCode" -Repo "tonsky/FiraCode" -Location ".\FiraCode"
Get-ChildItem -Path FiraCode\ttf -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode -Recurse -Force -Confirm:$false

# Fira Code iScript
gh repo clone kencrocken/FiraCodeiScript
Get-ChildItem -Path FiraCodeiScript -File | Move-Item -Destination Fonts
Remove-Item FiraCodeiScript -Recurse -Force -Confirm:$false

# Fira Code Nerd Font
Install-GitHub -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraCode.zip" -Location ".\FiraCode"
Install-GitHub -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraMono.zip" -Location ".\FiraMono"
Get-ChildItem -Path FiraCode -Recurse -File | Move-Item -Destination Fonts
Get-ChildItem -Path FiraMono -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode, FiraMono

# Install all fonts in Fonts folder
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

# -------------------- Progressive Web Apps --------------------

# Dinere
Start-Process https://app.dinero.dk/

# Proton Calendar
Start-Process https://calendar.proton.me/

# Google Photos
Start-Process https://photos.google.com/

# Overleaf
Start-Process https://www.overleaf.com/

# Remove.bg
Start-Process https://remove.bg/

# Snapdrop
Start-Process https://snapdrop.net/

# Youtube Music
Start-Process https://music.youtube.com/

# Proton Mail
Start-Process https://mail.proton.me/

# -------------------- Dependencies --------------------

# Msys2
gh release download -R msys2/msys2-installer --pattern "msys2-x86_64-*.exe"
Get-ChildItem "*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "msys2.exe"
}

.\msys2.exe in --confirm-command --accept-messages --root "$InstallDrive/Msys2-64"

Remove-Item msys2.exe

Set-Location "$InstallDrive\Msys2-64"
.\msys2.exe bash -l -c "pacman -Syu --noconfirm"
Start-Sleep(80)
.\msys2_shell.cmd -l -c "pacman -Syu --noconfirm" | Out-Null
.\msys2.exe bash -l -c "pacman -S --needed base-devel mingw-w64-x86_64-toolchain --noconfirm"
Start-Sleep(180)

Set-Location ~

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\Msys2-64\mingw64\bin",
    [EnvironmentVariableTarget]::User
)

# DotNet
[Environment]::SetEnvironmentVariable(
    'DOTNET_CLI_TELEMETRY_OPTOUT',
    '1',
    [System.EnvironmentVariableTarget]::User
)

Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -OutFile "dotnet-install.ps1";

./dotnet-install.ps1 -Channel "Current" -Runtime "dotnet"
Remove-item dotnet-install.ps1

# DotNet Desktop Runtime
$DotNetParams = @{
    Name         = "DesktopRuntime"
    ArgumentList = @("/install", "/quiet", "/norestart")
    URL          = "https://download.visualstudio.microsoft.com/download/pr/dc0e0e83-0115-4518-8b6a-590ed594f38a/65b63e41f6a80decb37fa3c5af79a53d/windowsdesktop-runtime-6.0.7-win-x64.exe"
}
Install-EXE @DotNetParams

# Visual Studio Enterprise 2022
winget install -e --id Microsoft.VisualStudio.2022.Enterprise --accept-package-agreements --accept-source-agreements

# Visual Studio 2019 Build Tools
winget install -e --id Microsoft.VisualStudio.2019.BuildTools --accept-package-agreements --accept-source-agreements

# Python
winget install -e --id Python.Python.3 --accept-package-agreements --accept-source-agreements

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$env:USERPROFILE\AppData\Roaming\Python\Python310\Scripts",
    [EnvironmentVariableTarget]::User
)

# Reloads profile
. $profile

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

python.exe -m pip install --upgrade pip --user

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

# 7-Zip
winget install -e --id 7zip.7zip --location (Join-Path -Path "$InstallDrive" -ChildPath "7-Zip") --accept-package-agreements --accept-source-agreements

if ($confirmationGames -eq 'y') {
    # Epic Games
    $EpicGamesParams = @{
        Name     = "Epic Games"
        Location = (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Epic Games")
        URL      = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-13.3.0.msi?launcherfilename=EpicInstaller-13.3.0.msi"
    }
    Install-MSI @EpicGamesParams

    # GOG Galaxy
    winget install -e --id GOG.Galaxy --location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "GOG Galaxy") --accept-package-agreements --accept-source-agreements

    # Playnite
    $PlayniteParams = @{
        Name     = "Playnite"
        Repo     = "JosefNemec/Playnite"
        Location = (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Playnite")
    }
    Install-GitHub @PlayniteParams

    # Steam
    winget install -e --id Valve.Steam --location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Steam") --accept-package-agreements --accept-source-agreements

    # Ubisoft Connect
    winget install -e --id Ubisoft.Connect --location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Ubisoft Connect") --accept-package-agreements --accept-source-agreements

    # Xbox
    winget install -e --id 9MV0B5HZVK9Z --accept-package-agreements --accept-source-agreements
}

if ($confirmationEmulators -eq 'y') {
    # Cemu
    $CemuParams = @{
        Name     = "Cemu"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators")
        URL      = "https://cemu.info/releases/cemu_1.26.2.zip"
    }
    Install-Zip @CemuParams

    Set-Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators")
    Get-ChildItem "*" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "Cemu"
    }
    Set-location ~

    # Citra
    Invoke-WebRequest "https://github.com/citra-emu/citra-nightly/releases/download/nightly-1775/citra-windows-mingw-20220723-357025d.7z" -OutFile "Citra.7z"

    if ($confirmationDrive -eq "c") {
        & C:\Program Files\7-Zip\7z.exe x -o".\" "Citra.7z" -r
    }
    if ($confirmationDrive -eq "d") {
        & D:\7-Zip\7z.exe x -o".\" "Citra.7z" -r
    }

    Rename-Item nightly-mingw Citra
    Move-Item Citra (Join-Path -Path "$InstallDrive" -ChildPath "Emulators")
    Remove-Item Citra.7z

    # Dolphin
    Invoke-WebRequest "https://dl.dolphin-emu.org/builds/0c/ca/dolphin-master-5.0-16793-x64.7z" -OutFile "Dolphin.7z"

    if ($confirmationDrive -eq "c") {
        & C:\Program Files\7-Zip\7z.exe x -o".\" "Dolphin.7z" -r
    }
    if ($confirmationDrive -eq "d") {
        & D:\7-Zip\7z.exe x -o".\" "Dolphin.7z" -r
    }

    Rename-Item Dolphin-x64 Dolphin
    Move-Item Dolphin (Join-Path -Path "$InstallDrive" -ChildPath "Emulators")
    Remove-Item Dolphin.7z

    # NoPayStation
    Invoke-WebRequest "https://nopaystation.com/vita/npsReleases/NPS_Browser_0.94.exe" -OutFile NoPayStation.exe

    mkdir $InstallDrive\Emulators\NoPayStation
    Move-Item NoPayStation.exe (Join-Path -Path "$InstallDrive\Emulators\NoPayStation" -ChildPath "NoPayStation.exe")
    gh release download -R mmozeiko/pkg2zip --pattern "pkg2zip_64bit.zip"

    Expand-Archive "pkg2zip_64bit.zip" (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "NoPayStation")
    Remove-item pkg2zip_64bit.zip

    # PCSX2
    gh release download -R PCSX2/pcsx2 --pattern "*-portable.7z"
    Get-ChildItem "*.7z" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "pcsx2.7z"
    }
    if ($confirmationDrive -eq "c") {
        & C:\Program Files\7-Zip\7z.exe x -o"$InstallDrive\Emulators" "pcsx2.7z" -r
    }
    if ($confirmationDrive -eq "d") {
        & D:\7-Zip\7z.exe x -o"$InstallDrive\Emulators" "pcsx2.7z" -r
    }
    Remove-Item "pcsx2.7z"

    Set-Location (Join-Path -Path "$InstallDrive" -ChildPath "Emulators")
    Get-ChildItem "PCSX2 *" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "PCSX2"
    }
    Set-Location ~

    # PPSSPP
    $PPSSPPParams = @{
        Name     = "PPSSPP"
        Location = (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "PPSSPP")
        URL      = "https://www.ppsspp.org/files/1_12_3/ppsspp_win.zip"
    }
    Install-Zip @PPSSPPParams

    # Project64
    $Project64Params = @{
        Name     = "Project64"
        Location = (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "Project64")
        URL      = "https://www.pj64-emu.com/file/project64-3-0-0-5632-f83bee9/"
    }
    Install-Zip @Project64Params

    # QCMA
    gh release download -R codestation/qcma --pattern "*.exe"
    Get-ChildItem "Qcma_*.exe" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "Qcma.exe"
    }

    New-Item $InstallDrive\Emulators\Qcma -ItemType Directory
    Move-Item Qcma.exe $InstallDrive\Emulators\Qcma\Qcma.exe

    # RetroArch
    Invoke-WebRequest "https://buildbot.libretro.com/stable/1.10.3/windows/x86_64/RetroArch.7z" -OutFile "RetroArch.7z"

    if ($confirmationDrive -eq "c") {
        & C:\Program Files\7-Zip\7z.exe x -o".\" "RetroArch.7z" -r
    }
    if ($confirmationDrive -eq "d") {
        & D:\7-Zip\7z.exe x -o".\" "RetroArch.7z" -r
    }

    Rename-Item RetroArch-Win64 RetroArch
    Move-Item RetroArch (Join-Path -Path "$InstallDrive" -ChildPath "Emulators")
    Remove-Item RetroArch.7z

    # RPCS3
    $RPCS3Params = @{
        Name     = "RPCS3"
        Repo     = "RPCS3/rpcs3-binaries-win"
        Pattern  = "*.7z"
        Location = (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "RPCS3")
        FileType = "7z"
    }
    Install-GitHub @RPCS3Params

    # Ryujinx
    $RyujinxParams = @{
        Name     = "Ryujinx"
        Repo     = "Ryujinx/release-channel-master"
        Pattern  = "ryujinx-*-win_x64.zip"
        Location = (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "Ryujinx")
    }
    Install-GitHub @RyujinxParams

    # SNES9X
    $SNES9XParams = @{
        Name     = "SNES9X"
        Location = (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "SNES9X")
        URL      = "https://dl.emulator-zone.com/download.php/emulators/snes/snes9x/snes9x-1.60-win32-x64.zip"
    }
    Install-Zip @SNES9XParams

    # Visual Boy Advance
    $VisualBoyAdvanceParams = @{
        Name     = "Visual Boy Advance"
        Location = (Join-Path -Path "$InstallDrive\Emulators" -ChildPath "Visual Boy Advance")
        URL      = "https://dl.emulator-zone.com/download.php/emulators/gba/vboyadvance/VisualBoyAdvance-1.8.0-beta3.zip"
    }
    Install-Zip @VisualBoyAdvanceParams
}

# -------------------- Miscellaneous --------------------

if ($confirmationLaptopDesktop -eq 'd') {
    # Archi Steam Farm
    $ArchiSteamFarmParams = @{
        Name     = "Archi Steam Farm"
        Repo     = "JustArchiNET/ArchiSteamFarm"
        Pattern  = "ASF-win-x64.zip"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Archi Steam Farm")
    }
    Install-GitHub @ArchiSteamFarmParams

    # Global Steam Controller
    $GloSCParams = @{
        Name     = "GloSC"
        Repo     = "Alia5/GlosSI"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Global Steam Controller")
        Version  = "0.0.7.0"
    }
    Install-GitHub @GloSCParams

    # Locale Emulator
    $LocaleEmulatorParams = @{
        Name     = "Locale Emulator"
        Repo     = "xupefei/Locale-Emulator"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Locale Emulator")
    }
    Install-GitHub @LocaleEmulatorParams

    # Hue Sync
    winget install -e --id Philips.HueSync --accept-package-agreements --accept-source-agreements
}

# HP Support Assistant
if ($confirmationLaptopDesktop -eq 'l') {
    $HPParams = @{
        Name         = "HP"
        ArgumentList = @("/s")
        URL          = "https://ftp.ext.hp.com/pub/softpaq/sp140001-140500/sp140482.exe"
    }
    Install-EXE @HPParams
}

# Amazon Send to Kindle
$AmazonParams = @{
    Name         = "Amazon Send to Kindle"
    ArgumentList = @("/norestart", "/S")
    URL          = "https://s3.amazonaws.com/sendtokindle/SendToKindleForPC-installer.exe"
}
Install-EXE @AmazonParams

# 1Password CLI
$arch = "64-bit"

switch ($arch) {
    '64-bit' { $opArch = 'amd64'; break }
    '32-bit' { $opArch = '386'; break }
    Default { Write-Error "Sorry, your operating system architecture '$arch' is unsupported" -ErrorAction Stop }
}

$installDir = Join-Path -Path "$InstallDrive" -ChildPath '1Password CLI'

Invoke-WebRequest -Uri "https://cache.agilebits.com/dist/1P/op2/pkg/v2.4.1/op_windows_$($opArch)_v2.4.1.zip" -OutFile op.zip
Expand-Archive -Path op.zip -DestinationPath $installDir -Force

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$installDir",
    [EnvironmentVariableTarget]::User
)

Remove-Item -Path op.zip

# 1Password
$1PasswordParams = @{
    Name         = "1Password"
    ArgumentList = @("--silent")
    URL          = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
}
Install-EXE @1PasswordParams

# Accessibility Insights for Windows
$AccessibilityInsightsforWindowsParams = @{
    Name     = "Accessibility Insights for Windows"
    Repo     = "microsoft/accessibility-insights-windows"
    Pattern  = "*.msi"
    FileType = "msi"
}
Install-GitHub @AccessibilityInsightsforWindowsParams

# Blender
winget install -e --id BlenderFoundation.Blender --accept-package-agreements --accept-source-agreements

# Calibre
winget install -e --id calibre.calibre --accept-package-agreements --accept-source-agreements

# CPU-Z
$CPUZParams = @{
    Name     = "CPU-Z"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "CPU-Z")
    URL      = "https://download.cpuid.com/cpu-z/cpu-z_2.01-en.zip"
}
Install-Zip @CPUZParams

# Cryptomator
$CryptomatorParams = @{
    Name     = "Cryptomator"
    Repo     = "cryptomator/cryptomator"
    Pattern  = "*.msi"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Cryptomator")
    FileType = "msi"
}
Install-GitHub @CryptomatorParams

# Discord
winget install -e --id Discord.Discord --location (Join-Path -Path "$InstallDrive" -ChildPath "Discord") --accept-package-agreements --accept-source-agreements

# Draw.io
winget install -e --id JGraph.Draw --location (Join-Path -Path "$InstallDrive" -ChildPath "DrawIO") --accept-package-agreements --accept-source-agreements

# DroidCam
$DroidCamParams = @{
    Name         = "DroidCam"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
    URL          = "https://files.dev47apps.net/win/DroidCam.Setup.6.5.2.exe"
}
Install-EXE @DroidCamParams

# eM Client
winget install -e --id eMClient.eMClient --accept-package-agreements --accept-source-agreements

# Microsoft Teams
winget install -e --id Microsoft.Teams --accept-package-agreements --accept-source-agreements

# FileZilla
$FileZillaParams = @{
    Name     = "FileZilla"
    Location = "$InstallDrive\"
    URL      = "https://dl1.cdn.filezilla-project.org/client/FileZilla_3.60.2_win64.zip?h=v0HJLEZWw0IRmgWMoieAfw&x=1658880574"
}
Install-Zip @FileZillaParams

Set-Location $InstallDrive\
Get-ChildItem "FileZilla-*" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "FileZilla"
}
Set-location ~

# Mozilla Firefox
$FirefoxParams = @{
    Name = "Mozilla Firefox"
    URL  = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=da"
}
Install-MSI @FirefoxParams

# Google Drive
$GoogleDriveParams = @{
    Name         = "GoogleDrive"
    ArgumentList = @("--silent", "--gsuite_shortcuts=false")
    URL          = "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe"
}
Install-EXE @GoogleDriveParams

# Handbrake
$HandBrakeParams = @{
    Name    = "HandBrake"
    Repo    = "HandBrake/HandBrake"
    Pattern = "*-x86_64-Win_GUI.zip"
}
Install-GitHub @HandBrakeParams

# Inkscape
$InkscapeParams = @{
    Name = "Inkscape"
    URL  = "https://media.inkscape.org/dl/resources/file/inkscape-1.2_2022-05-15_dc2aedaf03-x64_5iRsplS.msi"
}
Install-MSI @InkscapeParams

# Kmonad & Scoop
Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

scoop install stack # install stack

Set-Location $InstallDrive\
git clone https://github.com/kmonad/kmonad.git

Set-Location kmonad
stack build # compile KMonad (this will first download GHC and msys2, it takes a while)

Set-Location ~

# LaTeX-OCR
pip install torch torchvision torchaudio
pip install pix2tex[gui]

# MegaSync
winget install -e --id Mega.MEGASync --accept-package-agreements --accept-source-agreements

# Messenger
winget install -e --id 9WZDNCRF0083 --accept-package-agreements --accept-source-agreements

# MiniBin
$MiniBinParams = @{
    Name     = "MiniBin"
    Location = ".\"
    URL      = "https: / / dw47.uptodown.com / dwn / oc4YgcmvHp0-dsHGcZohsd42NY0ewNRNAiSTs2HlJtlCBGzXVi4M2l9UyDQU5v7WXJTm_8fVmOQ3FurkysYNjvyOcRCVFluvTewi0Zd4ogWUgzJ2_L4vFY22ad7Ahxrk/zSyQjuPPOOBEd3HdWoc1ApnZr_rW6ZdtPU4wcW5Et137n22-YXybLFJUrs96uf6toifQn2MidNgUkc1qwE7-obrnhXGrjQlZRwSNevtNrpnFN1gkSV0_lGRk_1PSEjZB/u7KFTm4cRv3o8Af70urxZIgddISO2Y4AcG4XEiB-DL4hfaGU9MCVBNV_8M5y6lvUPgbvAXnQWnlHedqL1mxdLg==/minibin-6-6-0-0-en-win.zip"
}
Install-Zip @MiniBinParams

Get-ChildItem "MiniBin-*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "MiniBin.exe"
}

Start-Process -FilePath .\Minibin.exe -Wait -ArgumentList "/S", "/D=D:\Minibin"
Remove-Item MiniBin.exe

# Notion
winget install -e --id Notion.Notion --location (Join-Path -Path "$InstallDrive" -ChildPath "Notion") --accept-package-agreements --accept-source-agreements

# Nvidia Geforce Experience
$NvidiaGEParams = @{
    Name         = "NvidiaGE"
    ArgumentList = @("-s", "-noreboot")
    URL          = "https://uk.download.nvidia.com/GFE/GFEClient/3.25.1.27/GeForce_Experience_v3.25.1.27.exe"
}
Install-EXE @NvidiaGEParams

# Nvidia RTX Voice
winget install -e --id Nvidia.RTXVoice --accept-package-agreements --accept-source-agreements

# OBS Studio
$OBSStudioParams = @{
    Name     = "OBS Studio"
    Repo     = "obsproject/obs-studio"
    Pattern  = "*-x64.zip"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "OBS Studio")
}
Install-GitHub @OBSStudioParams

# Open Hardware Monitor
$OpenHardwareParams = @{
    Name     = "Open Hardware Monitor"
    Location = "$InstallDrive\"
    URL      = "https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip"
}
Install-Zip @OpenHardwareParams
Rename-Item (Join-Path -Path "$InstallDrive" -ChildPath "OpenHardWareMonitor") "Open Hardware Monitor"

# Photoshop
Expand-Archive "$OneDriveDir\Backup\Adobe Photoshop 2020.zip" "$InstallDrive\"

# Proton VPN
winget install -e --id ProtonTechnologies.ProtonVPN --accept-package-agreements --accept-source-agreements

# Shotcut
$ShotcutParams = @{
    Name     = "Shotcut"
    Repo     = "mltframework/shotcut"
    Location = "$InstallDrive"
}
Install-GitHub @ShotcutParams

# TeamViewer
$TeamViewerParams = @{
    Name     = ""
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "TeamViewer")
    URL      = "https://download.teamviewer.com/download/TeamViewerPortable.zip"
}
Install-Zip @TeamViewerParams

# TeraCopy
$TeraCopyParams = @{
    Name         = "TeraCopy"
    ArgumentList = @("/exenoui", "/qn", "/norestart")
    URL          = "https://www.codesector.com/files/teracopy.exe"
}
Install-EXE @TeraCopyParams

# Tor Browser
$TorParams = @{
    Name         = "Tor"
    ArgumentList = @("/norestart", "/S")
    URL          = "https://www.torproject.org/dist/torbrowser/11.5/torbrowser-install-win64-11.5_en-US.exe"
}
Install-EXE @TorParams

Move-Item ([Environment]::GetFolderPath("Desktop") + "\Tor Browser") 'D:\Tor Browser'

# Unity Hub
$UnityHubParams = @{
    Name         = "Unity Hub"
    ArgumentList = @("/S", "/D=$InstallDrive\Unity Hub")
    URL          = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe"
}
Install-EXE @UnityHubParams

# WizTree
$WizTreeParams = @{
    Name     = "WizTree"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "WizTree")
    URL      = "https://antibodysoftware-17031.kxcdn.com/files/wiztree_4_08_portable.zip"
}
Install-Zip @WizTreeParams

# Yubikey Manager
$YubikeyManagerParams = @{
    Name         = "Yubikey Manager"
    ArgumentList = @("/S", "/D=$InstallDrive\Yubikey Manager")
    URL          = "https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-win32.exe"
}
Install-EXE @YubikeyManagerParams

# -------------------- Tools & Tweaks --------------------

# Figma
winget install -e --id Figma.Figma --accept-package-agreements --accept-source-agreements

# Mendeley
$MendeleyParams = @{
    Name         = "Mendeley"
    ArgumentList = @("/norestart", "/S")
    URL          = "https://static.mendeley.com/bin/desktop/mendeley-reference-manager-2.74.0.exe"
}
Install-EXE @MendeleyParams

# Onion Share
$OnionShareParams = @{
    Name     = "Onion Share"
    Repo     = "onionshare/onionshare"
    Pattern  = "*.msi"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Onion Share")
    FileType = "msi"
}
Install-GitHub @OnionShareParams

# Pandoc
Install-GitHub -Name "Pandoc" -Repo "jgm/pandoc" -Pattern "*_64.zip"
Get-ChildItem $InstallDrive\pandoc-* | Rename-Item -NewName {
    $_.Name -replace $_.Name, "Pandoc"
}

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\Pandoc",
    [EnvironmentVariableTarget]::User
)

# ShareX
$ShareXParams = @{
    Name     = "ShareX"
    Repo     = "ShareX/ShareX"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "ShareX")
}
Install-GitHub @ShareXParams

# Transmission
$TransmissionParams = @{
    Name     = "Transmission"
    Repo     = "transmission/transmission"
    Pattern  = "*-x64.msi"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Transmission")
    FileType = "msi"
}
Install-GitHub @TransmissionParams

# YT-DLP
gh release download -R yt-dlp/yt-dlp --pattern 'yt-dlp.exe' -D (Join-Path -Path "$InstallDrive" -ChildPath "YT-DLP")

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\YT-DLP",
    [EnvironmentVariableTarget]::User
)

# -------------------- Development Tools --------------------

# TexLive
if ($confirmationTex -eq 'y') {
    Invoke-WebRequest "https://mirrors.mit.edu/CTAN/systems/texlive/tlnet/install-tl.zip" -OutFile "Tex Live.zip"
    Expand-Archive "Tex Live.zip" ".\"
    Remove-Item "Tex Live.zip"

    Get-ChildItem "install-tl-*" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "install-tl"
    }

    .\install-tl\install-tl-windows.bat -no-gui -texdir (Join-Path -Path "$InstallDrive" -ChildPath "Tex Live") -no-interaction
    Remove-Item "install-tl", "install-tl.zip" -Recurse -Force -Confirm:$false
}

# Docker Desktop
winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements

# ffmpeg
Install-GitHub -Name "ffmpeg" -Repo "GyanD/codexffmpeg" -Pattern "*-full_build.zip"
Get-ChildItem $InstallDrive\*-full_build | Rename-Item -NewName {
    $_.Name -replace $_.Name, "ffmpeg"
}

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\ffmpeg\bin",
    [EnvironmentVariableTarget]::User
)

# JDK
winget install -e --id EclipseAdoptium.Temurin.17 --accept-package-agreements --accept-source-agreements

# GitHub Desktop
winget install -e --id GitHub.GitHubDesktop --accept-package-agreements --accept-source-agreements

# Insomnia
winget install -e --id Insomnia.Insomnia --accept-package-agreements --accept-source-agreements

# NVM
gh release download -R coreybutler/nvm-windows --pattern "nvm-noinstall.zip"
Expand-Archive nvm-noinstall.zip "$InstallDrive\NVM"
Remove-Item nvm-noinstall.zip

[Environment]::SetEnvironmentVariable(
    'NVM_HOME',
    '$InstallDrive\NVM',
    [System.EnvironmentVariableTarget]::User
)

[Environment]::SetEnvironmentVariable(
    'NVM_SYMLINK',
    '$InstallDrive\NodeJS',
    [System.EnvironmentVariableTarget]::User
)

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";%NVM_HOME%;%NVM_SYMLINK%",
    [EnvironmentVariableTarget]::User
)

New-Item $InstallDrive\NVM\settings.txt

"root: $InstallDrive\NVM" | Out-File -FilePath $InstallDrive\NVM\settings.txt
"path: $InstallDrive\NodeJS" | Out-File -FilePath $InstallDrive\NVM\settings.txt -Append
"arch: 64" | Out-File -FilePath $InstallDrive\NVM\settings.txt -Append
"proxy: none" | Out-File -FilePath $InstallDrive\NVM\settings.txt -Append

# Node.JS
nvm install latest

# R
$RParams = @{
    Name         = "R"
    ArgumentList = @("/SILENT", "/Dir=`"$InstallDrive\R`"")
    URL          = "https://mirrors.dotsrc.org/cran/bin/windows/base/R-4.2.1-win.exe"
}
Install-EXE @RParams

# Wireshark
$WiresharkParams = @{
    Name         = "Wireshark"
    ArgumentList = @("/S", "/desktopicon=no", "/quicklaunchicon=no", "/D=$InstallDrive\WireShark")
    URL          = "https://1.eu.dl.wireshark.org/win64/Wireshark-win64-3.6.6.exe"
}
Install-EXE @WiresharkParams

# Npcap
Start-Process "https://npcap.com/"

# -------------------- WSL --------------------

if ($confirmationUbuntu -eq 'y') {
    wsl --install -d Ubuntu
}

if ($confirmationDebian -eq 'y') {
    wsl --install -d Debian
}
