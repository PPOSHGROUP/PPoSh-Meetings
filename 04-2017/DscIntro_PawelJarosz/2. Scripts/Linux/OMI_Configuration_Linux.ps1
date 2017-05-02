##Creating config for LCM
[DSCLocalConfigurationManager()]
configuration LinuxPull {
    param (
        [String]$ComputerName
    )
    node $ComputerName {
        Settings {
            RefreshMode = 'Pull'
            ConfigurationMode = 'ApplyAndAutocorrect'
        }
        ConfigurationRepositoryWeb main {
            ServerURL = 'https://labdscps01:8080/PSDSCPullServer.svc'
            RegistrationKey = "875aa7df-78fa-4e71-ab1c-479d7248ab87"
            ConfigurationNames = @('TestLinuxPull')
        }
    }
}
LinuxPull -ComputerName labcentos01 


##Trigerig config
 #Manually trigger config pull on the linux client node
Set-DscLocalConfigurationManager -Path .\LinuxPull -CimSession $sess1 -Verbose
#Update configuration if there were some changes
Update-DscConfiguration -CimSession $sess1 -Wait 