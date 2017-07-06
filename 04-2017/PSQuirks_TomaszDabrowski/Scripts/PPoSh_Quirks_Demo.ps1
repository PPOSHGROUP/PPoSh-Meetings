#region Open presentation
$Uri = 'https://drive.google.com/file/d/0B3RgeHlcjv9dUGcxYjRxUFFFMWM/view'
[System.Diagnostics.Process]::Start('chrome.exe', $Uri)
#endregion


#region Enable-PSRemoting, RDP and PING. Run as computer Administrator
Enable-PSRemoting -Force
Set-ExecutionPolicy -ExecutionPolicy Unrestricted #least secure
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
New-NetFirewallRule -DisplayName 'Allow inbound ICMPv4' -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
New-NetFirewallRule -DisplayName 'Allow inbound ICMPv6' -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow
#endregion


#region ExecutionPolicy. Allow PowerShell functions run. Run command as computer Administrator
# https://technet.microsoft.com/en-us/library/ee176961.aspx
# https://blog.netspi.com/15-ways-to-bypass-the-powershell-execution-policy/
Set-ExecutionPolicy -ExecutionPolicy Restricted #check only 
Set-ExecutionPolicy -ExecutionPolicy AllSigned #most secure 
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned #medium secure 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted #least secure 
#endregion


#region Open website in four different ways
# install PowerShell 5.1..
# Example 1
$Uri = 'https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure'
$IE = New-Object -ComObject internetexplorer.application
$IE.navigate2($Uri)
$IE.visible = $true
# Example 2
Start-Process -FilePath $Uri
# Example 3
(New-Object -ComObject Shell.Application).Open($Uri)
# Example 4
$Uri = 'http://blog.feedspot.com/powershell_blogs/'
[System.Diagnostics.Process]::Start('chrome.exe', $Uri)
#endregion


#region download file from internet
# https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
$Url = 'http://www.reedbushey.com/86Windows%20Powershell%20Cookbook%203rd%20Edition.pdf'
Invoke-WebRequest -Uri $Url -OutFile 'C:\Temp\PS_CookBook_3.pdf' -UseBasicParsing
Invoke-Item -Path 'C:\Temp\PS_CookBook_3.pdf'
#endregion


#region Get-Help, don't know how cmdlet works use Get-Help'
Get-Help -Name Sort-Object
Get-Help -Name Sort-Object -Examples
Get-Help -Name Sort-Object -ShowWindow
Get-Help -Name Sort-Object -Online
#endregion


#region Get-Command
# get list of all cmdlets from a module
Get-Command -Module ObjectivityAdminTools
# see where the module is
(Get-Command -Module ObjectivityAdminTools).Path
#endregion


#region Get-Member, see properties and methods of an object
# https://mcpmag.com/articles/2015/03/24/using-get-member.aspx
'Hello World' | Get-Member | Format-Table -AutoSize -Wrap | Out-String -Width 150 | clip.exe
Get-Process | Get-Member
#endregion


#region Alias, what is alias, how to create an alias
Get-Alias
notepad.exe
notepad++
Set-Alias -Name 'notepad++' -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe'
notepad++
#endregion


#region profile
# https://www.howtogeek.com/50236/customizing-your-powershell-profile/
psedit $PROFILE
#endregion


#region Env
# https://technet.microsoft.com/en-us/library/ff730964.aspx
$env:USERDNSDOMAIN
$env:USERDOMAIN
$env:COMPUTERNAME
$env:HOMEDRIVE
#endregion


#region PSDrive
# https://4sysops.com/archives/powershell-psdrive-in-practice/
Get-PSDrive
Set-Location -Path Env:
Get-ChildItem
dir
#endregion


#region $PSDefaultParameterValues
# https://learn-powershell.net/2013/12/11/using-psdefaultparametervalues-in-powershell/
$PSDefaultParameterValues.Add('Stop-Process:WhatIf', $true)
Get-Process | Stop-Process

$PSDefaultParameterValues = @{
	'Get-Eventlog:logname' = 'Application'
	'Get-Eventlog:newest'  = 10
	'Stop-Process:WhatIf'  = $true
}
Get-EventLog

$PSDefaultParameterValues
$PSDefaultParameterValues.Clear()
#endregion


#region Comparing, use carefully
# Example wrong:
$a = $null
$a -eq $null # works: returns $true
$a.Count

$a = 1, 2, 3
$a -eq $null # fails: returns $null

