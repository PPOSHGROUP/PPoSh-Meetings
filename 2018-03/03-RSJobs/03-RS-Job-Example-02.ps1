# Set a value to pass into script block
$test = 'test'

1..40 | Start-RSJob -Throttle 10 -ScriptBlock {

    $seconds = Get-Random (1..5)

    # Pull in var from outside the scriptblock
    [pscustomobject]@{

        Job     = "$Using:test" + "$_"

        Seconds = $seconds

    }

    Start-Sleep -Seconds $seconds

    #Write-Output "Job $Using:test-$_ slept for $seconds seconds."
    # Waits for all jobs to complete before outputting results with jobs in numerical order
    #} | Wait-RSJob | Get-RSJob | Receive-RSJob

    # Outputs each job's info as it completes
    #} | Wait-RSJob -Timeout 8 -ShowProgress | Receive-RSJob

}



do {
    $runningcount = (Get-RSJob | ? {$_.state -eq "Running"}).count
    $remaining = (Get-RSJob | ? {$_.state -eq "NotStarted"}).count
    Write-Host "$runningcount threads running, $remaining threads not started."
    Start-Sleep -Seconds 5
} until ($runningcount -eq 0)

Write-Host "All threads complete"
$rsObjs = @()
$rsObjs = Get-RSJob | Receive-RSJob
Get-RSJob | Remove-RSJob
$rsObjs | Export-CSV -Path "C:\Users\PowershellVortex\OneDrive\PS-Multithreading\Jobs\test.csv" -NoTypeInformation

#Get-RSJob | Remove-RSJob -Verbose