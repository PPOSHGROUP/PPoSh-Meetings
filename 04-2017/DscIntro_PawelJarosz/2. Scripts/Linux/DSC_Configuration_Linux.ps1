$Node = "labcentos01"
## Establishing CIM session
$Credential = Get-Credential -UserName:"root" -Message:"Enter Password:"

#Options for a trusted SSL certificate
$opt = New-CimSessionOption -UseSsl:$true -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true
$Sess1=New-CimSession -Credential:$credential -ComputerName:$Node -Port:5986 -Authentication:basic -SessionOption:$opt -OperationTimeoutSec:90 

##Creating configuration
configuration TestLinuxPull {
    param (
        [String]$ComputerName
    )
    Import-DscResource -ModuleName nx
    node $ComputerName {
        nxFile Test {
            DestinationPath = '/tmp/pull'
            Contents = ";Hello World!"
        }
    }
}

TestLinuxPull -ComputerName labcentos01 -OutputPath "c:\dsc\linux"

Rename-Item "C:\dsc\linux\labcentos01.mof" "TestLinuxPull.mof"

New-DscChecksum -Path "c:\dsc\linux" -Force