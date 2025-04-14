#requires -RunAsAdministrator
# Prompt for Creds
$Credentials = Get-Credential

Get-Process sysprep | Stop-Process -ErrorAction SilentlyContinue

# get computer info
$BiosDetail = Get-CimInstance Win32_BIOS

Install-Script Get-WindowsAutopilotInfo -Scope CurrentUser -Force -Confirm:$false
Install-Module WindowsAutopilotIntune -Scope CurrentUser -Force -Confirm:$false

$outputPath = Join-Path $PSScriptRoot -ChildPath ('{0}.csv' -f $BiosDetail.SerialNumber)
Get-WindowsAutopilotInfo.ps1 -OutputFile $outputPath -GroupTag 'Dedicated' 

$SgKeyEmbed = '76492d1116743f0423413b16050a5345MgB8AFEAWgBDAGQAaQBJAGcAOQB4ADgAaABjAGoASwBhAGUAawB3ADcARQBMAGcAPQA9AHwAMABiADUAMQBhAGEAOAA0ADUANgA4ADIAYgAyAGIANABhADQAOABkAGUAOQA2AGEAZAAwAGUAMABkAGMANwA5AGIANAA0AGYAOQA0ADcAMgBlADUAMAA1AGUAMwA0ADAAZQA3AGYAYwA5ADQAOQBlAGUANQBlADIAMQA1ADkAOQAwAGMANAA1ADEAYwA4ADIAMQAxADkANgA5ADcAOQA3AGQAMQA4ADcANgBjAGQAOQBhAGYAZQAyAGIANgA5ADAAZgA3ADMAMgAyADAAYgBjAGIAMAA5AGYAYQAxAGEAOQA4AGIAZAA4ADAANQA3AGUAZQBmAGMANABhADQAOAA4AGYANwAxADIAMwBiADUAZgA3AGEANwBkADIANQBiADAAMQBjADEANwAyADkANwA0AGYAYgA0AGMAYwBjAGMAMwA2AGMAYgA5AGEAZQA5AGEANwAwAGMAMgAxAGMAMQAzADMAZgA2AGEAMgA3ADYAZgA5ADgAOABjADQANQBjADUAZQBmADMAOAA2AGIAMAAyADIANABhAGUAOQA2ADYAZQBjADAAZAA0AGEANAA4ADgAZgA5AGEAYwA2ADQAMAAxAGIAYwAyADUAYgA1AGQAOQBiAGYAYgA5ADIANgBlADUAYwBlAGUAMQBhADIANQAzAGMANgBhAGMANQAzAGMANAAwAGQANQA2AGMAMgAxADAAZAAxADUAMQAwADYANABlADUAMgBkADAAZgBlADQAMAAyADYANgBjADIAYQBlADIA'

$PTPass = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credentials.Password))
$keybytes = [System.Text.Encoding]::UTF8.GetBytes($PTPass)

$sgPasswordSS = ConvertTo-SecureString $SgKeyEmbed -Key $keybytes 

$sendCred = New-Object System.Management.Automation.PSCredential ('apikey', $sgPasswordSS)

if (Test-Path $outputPath) {
    # send to team
    $messageParams = @{
        To          = '364e56a6.advaniauk.onmicrosoft.com@uk.teams.ms'
        From        = 'migration@sura.com.au'
        Subject     = ('Device {0} for {1}' -f $BiosDetail.SerialNumber, $Credentials.UserName)
        Body        = ('Device {0} for {1}' -f $BiosDetail.SerialNumber, $Credentials.UserName)
        Attachments = $outputPath
        SmtpServer  = 'smtp.sendgrid.com'
        Credential  = $sendCred
    }
    Send-MailMessage @messageParams 
    # prepare for sysprep

    $appxPkg = Get-AppxPackage -AllUser | Where-Object PublisherId -EQ 8wekyb3d8bbwe

    $appxPkg | Where-Object -FilterScript { $_.IsFramework -eq $false } | Remove-AppxPackage -ErrorAction SilentlyContinue

    & "$PSScriptRoot\Sysprep.cmd"
}
