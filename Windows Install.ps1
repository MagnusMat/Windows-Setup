# Windows Install Script

Set-Location ~

# Terminate during any and all errors
$ErrorActionPreference = 'Stop'

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

    # TODO: Look at this again
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
    elseif ($FileType -eq "exe") {
        Move-Item "$Name.$FileType" $Location
    }
    else {
        Write-Output "Archive type not supported"
    }
    Remove-Item "$Name.$FileType"
}


function Install-Wingets {
    param (
        $items
    )

    foreach ($item in $items) {
        if ([string]::IsNullOrEmpty($item.Location) -and [string]::IsNullOrEmpty($item.Source)) {
            winget install -e --id $item.ID --accept-package-agreements --accept-source-agreements
        }
        elseif ([string]::IsNullOrEmpty($item.Source)) {
            winget install -e --id $item.ID --location $item.Location --accept-package-agreements --accept-source-agreements
        }
        elseif ([string]::IsNullOrEmpty($item.Location)) {
            winget install -e --id $item.ID --source $item.Source --accept-package-agreements --accept-source-agreements
        }
        else {
            winget install -e --id $item.ID --location $item.Location --source $item.Source --accept-package-agreements --accept-source-agreements
        }
    }
}


function Winget {
    param (
        [string]$Name,
        [string]$ID,
        [string]$Location,
        [string]$Source
    )

    $object = [PSCustomObject]@{
        Name     = $Name
        ID       = $ID
        Location = $Location
        Source   = $Source
    }

    return $object
}


# -------------------- Confirmations --------------------

# Prompt for Install Drive
do {
    $ConfirmationDrive = Read-Host "Do you want to install software the C: or D: drive c/d"
    if ($ConfirmationDrive -eq 'c') {
        $InstallDrive = "C:\Program Files"
        $CloudDriveDir = "$env:USERPROFILE\Proton Drive\Magnus_Mat\My files"
    }
    elseif ($ConfirmationDrive -eq 'd') {
        $InstallDrive = "D:"
        $CloudDriveDir = "D:\Proton Drive\Magnus_Mat\My files"
    }
    else {
        "You need to pick a valid option"
    }
} while (
    ($ConfirmationDrive -ne "c") -and ($ConfirmationDrive -ne "d")
)

# Install Laptop Desktop Prompt
Set-Confirmation -Confirmation $ConfirmationLaptopDesktop -Question "Are you installing on a Laptop or Desktop l/d" -FirstTerm 'l' -SecondTerm 'd'

# Graphics Card Architecture Prompt
Set-Confirmation -Confirmation $ConfirmationNvidiaAMD -Question "Are you installing on a Nvidia or AMD system n/a" -FirstTerm 'n' -SecondTerm 'a'

# Games Prompt
Set-Confirmation -Confirmation $ConfirmationGames -Question "Do you want to install Games y/n"

# Emulator prompt
Set-Confirmation -Confirmation $ConfirmationEmulators -Question "Do you want to install Emulators y/n"

# Tex Prompt
Set-Confirmation -Confirmation $ConfirmationTex -Question "Do you want to install LaTeX y/n"

# Windows Terminal Settings Prompt
Set-Confirmation -Confirmation $ConfirmationWindowsTerm -Question "Do you want to replace the Windows Terminal Settings? This will not work if you have a Windows Terminal instance open y/n"

# -------------------- Initial Setup - Updates & Package Managers --------------------

# Upgade all packages
winget source update
winget upgrade --all --accept-package-agreements --accept-source-agreements

$dependenciesWingets = @()

# Git
$dependenciesWingets += Winget -Name "Git" -ID "Git.Git"

# GitHub CLI
$dependenciesWingets += Winget -Name "GitHub CLI" -ID "GitHub.cli"

# PowerShell 7
$dependenciesWingets += Winget -Name "Powershell 7" -ID "Microsoft.PowerShell" -Source "winget"

