# Windows Install Script

Set-Location ~

# Terminate during any and all errors
$ErrorActionPreference = 'Stop'

# -------------------- Functions --------------------

function Set-Confirmation {
    param (
        [string]$Question,
        [string[]]$ValidOptions = @('y', 'n')
    )

    do {
        $Confirmation = Read-Host "$Question"
        if ($Confirmation -notin $ValidOptions) {
            Write-Host "You need to pick a valid option"
        }
    } while ($Confirmation -notin $ValidOptions)

    return $Confirmation
}


function Install-Zip {
    param (
        [string]$Name,
        [string]$Location,
        [string]$URL
    )
    try {
        Invoke-WebRequest $URL -OutFile "$Name.zip"
        Expand-Archive "$Name.zip" $Location
        Remove-Item "$Name.zip"
        Write-Output "$Name installed successfully"
    }
    catch {
        Write-Output "Failed to install $Name"
    }
}


function Install-EXE {
    param (
        [string]$Name,
        [string]$ArgumentList,
        [string]$URL
    )
    try {
        Invoke-WebRequest $URL -OutFile "$Name.exe"
        Start-Process -FilePath .\"$Name.exe" -Wait -ArgumentList $ArgumentList
        Remove-Item "$Name.exe"
        Write-Output "$Name installed successfully"
    }
    catch {
        Write-Output "Failed to install $Name"
    }
}


function Install-MSI {
    param (
        [string]$Name,
        [string]$Location = "$InstallDrive\",
        [string]$URL
    )
    try {
        Invoke-WebRequest $URL -OutFile "$Name.msi"
        Start-Process msiexec.exe -Wait -ArgumentList "/package `"$Name.msi`"", "INSTALLDIR=`"$Location`"", "TARGETDIR=`"$Location`"", "/passive", "/norestart"
        Remove-Item "$Name.msi"
        Write-Output "$Name installed successfully"
    }
    catch {
        Write-Output "Failed to install $Name"
    }
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
    elseif ($FileType -eq "exe") {
        Move-Item "$Name.$FileType" $Location
    }
    else {
        Write-Output "Archive type not supported"
    }
    Remove-Item "$Name.$FileType"
    Write-Output "$Name installed successfully"
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
        Write-Output "$item.Name installed successfully"
    }
}


function Get-DownloadLink {
    param (
        [string]$URL,
        [string]$DownloadURL
    )

    $url = ((Invoke-WebRequest -URI $URL -UseBasicParsing).Links | Where-Object { $_.href -like $DownloadURL } | Select-Object -First 1).href

    return $url
}


function Add-Winget {
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
$ConfirmationDrive = Set-Confirmation -Question "Do you want to install software the C: or D: drive c/d" -ValidOptions 'c', 'd'

if ($ConfirmationDrive -eq 'c') {
    $InstallDrive = "C:\Program Files"
}
if ($ConfirmationDrive -eq 'd') {
    $InstallDrive = "D:"
}

# Install Laptop Desktop Prompt
$ConfirmationLaptopDesktop = Set-Confirmation -Question "Are you installing on a Laptop or Desktop l/d" -ValidOptions 'l', 'd'

# Graphics Card Architecture Prompt
$ConfirmationNvidiaAMD = Set-Confirmation -Question "Are you installing on a Nvidia or AMD system n/a" -ValidOptions 'n', 'a'

# Games Prompt
$ConfirmationGames = Set-Confirmation -Question "Do you want to install Games y/n"

# Emulator prompt
$ConfirmationEmulators = Set-Confirmation -Question "Do you want to install Emulators y/n"

# Microsoft Teams
$ConfirmationTeams = Set-Confirmation -Question "Do you want to install Microsoft Teams? y/n"

# Unity Hub
$ConfirmationUnity = Set-Confirmation -Question "Do you want to install Unity Hub? y/n"

# Windows Terminal Settings Prompt
$ConfirmationWindowsTerm = Set-Confirmation -Question "Do you want to replace the Windows Terminal Settings? This will not work if you have a Windows Terminal instance open y/n"

# -------------------- Initial Setup - Updates & Package Managers --------------------

# Upgade all packages
winget source update

$dependenciesWingets = @()

# 7-Zip
$dependenciesWingets += Add-Winget -Name "7-Zip" -ID "7zip.7zip"

# Git
$dependenciesWingets += Add-Winget -Name "Git" -ID "Git.Git"

# GitHub CLI
$dependenciesWingets += Add-Winget -Name "GitHub CLI" -ID "GitHub.cli"

# PowerShell 7
$dependenciesWingets += Add-Winget -Name "Powershell 7" -ID "Microsoft.PowerShell" -Source "winget"

# Python 3.11
$dependenciesWingets += Add-Winget -Name "Python 3.11" -ID "Python.Python.3.11"

Install-Wingets -items $dependenciesWingets

Install-Module PSReadLine -Confirm:$false
Install-Module posh-git -Confirm:$false
Install-Module Terminal-Icons -Confirm:$false

$env:PATH = $env:PATH + ";C:\Program Files\Git\cmd"
$env:PATH = $env:PATH + ";C:\Program Files\GitHub CLI"
$env:PATH = $env:PATH + ";C:\Program Files\7-Zip"
$env:PATH = $env:PATH + ";$env:USERPROFILE\AppData\Roaming\Python\Python311\Scripts"

# Set PowerShell Profile
# Link not working
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MagnusMat/PowerShell-Scripts/main/Profile/Microsoft.PowerShell_profile.ps1" -OutFile Microsoft.Powershell_profile.ps1

Copy-Item .\Microsoft.Powershell_profile.ps1 $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
New-Item $env:USERPROFILE\Documents\PowerShell -ItemType Directory
Copy-Item .\Microsoft.Powershell_profile.ps1 $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

Remove-Item .\Microsoft.Powershell_profile.ps1

Start-Process -FilePath pwsh.exe -ArgumentList {
    # Execution Permission
    Set-ExecutionPolicy RemoteSigned
} -Verb RunAs

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
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$env:USERPROFILE\AppData\Roaming\Python\Python311\Scripts",
    [EnvironmentVariableTarget]::User
)

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

