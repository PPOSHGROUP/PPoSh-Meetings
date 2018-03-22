
# Write Host kills kitten
Start-RSJob { Get-Process }
$p = Get-RSJob | Receive-RSJob
$p | Get-Member

Get-RSJob | Remove-RSJob -Force
1..10 | Start-RSJob {
    if ( $_ % 2 ) {
        "First $_"
    } Else {
        Start-sleep -seconds 2
        "Last $_"
    }
} | Wait-RSJob | Receive-RSJob | % { "I am $($_)" }

# using $_
# double foreach

'123', 'qwe', 'asd' | ForEach-Object {
    [pscustomobject] @{
        CharArray = $_.ToCharArray()
        Length    = $_.Length
    } | % {
        $_.CharArray
    }
}

'123', 'qwe', 'asd' | Start-RSjob {
    $_
    [pscustomobject] @{
        CharArray = $_.ToCharArray()
        Length    = $_.Length
    } | % {
        $_.CharArray
    }
} | Wait-RSJob -ShowProgress
Get-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob

$Test = 42
$AnotherTest = 7
$String = 'SomeString'
$ProcName = 'code - insiders'
$ScriptBlock = {
    Param($y,$z)
    [pscustomobject] @{
        Test = $y
        Proc = (Get-Process -Name $Using:ProcName)
        String = $Using:String
        AnotherTest = ($z + $_)
        PipedObject = $_
    }
}

1..5 | Start-RSJob $ScriptBlock -ArgumentList $test, $anothertest

Get-RSJob | Receive-RSJob

# Wait-RSJob
1..10 | Start-RSJob -ScriptBlock {
    Start-Sleep -Seconds (Get-Random (5..10))
    $_
} | Wait-RSJob