# 7-Zip
$dependenciesWingets += Winget -Name "7-Zip" -ID "7zip.7zip"

# DotNet 7 SDK
$dependenciesWingets += Winget -Name "DotNet 7 SDK" -ID "Microsoft.DotNet.SDK.7"

# DotNet 7 Runtime
$dependenciesWingets += Winget -Name "DotNet 7 Runtime" -ID "Microsoft.DotNet.Runtime.7"

# DotNet 7 Desktop Runtime
$dependenciesWingets += Winget -Name "DotNet 7 Desktop Runtime" -ID "Microsoft.DotNet.DesktopRuntime.7"

# AspNet Core 7
$dependenciesWingets += Winget -Name "AspNet Core 7" -ID "Microsoft.DotNet.AspNetCore.7"

# Visual Studio 2022 Enterprise
$dependenciesWingets += Winget -Name "Visual Studio 2022 Enterprise" -ID "Microsoft.VisualStudio.2022.Enterprise"

# Visual Studio 2019 Build Tools
$dependenciesWingets += Winget -Name "Visual Studio 2019 Build Tools" -ID "Microsoft.VisualStudio.2019.BuildTools"

# Microsoft 2015 VCRedistributables
$dependenciesWingets += Winget -Name "Microsoft 2015 VCRedistributables" -ID "Microsoft.VCRedist.2015+.x64"

# Python 3.10
$dependenciesWingets += Winget -Name "Python 3.10" -ID "Python.Python.3.10"

Install-Wingets -items $dependenciesWingets

Start-Process -FilePath pwsh.exe -ArgumentList {
    # Execution Permission
    Set-ExecutionPolicy RemoteSigned
} -Verb RunAs

# Reloads profile
. $profile

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";C:\Program Files\7-Zip",
    [EnvironmentVariableTarget]::User
)

# GitHub Cli Login
& 'C:\Program Files\GitHub CLI\gh.exe' auth login

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$env:USERPROFILE\AppData\Roaming\Python\Python310\Scripts",
    [EnvironmentVariableTarget]::User
)

# Reloads profile
. $profile

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

python.exe -m pip install --upgrade pip --user

# Install Windows Theme
Start-Process -filepath "$CloudDriveDir\Backup\Windows\Planets (Dark).deskthemepack"

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
Set-Location Fonts
Remove-Item README.md
Set-Location ~/FiraCode
Remove-Item readme.md, LICENSE
Set-Location ~/FiraMono
Remove-Item readme.md, LICENSE.txt
Set-Location ~
Get-ChildItem -Path FiraCode -Recurse -File | Move-Item -Destination Fonts
Get-ChildItem -Path FiraMono -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode, FiraMono

# Install all fonts in Fonts folder
Set-Location Fonts

$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
foreach ($file in Get-ChildItem "Fira*.ttf") {
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        Write-Output $fileName
        Get-ChildItem $file | ForEach-Object { $fonts.CopyHere($_.fullname) }
    }
}

Set-Location ~
Remove-Item Fonts -Recurse -Force -Confirm:$false

# -------------------- Websites --------------------

# Create a list of urls
$urls = @(
    "https://www.overleaf.com/"
    "https://pairdrop.net/"
    "https://mail.proton.me/"
    "https://github.com/ranmaru22/firefox-vertical-tabs"
    "https://www.minitool.com/news/how-to-pin-a-website-to-taskbar.html"
)

# Drivers and Software for HP Laptops
if ($confirmationLaptopDesktop -eq 'l') {
    $urls += "https://support.hp.com/us-en/drivers/laptops"
}

foreach ($url in $urls) {
    Start-Process $url
}

# -------------------- Development Tools & Dependencies --------------------

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

# -------------------- Programs --------------------

$wingets = @()

if ($confirmationNvidiaAMD -eq - 'a') {
    #TODO: AMD Radeon Software
}

