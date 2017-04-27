function Get-VHDTemplates {
  <#
      .SYNOPSIS
      Retrieve VHD Templates from json config file

      .DESCRIPTION
      Get and parse (using helper functions) information from json configuration file about VHD templates - golden image and unattend.xml files

      .PARAMETER Path
      Path to json file with vhd templates information

      .EXAMPLE
      Get-VHDTemplates -Path c:\AdminTools\vhdtemplates.json
      Will retrieve content of this file and output hashtable

      .INPUTS
      Location of a json file.

      .OUTPUTS
      Custom hashtable of vhd template properties
  #>

    
  [CmdletBinding()]
  [OutputType([Hashtable])]
  param ( 
    [Parameter(
        Position = 0, HelpMessage = 'Provide path for configuration file with vhd templates',
        Mandatory = $true   
    )]
    [ValidateScript({Test-Path -Path $_})]

    [string]
    $Path 
  )

  begin {
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) BEGIN   ] Starting: $($MyInvocation.Mycommand)"
  }

  process { 
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) PROCESS ] Processing file {$Path}"
    return (ConvertTo-HashtableFromJSON -Path $Path )
  }
  
  end {
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) END     ] Ending: $($MyInvocation.Mycommand)"
  }
}