function Write-PesterEventLog
{
  <#
    .SYNOPSIS
    Custom formating of Pester test results written to EventLog Application
 
    .DESCRIPTION
    Accepts PesterResults from Invoke-Pester -passThru as input. Will parse through results and write events to EventLog Application with provided EventSource.
    EventIDBase will be used to calculate Information (+1) and Error (+2) EventIDs.
 
    .PARAMETER PesterTestsResults
    PSCustomObject from Invoke-Pester -PassThru option

    .PARAMETER EventSource
    EventSource used to write events to EventLog

    .PARAMETER EventIDBase
    Base Integer number that will be used to calculate Information (+1) and Error (+2) messages.

    .EXAMPLE
    $tests = Invoke-Pester -Script c:\adminTools\tests.ps1 -PassThru
    Write-PesterEventLog -PesterTestsResults $tests -EventSource MySource -EventIDBase 1000
    
    Will parse through all results in $tests. 
    Passed tests will be written as Information events with EventID 1001 to 'Application' Log with source $EventSource
    Failed tests will be written as Error events with EventID 1002 to 'Application' Log with source $EventSource

    .INPUTS
    Accepts PesterResults from Invoke-Pester -passThru

    .OUTPUTS
    Events in EventLog are the output.
  #>



  [CmdletBinding()]
  [OutputType([Void])]
  param
  (
    [Parameter(Mandatory=$true,HelpMessage='Add help message for user', Position=0)]
    [PSCustomObject]
    $PesterTestsResults,
    
    [Parameter(Mandatory=$true,HelpMessage='Add help message for user', Position=1)]
    [System.String]
    $EventSource,
    
    [Parameter(Mandatory=$false, Position=2)]
    [System.Int32]
    $EventIDBase = 1000
  )
  
  begin {
    $EventIDInfo = $EventIDBase + 1
    $EventIDError = $EventIDBase + 2
  
    try { 
      if (-not [system.diagnostics.eventlog]::SourceExists($EventSource)) {
        [system.diagnostics.EventLog]::CreateEventSource($EventSource, 'Application')
        Write-Log -Info -Message "Created EventSource {$EventSource} in {Application} log. Information messages with EventID {$EventIDInfo}. Error messages with EventID {$EventIDError}"
      }
    }
    catch [System.Security.SecurityException],[Microsoft.PowerShell.Commands.WriteEventLogCommand]{
      Write-Log -Error -Message "You don't have permissions to access eventlogs. Unable to create EventSource {$EventSource}"
    }
    catch {
      $_
    }
  
  }
  process{
    foreach ($testResult in $PesterTestsResults.TestResult) { 
      $message = @"
{0} 
  {1}
    {2}
       Status: {3}
       {4}
"@ -f $testResult.Describe, $testResult.Context, $testResult.Name, $testResult.Passed, $testResult.FailureMessage
      try { 
        if ($testResult.Result -match 'Passed'){
          Write-EventLog -LogName Application -Source $EventSource  -EntryType Information -Message $message -EventId $EventIDInfo -Category 0
        }
        elseif ($testResult.Result -match 'Failed') {
          Write-EventLog -LogName Application -Source $EventSource  -EntryType Error -Message $message -EventId $EventIDError -Category 0 
        }
      }      
      catch { 
        $_
      }
    }
  }
  end {
  }

}

