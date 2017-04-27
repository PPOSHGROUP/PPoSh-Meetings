$HVCreds = Get-Credential
$ConfigurationFile = Get-Content '.\Arcon-HV1\Arcon-HV1.Configuration.json' -raw | ConvertFrom-Json 
$ComputerName = $ConfigurationFile.ComputerName

#region configure NIC Advanced Properties
Invoke-command -ComputerName $ComputerName -Credential $HVCreds -ScriptBlock { 
  $NICFeatures = [ordered]@{
    '*LsoV2IPv4' = '0'
    '*LsoV2IPv6' = '0'
  }
  $NICs = (Get-NetAdapter).Name

  foreach ($nic in $NICs) {
    foreach ($feature in $NICFeatures.GetEnumerator()) {
      $check = Get-NetAdapterAdvancedProperty -Name $nic -RegistryKeyword $feature.Name -ErrorAction SilentlyContinue
      if ($check) {
        $check | Set-NetAdapterAdvancedProperty -RegistryValue $feature.Value -Verbose
      }
    }
  }

}
#endregion

#region Configure NICs
Invoke-Command -ComputerName $ComputerName -Credential $HVCreds -ScriptBlock { 
  foreach ($NIC in $USING:ConfigurationFile.NIC) {
    if ($NIC) {   
      Get-NetAdapter | Where-Object {($_.MACAddress -eq $NIC.MACAddress) -AND ($_.ifDesc -notmatch 'Multiplexor')} | ForEach-Object {
        Write-Output "Processing NIC {$($_.Name)}"
        if ($_.Name -ne $NIC.Name) {  
          Rename-NetAdapter -Name $_.Name -NewName $NIC.Name
          Write-Output "Renamed {$($_.Name)} to {$($NIC.Name)}"
        } 
        if (-not ((Get-NetIPInterface -ifIndex $_.ifIndex -AddressFamily IPv4).Dhcp -eq $NIC.DHCP )) { 
          Set-NetIPInterface -InterfaceIndex $_.ifIndex -Dhcp $NIC.DHCP
          Write-Output "Disabled DHCP on interface {$($_.ifAlias)}"
        }
        if ($NIC.IPConfiguration.IPAddress) {
          if (-not (Get-NetIPAddress -InterfaceAlias $NIC.Name)) { 
            $props = @{ 
              IPAddress = $NIC.IPConfiguration.IpAddress
              AddressFamily = $NIC.IPConfiguration.AddressFamily
              PrefixLength = $NIC.IPConfiguration.PrefixLength
              DefaultGateway = $NIC.IPConfiguration.DefaultGateway
            }  
            New-NetIPAddress -InterfaceIndex $_.ifIndex @props
            Write-Output "Set IP {$($props.IPAddress)} on NIC {$($_.ifAlias)}"
          }
        }
        if ($NIC.IPConfiguration.DNSClientServerAddress) {
          $DNSServers = (Get-DnsClientServerAddress -InterfaceIndex $_.ifIndex | Select-Object -ExpandProperty ServerAddresses) -join ','
          if ($DNSServers -notcontains $NIC.IPConfiguration.DNSClientServerAddress) { 
            Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses $NIC.IPConfiguration.DNSClientServerAddress
            Write-Output "Set DNS servers {$($NIC.IPConfiguration.DNSClientServerAddress)} on NIC {$($_.ifAlias)}"
          }
        }
      } 
    }  
  } 
}
#endregion

#region Configure Team
Invoke-command -ComputerName $ComputerName -Credential $HVCreds -ScriptBlock {  
  foreach ($Team in $USING:ConfigurationFile.Team) {
    if ($Team.TeamName) { 
      Write-Output "Processing Team {$($Team.TeamName)}"
      $testTeam = Get-NetLbfoTeam -Name $Team.TeamName -ErrorAction SilentlyContinue
      if (-not $testTeam) { 
        $netprops = @{  
          Name = $Team.TeamName
          TeamingMode = $Team.TeamingMode
          LoadBalancingAlgorithm = $Team.LoadBalancingAlgorithm
          TeamMembers = $Team.TeamMembers
          Confirm=$false
        } 
        [void] (New-NetLbfoTeam @netprops)
        Write-Output "No Team found. Created Team {$($netprops.Name)} with members {$($netprops.TeamMembers)}"
      }
      $TeamDHCP = (Get-NetIPInterface -InterfaceAlias $Team.TeamName -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DHCP).ToString()
      Write-Output "TeamDHCP status should be {$($Team.DHCP)}. Current status is {$TeamDHCP}"
      if ($TeamDHCP -ne $Team.DHCP ) {
        Set-NetIPInterface -InterfaceAlias $Team.TeamName -AddressFamily IPv4 -Dhcp $Team.DHCP
        Write-Output "Disabled DHCP on interface {$($Team.TeamName)}"
      }   
       
    }
  
  }
}
#endregion

