function ConvertTo-HashtableFromJSON {
  #requires -Version 3.0 
  <#
      .SYNOPSIS
      Retrievies json file from disk and converts to hashtable.

      .DESCRIPTION
      Reads file given as Path parameter and using ConvertTo-HashtableFromPsCustomObject converts it to a hashtable.

      .PARAMETER Path
      Path to a json file.

      .EXAMPLE
      ConvertTo-HashtableFromJSON -Path c:\AdminTools\somefile.json
      Will read somefile.json and convert it to custom hashtable.

      .INPUTS
      Path to a json file (string).

      .OUTPUTS
      Custom Hashtable.
  #>



    [CmdletBinding()]
    [OutputType([Hashtable])]
    param ( 
         [Parameter(  
             Position = 0,HelpMessage='Path to json file', 
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true)]
         [ValidateScript({Test-Path -Path $_ -PathType 'Leaf' })]
         
         [string]
         $Path 
     ) 
  Begin {
    Write-Verbose -Message "Starting $($MyInvocation.MyCommand) " 
    Write-Verbose -Message 'Execution Metadata:'
    Write-Verbose -Message "User = $($env:userdomain)\$($env:USERNAME)" 
    Write-Verbose -Message "Computername = $env:COMPUTERNAME" 
    Write-Verbose -Message "Host = $($host.Name)"
    Write-Verbose -Message "PSVersion = $($PSVersionTable.PSVersion)"
    Write-Verbose -Message "Runtime = $(Get-Date)" 

    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) BEGIN   ] Starting: $($MyInvocation.Mycommand)"
    
  }
  Process{
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) PROCESS ] Processing json file {$Path}"
    $content = Get-Content -LiteralPath $path -ReadCount 0 -Raw | Out-String
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) PROCESS ] File read. Converting to PSCustomObject"
    $pscustomObject = ConvertFrom-Json -InputObject $content
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) PROCESS ] Converting from PSCustomObject to HashTable"
    $hashtable = ConvertTo-HashtableFromPsCustomObject -psCustomObject $pscustomObject
    $hashtable
  }
  End {
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) END     ] Ending: $($MyInvocation.Mycommand)"
    Write-Verbose -Message "Ending $($MyInvocation.MyCommand) " 
  }
}


