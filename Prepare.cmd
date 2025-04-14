curl https://raw.githubusercontent.com/psit365/aub/refs/heads/master/SendDeviceInfo.ps1 -o SendDeviceInfo.ps1
curl https://raw.githubusercontent.com/psit365/aub/refs/heads/master/Sysprep.cmd -o Sysprep.cmd

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0SendDeviceInfo.ps1"
