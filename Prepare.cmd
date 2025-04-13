wget https://github.com/psit365/aub/blob/master/SendDeviceInfo.ps1
wget https://github.com/psit365/aub/blob/master/Sysprep.cmd

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0SendDeviceInfo.ps1"

