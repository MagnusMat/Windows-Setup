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

# Set Wallpaper
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


$ConfirmParams = @{
    Confirmation = $confirmationLaptopDesktop
    Question     = "Are you installing on a Laptop or Desktop l/d"
    FirstTerm    = 'l'
    SecondTerm   = 'd'
}
Set-Confirmation @ConfirmParams

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

# Upgade all packages
winget upgrade -h --all

# -------------------- Dependencies --------------------

# Git
winget install -e --id Git.Git --accept-package-agreements

# GitHub CLI
winget install -e --id GitHub.cli --accept-package-agreements

# GitHub Cli Login
gh auth login

# Msys2
gh release download -R msys2/msys2-installer --pattern "msys2-x86_64-*.exe"
Get-ChildItem "*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "msys2.exe"
}

.\msys2.exe in --confirm-command --accept-messages --root "$InstallDrive/Msys2-64"

Remove-Item msys2.exe

Set-Location "$InstallDrive\Msys2-64"
.\msys2.exe bash -l -c "pacman -Syu --noconfirm"
.\msys2_shell.cmd -l -c "pacman -Syu --noconfirm"
.\msys2.exe bash -l -c "pacman -S --needed base-devel mingw-w64-x86_64-toolchain --noconfirm"

Set-Location ~

# DotNet
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
$VisualStudioEnterprise2022Params = @{
    Name         = "VSEnterprise"
    ArgumentList = @("--installPath (Join-Path -Path `"$InstallDrive`" -ChildPath `"Visual Studio`" -AdditionalChildPath `"Visual Studio 2022`")", "--passive", "--norestart")
    URL          = "https://aka.ms/vs/17/release/vs_enterprise.exe"
}
Install-EXE @VisualStudioEnterprise2022Params

# Visual Studio 2019 Build Tools
$VisualStudio2019BuildToolsParams = @{
    Name         = "BuildTools"
    ArgumentList = @("--installPath (Join-Path -Path `"$InstallDrive`" -ChildPath `"Visual Studio`" -AdditionalChildPath `"Build Tools 2022`")", "--passive", "--norestart")
    URL          = "https://download.visualstudio.microsoft.com/download/pr/d59287e5-e208-462b-8894-db3142c39eca/c6d14e46b035dd68b0e813768ca5d8d4fb712a2930cc009a2fc68873e37f0e42/vs_BuildTools.exe"
}
Install-EXE @VisualStudio2019BuildToolsParams

# Python
Start-Process -FilePath powershell.exe -ArgumentList {
    choco install -y python
} -verb RunAs

python.exe -m pip install --upgrade pip --user

# -------------------- Package Managers --------------------

# Scoop
Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