if ($confirmationNvidiaAMD -eq - 'n') {
    # Nvidia Broadcast
    $wingets += winget -Name "Nvidia Broadcast" -ID "Nvidia.Broadcast"

    # Nvidia Control Panel
    $wingets += winget -Name "Nvidia Control Panel" -ID "9NF8H0H7WMLT"

    # Nvidia GeForce Experience
    $wingets += winget -Name "Nvidia GeForce Experience" -ID "Nvidia.GeForceExperience"
}

if ($confirmationLaptopDesktop -eq 'd') {
    # Hue Sync
    $wingets += winget -Name "Hue Sync" -ID "Philips.HueSync"

    # Locale Emulator
    $LocaleEmulatorParams = @{
        Name     = "Locale Emulator"
        Repo     = "xupefei/Locale-Emulator"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Locale Emulator")
    }
    Install-GitHub @LocaleEmulatorParams
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

# 3D Viewer
$wingets += Winget -Name "3D Viewer" -ID "9NBLGGH42THS"

# Accessibility Insights for Windows
$AccessibilityInsightsforWindowsParams = @{
    Name     = "Accessibility Insights for Windows"
    Repo     = "microsoft/accessibility-insights-windows"
    Pattern  = "*.msi"
    FileType = "msi"
}
Install-GitHub @AccessibilityInsightsforWindowsParams

# Amazon Send to Kindle
$AmazonParams = @{
    Name         = "Amazon Send to Kindle"
    ArgumentList = @("/norestart", "/S")
    URL          = "https://s3.amazonaws.com/sendtokindle/SendToKindleForPC-installer.exe"
}
Install-EXE @AmazonParams

# Blender
$wingets += Winget -Name "Blender" -ID "BlenderFoundation.Blender"

# Calibre
$wingets += Winget -Name "Calibre" -ID "calibre.calibre"

# Clangd
gh release download -R llvm/llvm-project --pattern "LLVM-*-win64.exe"

Get-ChildItem LLVM-*-win64.exe | Rename-Item -NewName {
    $_.Name -replace $_.Name, "LLVM.exe"
}

Start-Process -FilePath .\LLVM.exe -Wait -ArgumentList "/S"
remove-item LLVM.exe

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";C:\Program Files\LLVM\bin",
    [EnvironmentVariableTarget]::User
)

# CPU-Z
$CPUZParams = @{
    Name     = "CPU-Z"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "CPU-Z")
    URL      = "https://download.cpuid.com/cpu-z/cpu-z_2.01-en.zip"
}
Install-Zip @CPUZParams

# Discord
$wingets += Winget -Name "Discord" -ID "Discord.Discord"

# Docker Desktop
$wingets += Winget -Name "Docker Desktop" -ID "Docker.DockerDesktop"

# Draw.io
$wingets += Winget -Name "Draw.io" -ID "JGraph.Draw"

# DroidCam
$DroidCamParams = @{
    Name         = "DroidCam"
    ArgumentList = @("INSTALLDIR=$Location", "TARGETDIR=$Location", "/norestart", "/S")
    URL          = "https://files.dev47apps.net/win/DroidCam.Setup.6.5.2.exe"
}
Install-EXE @DroidCamParams

# Facebook Messenger
$wingets += Winget -Name "Facebook Messenger" -ID "9WZDNCRF0083"

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

# Figma
$wingets += Winget -Name "Figma" -ID "Figma.Figma"

# GitHub Desktop
$wingets += Winget -Name "GitHub Desktop" -ID "GitHub.GitHubDesktop"

# Handbrake
$HandBrakeParams = @{
    Name    = "HandBrake"
    Repo    = "HandBrake/HandBrake"
    Pattern = "*-x86_64-Win_GUI.zip"
}
Install-GitHub @HandBrakeParams

# HP Smart
$wingets += Winget -Name "HP Smart" -ID "9WZDNCRFHWLH"