$a = 1, 2, $null, 3, 4
$a -eq $null # fails: returns $null

$a = 1, 2, $null, 3, 4, $null, 5
$a -eq $null # fails: returns array of 2x $null
$a.Count
($a -eq $null).Count

# Example fine:
$a = $null
$null -eq $a # works: $true

$a = 1, 2, 3
$null -eq $a # works: $false

$a = 1, 2, $null, 3, 4
$null -eq $a # works: $false

$a = 1, 2, $null, 3, 4, $null, 5
$null -eq $a # works: $false
#endregion


#region Array on the fly
$csv = @'  
Name,Date
Adam,2017-02-21
Andrzej,2017-01-28
Kzysztof,2016-02-28
Jan,2017-06-28
Kasia,2017-06-18
Pawel,2012-02-28
Tomek,2015-09-08
Ania,2017-05-12
'@

$data = $csv | ConvertFrom-Csv -Delimiter ','

$data
$data | Out-GridView
#endregion


#region is Array Contains Value
$a = 'Krzysiek', 'Ania', 'Tomek', 'Adam', 'Pawel', 'Kasia'

# exact phrase
$a -contains 'Adam'

# is ANY phrase present
(@($a) -like '*ek*').Count -gt 0

# list all phrases
@($a) -like '*ek*'
#endregion


#region Where-Object and .Where(), use carefully
$Services = Get-Service
$Watch = New-Object -TypeName System.Diagnostics.StopWatch

$Watch.Start()
# streaming
$Services | Where-Object -FilterScript {
	$_.Status -eq 'Running'
}
$Watch.Stop()
$Took = '{0:N2}' -f $Watch.Elapsed.TotalSeconds
Write-Host -Object "Took: $Took"

$Watch.Start()
# non-streaming
$Services.Where{
	$_.Status -eq 'Running'
}
$Watch.Stop()
$Took = '{0:N2}' -f $Watch.Elapsed.TotalSeconds
Write-Host -Object "Took: $Took"

# the best way
Get-Service | Where-Object -FilterScript {
	$_.Status -eq 'Running'
}
#endregion


#region execute
$code = {
	Get-Process
}

$result1 = & $code
$result2 = $code.Invoke()
#endregion


#region Invoke-Command
# http://www.computerperformance.co.uk/powershell/powershell_invoke.htm
# see how to pass to ScriptBlock values

$DestinationScan = 'C:\Temp'

# Example 1, the fastes way and I think moste clear
Invoke-Command -Session $PSSession1 -ScriptBlock {
	Get-ChildItem -Path $Using:DestinationScan
}

# Example 2 
Invoke-Command -Session $PSSession1 -ScriptBlock {
	$DestinationScan = 'C:\Temp'
	Get-ChildItem -Path $DestinationScan
}

# Example 3
Invoke-Command -Session $PSSession1 -ScriptBlock {
	Get-ChildItem -Path $args[0]
} -ArgumentList $DestinationScan, $dffdv

# Example 4
Invoke-Command -Session $PSSession1 -ScriptBlock {
	param
	(
		$DestinationScan
	)
	Get-ChildItem -Path $DestinationScan
} -ArgumentList $DestinationScan
#endregion

#region Param
$Error.Clear()
Clear-Host
$ServerName = 'OBJPLRESTART'

#region Test-Connection, check if computer if online before connecting, it is faster
Test-Connection -ComputerName $ServerName -Count 5 -Delay 2 -TTL 255 -BufferSize 256 -ThrottleLimit 32
# to omit error if computer is off-line
Test-Connection -ComputerName $ServerName -Quiet

#endregion Creates a persistent connection to a local or remote computer
$PSSession1 = New-PSSession -ComputerName $ServerName
#endregion

#region
# EnterPssession
Set-Location -Path 'C:'
Enter-PSSession -ComputerName $ServerName
Get-ChildItem -Path $DestinationScan
$DestinationScan = 'C:\Temp'
Get-ChildItem -Path $DestinationScan
#Exit-PSSession !!! wykonac po
#endregion


#region how easy it is to make computer speak
$s = New-Object -ComObject SAPI.SPVoice
$s.Speak('I can speak!')
#endregion


#region, get useful information
Get-WmiObject -Class Win32_ComputerSystem
Get-WmiObject -Class Win32_BIOS
#endregion


#region, read RSS channel using Invoke-RestMethod
# http://otheratmosphere.com/invoke-restmethod-and-invoke-webrequest/
Invoke-RestMethod -Uri http://blogs.msdn.com/powershell/rss.aspx | Select-Object -Property Title, Link | Out-GridView
#endregion