# Chocolatey
Set-ExecutionPolicy Bypass -Scope Process
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

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
    # Battle.net
    $BattleNetParams = @{
        Name         = "BattleNet"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
        URL          = "https://eu.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe&id=undefined"
    }
    Install-EXE @BattleNetParams

    # EA Desktop
    $EADesktopParams = @{
        Name         = "EADesktop"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
        URL          = "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe"
    }
    Install-EXE @EADesktopParams

    # Epic Games
    $EpicGamesParams = @{
        Name     = "Epic Games"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Game Launchers" -AdditionalChildPath "Epic Games")
        URL      = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-13.3.0.msi?launcherfilename=EpicInstaller-13.3.0.msi"
    }
    Install-MSI @EpicGamesParams

    # GOG Galaxy
    $GOGParams = @{
        Name         = "GOG"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART")
        URL          = "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe?payload=-pDvfQCpG8P9YBHyMv6HtcPD-BtNgQymtd9H0KBdPUr1h9uW1LKDjc5Kh1-fFSyEesU5Ic5tf5WXX6AQXsbLD6-jOUEjJWbrIhJm-HKVMq7Lb5gvM2y8xZgl_P9zHlF25dzeJK_w2jqnZgyzyi33pvhyt8L-rTz58B5-oCc03OUb4BbSFrNqOiCC5Ld61Td_76QdEa5XXw0FYvKiROta7cwLBat56Pfg071C3jRlQSOdX7wLhof7UNbI-PJhMZT6Q6PWSYDfQeBzQJoHxvemMjO-gLtE2VRg2ymeJfX6wN4SvMY7oATjltWHEPgBr28FusGf7o_n1mvGCg_VXqthYxGal17ezyMV9TcMd2ias0tnJgJjItfoVXtCLmmH9SNIYrjl-dr7JzR-j1PjFgV6mUIHOx5QCuLVhKL6mXyT2UniuoJM22F1Lu3M_DIjFUIhCb2RCG542_Hu9CcyxCR5umuHlBPEKsFPTRy7Xy5PzLlkLntVUNj6Z9N5r1ZR-w2_UIQKGgDhPS3NKG4IRkHxWtMAJV4_9vqLymgbiO5DQAZg0dnlCJZvc4EWC_87Ri71kriCQ7DfX-HjSfOOY8EQyx3FXHSpLvNtyR1bkXdVCYUTHQRIaBdPlkxmzTUARhquOHGRScqqbT3Qy4Af0vXx1vA1GCka3F59174nkYbW84s8019WCiVsPeXHCC8_YjaZMefsTnS5_1Qu7uMHT5ixqqrUEMxh2rHRux34l4uPpYH73SIC5rUmwcff2ASmLSv_mELqW5RpcXqjO2dRVEYkrZkCt1uPfVrH1_RMOa7oHE34G6oP3E4JjaYdxMj-3iEiZ-F6jtxe"
    }
    Install-EXE @GOGParams

    # Playnite
    $PlayniteParams = @{
        Name     = "Playnite"
        Repo     = JosefNemec/Playnite
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Game Launchers" -AdditionalChildPath "Playnite")
    }
    Install-GitHub @PlayniteParams

    # Steam
    winget install -e --id Valve.Steam --location (Join-Path -Path "$InstallDrive" -ChildPath "Game Launchers" -AdditionalChildPath "Steam") --accept-package-agreements

    # Ubisoft Connect
    $UbisoftConnectParams = @{
        Name         = "Ubisoft Connect"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
        URL          = "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe"
    }
    Install-EXE @UbisoftConnectParams
}

