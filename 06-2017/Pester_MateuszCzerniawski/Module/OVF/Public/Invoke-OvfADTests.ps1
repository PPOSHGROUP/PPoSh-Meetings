function Invoke-OvfADTests
{
  <#
      .SYNOPSIS
      Describe purpose of "Invoke-OvfADTests" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER SourceFolder
      Describe parameter -SourceFolder.

      .PARAMETER OutputFolder
      Describe parameter -OutputFolder.

      .EXAMPLE
      Invoke-OvfADTests -SourceFolder Value -OutputFolder Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Invoke-OvfADTests

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
  
    $configuration = ConvertTo-HashtableFromJSON -path (Join-Path -Path $ConfigurationFolder -ChildPath 'AD.ServiceConfiguration.json')
  
    $PesterTests = Get-ChildItem -Path $DiagnosticsFolder -Recurse -File| Where-Object {$_.Name -match 'Tests.ps1'} | Select-Object -ExpandProperty FullName
  
  
    Invoke-OVFPester -PesterFile $PesterTests -EventSource 'OVF.AD' -EventBaseID 1010 -OutputFolder $OutputFolder
  } 
}