#region $PSBoundParameters
# http://tommymaynard.com/quick-learn-the-psboundparameters-automatic-variable-2016/
function Show-Parameter
{
	Param (
		[string]$Text,
		[int]$Number
	)
	
	If ($PSBoundParameters.ContainsKey('Text'))
	{
		Write-Output -InputObject "Parameter Text included : '$Text'"
	}
	
	If ($PSBoundParameters.ContainsKey('Number'))
	{
		Write-Output -InputObject "Parameter Number included : '$Number'"
	}
	
	$PSBoundParameters
}
Show-Parameter -Text 'Test text test' -Number 7
#endregion


#region Pipeline
function Start-FunctionA
{
	begin
	{
		Write-Host -Object 'Begin a'
	}
	process
	{
		Write-Host -Object "Process a: $_"
	}
	end
	{
		Write-Host -Object 'End a'
	}
}
function Start-FunctionB
{
	begin
	{
		Write-Host -Object 'Begin b'
	}
	process
	{
		Write-Host -Object "Process b: $_"
	}
	end
	{
		Write-Host -Object 'End b'
	}
}

function Start-FunctionC
{
	Write-Host -Object 'c'
}

Clear-Host
1 .. 3 | Start-FunctionA | Start-FunctionB | Start-FunctionC
#endregion


#region, pipeline can sometimes slow down execution
function Stop-Motion
{
	process
	{
		$_
		Start-Sleep -Seconds 1
	}
}
Get-ChildItem -Path C:\Windows\System32
Get-ChildItem -Path C:\Windows\System32 | Stop-Motion
#endregion


#region No PipeLine
Write-Host -Object 'With Pipe'
(Measure-Command -Expression {
		1 .. 1E6 | Get-Random
	}).TotalSeconds

Write-Host -Object 'No pipe'
(Measure-Command -Expression {
		Get-Random -InputObject (1 .. 1E6)
	}).TotalSeconds
#endregion


#region Firewall, creating new rule. Run as computer Administrator
Invoke-Command -Session $PSSession1 -ScriptBlock {
	if ((Get-NetFirewallRule).DisplayName -ne 'SQLDB')
	{
		New-NetFirewallRule -DisplayName 'SQLDB' -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
	}
	if ((Get-NetFirewallRule).DisplayName -ne 'SQLBrowser')
	{
		New-NetFirewallRule -DisplayName 'SQLBrowser' -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow
	}
}
#endregion SQLFirewall


#region PowerShell Job, parallel process, go faster
# https://www.howtogeek.com/138856/geek-school-learn-how-to-use-jobs-in-powershell/
$servers = 'OBJPLCON0', 'OBJPLRESTART', 'NBTDABROWSKI'
$JobBody = {
	param (
		$server
	)
	$BiosDate = (Get-WmiObject -Class win32_bios -ComputerName $server).Name
	Write-Output -InputObject "$server : $BiosDate"
}

foreach ($server in $Servers)
{
	$null = Start-Job -ScriptBlock $JobBody -ArgumentList $server
}

Get-Job | Wait-Job | Receive-Job | Set-Content -Path 'C:\Temp\JobsResult.txt' -Force

Invoke-Item -Path 'C:\Temp\JobsResult.txt'
#endregion


#region Pester, test your functions
# https://github.com/pester/Pester
Describe 'PowerShell Basic Check' {
	Context 'PS Versioning'   {
		It 'is current version' {
			$host.Version.Major -ge 5 -and $host.Version.Minor -ge 1 | Should Be $true
		}
	}
	Context 'PS Settings'   {
		It 'can execute scripts' {
			(Get-ExecutionPolicy) | Should Not Be 'Restricted'
		}
		It 'does not use AllSigned' {
			(Get-ExecutionPolicy) | Should Not Be 'AllSigned'
		}
		It 'does not have GPO restrictions' {
			(Get-ExecutionPolicy -Scope MachinePolicy) | Should Be 'Undefined'
			(Get-ExecutionPolicy -Scope UserPolicy) | Should Be 'Undefined'
		}
	}
}
#endregion





#region credentials CliXml and JSON
# how to store credentials for automation purpose
$Path = 'C:\Temp\MyCredential_JS.json'

