#region DPS
    throw "Forgot to use F8, Dory?"
#endregion

$demoRoot = 'D:\GitHub\PesterVsSloppiness'

Set-Location $demoRoot\Tests
Invoke-Pester
psedit $demoRoot\MyModule
Remove-Module MyModule
git checkout demo/Invoke
Invoke-Pester
psedit $demoRoot\Tests\Test-ModuleFunction.Tests.ps1

Set-Location $demoRoot\ModernTests
Invoke-Pester
Import-Module -Name $demoRoot\ModernTests\Assertions.psm1
Invoke-Pester