# Inkscape
$wingets += Winget -Name "Inkscape" -ID "Inkscape.Inkscape"

# Insomnia #TODO: Fix this
$InsomniaParams = @{
    Name     = "Insomnia"
    Repo     = "Kong/insomnia"
    Pattern  = "*portable.exe"
    FileType = "exe"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Insomnia")
}
Install-GitHub @InsomniaParams

# JDK Adoptium JDK 17
$wingets += Winget -Name "JDK Adoptium JDK 17" -ID "EclipseAdoptium.Temurin.17.JDK"

# Jupyter Notebook
pip install jupyter

# LaTeX-OCR
pip install torch torchvision torchaudio
pip install pix2tex[gui]

# Libre Hardware Monitor
$LibreHardwareParams = @{
    Name     = "Libre Hardware Monitor"
    Repo     = "LibreHardwareMonitor/LibreHardwareMonitor"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Libre Hardware Monitor")
}
Install-GitHub @LibreHardwareParams
Rename-Item (Join-Path -Path "$InstallDrive/Libre Hardware Monitor" -ChildPath "LibreHardwareMonitor.exe") "Libre Hardware Monitor.exe"

# Mendeley
$MendeleyLink = ((Invoke-WebRequest -URI https://www.mendeley.com/download-reference-manager/windows -UseBasicParsing).Links | Where-Object href -like "https://static.mendeley.com/bin/desktop/*.exe").href

$MendeleyParams = @{
    Name         = "Mendeley"
    ArgumentList = @("/norestart", "/S")
    URL          = "$MendeleyLink"
}
Install-EXE @MendeleyParams

# Microsoft Teams
$wingets += Winget -Name "Microsoft Teams" -ID "Microsoft.Teams"

# Microsoft Whiteboard
$wingets += Winget -Name "Microsoft Whiteboard" -ID "9MSPC6MP8FM4"

# MiniBin
$MiniBinParams = @{
    Name     = "MiniBin"
    Location = ".\"
    URL      = "https://files03.tchspt.com/temp/minibin.zip"
}
Install-Zip @MiniBinParams

Get-ChildItem "MiniBin-*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "MiniBin.exe"
}

Start-Process -FilePath .\Minibin.exe -Wait -ArgumentList "/S", "/D=D:\Minibin"
Remove-Item MiniBin.exe

# Mozilla Firefox
$wingets += Winget -Name "Mozilla Firefox" -ID "Mozilla.Firefox"

# Mozilla Thunderbird Beta
$wingets += Winget -Name "Mozilla Thunderbird Beta" -ID "Mozilla.Thunderbird.Beta"

# MPEG-2
$wingets += Winget -Name "MPEG-2" -ID "9N95Q1ZZPMH4"

# Nextcloud
$wingets += Winget -Name "Nextcloud" -ID "Nextcloud.NextcloudDesktop"

# Notion
$wingets += Winget -Name "Notion" -ID "Notion.Notion"

# NVM for Windows
$wingets += Winget -Name "NVM for Windows" -ID "CoreyButler.NVMforWindows"

# OBS Studio
$OBSStudioParams = @{
    Name     = "OBS Studio"
    Repo     = "obsproject/obs-studio"
    Pattern  = "*-x64.zip"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "OBS Studio")
}
Install-GitHub @OBSStudioParams

# Obsidian
$wingets += Winget -Name "Obsidian" -ID "Obsidian.Obsidian"

