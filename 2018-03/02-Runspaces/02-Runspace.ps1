### Couple of ways to create a Runspace
#region Use [powershell] to create an instance of PowerShell in process with already created runspace
$PowerShell = [powershell]::Create()
$PowerShell | Get-Member
$PowerShell.Runspace
$PowerShell.Runspace | Get-Member
$PowerShell.Runspace.RunspaceConfiguration
$PowerShell.Runspace.RunspaceConfiguration | Get-Member
$PowerShell.Dispose()
#endregion

# more than 1 parameter needs to use a hashtable with AddParameters() method
$Params = @{
    Path   = "C:\Users\PowershellVortex\OneDrive\PS-Multithreading"
    Recurse = [switch]$true
    Filter = "*.ps1"
}
[powershell]::Create().AddCommand("Get-ChildItem").AddParameters($Params).Invoke()

#endregion

#region AddScript() method
$PowerShell = [powershell]::Create()

#Notice it returns the PowerShell object; can be sent to $Null
$PowerShell.AddScript( {
        Get-Date
    })

#View the commands
$PowerShell.Commands.Commands

#Invoke the command
$PowerShell.Invoke()

#endregion

#region Workaround for this is to use AddParameter() instead
$Param1 = 'Param1'
$Param2 = 'Param2'

$PowerShell = [powershell]::Create()

[void]$PowerShell.AddScript( {
        Param ($Param1, $Param2)
        [pscustomobject]@{
            Param1 = $Param1
            Param2 = $Param2
        }
    }).AddParameter('Param2', $Param2).AddParameter('Param1', $Param1) #Order won't matter now


$PowerShell.Commands.Commands.parameters

#Invoke the command
$PowerShell.Invoke()
$PowerShell.Dispose()

#endregion

#region Async approach (multithreading)

$PowerShell = [powershell]::Create()
#Now let it sleep for a couple seconds
[void]$PowerShell.AddScript( {
        Start-Sleep -Seconds 5
        Get-Date
    })

#Invoke the command
$PowerShell.Invoke()
$PowerShell.Dispose()

#region Async
$PowerShell = [powershell]::Create()

[void]$PowerShell.AddScript( {
        Start-Sleep -Seconds 10
        [pscustomobject]@{
            RSProcessId    = $PID
            RSThread       = [appdomain]::GetCurrentThreadId()
            RSTotalThreads = (get-process -id $PID).Threads.count
        }
    })

#Take the same scriptblock and run it in the background
# System.Management.Automation.PowerShellAsyncResult
$Handle = $PowerShell.BeginInvoke()

#Notice IsCompleted property; tells us when command has completed
$Handle

#During this time we have free reign over the console
(Get-Process -id $PID).Threads | Select Id, ThreadState, StartTime

#Check again
$Handle

#Get results
#EndInvoke waits for a pending async call and returns the results, if any
$PowerShell.EndInvoke($Handle)

#Perform cleanup
$PowerShell.Dispose()
#endregion

#region Serialized Object PSJob
$Process = Get-Process
$Process | Get-Member

$Job = Start-Job {Get-Process}
[void]($job | Wait-Job)
$Data = $job | Receive-Job
Remove-Job $job

#Note the Typename and available methods compared to $Process
$Data | Get-Member

#View the methods
$Data | Get-Member -Type Method
$Process | Get-Member -Type Method
#endregion

#region Live Object Runspace
$PowerShell = [powershell]::Create()

#Now let it sleep for a couple seconds
[void]$PowerShell.AddScript( {
        Get-Process
        Start-Sleep -Seconds 2
    })

#Take the same scriptblock and run it in the background
$Handle = $PowerShell.BeginInvoke()

While (-Not $handle.IsCompleted) {
    Write-Host "." -NoNewline; Start-Sleep -Milliseconds 100
}

#Get results
$Data = $PowerShell.EndInvoke($Handle)

#Perform cleanup
$PowerShell.Runspace.Close()
$PowerShell.Dispose()

#Note TypeName and available methods
$Data | Get-Member
#endregion

#endregion

#region Adding a Module
$PowerShell = [powershell]::Create()
$SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$Runspace = [runspacefactory]::CreateRunspace($Host, $SessionState)
$Runspace.Open()
$SessionState.ImportPSModule(@('IEFavorites', 'Pester', 'PoshPrivilege'))
$PowerShell.Runspace = $Runspace
[void]$PowerShell.AddScript( {
        @{
            IEFavorites = (Get-IEFavorite)
            Privileges  = (Get-Privilege)
        }
    })
$Return = $PowerShell.Invoke()
$PowerShell.Dispose()
#endregion Adding a Module

#region Remote Runspace
# Create connectionInfo
$Uri = New-Object System.Uri("http://$($dataCSVHash.ComputerName):5985/wsman")
$connectionInfo = New-Object System.Management.Automation.Runspaces.WSManConnectionInfo -ArgumentList $Uri
$connectionInfo.OpenTimeout = 3000

# Create remote runspace
$runspace = [runspacefactory]::CreateRunspace($connectionInfo)
#endregion

    #region Show currenty ID and Thread for PowerShell.exe
    ## Check if running on same Process ID but in different Thread
    [pscustomobject]@{
        Type         = 'Standard'
        ProcessId    = $PID
        Thread       = [appdomain]::GetCurrentThreadId()
        TotalThreads = (get-process -id $PID).Threads.count
    }

    # Show Process ID and thread for new runspace
    $PowerShell = [powershell]::Create()
    [void]$PowerShell.AddScript( {
            [pscustomobject]@{
                Type         = 'Runspace'
                ProcessId    = $PID
                Thread       = [appdomain]::GetCurrentThreadId()
                TotalThreads = (get-process -id $PID).Threads.count
            }
        })
    #Invoke the command
    $PowerShell.Invoke()
    $PowerShell.Dispose()

    #Check threads again
    [pscustomobject]@{
        Type         = 'Standard'
        ProcessId    = $PID
        Thread       = [appdomain]::GetCurrentThreadId()
        TotalThreads = (get-process -id $PID).Threads.count
    }
    #region Using PSJobs
    [void](Start-Job -Name Thread -ScriptBlock {
            [pscustomobject]@{
                Type         = 'PSJob'
                ProcessId    = $PID
                Thread       = [appdomain]::GetCurrentThreadId()
                TotalThreads = (get-process -id $PID).Threads.count
            }
        })
    [void](Wait-Job -Name Thread)
    Receive-Job -Name Thread | Select Type, ProcessID, Thread, TotalThreads
    Remove-Job -Name Thread
#endregion
#endregion
