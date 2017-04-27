$RootConfigFolder = "$PSScriptRoot"
$Configuration = [ordered]@{
  ComputerName = 'Arcon-HV1'
  NIC = @(
     @{
          MACAddress = '00-1B-21-9F-37-0A'
          Name = 'PCI1'
          DHCP = 'Disabled'
          NetLBFOTeam = 'Team1'
          IPConfiguration =@{ 
            IPAddress = ''
            AddressFamily = ''
            PrefixLength = ''
            DefaultGateway =''
          DNSClientServerAddress = ('')
          }
      },
     @{
          MACAddress = '00-1B-21-9F-33-22'
          Name = 'PCI2'
          DHCP = 'Disabled'
          NetLBFOTeam = 'Team1'
          IPConfiguration =@{ 
            IPAddress = ''
            AddressFamily = ''
            PrefixLength = ''
            DefaultGateway =''
          DNSClientServerAddress = ('')
          }
      },
     @{
          MACAddress = '70-F3-95-04-49-50'
          Name = 'NIC1'
          DHCP = 'Disabled'
          NetLBFOTeam = ''
          IPConfiguration =@{ 
            IPAddress = '10.2.40.11'
            AddressFamily = 'IPV4'
            PrefixLength = '16'
            DefaultGateway ='10.2.254.254'
          DNSClientServerAddress = ('10.2.6.50,10.2.6.49')
          }
      }
  
  )
  Team = @( 
    @{
      TeamName = 'Team1'
      TeamingMode = 'SwitchIndependent'
      LoadBalancingAlgorithm = 'Dynamic' 
      TeamMembers = @('PCI1','PCI2')   
      DHCP = 'Disabled'
      IPConfiguration =@{ 
        IPAddress = ''
        AddressFamily = ''
        PrefixLength = ''
        DefaultGateway =''
        DNSClientServerAddress = ('')
      }
    }
  )
  vSwitch =@(
    @{
      Name = 'External-Team1'
      NetAdapterName = 'Team1'
      MinimumBandwidthMode = 'Weight'
      DefaultFlowMinimumBandwidthWeight = 50
      AllowManagementOS = $false
      VMNetworkAdapters = @(
        @{
          Name = 'Management'
          VLANID = $null
          InterfaceDescription = 'OS Management vNIC'
          MinimumBandwidthWeight = 20
          IPConfiguration =@{ 
            IPAddress = '10.2.40.12'
            AddressFamily = 'IPV4'
            PrefixLength = '16'
            DefaultGateway ='10.2.254.254'
          DNSClientServerAddress = ('10.2.6.50,10.2.6.49')
          }
        }
      )
    }
  )
  Roles = @()
  Storage =@{
    PoolName ='DAS1'
    DASFriendlyName = 'VMs'
    DriveLetter = 'D'
    FileSystem = 'ReFS'
    AllocationUnitSize = 64KB
    WriteCacheSize = 30GB
    StorageTierSizes = @(200GB,460GB)
  }
  HyperVConfig =@{
    VMs = 'd:\VMs'
    Folders = @('C:\AdminTools','D:\Library','D:\vhdx','D:\Unattend')
  }
}

$FilePath = "$RootConfigFolder\$($Configuration.ComputerName)"
$FileName = "$($Configuration.ComputerName).Configuration.json"
if (-not (Test-Path $FilePath)) {
  [void] (New-Item -ItemType Directory -Path $FilePath -Force )
}
$Configuration | ConvertTo-Json -Depth 99 | Out-File -FilePath (Join-Path -Path $FilePath -ChildPath $FileName) -Force
