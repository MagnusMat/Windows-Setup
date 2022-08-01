# Windows-Setup

Windows Setup Script. Install automatically with the command below.

```ps1
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/MagnusMat/Windows-Setup/main/Windows%20Install.ps1?token=GHSAT0AAAAAABXGVPFSN7EL2XNVO7B6HS5QYXIJKMQ
Invoke-Expression $($ScriptFromGitHub.Content)
```