python.exe -m pip install --upgrade pip --user

# Install Windows Theme
# Link not working
Invoke-WebRequest -Uri https://github.com/MagnusMat/Windows-Setup/raw/6f36349404c969e2639bbe333fe7ed51c036e397/Desktop/Planets.deskthemepack -OutFile ./Planets.deskthemepack
Start-Process -FilePath ./Planets.deskthemepack
Remove-Item ./Planets.deskthemepack

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
Remove-Item README.md -Force -Confirm:$false
Set-Location ~/FiraCode
Remove-Item readme.md, LICENSE -Force -Confirm:$false
Set-Location ~/FiraMono
Remove-Item readme.md, LICENSE -Force -Confirm:$false
Set-Location ~
Get-ChildItem -Path FiraCode -Recurse -File | Move-Item -Destination Fonts
Get-ChildItem -Path FiraMono -Recurse -File | Move-Item -Destination Fonts
Remove-Item FiraCode, FiraMono -Recurse -Force -Confirm:$false

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
    "https://languagetool.org/insights/post/product-libreoffice/#how-to-enable-languagetool-on-libreoffice"
)

# Drivers and Software for HP Laptops
if ($confirmationLaptopDesktop -eq 'l') {
    $urls += "https://support.hp.com/us-en/drivers/laptops"
}

# Drivers and Software for AMD Radeon
if ($confirmationNvidiaAMD -eq 'a') {
    $urls += "https://www.amd.com/en/support"
}

# Drivers and Software for Nvidia RTX
if ($confirmationNvidiaAMD -eq 'n') {
     $urls += "https://www.nvidia.com/en-us/software/nvidia-app/"
}

foreach ($url in $urls) {
    Start-Process $url
}

# -------------------- Development Tools --------------------

$developmentToolWingets = @()

# AspNet Core 8
$developmentToolWingets += Add-Winget -Name "AspNet Core 8" -ID "Microsoft.DotNet.AspNetCore.8"

# DotNet 8 SDK
$developmentToolWingets += Add-Winget -Name "DotNet 8 SDK" -ID "Microsoft.DotNet.SDK.8"

# DotNet 8 Runtime
$developmentToolWingets += Add-Winget -Name "DotNet 8 Runtime" -ID "Microsoft.DotNet.Runtime.8"

# DotNet 8 Desktop Runtime
$developmentToolWingets += Add-Winget -Name "DotNet 8 Desktop Runtime" -ID "Microsoft.DotNet.DesktopRuntime.8"

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

# Microsoft 2015 VCRedistributables
$developmentToolWingets += Add-Winget -Name "Microsoft 2015 VCRedistributables" -ID "Microsoft.VCRedist.2015+.x64"

