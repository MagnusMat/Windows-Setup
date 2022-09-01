# Windows-Setup

Windows Setup Script. Installs all the software that i use.
Before running script, please set the execution policy to RemoteSigned or similar.

```ps1
Set-ExecutionPolicy RemoteSigned
```

Install automatically with the command below.

```ps1
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/MagnusMat/Windows-Setup/main/Windows%20Install.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
```

Afterwards, please install the desired WSL Distribution, eg.

```ps1
wsl --install -d Ubuntu
```

or

```ps1
wsl --install -d Debian
```

You might need to upgrade the Linux Kernel in WSL. To do so, follow the instructions [here](https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package) or use the code snippet below.

```ps1
Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile "wsl_update_x64.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/package `"wsl_update_x64.msi`"", "/passive", "/norestart"
Remove-Item "wsl_update_x64.msi"
wsl --set-default-version 2
```
