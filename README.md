# Windows-Setup

Windows Setup Script. Install automatically with the command below.

```ps1
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/MagnusMat/Windows-Setup/main/Windows%20Install.ps1?token=GHSAT0AAAAAABVGWAJ5PQWDWWSMPRU34NLYYVZ3ESQ
Invoke-Expression $($ScriptFromGitHub.Content)
```