# Visual Studio 2022 Community
$developmentToolWingets += Add-Winget -Name "Visual Studio 2022 Community" -ID "Microsoft.VisualStudio.2022.Community"

Install-Wingets -items $developmentToolWingets

# -------------------- Programs --------------------

$wingets = @()

# 1Password
$wingets += Add-Winget -Name "1Password" -ID "AgileBits.1Password"

# 1Password CLI
$wingets += Add-Winget -Name "1Password CLI" -ID "1password-cli"

# 3D Viewer
$wingets += Add-Winget -Name "3D Viewer" -ID "9NBLGGH42THS"

# Blender
$wingets += Add-Winget -Name "Blender" -ID "BlenderFoundation.Blender"

# Calibre
$wingets += Add-Winget -Name "Calibre" -ID "calibre.calibre"

# CPU-Z
$wingets += Add-Winget -Name "CPU-Z" -ID "CPUID.CPU-Z"

# Discord
$wingets += Add-Winget -Name "Discord" -ID "Discord.Discord"

# Draw.io
$wingets += Add-Winget -Name "Draw.io" -ID "JGraph.Draw"

# Ente Auth
$EnteAuthParams = @{
    Name    = "Ente Auth"
    Repo    = "ente-io/ente"
    Pattern = "ente-auth-*-installer.exe "
}
Install-GitHub @$EnteAuthParams

# Facebook Messenger
$wingets += Add-Winget -Name "Facebook Messenger" -ID "9WZDNCRF0083"

# GitHub Desktop
$wingets += Add-Winget -Name "GitHub Desktop" -ID "GitHub.GitHubDesktop"

# Godot
$GodotParams = @{
    Name    = "Godot"
    Repo    = "godotengine/godot"
    Pattern = "*_win64.zip"
}
Install-GitHub @GodotParams

# Inkscape
$wingets += Add-Winget -Name "Inkscape" -ID "Inkscape.Inkscape"

# Jupyter Notebook
pip install jupyter

# Libre Hardware Monitor
$LibreHardwareParams = @{
    Name     = "Libre Hardware Monitor"
    Repo     = "LibreHardwareMonitor/LibreHardwareMonitor"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "Libre Hardware Monitor")
}
Install-GitHub @LibreHardwareParams
Rename-Item (Join-Path -Path "$InstallDrive/Libre Hardware Monitor" -ChildPath "LibreHardwareMonitor.exe") "Libre Hardware Monitor.exe"

# Libre Office
$wingets += Add-Winget -Name "Libre Office" -ID "TheDocumentFoundation.LibreOffice"

# Microsoft Teams
if ($confirmationTeams -eq 'y') {
    $wingets += Add-Winget -Name "Microsoft Teams" -ID "Microsoft.Teams"
}

# LocalSend
$wingets += Add-Winget -Name "LocalSend" -ID "localsend"

# LogSeq
$wingets += Add-Winget -Name "LogSeq" -ID "Logseq.Logseq"

# Microsoft Whiteboard
$wingets += Add-Winget -Name "Microsoft Whiteboard" -ID "9MSPC6MP8FM4"

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

# Mozilla Thunderbird
$wingets += Add-Winget -Name "Mozilla Thunderbird" -ID "Mozilla.Thunderbird"

# MPEG-2
$wingets += Add-Winget -Name "MPEG-2" -ID "9N95Q1ZZPMH4"

# Notion
$wingets += Add-Winget -Name "Notion" -ID "Notion.Notion"

# OBS Studio
$wingets += Add-Winget -Name "OBS Studio" -ID "XPFFH613W8V6LV"

# Oh My Posh
$wingets += Add-Winget -Name "Oh My Posh" -ID JanDeDobbeleer.OhMyPosh -Source "winget"

# PDF Sam
$wingets += Add-Winget -Name "PDF Sam" -ID "PDFsam.PDFsam"

# PowerToys
$wingets += Add-Winget -Name "PowerToys" -ID "Microsoft.PowerToys"

# ProtonDrive
$wingets += Add-Winget -Name "ProtonDrive" -ID "Proton.ProtonDrive"

# ProtonMail
$wingets += Add-Winget -Name "ProtonMail" -ID "Proton.ProtonMail"

# ProtonPass
$wingets += Add-Winget -Name "ProtonPass" -ID "Proton.ProtonPass"