$CredentialJS = Get-Credential
$CredentialJS |
Select-Object -Property Username, @{
	Name	   = 'Password'
	Expression = {
		$_.password | ConvertFrom-SecureString
	}
} |
ConvertTo-Json |
Set-Content -Path $Path -Encoding UTF8


notepad.exe $Path

$Path = 'C:\Temp\MyCredential_JS.json'

$o = Get-Content -Path $Path -Encoding UTF8 -Raw | ConvertFrom-Json
$CredentialJS = New-Object -TypeName PSCredential -ArgumentList $o.UserName,
($o.Password | ConvertTo-SecureString)

Start-Process -FilePath notepad -Credential $CredentialJS

$UserName = '{0}\{1}' -f $env:USERDOMAIN, $env:USERNAME

$CredentialXML = Get-Credential -UserName $UserName -Message 'Please provide credentials'
$CredentialXML | Export-Clixml -Path 'C:\Temp\MyCredential_XML.xml'
$CredentialXML = Import-Clixml -Path 'C:\Temp\MyCredential_XML.xml'
Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ServerName -Credential $CredentialXML
#endregion


#region read credentials, never leave your computer unlock
$CredentialXML = Get-Credential -Credential 'Test'
$Password = $CredentialXML.GetNetworkCredential().Password
"Password: $Password"

$Password = Read-Host -AsSecureString -Prompt 'Enter Password'
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$plaintext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
"Password: $plaintext"
#endregion


#region Try Catch Finally
# https://www.vexasoft.com/blogs/powershell/7255220-powershell-tutorial-try-catch-finally-and-error-handling-in-powershell
#1
Try
{
	Write-Host -Object 'in Try'
}
Catch
{
	Write-Host -Object 'in Catch'
	$_
}
Finally
{
	Write-Host -Object 'in Finally'
}
#2
Try
{
	Write-Host -Object 'in Try'
	$errMsg = 'Test Test'
	throw $errMsg
}
Catch
{
	Write-Host -Object 'in Catch'
	$_
}
Finally
{
	Write-Host -Object 'in Finally'
}
#3
Try
{
	Write-Host -Object 'in Try'
	$errMsg = 'Test Test'
	throw $errMsg
}
Catch
{
	Write-Host -Object 'in Catch'
	# use $_ because $error stores all errors from session
	$_
	$Error
}
Finally
{
	Write-Host -Object 'in Finally'
}
#endregion


#region -replace and .Replace, use carefully
# http://www.curiouslycorrect.com/dev-ops/powershell-replace-not-replace/
# -replace replace using RegEx
# .Replace plain text
# Example 1
[string]$Text = 'C:\Temp\file.exe'
$result1 = $Text.Replace('\file.exe', '\newfile.exe')
$result2 = $Text -replace '\file.exe', '\newfile.exe'
Write-Host -Object $result1 -ForegroundColor Yellow
Write-Host -Object $result2 -ForegroundColor Cyan

# Example 2
[string]$Text = 'C:\Temp\file.exe'
$Result = $Text -replace '\\file.exe', '\\newfile.exe'
Write-Host -Object $Result -ForegroundColor Cyan

# Example 3
[string]$Text = 'C:\Temp\file.exe'
$Result = $Text -replace '\\file.exe', '\newfile.exe'
Write-Host -Object $Result -ForegroundColor Cyan

# Example 4
$Text = '\escape\your\backslashes'
$Text = $Text -replace '\\', '\\'
Write-Host -Object $Text -ForegroundColor cyan
#endregion


#region Split
$Uri = 'https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure'
$Uri.Split('/')
$SplitCount = $Uri.Split('/').Count
$SplitCount
$Uri.Split('/')[$SplitCount]
$Uri.Split[-1]
#endregion


#region useful AD function
#requires -Modules ActiveDirectory
Search-ADAccount -AccountDisabled
Search-ADAccount -AccountExpired
Search-ADAccount -AccountInactive
#endregion


#region kill process which handle a file
$handle = (& C:\Temp\Handle\handle64.exe C:\Windows\System32\Speech\Common\sapi.dll) #-accepteula
$handle = (& C:\Temp\Handle\handle64.exe C:\Windows\System32\Speech\Common) #-accepteula

$regexp1 = 'pid:\s(\d+)'
$ProcessIDResults = $handle | Select-String -Pattern $regexp1 -AllMatches

$PIDS = @()
$PIDS = foreach ($match in $ProcessIDResults.Matches)
{
	Write-Output -InputObject $($match.Value.Split(' ')[-1])
}

