#region Windows2016Template
$VMName = 'Windows2016Template'
$VMLocation = Get-VMHost| select-object -ExpandProperty VirtualMachinePath
$VHDPath = "$VMLocation\$VMName\$VMName"+'_disk0.vhdx'
$DVDISO = 'D:\ISO\14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
$VMSwitch = Get-VMSwitch | Select-Object -ExpandProperty Name
$FunctionsFolder = 'C:\AdminTools\Functions'

Get-ChildItem -Path $FunctionsFolder | ForEach-Object { . $_.FullName}

$VMBasicProps = @{
    Name = $VMName
    NewVHDPath = $VHDPath
    NewVHDSizeBytes = 100GB
    Generation = 2
    MemoryStartupBytes = 2GB
    Path = $VMLocation
    SwitchName = $VMSwitch
    ComputerName = $env:computername
}
 
New-VM @VMBasicProps 
$VMExtendProps = @{
    ProcessorCount = '4'
    MemoryMinimumBytes = 2GB
    MemoryMaximumBytes = 4GB
    DynamicMemory = $true
    AutomaticStopAction = 'Shutdown'
} 
 
Set-VM $VMBasicProps.Name @VMExtendProps 


Add-VMDvdDrive -VMName $VMBasicProps.Name -Path $DVDISO
$dvdDrive = Get-VMDvdDrive -VMName $VMBasicProps.Name
Set-VMFirmware -VMName $VMBasicProps.Name -FirstBootDevice $dvdDrive
vmconnect.exe localhost $VMBasicProps.Name
 
Start-VM -Name $VMBasicProps.Name 
#endregion

#region Windows2016CoreTemplate
$VMName = 'Windows2016CoreTemplate'
$VMLocation = Get-VMHost| select-object -ExpandProperty VirtualMachinePath
$VHDPath = "$VMLocation\$VMName\$VMName"+'_disk0.vhdx'
$DVDISO = 'D:\ISO\14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
$VMSwitch = Get-VMSwitch | Select-Object -ExpandProperty Name


$VMBasicProps = @{
    Name = $VMName
    NewVHDPath = $VHDPath
    NewVHDSizeBytes = 100GB
    Generation = 2
    MemoryStartupBytes = 2GB
    Path = $VMLocation
    SwitchName = $VMSwitch
    ComputerName = $env:computername
}
 
New-VM @VMBasicProps 
$VMExtendProps = @{
    ProcessorCount = '4'
    MemoryMinimumBytes = 2GB
    MemoryMaximumBytes = 4GB
    DynamicMemory = $true
    AutomaticStopAction = 'Shutdown'
} 
 
Set-VM $VMBasicProps.Name @VMExtendProps 


Add-VMDvdDrive -VMName $VMBasicProps.Name -Path $DVDISO
$dvdDrive = Get-VMDvdDrive -VMName $VMBasicProps.Name
Set-VMFirmware -VMName $VMBasicProps.Name -FirstBootDevice $dvdDrive
vmconnect.exe localhost $VMBasicProps.Name
 
Start-VM -Name $VMBasicProps.Name 
#endregion

#region Windows2012R2Template
$VMName = 'Windows2012R2Template'
$VMLocation = Get-VMHost| select-object -ExpandProperty VirtualMachinePath
$VHDPath = "$VMLocation\$VMName\$VMName"+'_disk0.vhdx'
$DVDISO = 'D:\ISO\9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
$VMSwitch = Get-VMSwitch | Select-Object -ExpandProperty Name


$VMBasicProps = @{
    Name = $VMName
    NewVHDPath = $VHDPath
    NewVHDSizeBytes = 100GB
    Generation = 2
    MemoryStartupBytes = 2GB
    Path = $VMLocation
    SwitchName = $VMSwitch
    ComputerName = $env:computername
}
 
New-VM @VMBasicProps 
$VMExtendProps = @{
    ProcessorCount = '4'
    MemoryMinimumBytes = 2GB
    MemoryMaximumBytes = 4GB
    DynamicMemory = $true
    AutomaticStopAction = 'Shutdown'
} 
 
Set-VM $VMBasicProps.Name @VMExtendProps 


Add-VMDvdDrive -VMName $VMBasicProps.Name -Path $DVDISO
$dvdDrive = Get-VMDvdDrive -VMName $VMBasicProps.Name
Set-VMFirmware -VMName $VMBasicProps.Name -FirstBootDevice $dvdDrive
vmconnect.exe localhost $VMBasicProps.Name
 
Start-VM -Name $VMBasicProps.Name 
#endregion

