function Set-VMSysprepedImage {
  <#
    .SYNOPSIS
    Injects unattend.xml file to target vhd(x) image file

    .DESCRIPTION
    It does the following steps:
        1. Copy template syspreped file.
        2. Uses New-UnattendAnswerFile to prepare temporary unattend.xml based on parameters $LocalAdministrator and $LocalAdministratorPassword
        3. Uses Set-SysprepedVHDUnattendFile to inject prepared unattend.xml file
        4. Removes temporary unattend.xml

    .PARAMETER LocalAdministrator
    Describe parameter -LocalAdministrator.

    .PARAMETER LocalAdministratorPassword
    Describe parameter -LocalAdministratorPassword.

    .PARAMETER SysprepedImageSource
    Describe parameter -SysprepedImageSource.

    .PARAMETER SysprepedImageDestination
    Describe parameter -SysprepedImageDestination.

    .PARAMETER TemplateUnattendFile
    Describe parameter -TemplateUnattendFile.

    .PARAMETER OutputUnattendFile
    Describe parameter -OutputUnattendFile.

    .PARAMETER MountLocation
    Describe parameter -MountLocation.

    .EXAMPLE
       Set-VMSysprepedImage -LocalAdministrator 'Administrator' -LocalAdministratorPassword '1234Qwer' -SysprepedImageSource 'D:\Templates\syspreped_Windows2012R2_OS.vhdx' -SysprepedImageDestination 'D:\syspreped_Windows2012R2_OS.vhdx' -TemplateUnattendFile 'D:\unattend.xml' -OutputUnattendFile 'D:\UnattendFile\myunattend.xml' -MountLocation 'D:\vhdx'

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Set-VMSysprepedImage

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>

   [cmdletbinding()]
   [OutputType([void])]

    Param(
       [Parameter(Mandatory=$true)]
       [string]
       $LocalAdministrator,

       [Parameter(Mandatory=$true)]
       [string]
       $LocalAdministratorPassword,

       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $SysprepedImageSource,
       
       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $SysprepedImageDestination,
       
       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $TemplateUnattendFile,

       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $OutputUnattendFile,

       [Parameter(Mandatory=$true)]
       [ValidateScript({Test-Path $_ -IsValid})]
       [string]
       $MountLocation
    )

    #Copy template file
    Copy-Item $SysprepedImageSource -Destination $SysprepedImageDestination
    
    #Prepare xml file
    New-UnattendAnswerFile -TemplateUnattendFile $TemplateUnattendFile -OutputUnattendFile $OutputUnattendFile -LocalAdministrator $LocalAdministrator -LocalAdministratorPassword $LocalAdministratorPassword
    
    #Mount image, copy xml file, dismount image
    Set-SysprepedVHDUnattendFile -ImagePath $SysprepedImageDestination -Path $MountLocation -UnattendFile $OutputUnattendFile
    
    #delete local xml file
    Remove-Item $OutputUnattendFile -Force



}