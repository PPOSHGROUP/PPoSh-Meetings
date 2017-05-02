## Going to our folder
cd c:\dsc\webservice

## Creating configuration
Configuration webservice
{
    param ($MachineName)
        Node $MachineName
        {
                #Install the IIS Role
                WindowsFeature IIS
                {
                    Ensure = "Present"
                    Name = "Web-Server"
                }
                #Install ASP.NET 4.5
                WindowsFeature ASP
                {
                    Ensure = "Present"
                    Name = "web-Asp-Net45"
                }
        }
}
 
webservice -MachineName localhost 

## New DSC Checksum
New-DscChecksum .\webservice

## Now we need to move these two files to "C:\Program Fles\WindowsPowerShell\DscService\Configuration"
