function Get-ComputerInformation
{
  [CmdletBinding()]
  param
  (
    [String]$ComputerName, [PScredential]$Credential
  )
  
  $CimSession = New-CimSession @PSBoundParameters

  $SystemData = Get-CimInstance -ClassName CIM_ComputerSystem -CimSession $CimSession
  $BiosData = Get-CimInstance -ClassName CIM_BIOSElement -CimSession $CimSession
  $OSData = Get-CimInstance -ClassName CIM_OperatingSystem -CimSession $CimSession
  $CPUData = Get-CimInstance -ClassName CIM_Processor -CimSession $CimSession
  $HDDData = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'" -CimSession $CimSession
  
  Class ComputerInformation {
    [String]$OperatingSystem
    [String]$Manufacturer
    [String]$Model
    [String]$SerialNumber
    [String]$CPU
    [String]$RAM
    [String]$HDDCapacity
    [String]$HDDFreeSpace
    [String]$UserLoggedIn
    [String]$LastReboot
  }
  
  $ComputerInformation = New-Object -TypeName ComputerInformation
  
  $ComputerInformation.OperatingSystem = $OSData.caption + ', Service Pack: ' + $OSData.ServicePackMajorVersion
  $ComputerInformation.Manufacturer = $SystemData.Manufacturer
  $ComputerInformation.Model = $SystemData.Model
  $ComputerInformation.SerialNumber = $BiosData.SerialNumber
  $ComputerInformation.CPU = $CPUData.Name
  $ComputerInformation.RAM = '{0:N0} GB' -f ($SystemData.TotalPhysicalMemory/1GB)
  $ComputerInformation.HDDCapacity = '{0:N0} GB' -f ($HDDData.Size/1GB)
  $ComputerInformation.HDDFreeSpace = '{0:P0}' -f ($HDDData.FreeSpace/$HDDData.Size) + ' ({0:N0} GB)' -f ($HDDData.FreeSpace/1GB)
  $ComputerInformation.UserLoggedIn = $SystemData.UserName
  $ComputerInformation.LastReboot = $OSData.LastBootUpTime
  
  Write-Host "System Information for Computer: $($SystemData.Name)" -BackgroundColor DarkGray
  
  # define an array containing the properties you are interested in
  $DefaultProperties = @('OperatingSystem', 'SerialNumber')
  
  # create a new object of type PSPropertySet using the previously created array
  # this object will be called DefaultDisplayPropertySet
  $DefaultDisplay = New-Object System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$DefaultProperties)
 
  # create a PSStandardMembers object with the previously created DefaultDisplayPropertySet object
  $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplay)
 
  # add this object as a property to our object
  $ComputerInformation | Add-Member MemberSet PSStandardMembers $PSStandardMembers
  
  $ComputerInformation
}

Clear-Host
Get-ComputerInformation -ComputerName 'OBJPLRESTART'
Get-ComputerInformation -ComputerName 'OBJPLRESTART' | Select-Object *