function Set-SysprepedVHDUnattendFile {
  <#
    .SYNOPSIS
    Injects unattend.xml file to target vhd(x) image file

    .DESCRIPTION
    It does the following steps:
        1. Creates folder specified at Path parameter if needed.
        2. Mounts vhd(x) specified in ImagePath parameter at target location Path
        3. Copy $UnattendFile to Windows Panther folder in the mounted image
        4. Dismounts image.

    .PARAMETER ImagePath
    Describe parameter -ImagePath.

    .PARAMETER Path
    Describe parameter -Path.

    .PARAMETER UnattendFile
    Describe parameter -UnattendFile.

    .EXAMPLE
    Set-SysprepedVHDUnattendFile -ImagePath 'D:\syspreped_Windows2012R2_OS.vhdx' -Path 'd:\vhdx' -UnattendFile 'D:\UnattendFile\myunattend.xml'

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Set-SysprepedVHDUnattendFile

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>

   [cmdletbinding()]
   [OutputType([void])]

    Param(
       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $ImagePath,

       [Parameter(Mandatory=$true)]
       [string]
       $Path,

       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $UnattendFile
    )
    if (-not (Test-Path $Path)) {
        $null = New-Item $Path -ItemType Directory -Force
    }
    Mount-WindowsImage -ImagePath $ImagePath -Path $Path -Index 1
    $null = New-Item "$Path\Windows\Panther\Unattend" -ItemType Directory -Force
    Copy-Item -Path $UnattendFile -Destination "$Path\Windows\Panther\Unattend\unattend.xml" -Force
    Dismount-WindowsImage -Path $Path -Save




}