$ComputerName = 'V22'

#ScriptBlock
function f1 { $args }
f1 'asd','zxc'

$ScriptBlock = [scriptblock]::Create( {Get-ChildItem C:\Windows\System –Recurse} )
$ScriptBlock = { Get-ChildItem C:\Windows\System –Recurse }

#1
Start-Job -Scriptblock { Get-ChildItem C:\Windows\System –Recurse | Select-Object -ExpandProperty FullName }
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force

$p = Get-Process
$p | Get-Member
$jP = Start-Job -Scriptblock { Get-Process }
$jP = Get-Job | Receive-Job
$jP | Get-Member

#2 domyślna zmienna $Input
"hell" | Start-Job -InitializationScript { Set-Location C:\Windows } -ScriptBlock { Get-ChildItem -Filter *$Input* }
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force

#3 Invoke-Command jako Job
Invoke-Command -JobName 'win.ini' -ScriptBlock { Get-Content C:\Windows\win.ini } -AsJob -ComputerName $ComputerName
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force

Invoke-Command -JobName 'GetService' -ScriptBlock { Get-Service | ? { $_.Status -eq "Stopped" } } -AsJob -ComputerName $ComputerName -ThrottleLimit 4
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force

