$ComputerName = '192.168.2.129'
$cred = Get-Credential -UserName "V21\V21" -Message V21\V21

#4 InDisconnectedSession
Invoke-Command -ComputerName $ComputerName -Credential $cred -ScriptBlock { 1..999 | % { 1..999 } } -InDisconnectedSession -SessionName InDiscSes2
$Job = Receive-PSSession -ComputerName $ComputerName -Name InDiscSes2 -Credential $cred
Receive-Job -Job $Job

Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force

#5 AsJob
# jeżeli połczenie do zdalnego serwera zostanie utracone, wynik komendy również zostanie utracony
Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-Process } -AsJob -JobName myJob

Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force

#6 Invoke-Command > Start-Job
# Zdalny Job w sesji Powershell, obiekt istnieje w zdalnej sesji
$Session = New-PSSession -ComputerName $ComputerName -Credential $cred
Invoke-Command -Session $Session -ScriptBlock { Start-Job -ScriptBlock { Get-Process } -Name myJob }

Get-Job # nie pokaże wyniku
# pobranie obiektu Joba z zdalnego komputera

$Result = Invoke-Command -Session $Session -ScriptBlock { Receive-Job -Name myJob -Keep }
$Result

Get-Job | Receive-Job -Keep
Get-Job | Remove-Job -Force
Get-PSSession | Remove-PSSession