# ProtonVPN
$wingets += Add-Winget -Name "ProtonVPN" -ID "Proton.ProtonVPN"

# RustDesk
gh release download -R rustdesk/rustdesk --pattern "*_64.exe"

Get-ChildItem "rustdesk-*.exe" | Rename-Item -NewName {
    $_.Name -replace $_.Name, "RustDesk.exe"
}

New-Item -Path $InstallDrive\RustDesk -ItemType Directory
Move-Item .\RustDesk.exe $InstallDrive\RustDesk\RustDesk.exe

# Shotcut
$wingets += Add-Winget -Name "Shotcut" -ID "Meltytech.Shotcut"

# SyncTrayzor
$wingets += Add-Winget -Name "SyncTrayzor" -ID "SyncTrayzor.SyncTrayzor"

# TeraCopy
$wingets += Add-Winget -Name "TeraCopy" -ID "CodeSector.TeraCopy"

# Tor Browser
$TorParams = @{
    Name         = "Tor"
    ArgumentList = @("/norestart", "/S")
    URL          = -Join ("https://www.torproject.org", (Get-DownloadLink -URL "https://www.torproject.org/download/" -DownloadURL "*.exe"))
}
Install-EXE @TorParams

Move-Item ([Environment]::GetFolderPath("Desktop") + "\Tor Browser") "$InstallDrive\Tor Browser"

# Transmission
$wingets += Add-Winget -Name "Transmission" -ID "Transmission.Transmission"

# Unity Hub
if ($ConfirmationUnity -eq 'y') {
    $wingets += Add-Winget -Name "Unity Hub" -ID "Unity.UnityHub" -Location "$InstallDrive\Unity Hub"
}

# Visual Studio Code
$wingets += Add-Winget -Name "Visual Studio Code" -ID "Microsoft.VisualStudioCode"

# Windows File Recovery
$wingets += Add-Winget -Name "Windows File Recovery" -ID "9N26S50LN705"

# Windows Terminal settings
if ($confirmationWindowsTerm -eq 'y') {
    Set-Location 'C:\Users\magnu\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
    if ((Test-Path ./settings.json) -eq $false) {
        New-Item settings.json
    }

    Set-Content -Path 'settings.json' -Value (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MagnusMat/Windows-Terminal-Setup/main/Terminal%20settings.json").Content
    Set-Location ~
}

# WinSCP
$wingets += Add-Winget -Name "WinSCP" -ID "WinSCP.WinSCP"

# WizTree
$WizTreeParams = @{
    Name     = "WizTree"
    Location = (Join-Path -Path "$InstallDrive" -ChildPath "WizTree")
    URL      = "https://antibodysoftware-17031.kxcdn.com/files/wiztree_4_08_portable.zip"
}
Install-Zip @WizTreeParams

# Yubico Authenticator
$wingets += Add-Winget -Name "Yubico Authenticator" -ID "Yubico.Authenticator"

# Zen Browser
$wingets += Add-Winget -Name "Zen Browser" -ID "Zen-Team.Zen-Browser"

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

    # Battle.net
    $wingets += Add-Winget -Name "Battle.net" -ID "XPDM5VSMTKQLBJ"

    # Epic Games
    $wingets += Add-Winget -Name "Epic Games Store" -ID "EpicGames.EpicGamesLauncher" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Epic Games")

    # GOG Galaxy
    $wingets += Add-Winget -Name "GOG Galaxy" -ID "GOG.Galaxy" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "GOG Galaxy")

    # Steam
    $wingets += Add-Winget -Name "Steam" -ID "Valve.Steam" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Steam")

    # Ubisoft Connect
    $wingets += Add-Winget -Name "Ubisoft Connect" -ID "Ubisoft.Connect" -Location (Join-Path -Path "$InstallDrive\Game Launchers" -ChildPath "Ubisoft Connect")

    # Xbox
    $wingets += Add-Winget -Name "Xbox" -ID "9MV0B5HZVK9Z"

    # Xbox Accessories
    $wingets += Add-Winget -Name "Xbox Accessories" -ID "9NBLGGH30XJ3"
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
}

# -------------------- Final Install of Wingets --------------------

# Install all the wingets in an array
Install-Wingets -items $wingets

# Remove Desktop Icons
$desk = [Environment]::GetFolderPath("Desktop")
Set-Location $desk

Remove-Item *
Set-Location ~
