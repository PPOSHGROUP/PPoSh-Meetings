##Step 1: Installing needed DSC module module from PowerShell gallery
Find-Module xPSDesiredStateConfiguration | Install-Module

##Step 2: DSC Pull Server Function
configuration Sample_xDscPullServer
{ 
    param  
    ( 
            [string[]]$NodeName = 'localhost', 

            [ValidateNotNullOrEmpty()] 
            [string] $certificateThumbPrint,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string] $RegistrationKey 
     ) 


     Import-DSCResource -ModuleName xPSDesiredStateConfiguration
     Import-DSCResource –ModuleName PSDesiredStateConfiguration

     Node $NodeName 
     { 
         WindowsFeature DSCServiceFeature 
         { 
             Ensure = 'Present'
             Name   = 'DSC-Service'             
         } 

         xDscWebService PSDSCPullServer 
         { 
             Ensure                   = 'Present' 
             EndpointName             = 'PSDSCPullServer' 
             Port                     = 8080 
             PhysicalPath             = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer" 
             CertificateThumbPrint    = $certificateThumbPrint          
             ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules" 
             ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration" 
             State                    = 'Started'
             DependsOn                = '[WindowsFeature]DSCServiceFeature'     
             UseSecurityBestPractices = $false
         } 

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}

###Step 3: Getting all needed variables for DSC Sample_xDscPullServer Function
$WebCertThumb = (Invoke-Command -Computername labdscps01 {Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.FriendlyName -eq "DSCPSPullServerCert"} | Select-Object -ExpandProperty ThumbPrint})
$Guid = (New-Guid).Guid

##Step4: Running Sample_xDscPullServer function to create DSC Server MOF file
Sample_xDSCPullServer -certificateThumbprint $WebCertThumb -RegistrationKey $Guid -OutputPath c:dsc\PullServer

##Step5: Applying DSC Configration - Instaling DSC Pull Server 
## Update-DscConfiguration

## Fire in the hole!
Start-DscConfiguration -Path c:\dsc\PullServer -Wait -Verbose -Force