if ($confirmationEmulators -eq 'y') {
    # Cemu
    $CemuParams = @{
        Name     = "Cemu"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Cemu")
        URL      = "https://cemu.info/releases/cemu_1.26.2.zip"
    }
    Install-Zip @CemuParams

    # Citra
    $CitraParams = @{
        Name         = "Citra"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
        URL          = "https://github.com/citra-emu/citra-web/releases/download/1.0/citra-setup-windows.exe"
    }
    Install-MSI @CitraParams

    # Dolphin
    $DolphinParams = @{
        Name     = "Dolphin"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Dolphin")
        URL      = "https://dl.dolphin-emu.org/builds/0c/ca/dolphin-master-5.0-16793-x64.7z"
    }
    Install-MSI @DolphinParams

    # NoPayStation
    Invoke-WebRequest "https://nopaystation.com/vita/npsReleases/NPS_Browser_0.94.exe" -OutFile NoPayStation.exe

    Move-Item NoPayStation.exe (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "NoPayStation")
    gh release download -R mmozeiko/pkg2zip --pattern "pkg2zip_64bit.zip"

    Expand-Archive "pkg2zip_64bit.zip" (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "NoPayStation")
    Remove-item pkg2zip_64bit.zip

    # PCSXR
    $PCSXRParams = @{
        Name     = "PCSXR"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "PCSXR")
        URL      = "https://doc-04-7k-docs.googleusercontent.com/docs/securesc/ecq0a8qqs25h8o2tcb0lnareatt3292s/vjg8o6edbh6iucm8c59hk0bdpp5i3fp7/1657727400000/06771232046367458076/05057713440002365443/1mLmNoRIeswoPy2GT78PKk0uig2a65jyC?e=download&ax=ACxEAsbeLFMyQwcpa6aKRjY2QhwN9qLhb72MeXCppKHIVJmNOzXeL6keX0E9I2kuasSz-rIWhmTqSGU-WkJiDGS1yiO5_8V9EpDoqUleyJ6h9oY4fWmED1jcwgcYvm9iEBzuvn5ft-Kr6feB3UB6F7bbQ5pRe0FAFXQlXqDbGDpfRu-1HBv_VGUnHDcn2Pt4ytDQ_Sp25KNTnZ5GM3qJjwStz_iNlxF3vbwhF4lbwtmkRmaF8SjYwrw5ljKRhJpW7hXMmxs0W82MqBPdkDbqyUA7A9c5B6UXidB1LXNQUqDzjc0Ew6hZh3BKhIeeeC4h_HEmo99QZjfF2kdjuHK8NKCQLI1jwygeDGPDvJq0Y86FgjN5tewgiVCfDGvAytkwgYRT_R7fUirk8-boCLVwX-Nr-97loYKJkMgjQp3PBY0hg2cQxeqzdcJZHB4wTOEjIWnh9ow_l9yqva1utHMr04F_GrMObxj5POO4XhxFIzTl52d6Ciqa86BN2WzwuP1b2eTg-iaMFEKXssYgSUOW-bYEPz7_YnKTYbfu5FOnsUR5worM2VQQ27C6KTPcBaycrf1pwdTNkz8eRoBPBH-uHyhMRsksBSWOzRbCwqVDQkB72WBKvXrop54qk4J8jZMTUjxuSdFJCkgsoPu16ZhwPXGzL-5RJnAo9bO9zItma-hCoDTwn-HKRzplAeOPxXV5WZcQjm71D-qPsr2tOgktF7RihlrGLM9crtIfwxRE6PZS-_-1K6I000RHmNa_BMciv9tnCeoR5v04Pjrr69s3RqGAKyc&uuid=4b06f5cb-861d-4546-a5f4-e4f90058e466&authuser=0&nonce=8vp23uqdplcoa&user=05057713440002365443&hash=q4k56sa03ibsqu7lp3rcgd5eu32va0au"
    }
    Install-Zip @PCSXRParams

    # PCSX2
    $PCSX2Params = @{
        Name     = "PCSX2"
        Repo     = "PCSX2/pcsx2"
        Pattern  = "*.7z"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "PCSX2")
        FileType = "7z"
    }
    Install-GitHub @PCSX2Params

    # PPSSPP
    $PPSSPPParams = @{
        Name     = "PPSSPP"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "PPSSPP")
        URL      = "https://www.ppsspp.org/files/1_12_3/ppsspp_win.zip"
    }
    Install-Zip @PPSSPPParams

    # Project64
    $Project64Params = @{
        Name     = "Project64"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Project64")
        URL      = "https://www.pj64-emu.com/file/project64-3-0-0-5632-f83bee9/"
    }
    Install-Zip @Project64Params

    # QCMA
    gh release download -R codestation/qcma --pattern "*.exe"
    Get-ChildItem "Qcma_*.exe" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "Qcma.exe"
    }

    Start-Process -FilePath .\Qcma.exe -Wait -ArgumentList "INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S"
    Remove-Item Qcma.exe

    # RetroArch
    $RetroArchParams = @{
        Name     = "RetroArch"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "RetroArch")
        URL      = "https://buildbot.libretro.com/stable/1.10.3/windows/x86_64/RetroArch.7z"
    }
    Install-Zip @RetroArchParams

    # RPCS3
    $RPCS3Params = @{
        Name     = "RPCS3"
        Repo     = "RPCS3/rpcs3-binaries-win"
        Pattern  = "*.7z"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPaths "RPCS3")
        FileType = "7z"
    }
    Install-GitHub @RPCS3Params

    # Ryujinx
    $RyujinxParams = @{
        Name     = "Ryujinx"
        Repo     = "Ryujinx/release-channel-master"
        Pattern  = "ryujinx-*-win_x64.zip"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPaths "Ryujinx")
    }
    Install-GitHub @RyujinxParams

    # SNES9X
    $SNES9XParams = @{
        Name     = "SNES9X"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "SNES9X")
        URL      = "https://dl.emulator-zone.com/download.php/emulators/snes/snes9x/snes9x-1.60-win32-x64.zip"
    }
    Install-Zip @SNES9XParams

    # Visual Boy Advance
    $VisualBoyAdvanceParams = @{
        Name     = "Visual Boy Advance"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Emulators" -AdditionalChildPath "Visual Boy Advance")
        URL      = "https://dl.emulator-zone.com/download.php/emulators/gba/vboyadvance/VisualBoyAdvance-1.8.0-beta3.zip"
    }
    Install-Zip @VisualBoyAdvanceParams
}