#region configure vSwitch
Invoke-command -ComputerName $ComputerName -Credential $HVCreds -ScriptBlock { 
  foreach ($vSwitch in $USING:ConfigurationFile.vSwitch) {
    if (-not (Get-VMSwitch -Name $vSwitch.Name -ErrorAction SilentlyContinue)) {
      New-VMSwitch -Name $vSwitch.Name -NetAdapterName $vSwitch.NetAdapterName -MinimumBandwidthMode $vSwitch.MinimumBandwidthMode -AllowManagementOS $vSwitch.AllowManagementOS
    }
    foreach ($VMNetworkAdapter in $vSwitch.VMNetworkAdapters) {
      if (-not (Get-VMNetworkAdapter -name $VMNetworkAdapter.Name -SwitchName $vSwitch.Name -ManagementOS -ErrorAction SilentlyContinue)) { 
        Add-VMNetworkAdapter -Name $VMNetworkAdapter.Name -SwitchName $vSwitch.Name -ManagementOS
        Get-NetAdapter | Where-Object {$_.Name -match $VMNetworkAdapter.Name} | Rename-NetAdapter -NewName $VMNetworkAdapter.Name
        if ($VMNetworkAdapter.VLANID) {
          Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName $VMNetworkAdapter.Name -Access -VlanId $VMNetworkAdapter.VLANID
        }
        else { 
          Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName $VMNetworkAdapter.Name -Untagged 
        }
        
        if ($VMNetworkAdapter.IPConfiguration.IPAddress) {
          $props = @{ 
            IPAddress = $VMNetworkAdapter.IPConfiguration.IpAddress
            AddressFamily = $VMNetworkAdapter.IPConfiguration.AddressFamily
            PrefixLength = $VMNetworkAdapter.IPConfiguration.PrefixLength
            DefaultGateway = $VMNetworkAdapter.IPConfiguration.DefaultGateway
          }
          New-NetIPAddress -InterfaceAlias $VMNetworkAdapter.Name  @props
          Write-Output "Set IP {$($props.IPAddress)} on vNIC {$($VMNetworkAdapter.Name)}"
        }
        if ($VMNetworkAdapter.IPConfiguration.DNSClientServerAddress) {
          $DNSServers = (Get-DnsClientServerAddress -InterfaceAlias $VMNetworkAdapter.Name | Select-Object -ExpandProperty ServerAddresses) -join ','
          if ($DNSServers -notcontains $VMNetworkAdapter.IPConfiguration.DNSClientServerAddress) { 
            Set-DnsClientServerAddress -InterfaceAlias $VMNetworkAdapter.Name -ServerAddresses $VMNetworkAdapter.IPConfiguration.DNSClientServerAddress
            Write-Output "Set DNS servers {$($VMNetworkAdapter.IPConfiguration.DNSClientServerAddress)} on vNIC {$($VMNetworkAdapter.Name)}"
          }
        }
      
      }
    }
  }
} 
#endregion

#region configure Storage
Invoke-command -ComputerName $ComputerName -Credential $HVCreds -ScriptBlock {
  $StorageConfig = $USING:ConfigurationFile.Storage
  $disks = Get-PhysicalDisk -CanPool $true
  New-StoragePool -FriendlyName $StorageConfig.PoolName -StorageSubSystemFriendlyName (Get-StorageSubSystem).FriendlyName -PhysicalDisks $disks -ResiliencySettingNameDefault simple -ProvisioningTypeDefault Fixed -Verbose 
  $ssdTier = New-StorageTier -StoragePoolFriendlyName $StorageConfig.PoolName -FriendlyName SSDTier -MediaType SSD
  $hddTier = New-StorageTier -StoragePoolFriendlyName $StorageConfig.PoolName -FriendlyName HDDTier -MediaType HDD 

  New-Volume -StoragePoolFriendlyName $StorageConfig.PoolName -FriendlyName $StorageConfig.DASFriendlyName -FileSystem $StorageConfig.FileSystem -DriveLetter $StorageConfig.DriveLetter -StorageTiers @($ssdTier,$hddTier) -StorageTierSizes $StorageConfig.StorageTierSizes -ResiliencySettingName Simple -AllocationUnitSize $StorageConfig.AllocationUnitSize -WriteCacheSize $StorageConfig.WriteCacheSize

}
#endregion

#region Configure HyperV
Invoke-command -ComputerName $ComputerName -Credential $HVCreds -ScriptBlock {
  $HyperVConfig = $USING:ConfigurationFile.HyperVConfig
  New-Item -Path $HyperVConfig.VMs -ItemType Directory
  Set-VMHost -VirtualHardDiskPath $HyperVConfig.VMs -VirtualMachinePath $HyperVConfig.VMs
  
  foreach ($folder in $HyperVConfig.Folders) {}
  New-Item -Path $Folder -ItemType Directory -force
  
}
#endregion

#region Deploy VM from templates
#From HyperV Host

#endregion