foreach ($p_id in $PIDS)
{
	$p_id
	if ((Get-Process -Id $p_id).ProcessName -match 'powershell')
	{
		Stop-Process -Id $p_id -Force
	}
}

#
$LockedFile = 'C:\Windows\System32\Speech\Common\sapi.dll'
Get-Process | ForEach-Object -Process {
	$processVar = $_
	$_.Modules | ForEach-Object -Process {
		if ($_.FileName -eq $LockedFile)
		{
			$processVar.Name + ' PID:' + $processVar.id
		}
	}
}
#endregion


#region ScheduleTask creation, schedule computer restart
$TaskName = "RESTART - $ServerName"
$User = $null
$Password = $null
$Date = $null

$ContentPS = @'

'@

$ContentBat = @'
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\AdminTools\RESTART_script.ps1
'@

$ContentPS | Out-File -FilePath "\\$ServerName\C`$\AdminTools\RESTART_script.ps1" -Encoding ascii -Force
$ContentBat | Out-File -FilePath "\\$ServerName\C`$\AdminTools\RESTART_bat.bat" -Encoding ascii -Force

Invoke-Command -Session $PSSession1 -ScriptBlock {
	Import-Module -Name ScheduledTasks
	
	$TaskName = $Using:TaskName
	$TaskTime = New-ScheduledTaskTrigger -Once -At $Using:Date
	$TaskUser = "$Using:User"
	$TaskUserPass = $Using:Password
	$TaskAction = New-ScheduledTaskAction -Execute 'C:\AdminTools\RESTART_bat.bat'
	$TaskDescription = "$Using:ServerName restart"
	
	if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)
	{
		Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
	}
	
	Register-ScheduledTask -TaskName $TaskName -Trigger $TaskTime -User $TaskUser -Password $TaskUserPass -Action $TaskAction -Description $TaskDescription -RunLevel Highest
}
#endregion


#region Google VirusTotal, check if file is save
# https://www.virustotal.com/en/documentation/public-api/
$VirusTotalApiKey = $Global:ObjectivityAdminConfig.VirusTotal.VirusTotalApiKey

$FilePath = 'C:\Temp\Handle\handle.exe'
$FileStream = [System.IO.File]::OpenRead($FilePath)
$Hash = ([System.Security.Cryptography.HashAlgorithm]::Create('SHA256')).ComputeHash($FileStream)
$FileStream.Close()
$FileStream.Dispose()
$SHA = [System.Bitconverter]::tostring($Hash).replace('-', '')

$request = @{
	resource = $SHA
	apikey   = $VirusTotalApiKey
}

$VirusTotalReport = Invoke-RestMethod -Method 'POST' -Uri 'https://www.virustotal.com/vtapi/v2/file/report' -Body $request

foreach ($scan in ($VirusTotalReport.scans | Get-Member -Type NoteProperty -ErrorAction SilentlyContinue))
{
	if ($scan.Definition -match 'detected=(?<detected>.*?); version=(?<version>.*?); result=(?<result>.*?); update=(?<update>.*?})')
	{
		if ($Matches.detected -eq 'True')
		{
			$VirusTotalResult += '{0}({1}) - {2}' -f $scan.Name, $Matches.version, $Matches.result
		}
	}
}
$Uri = $VirusTotalReport.permalink
$HTML = Invoke-WebRequest -Uri $Uri
$HTMLResult = ($HTML.ParsedHtml.getElementsByTagName('div') | Where-Object -FilterScript {
		$_.className -eq 'span8 columns'
	}).innerText
Clear-Host
$HTMLResult
#endregion


#region Gmail email send
$SMTPServer = 'smtp.gmail.com'
$SMTPPort = '587'
$UserName = 'TestPPoSh@gmail.com'
$Password = ''

$to = 'dombros@gmail.com'
$cc = 'dombros@gmail.com'
$subject = 'Email Subject'
$body = 'Email body here'
$attachment = 'C:\Temp\PPoSh_Demo_1.ps1'

$message = New-Object -TypeName System.Net.Mail.MailMessage
$message.subject = $subject
$message.body = $body
$message.to.add($to)
$message.cc.add($cc)
$message.from = $UserName
$message.attachments.add($attachment)

$smtp = New-Object -TypeName System.Net.Mail.SmtpClient -ArgumentList ($SMTPServer, $SMTPPort)
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList ($UserName, $Password)
$smtp.send($message)
Write-Host -Object 'Mail Sent'
#endregion