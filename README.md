# Windows-Setup

Windows Setup Script. Installs all the software that i use.
Before running script, please set the execution policy to RemoteSigned or similar.


```ps1
Set-ExecutionPolicy RemoteSigned
```

Install automatically with the command below.

```ps1
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/MagnusMat/Windows-Setup/main/Windows%20Install.ps1?token=GHSAT0AAAAAABXGVPFSN7EL2XNVO7B6HS5QYXIJKMQ
Invoke-Expression $($ScriptFromGitHub.Content)
```
