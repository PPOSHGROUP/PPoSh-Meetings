[string[]]$ComputerName = 'V21', 'V22'

#region Use [powershell] to create an instance of PowerShell and [runspacefactory] to create a runspace
## Not as important right now but will be more important with runspace pools
$PowerShell = [powershell]::Create()
$Runspace = [runspacefactory]::CreateRunspace()

$Runspace.ApartmentState = 'STA'
#Default = UseNewThread on Runspaces and ReuseThread on Runspace Pool
$Runspace.ThreadOptions = 'Default'

#Open the runspace
$Runspace.Open()

#Add the runspace into the PowerShell instance
$PowerShell.Runspace = $Runspace

#Run like before
[void]$PowerShell.AddScript( {
        Start-Sleep -Seconds 10
        [pscustomobject]@{
            RSProcessId    = $PID
            RSThread       = [appdomain]::GetCurrentThreadId()
            RSTotalThreads = (get-process -id $PID).Threads.count
        }
    })

#Take the same scriptblock and run it in the background
$Handle = $PowerShell.BeginInvoke()

While (-Not $Handle.IsCompleted) {
    Write-Host '.' -NoNewline; Start-Sleep -Milliseconds 100
}

#Get results
$Results = $PowerShell.EndInvoke($Handle)

#Perform cleanup
$PowerShell.Runspace.Close()
$PowerShell.Dispose()

$Results
#endregion

