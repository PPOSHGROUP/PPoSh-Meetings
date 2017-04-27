$ComputerName = 'Arcon-HV1'

###########################
#RUN LOCALLY on MACHINE
Enable-PSRemoting -force

#RUN REMOTELY
###########################
$HVCreds = Get-Credential

Invoke-Command -ComputerName win-l02ngu08qn1 -Credential $HVCreds -ScriptBlock {
  Set-ExecutionPolicy unrestricted -Force
  Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
  Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
  New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
  New-NetFirewallRule -DisplayName "Allow inbound ICMPv6" -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow
  Install-WindowsFeature Hyper-v -IncludeManagementTools 

  diskperf -Y
  Rename-Computer -NewName $USING:ComputerName
  Restart-Computer -force
  

}

