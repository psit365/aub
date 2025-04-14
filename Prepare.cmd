curl https://github.com/psit365/aub/blob/master/SendDeviceInfo.ps1 -o SendDeviceInfo.ps1
curl https://github.com/psit365/aub/blob/master/Sysprep.cmd -o Sysprep.cmd

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0SendDeviceInfo.ps1"