# -------------------- Miscellaneous --------------------

if ($confirmationLaptopDesktop -eq 'd') {
    # Aorus Engine
    $AorusParams = @{
        Name         = "Aorus"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
        URL          = "https://download.gigabyte.com/FileList/Utility/AORUS_ENGINE_SETUP_V2.1.8_B220627_x86.exe?v=e95db161109e2514a9d69c5b9f2d1bb6"
    }
    Install-EXE @AorusParams

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
    $HueSyncParams = @{
        Name         = "Hue Sync"
        ArgumentList = @("/LANG=ENGLISH", "/NORESTART", "/SILENT", "/SUPPRESSMSGBOXES", "/DIR=`"$InstallDrive\Hue Sync`"")
        URL          = "https://firmware.meethue.com/storage/huesyncwin/28/67a57475-89a5-4e08-af01-e2f2299d458f/HueSyncInstaller_1.8.1.28.exe"
    }
    Install-EXE @HueSyncParams

    # Notes for Game Bar
    winget install -e --id 9NG4TL7TX1KW --accept-package-agreements
}

# HP Support Assistant
if ($confirmationLaptopDesktop -eq 'l') {
    $HPParams = @{
        Name         = "HP"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "-s")
        URL          = "https://ftp.ext.hp.com/pub/softpaq/sp140001-140500/sp140482.exe"
    }
    Install-EXE @HPParams
}

# Amazon Send to Kindle
if ($confirmationAmazon -eq 'y') {
    $AmazonParams = @{
        Name         = "Amazon Send to Kindle"
        ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
        URL          = "https://s3.amazonaws.com/sendtokindle/SendToKindleForPC-installer.exe"
    }
    Install-EXE @AmazonParams
}

# Samsung Magician
if ($confirmationSamsung -eq 'y') {
    Start-Process -FilePath powershell.exe -ArgumentList {
        choco install -y samsung-magician
    } -verb RunAs
}

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

$envMachinePath = [System.Environment]::GetEnvironmentVariable('PATH', 'machine')

if ($envMachinePath -split ';' -notcontains $installDir) {
    [Environment]::SetEnvironmentVariable('PATH', "$envMachinePath; $installDir", 'Machine')
}

Remove-Item -Path op.zip

# 1Password
$1PasswordParams = @{
    Name         = "1Password"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/S", "--silent")
    URL          = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
}
Install-EXE @1PasswordParams

# 7-Zip
winget install -e --id 7zip.7zip --location (Join-Path -Path "$InstallDrive" -ChildPath "7-Zip") --accept-package-agreements

# Accessibility Insights for Windows
$AccessibilityInsightsforWindowsParams = @{
    Name     = "Accessibility Insights for Windows"
    Repo     = "microsoft/accessibility-insights-windows"
    Pattern  = "* .msi"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Accessibility Insights for Windows")
    FileType = "msi"
}
Install-GitHub @AccessibilityInsightsforWindowsParams

# Blender
winget install -e --id BlenderFoundation.Blender --accept-package-agreements

# Calibre
winget install -e --id calibre.calibre --accept-package-agreements

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
winget install -e --id Discord.Discord --accept-package-agreements

# Draw.io
$DrawIOParams = @{
    Name     = "DrawIO"
    Repo     = "jgraph/drawio-desktop"
    Pattern  = "*.msi"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "DrawIO")
    FileType = "msi"
}
Install-GitHub @DrawIOParams

# DroidCam
$DroidCamParams = @{
    Name         = "DroidCam"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
    URL          = "https://files.dev47apps.net/win/DroidCam.Setup.6.5.2.exe"
}
Install-EXE @DroidCamParams

# eM Client
$EMClientParams = @{
    Name     = "EM Client"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "EM Client")
    URL      = "https://cdn-dist.emclient.com/dist/v9.0.1708/setup.msi?sp=r&st=2020-05-06T07:52:16Z&se=3000-05-07T07:52:00Z&sv=2019-10-10&sr=c&sig=XTseyj3q1sYO2avsYPMzj5b8MMTOWRpL1KN92wU5HR4%3D"
}
Install-MSI @EMClientParams

# Microsoft Teams
winget install -e --id Microsoft.Teams --accept-package-agreements

# FileZilla
$FileZillaParams = @{
    Name     = "FileZilla"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "FileZilla")
    URL      = "https://dl3.cdn.filezilla-project.org/client/FileZilla_3.60.1_win64.zip?h=vDeiZ54lWjJOb0sS_f8mWg&x=1657730266"
}
Install-Zip @FileZillaParams

# Mozilla Firefox
$FirefoxParams = @{
    Name     = "Mozilla Firefox"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Mozilla Firefox")
    URL      = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=da"
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
    Name     = "Inkscape"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Inkscape")
    URL      = "https://media.inkscape.org/dl/resources/file/inkscape-1.2_2022-05-15_dc2aedaf03-x64_5iRsplS.msi"
}
Install-MSI @InkscapeParams

# Kmonad
scoop install stack # install stack
if ($confirmationKmonad -eq 'y') {
    Set-Location $InstallDrive\
    git clone https://github.com/kmonad/kmonad.git

    Set-Location kmonad
    stack build # compile KMonad (this will first download GHC and msys2, it takes a while)

    Set-Location ~
}

# LaTeX-OCR
pip3 install torch torchvision torchaudio
pip install pix2tex[gui]

# MegaSync
$MegaSyncParams = @{
    Name         = "MegaSync"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
    URL          = "https://mega.nz/MEGAsyncSetup64.exe"
}
Install-EXE @MegaSyncParams

# Messenger
winget install -e --id 9WZDNCRF0083 --accept-package-agreements

# MiniBin
$MiniBinParams = @{
    Name     = "MiniBin"
    Location = ".\"
    URL      = "https://dw11.uptodown.com/dwn/NMb64HUUsy0TDuk_tO7tYTlr4pXEwg21C7K0zBrvfqRxaGACdxEDLLIECOcQ6uNl9z31zNLlug0ZCWJwfawtEJrKjpr3p4Lqky56_Eb_UP_MXF-_Oz-4bbu_AjWsJ9iE/tKjr_zz741k7e0q0pzGVGvz0B_55fL9BmwDo8n6mfgESODl9t6WIv5JkYEes21RSMTLfoTzwGGzDV7A02ar9L0yDWsODD0KiLyCH0oooBOCm02OhYdLsw1T-UQPByMC0/l3sBFcGDrooxO805_ZPrD3vtZHQXS3vldy3YtqyIPRMufhykJZ6NXnBLO9otURtUfbHDRCDus8e-U4_2ZxCCFQ==/minibin-6-6-0-0-en-win.zip"
}
Install-Zip @MiniBinParams

Get-ChildItem "MiniBin-*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "MiniBin.exe"
}

Start-Process -FilePath .\Minibin.exe -Wait -ArgumentList "/norestart", "/S"
Remove-Item MiniBin.exe

# Notion
$NotionParams = @{
    Name         = "Notion"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
    URL          = "https://desktop-release.notion-static.com/Notion%20Setup%202.0.28.exe"
}
Install-EXE @NotionParams

# Nvidia Geforce Experience
$NvidiaGEParams = @{
    Name         = "NvidiaGE"
    ArgumentList = @("-s", "-noreboot")
    URL          = "https://uk.download.nvidia.com/GFE/GFEClient/3.25.1.27/GeForce_Experience_v3.25.1.27.exe"
}
Install-EXE @NvidiaGEParams

# Nvidia RTX Voice
winget install -e --id Nvidia.RTXVoice --accept-package-agreements

# OBS Studio
$OBSStudioParams = @{
    Name     = "OBS Studio"
    Repo     = "obsproject/obs-studio"
    Pattern  = "*-x64.zip"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "OBS Studio")
}
Install-GitHub @OBSStudioParams

# Open Hardware Monitor
Install-Zip -Name "Open Hardware Monitor" -URL "https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip"
Rename-Item (Join-Path -Path "$InstallDrive" -ChildPath "OpenHardWareMonitor") "Open Hardware Monitor"

# Proton VPN
$ProtonVPNParams = @{
    Name         = "ProtonVPN"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/quiet")
    URL          = "https://protonvpn.com/download/ProtonVPN_win_v2.0.1.exe"
}
Install-EXE @ProtonVPNParams

# Shotcut
$ShotcutParams = @{
    Name     = "Shotcut"
    Repo     = "mltframework/shotcut"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Shotcut")
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

Move-Item '.\Desktop\Tor Browser\' 'D:\Tor Browser'

# Unity Hub
$UnityHubParams = @{
    Name         = "Unity Hub"
    ArgumentList = @("/D=$InstallDrive\Unity", "/norestart", "/S")
    URL          = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe"
}
Install-EXE @UnityHubParams

# VeraCrypt
$VeraCryptParams = @{
    Name     = "VeraCrypt"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "VeraCrypt")
    URL      = "https://launchpad.net/veracrypt/trunk/1.25.9/+download/VeraCrypt_Setup_x64_1.25.9.msi"
}
Install-MSI @VeraCryptParams

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
    ArgumentList = @("/S")
    URL          = "https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-win32.exe"
}
Install-EXE @YubikeyManagerParams

# -------------------- Tools & Tweaks --------------------

# Figma
$FigmaParams = @{
    Name         = "Figma"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S", "/Silent")
    URL          = "https://desktop.figma.com/win/FigmaSetup.exe"
}
Install-EXE @FigmaParams

# Mendeley
$MendeleyParams = @{
    Name         = "Mendeley"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
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

# -------------------- Development Tools --------------------

# TexLive
if ($confirmationTex -eq 'y') {
    Start-Process -FilePath powershell.exe -ArgumentList {
        $TexLiveParams = @{
            Name     = "Tex Live"
            Location = ".\"
            URL      = "https://mirrors.mit.edu/CTAN/systems/texlive/tlnet/install-tl.zip"
        }
        Install-Zip @TexLiveParams

        Get-ChildItem "install-tl-*" | Rename-Item -NewName {
            $_.Name -replace $_.Name, "install-tl"
        }

        .\install-tl\install-tl-windows.bat -no-gui -texdir (Join-Path -Path "$InstallDrive" -ChildPath "Tex Live") -no-interaction
        Remove-Item "install-tl", "install-tl.zip" -Recurse -Force -Confirm:$false
    } -verb RunAs
}

# Docker Desktop
if ($confirmationDocker -eq 'y') {
    winget install -e --id Docker.DockerDesktop --location (Join-Path -Path "$InstallDrive" -ChildPath "Docker") --accept-package-agreements
}

# ffmpeg
Install-GitHub -Name "ffmpeg" -Repo "GyanD/codexffmpeg" -Pattern "*-full_build.zip"
Get-ChildItem $InstallDrive\*-full_build | Rename-Item -NewName {
    $_.Name -replace $_.Name, "ffmpeg"
}

# JDK
$JDKParams = @{
    Name     = "JDK"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "JDK")
    URL      = "https://objects.githubusercontent.com/github-production-release-asset-2e65be/372925194/624fbac8-d836-4208-8186-3d54c73e74f1?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220709%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220709T142037Z&X-Amz-Expires=300&X-Amz-Signature=1b5498f3c26397b1a8e86af9f65b2c7cb0d92ec0da0f2e239ecd597788c8e821&X-Amz-SignedHeaders=host&actor_id=26505751&key_id=0&repo_id=372925194&response-content-disposition=attachment%3B%20filename%3DOpenJDK17U-jdk_x64_windows_hotspot_17.0.3_7.zip&response-content-type=application%2Foctet-stream"
}
Install-Zip @JDKParams

# GitHub Desktop
winget install -e --id GitHub.GitHubDesktop --location (Join-Path -Path "$InstallDrive" -ChildPath "Github" -AdditionalChildPaths "Desktop") --accept-package-agreements

# Insomnia
$InsomniaParams = @{
    Name         = "Insomnia"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S", "--silent")
    URL          = "https://objects.githubusercontent.com/github-production-release-asset-2e65be/56899284/dd3795fc-6215-4d0a-875d-74746c959441?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220725%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220725T120532Z&X-Amz-Expires=300&X-Amz-Signature=40d36aafdfe6a98b8db10c62167db9e23df5409dcfa0220a47123515879632ec&X-Amz-SignedHeaders=host&actor_id=26505751&key_id=0&repo_id=56899284&response-content-disposition=attachment%3B%20filename%3DInsomnia.Core-2022.4.2.exe&response-content-type=application%2Foctet-stream"
}
Install-EXE @InsomniaParams

# NVM
Start-Process -FilePath powershell.exe -ArgumentList {
    choco install -y nvm
} -verb RunAs

# NPM & Node.JS
Start-Process -FilePath powershell.exe -ArgumentList {
    nvm install latest
} -verb RunAs

# R
$RParams = @{
    Name         = "R"
    ArgumentList = @("/SILENT", "/Dir=`"$InstallDrive\R`"")
    URL          = "https://mirrors.dotsrc.org/cran/bin/windows/base/R-4.2.1-win.exe"
}
Install-EXE @RParams

# Wireshark # Maybe
$WiresharkParams = @{
    Name         = "Wireshark"
    ArgumentList = @("/S", "/desktopicon=no", "/quicklaunchicon=no", "/D=$InstallDrive\WireShark")
    URL          = "https://1.eu.dl.wireshark.org/win64/Wireshark-win64-3.6.6.exe"
}
Install-EXE @WiresharkParams

# Npcap
$NpcapParams = @{
    Name         = "Npcap"
    ArgumentList = @("/S", "/D=$InstallDrive\Npcap")
    URL          = "https://npcap.com/dist/npcap-1.70.exe"
}
Install-EXE @NpcapParams

# -------------------- Windows Store Apps (winget) --------------------

# Microsoft Whiteboard
winget install -e --id 9MSPC6MP8FM4 --accept-package-agreements

# MPEG-2
winget install -e --id 9N95Q1ZZPMH4 --accept-package-agreements

# Nvidia Control Panel
winget install -e --id 9NF8H0H7WMLT --accept-package-agreements

# Powertoys
winget install -e --id Microsoft.PowerToys --accept-package-agreements

# PowerShell 7
winget install -e --id Microsoft.Powershell --source winget --accept-package-agreements

# QuickLook
winget install -e --id QL-Win.QuickLook --accept-package-agreements

# Visual Studio Code
winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements

# Windows File Recovery
winget install -e --id 9N26S50LN705 --accept-package-agreements

# HP Smart
winget install -e --id 9WZDNCRFHWLH --accept-package-agreements

# Wikipedia
winget install -e --id 9WZDNCRFHWM4 --accept-package-agreements

# 3d Viewer
winget install -e --id 9NBLGGH42THS --accept-package-agreements

# Xbox Accessories
winget install -e --id 9NBLGGH30XJ3 --accept-package-agreements

# -------------------- Fonts --------------------

New-Item Fonts -ItemType Directory

# Fira Code
Install-GitHub -Name "FiraCode" -Repo "tonsky/FiraCode" -Location ".\"
Get-ChildItem -Path FiraCode\ttf -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode -Recurse -Force -Confirm:$false

# Fira Code iScript
gh repo clone kencrocken/FiraCodeiScript
Get-ChildItem -Path FiraCodeiScript -File | Move-Item -Destination Fonts
Remove-Item FiraCodeiScript -Recurse -Force -Confirm:$false

# Fira Code Nerd Font
Install-GitHub -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraCode.zip" -Location ".\"
Install-GitHub -Name "FiraCode" -Repo "ryanoasis/nerd-fonts" -Pattern "FiraMono.zip" -Location ".\"
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

# -------------------- Paths --------------------
# DotNET Telemetry
[System.Environment]::SetEnvironmentVariable(
    'DOTNET_CLI_TELEMETRY_OPTOUT',
    '1',
    [System.EnvironmentVariableTarget]::User
)

# YT-DLP
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\YT-DLP",
    [EnvironmentVariableTarget]::User
)

# Cmake
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";C:\Program Files\CMake\bin",
    [EnvironmentVariableTarget]::User
)

# NodeJS
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\NodeJS",
    [EnvironmentVariableTarget]::User
)

# NVM
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\NVM",
    [EnvironmentVariableTarget]::User
)

# MinGW-64
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\Msys2-64\mingw64\bin",
    [EnvironmentVariableTarget]::User
)

# ffmpeg
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$InstallDrive\ffmpeg\bin",
    [EnvironmentVariableTarget]::User
)

# -------------------- WSL --------------------

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --install
# Needs reboot https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script

if ($confirmationUbuntu -eq 'y') {
    wsl --install -d Ubuntu
}

if ($confirmationDebian -eq 'y') {
    wsl --install -d Debian
}
wsl --set-default-version 2
