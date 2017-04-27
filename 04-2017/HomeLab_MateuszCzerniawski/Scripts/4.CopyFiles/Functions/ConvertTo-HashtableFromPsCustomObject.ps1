function ConvertTo-HashtableFromPsCustomObject {
  #requires -Version 3.0 
  <#
      .SYNOPSIS
      Converts any powershell custom object to a custom hashtable.

      .DESCRIPTION
      Iterates through elements of a custom object and converts them to a corresponding items in a hashtable. Uses recursion to go deep into json object.

      .PARAMETER PSCustomObject
      PS Custom Object that should be converted to a hashtable

      .EXAMPLE
      ConvertTo-HashtableFromPsCustomObject -PSCustomObject SomePSCustomObject
      This will convert SomePSCustomObject to a corresponding hashtable

      .INPUTS
      Any Powershell Custom Object

      .OUTPUTS
      A hashtable
  #>
 
  [CmdletBinding()]
  [OutputType([HashTable])]
  param ( 
    [Parameter(Mandatory = $true,Position = 0,         
              ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
         
    [object[]]
    $PSCustomObject 
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
  process { 
    foreach ($myPsObject in $PSCustomObject) { 
      Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) PROCESS ] Processing PSCustomObject"
      $output = @{} 
      $myPsObject | Get-Member -MemberType *Property | ForEach-Object { 
        $value = $myPsObject.($_.name)
        if ($value -is [PSCustomObject]) {
          $value = ConvertTo-HashtableFromPsCustomObject -psCustomObject $value
        }
        $output.($_.name) = $value
      }
      Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) PROCESS ] Processing of PSCustomObject done" 
      $output
    } 
  }
  End {
    Write-Verbose -Message "[$((get-date).TimeOfDay.ToString()) END     ] Ending: $($MyInvocation.Mycommand)"
    Write-Verbose -Message "Ending $($MyInvocation.MyCommand) " 
  } 
}