# Onion Share
$OnionShareParams = @{
    Name     = "Onion Share"
    Repo     = "onionshare/onionshare"
    Pattern  = "*-win64-*.msi"
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

# PDF Sam
$PDFSamParams = @{
    Name     = "PDF Sam"
    Repo     = "torakiki/pdfsam"
    Pattern  = "pdfsam-*-windows.zip"
    Location = "$InstallDrive"
}
Install-GitHub @PDFSamParams

Get-ChildItem $InstallDrive\pdfsam-*-windows | Rename-Item -NewName {
    $_.Name -replace $_.Name, "PDF Sam"
}

# Postman
$wingets += Winget -Name "Postman" -ID "Postman.Postman"

# PowerToys
$wingets += Winget -Name "PowerToys" -ID "Microsoft.PowerToys"

# Proton Drive
$ProtonDriveLink = ((Invoke-WebRequest -URI https://proton.me/drive/download -UseBasicParsing).Links | Where-Object href -like "https://proton.me/download/drive/windows/*.exe").href

$ProtonDriveParams = @{
    Name         = "Proton Drive"
    ArgumentList = @("/norestart", "/S")
    URL          = "$ProtonDriveLink"
}
Install-EXE @ProtonDriveParams

# ProtonVPN
$wingets += Winget -Name "ProtonVPN" -ID "ProtonTechnologies.ProtonVPN"

# RustDesk
gh release download -R rustdesk/rustdesk --pattern "*-windows_x64-portable.zip"

Get-ChildItem "rustdesk-*.zip" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "RustDesk.zip"
}

Expand-Archive .\RustDesk.zip $InstallDrive\RustDesk
Remove-Item RustDesk.zip

Set-Location $InstallDrive\RustDesk

Get-ChildItem "rustdesk-*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "RustDesk.exe"
}

Set-Location ~

# Shotcut
gh release download -R mltframework/shotcut --pattern "*.zip"

Get-ChildItem "shotcut-*.zip" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "Shotcut.zip"
}

Expand-Archive Shotcut.zip $InstallDrive\

Remove-Item Shotcut.zip

# TeraCopy
$wingets += Winget -Name "TeraCopy" -ID "CodeSector.TeraCopy"

# TexLive
if ($confirmationTex -eq 'y') {
    Invoke-WebRequest "https://mirrors.mit.edu/CTAN/systems/texlive/tlnet/install-tl.zip" -OutFile "Tex Live.zip"
    Expand-Archive "Tex Live.zip" ".\"
    Remove-Item "Tex Live.zip"

    Get-ChildItem "install-tl-*" | Rename-Item -NewName {
        $_.Name -replace $_.Name, "install-tl"
    }

    .\install-tl\install-tl-windows.bat -no-gui -texdir (Join-Path -Path "$InstallDrive" -ChildPath "Tex Live") -no-interaction
}

