function Get-OPBrokenFile {
    <#
        .Synopsis
        My synopsis...

        .Description
        My description...

        .Example
        Get-OPBrokenFile
        First example...

        .Example
        Get-OPBrokenFile -Param
        Second example
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [switch]$Param
    )

    if ($Param) {
        "Got param..."
    } else {
        "No param..."
    }
}
