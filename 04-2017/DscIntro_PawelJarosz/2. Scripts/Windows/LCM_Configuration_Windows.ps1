[DSCLocalConfigurationManager()]
configuration BaseDscClientConfig
{
    Node localhost
    {
        Settings
        {
            RefreshMode          = 'Pull'
            RefreshFrequencyMins = 30 
            RebootNodeIfNeeded   = $true
            ConfigurationMode = "ApplyAndAutoCorrect"
 
        }
 
        ConfigurationRepositoryWeb PullSrv
        {
            ServerURL          = 'https://labdscps01:8080/PSDSCPullServer.svc'
            RegistrationKey    = '875aa7df-78fa-4e71-ab1c-479d7248ab87'
            ConfigurationNames = @('webservice')
            AllowUnsecureConnection = $true
        }   
        ReportServerWeb ReptSrv
        {
            ServerURL          = 'https://labdscps01:8080/PSDSCPullServer.svc'
            RegistrationKey    = '875aa7df-78fa-4e71-ab1c-479d7248ab87'
            AllowUnsecureConnection = $true
 
        }
 
 
    }
}
 
BaseDscClientConfig 

Set-DscLocalConfigurationManager .\BaseDscClientConfig