# Tor Browser
$torLink = -Join ("https://www.torproject.org", ((Invoke-WebRequest -URI https://www.torproject.org/download/ -UseBasicParsing).Links | Where-Object href -like "*.exe").href[0])

$TorParams = @{
    Name         = "Tor"
    ArgumentList = @("/norestart", "/S")
    URL          = "$torLink"
}
Install-EXE @TorParams

Move-Item ([Environment]::GetFolderPath("Desktop") + "\Tor Browser") 'D:\Tor Browser'

# Transmission #TODO: Fix this
$TransmissionParams = @{
    Name     = "Transmission"
    Repo     = "transmission/transmission"
    Pattern  = "*-x64.msi"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Transmission")
    FileType = "msi"
}
Install-GitHub @TransmissionParams

# Unity Hub
$UnityHubParams = @{
    Name         = "Unity Hub"
    ArgumentList = @("/S", "/D=$InstallDrive\Unity")
    URL          = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe"
}
Install-EXE @UnityHubParams

# Visual Studio Code
$wingets += Winget -Name "Visual Studio Code" -ID "Microsoft.VisualStudioCode"

# Windows File Recovery
$wingets += Winget -Name "Windows File Recovery" -ID "9N26S50LN705"

# Windows Terminal settings
if ($confirmationWindowsTerm -eq 'y') {
    Set-Location 'C:\Users\magnu\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
    if ((Test-Path ./settings.json) -eq $false) {
        New-Item settings.json
    }
    Set-Content -Path 'settings.json' -Value (Get-Content -Path 'D:\GitHub\Windows-Terminal-Setup\Terminal settings.json' -Raw)
    Set-Location ~
}

# WinSCP
$wingets += Winget -Name "WinSCP" -ID "WinSCP.WinSCP"

# Wireshark
$wingets += Winget -Name "Wireshark" -ID "WiresharkFoundation.Wireshark"

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

# -------------------- Game Launchers & Emulators --------------------

if ($confirmationGames -eq 'y') {
    # Archi Steam Farm
    $ArchiSteamFarmParams = @{
        Name     = "Archi Steam Farm"
        Repo     = "JustArchiNET/ArchiSteamFarm"
        Pattern  = "ASF-win-x64.zip"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Archi Steam Farm")
    }
    Install-GitHub @ArchiSteamFarmParams

    # Epic Games
    $EpicGamesParams = @{
        Name     = "Epic Games"
        Location = (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Epic Games")
        URL      = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-13.3.0.msi?launcherfilename=EpicInstaller-13.3.0.msi"
    }
    Install-MSI @EpicGamesParams

    # Global Steam Controller
    $GloSCParams = @{
        Name     = "GloSC"
        Repo     = "Alia5/GlosSI"
        Location = (Join-Path -Path "$InstallDrive" -ChildPath "Global Steam Controller")
        Version  = "0.0.7.0"
    }
    Install-GitHub @GloSCParams

    # GOG Galaxy
    $wingets += winget -Name "GOG Galaxy" -ID "GOG.Galaxy" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "GOG Galaxy")

    # Minecraft
    $wingets += winget -Name "Minecraft" -ID "Mojang.MinecraftLauncher"

    # Playnite
    $PlayniteParams = @{
        Name     = "Playnite"
        Repo     = "JosefNemec/Playnite"
        Location = (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Playnite")
    }
    Install-GitHub @PlayniteParams

    # Steam
    $wingets += winget -Name "Steam" -ID "Valve.Steam" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Steam")

    # Ubisoft Connect
    $wingets += winget -Name "Ubisoft Connect" -ID "Ubisoft.Connect" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Ubisoft Connect")

    # Xbox
    $wingets += winget "Xbox" -ID "9MV0B5HZVK9Z"

    # Xbox Accessories
    $wingets += winget "Xbox Accessories" -ID "9NBLGGH30XJ3"
}

if ($confirmationEmulators -eq 'y') {
    # Cemu
    $CemuParams = @{
        Name     = "Cemu"
        Repo     = "cemu-project/Cemu"
        Pattern  = "*-windows-x64.zip"
        Location = (Join-Path -Path "$InstallDrive/Emulators" -ChildPath "Cemu")
    }
    Install-GitHub @CemuParams

    # Citra
    Invoke-WebRequest "https://github.com/citra-emu/citra-nightly/releases/download/nightly-1775/citra-windows-mingw-20220723-357025d.7z" -OutFile "Citra.7z"

    if ($confirmationDrive -eq "c") {
        & C:\Program Files\7-Zip\7z.exe x -o".\" "Citra.7z" -r
    }
    if ($confirmationDrive -eq "d") {
        & D:\7-Zip\7z.exe x -o".\" "Citra.7z" -r
    }

    Rename-Item nightly-mingw Citra
    Move-Item Citra (Join-Path -Path "$InstallDrive/Emulators" -ChildPath "Citra")
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
    $noPayStationLink = ((Invoke-WebRequest -URI https://nopaystation.com/ -UseBasicParsing).Links | Where-Object href -like "https://nopaystation.com/vita/npsReleases/*.exe").href
    Invoke-WebRequest "$noPayStationLink" -OutFile NoPayStation.exe

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

# -------------------- Final Install of Wingets --------------------

# Install all the wingets in an array
Install-Wingets -items $wingets

# Remove Desktop Icons
$desk = [Environment]::GetFolderPath("Desktop")
Set-Location $desk

remove-item *
Set-Location ~
