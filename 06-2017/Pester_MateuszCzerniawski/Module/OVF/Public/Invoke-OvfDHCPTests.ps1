function Invoke-OvfDHCPTests
{
  <#
      .SYNOPSIS
      Describe purpose of "Invoke-OvfDHCPTests" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER SourceFolder
      Describe parameter -SourceFolder.

      .PARAMETER OutputFolder
      Describe parameter -OutputFolder.

      .EXAMPLE
      Invoke-OvfDHCPTests -SourceFolder Value -OutputFolder Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Invoke-OvfDHCPTests

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>



  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [ValidateScript({Test-Path $_ -PathType Container })]
    [System.String]
    $SourceFolder,

    [Parameter(ValueFromPipeline=$True,
        Mandatory=$false,
    ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Container -IsValid})]
    [String]
    $OutputFolder
  )
  
  process{
    
    $configurationFolder = Join-Path -Path $SourceFolder -ChildPath 'Configuration'
    $DiagnosticsFolder = Join-Path -Path $SourceFolder -ChildPath 'Diagnostics'
    $CredentialFolder = Join-Path -Path $SourceFolder -ChildPath 'Credentials'

    #$Credentials =  Import-Clixml "$CredentialFolder\OVF.OBJPLDHCP1_creds.creds"
    
    $DHCPConfiguration = ConvertTo-HashtableFromJSON (Join-Path $ConfigurationFolder 'OBJPLDHCP1.DHCP.ServiceConfiguration.json')
    $DHCPScopes = Get-ChildItem -file -path (Join-Path $ConfigurationFolder 'Scopes') | ForEach-Object { ConvertTo-HashtableFromJSON $_.FullName }
    $DHCPReservations = Get-ChildItem -file -path (Join-Path $ConfigurationFolder 'Reservations') | ForEach-Object { ConvertTo-HashtableFromJSON $_.FullName }


    $PesterTests = Get-ChildItem -Path $DiagnosticsFolder -Recurse -File| Where-Object {$_.Name -match 'Tests.ps1'} | Select-Object -ExpandProperty FullName
    $PesterTests
    $DHCPScopes
    foreach ($pesterFile in $PesterTests) { 
      $fileName = (Split-Path $pesterFile -Leaf).Split('Simple')[0] 
      #Invoke-OVFPester -PesterFile $pesterFile -EventSource $fileName -EventBaseID 1020 -OutputFolder $OutputFolder
    }
  } 
}

