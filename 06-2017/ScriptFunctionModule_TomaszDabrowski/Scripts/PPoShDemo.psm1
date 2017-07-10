# PPoShDemo module
Set-StrictMode -Version Latest

# we're setting 'Stop' globally to ensure that each exception stops the script from running
$Global:ErrorActionPreference = 'Stop'

#region read all files
#$Functions  = @(Get-ChildItem -Recurse -Path $PSScriptRoot\*.ps1 | Where-Object { $_ -notmatch '\.Examples.ps1' })
$Functions = Get-ChildItem -Path "$PSScriptRoot\Show-Hello.ps1"
foreach ($import in $Functions) {
    try {
        . $import.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
# export functions (all or selected)
Export-ModuleMember -Function Show-Hello
#endregion

$psVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
$bit = if ([Environment]::Is64BitProcess) { 'x64' } else { 'x86' }
Write-Host ("PPoSh Demo started at '{0}', Powershell {1} {2}." -f $PSScriptRoot, $psVersion, $bit)
