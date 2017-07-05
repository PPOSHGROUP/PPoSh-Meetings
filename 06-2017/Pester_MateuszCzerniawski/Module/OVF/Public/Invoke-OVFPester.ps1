function Invoke-OVFPester {
  <#
      .SYNOPSIS
      Describe purpose of "Invoke-MyPester" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER PesterFile
      Describe parameter -PesterFile.

      .PARAMETER EventSource
      Describe parameter -EventSource.

      .PARAMETER EventID
      Describe parameter -EventID.

      .PARAMETER TestType
      Describe parameter -TestType.

      .EXAMPLE
      Invoke-MyPester -PesterFile Value -EventSource Value -EventID Value -TestType Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Invoke-MyPester

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>



  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipeline=$True,
        Mandatory=$True,
    ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Leaf})]
    [string[]]
    $PesterFile,

    [Parameter(ValueFromPipeline=$True,
        Mandatory=$false,
    ValueFromPipelineByPropertyName=$True)]
    [string]
    $EventSource,

    [Parameter(ValueFromPipeline=$True,
        Mandatory=$false,
    ValueFromPipelineByPropertyName=$True)]
    [int32]
    $EventBaseID,

    [Parameter(ValueFromPipeline=$True,
        Mandatory=$false,
    ValueFromPipelineByPropertyName=$True)]
    [ValidateScript({Test-Path $_ -Type Container -IsValid})]
    [String]
    $OutputFolder
  )

  Begin{ 
    $pesterParams =@{
      Show = 'None'
      PassThru = $true
    }
}
  Process{
    ForEach ($file in $PesterFile){
      Write-Log -Info -Message "Processing PesterFile {$file}"
      if($PSBoundParameters.Keys -match 'OutputFolder') { 
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmm'
        $fileNameTemp = (split-Path $file -Leaf).replace('.ps1','')
        $childPath = "{0}_{1}_PesterResults.xml" -f $fileNameTemp, $timestamp

        $fileName = Join-Path -Path $OutputFolder -ChildPath $childPath
        $pesterParams.OutputFile = $fileName
        $pesterParams.OutputFormat ='NUnitXml'
        Write-Log -Info -Message "Results for Pester file {$file} will be written to {$($pesterParams.OutputFile)}"
      }
      $tests = Invoke-Pester $file @pesterParams
     
      Write-PesterEventLog -PesterTestsResults $tests -EventSource $EventSource -EventIDBase $EventBaseID
      Write-Log -Info -Message "Pester File {$file} Processed."
    }
  }
  End {

  }
}