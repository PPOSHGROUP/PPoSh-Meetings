#8 Limitowanie uruchamianych Jobów

$MaxThreads = 2
$Data = 'V21', 'V21', 'V21', 'V21'
$Data | % {
    $Check = $false
    while ( $Check -eq $false ) {
        if (( Get-Job -State 'Running' ).Count -lt $MaxThreads ) {
            $ScriptBlock = {
                Get-Process
            }
            Start-Job -ScriptBlock $ScriptBlock
            $Check = $true
        }
    }
}

# pętla While

1..4 | % {
    $MaxThreads = 2
    While (
        [array]( Get-Job | Where { $_.State -eq "Running" } ).Count -ge $MaxThreads ) {
        Write-Host "Waiting for open thread...($MaxThreads Maximum)"
        Start-Sleep -Seconds 3
    }
    $ScriptBlock = { Get-Process }
    Start-Job -ScriptBlock $ScriptBlock
}

While ( [array]( Get-Job | Where { $_.State -eq "Running" } ).Count -ne 0 ) {
    Write-Host "Waiting for background jobs..."
    Get-Job
    Start-Sleep -Seconds 3
}

Get-Job
$Data = Get-Job | % {
    Receive-Job $_
    Remove-Job $_
}

$Data[0] | Select ProcessName,Product,ProductVersion | Format-Table -AutoSize

# zakończenie zawieszonych Jobów
$MaxThreads = 2
while (@(Get-Job -State Running).Count -ge $MaxThreads ) {
    $now = Get-Date
    foreach ($job in @(Get-Job -State Running)) {
        if ($now - (Get-Job -Id $job.id).PSBeginTime -gt [TimeSpan]::FromMinutes(10)) {
            Stop-Job $job
        }
    }
    Start-Sleep -sec 2
}

Get-Job | Receive-Job
Get-Job | Remove-Job -Force
