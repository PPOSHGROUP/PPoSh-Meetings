$FunctionsFolder = 'C:\AdminTools\Functions'
Get-ChildItem -Path $FunctionsFolder | ForEach-Object { . $_.FullName}
$VMConfigs = Get-ChildItem 'C:\AdminTools\VMs\' -Filter '*.json' | ForEach-Object {Get-Content $_.FullName -Raw | ConvertFrom-Json }

$LocalCredentials = Get-Credential

    ###################################
    #         AUTO GENERATED          #
    ###################################


foreach ($VMConfiguration in $VMConfigs) {

    
    $ComputerName = $env:COMPUTERNAME
    $MountLocation = 'D:\vhdx'
    $UnattendFiles = 'D:\Unattend'


    $VMName = $VMConfiguration.VMName
    $vSwitch = Get-VMSwitch | Select-Object -ExpandProperty Name

    $VMFolder = (Get-VMHost).VirtualMachinePath

    $VMLocation = "$VMFolder\$VMName\"
    $DestinationVHDFile = "{0}_disk0.vhdx" -f $VMName

    $vhdtemplate = (Get-VHDTemplates -Path 'D:\Library\Templates\HyperVVHDTemplates.json' ).WindowsTemplate | where-object {$_.Name -eq $VMConfiguration.SKU}

    $SysprepProperties = @{
      LocalAdministrator = $VMConfiguration.LocalAdminAccount
      LocalAdministratorPassword = $VMConfiguration.LocalAdminPassword 
      SysprepedImageSource = $vhdtemplate.Path 
      SysprepedImageDestination = $VMLocation + $DestinationVHDFile
      TemplateUnattendFile = $vhdtemplate.Unattend
      OutputUnattendFile = "$UnattendFiles\$VMName.xml"
      MountLocation = $MountLocation
    }

    Write-Output 'Starting'
    if ( -not ( Test-Path -Path $VMLocation ) )
    {
      $null = New-Item -Path $VMLocation -ItemType Directory 
    }

    Set-VMSysprepedImage @SysprepProperties  -Verbose

    Write-Output 'VHD prepared'

    $VMBasicProps = @{
        ComputerName = $ComputerName
        Name = $VMName
        VHDPath = $VMLocation + $DestinationVHDFile
        SwitchName = $vSwitch
        Generation = $VMConfiguration.Hardware.Generation
        Path = $VMFolder
    }
    New-VM @VMBasicProps

    Write-Output 'VM Created'

    $VMExtendedProps = @{
        ComputerName = $ComputerName
        Name = $VMName
        ProcessorCount = $VMConfiguration.Hardware.vCPU
        AutomaticStopAction = $VMConfiguration.AutomaticStopAction
        MemoryStartupBytes = $VMConfiguration.Hardware.MemoryStartupBytes
        AutomaticStartAction = $VMConfiguration.AutomaticStartAction
        AutomaticStartDelay = $VMConfiguration.AutomaticStartDelay
    } 

    ###################################
    #             VLANs               #
    ###################################

    if ($VMConfiguration.Hardware.Network.VLAN) {
        $props = @{
            ComputerName = $ComputerName
            Name = $VMName
            VlanId = $VMConfiguration.Hardware.Network.VLAN
        }
        if ($VMConfiguration.Hardware.Network.VLANMode -eq 'Access') {
            $props.Access='' 
        }
        elseif ($VMConfiguration.Hardware.Network.VLANMode -eq 'Trunk') {
            $props.Trunk='' 
        }

        Set-VMNetworkAdapterVlan @props
        Write-Output 'Vlan set'
    }

    

    ###################################
    #         Dynamic Memory          #
    ###################################


    if ($VMConfiguration.Hardware.MemoryMinimumBytes -AND $VMConfiguration.Hardware.MemoryMaximumBytes) {
        $VMExtendedProps.DynamicMemory = $true
        $VMExtendedProps.MemoryMinimumBytes = $VMConfiguration.Hardware.MemoryMinimumBytes
        $VMExtendedProps.MemoryMaximumBytes = $VMConfiguration.Hardware.MemoryMaximumBytes
    }
    else {
        $VMExtendedProps.StaticMemory = $true
    }


    Set-VM @VMExtendedProps

    Write-Output 'Additional VM props set'

    Start-VM $VMName -ComputerName $ComputerName

    Write-Output 'VM started'

    Start-Sleep (30)



    ###################################
    #         IP Configuration        #
    ###################################
    Invoke-Command -VMName $VMName -Credential $LocalCredentials -ScriptBlock {
        $NetworkParams = $USING:VMConfiguration.Hardware.Network
        if ($NetworkParams.NICName) {  
            Get-NetAdapter | Rename-NetAdapter -NewName $NetworkParams.NICName
        }
        if ($NetworkParams.IPAddress) {
            $props = @{ 
                IPAddress = $NetworkParams.IPAddress
                PrefixLength = $NetworkParams.PrefixLength
                DefaultGateway = $NetworkParams.DefaultGateway
            }  
            Get-NetAdapter | New-NetIPAddress @props
        }
        if ($NetworkParams.DNSClientServerAddress) {
            Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $NetworkParams.DNSClientServerAddress
        }
    }
    Write-Output 'IP Configuration set'



    ###################################
    #            SYSPREP              #
    ###################################


    Invoke-Command -VMName $VMName -Credential $LocalCredentials -ScriptBlock {
        Start-Process 'c:\windows\system32\sysprep\sysprep.exe' -ArgumentList '/oobe /generalize /reboot /mode:vm' -NoNewWindow -Wait
    }
    
    Write-Output 'VM Syspreped'

    Start-Sleep (60)
    ###################################
    #      Remove SYSPREP File        #
    ###################################

    $LocalPassword = ConvertTo-SecureString -String $VMConfiguration.LocalAdminPassword  -AsPlainText -Force
    $LocalCredsTemplate = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", $LocalPassword


    Invoke-Command -VMName $VMName -Credential $LocalCredsTemplate -ScriptBlock {
        if (Test-Path C:\Windows\Panther\Unattend\Unattend.xml) {
            Remove-Item C:\Windows\Panther\Unattend\Unattend.xml
        }
        Rename-Computer -NewName $USING:VMName -Restart
    }
    Write-Output 'VM renamed'
}