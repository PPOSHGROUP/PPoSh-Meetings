$RootConfigFolder = "$PSScriptRoot"
$VMConfiguration = [ordered]@{
  VMName = 'TestName3'
  SKU = 'Windows2012R2'
  Hardware = @{
    vCPU = '2'
    Generation = '2'
    MemoryStartupBytes = 1GB
    MemoryMinimumBytes = 1GB
    MemoryMaximumBytes = 4GB
    Network = @{
        VLAN = $null
        VLANMode = 'Access'
        vSwitchType = 'External'
        NICName = 'Management'
        IPAddress = '10.2.40.53'
        PrefixLength = '16'
        DefaultGateway = '10.2.254.254'
        DNSClientServerAddress = '10.2.6.50,10.2.6.49,10.3.6.50,10.5.6.50'
      }
    
  }
  LocalAdminAccount = 'Administrator'
  LocalAdminPassword = '1234Qwer'
  AutomaticStopAction = 'Shutdown'
  AutomaticStartAction = 'StartIfRunning'
  AutomaticStartDelay = 10
}




$FilePath = "$RootConfigFolder\VMs"
$FileName = "$($VMConfiguration.VMName).Configuration.json"
if (-not (Test-Path $FilePath)) {
  [void] (New-Item -ItemType Directory -Path $FilePath -Force )
}
$VMConfiguration | ConvertTo-Json -Depth 99 | Out-File -FilePath (Join-Path -Path $FilePath -ChildPath $FileName) -Force
