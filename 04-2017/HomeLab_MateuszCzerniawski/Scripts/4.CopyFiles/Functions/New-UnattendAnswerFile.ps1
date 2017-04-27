function New-UnattendAnswerFile {
  <#
    .SYNOPSIS
    Creates new unattend answer file based on template and provided parameters

    .DESCRIPTION
    It does the following steps:
        1. Reads the template file $TemplateUnattendFile
        2. Replaces 'unattendAdministratorHere' and 'unattendPasswordHere' with provided parameters
        3. Saves the file to specified location $OutputUnattendFile. If needed, folders are created.

    .PARAMETER TemplateUnattendFile
    Describe parameter -TemplateUnattendFile.

    .PARAMETER OutputUnattendFile
    Describe parameter -OutputUnattendFile.

    .PARAMETER LocalAdministrator
    Describe parameter -LocalAdministrator.

    .PARAMETER LocalAdministratorPassword
    Describe parameter -LocalAdministratorPassword.

    .EXAMPLE
    New-UnattendAnswerFile -TemplateUnattendFile 'D:\unattend.xml' -OutputUnattendFile 'D:\UnattendFile\myunattend.xml' -LocalAdministrator 'Administrator' -LocalAdministratorPassword '1234Qwer'

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online New-UnattendAnswerFile

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
       $TemplateUnattendFile,

       [Parameter(Mandatory=$true)]
       [string]
       $OutputUnattendFile,

       [Parameter(Mandatory=$false)]
       [string]
       $LocalAdministrator='Administrator',

       [Parameter(Mandatory=$true)]
       [string]
       $LocalAdministratorPassword
    )

    $XMLFile = Get-Content $TemplateUnattendFile -Raw -ReadCount 0
    $XmlFileOutput = $XMLFile.Replace('unattendAdministratorHere',$LocalAdministrator).Replace('unattendPasswordHere',$LocalAdministratorPassword)
    if (-not (Test-Path (Split-Path $OutputUnattendFile -Parent))) {
        $null = New-Item (Split-Path $OutputUnattendFile -Parent) -ItemType Directory
    }
    $XmlFileOutput | Out-File $OutputUnattendFile -Force utf8




}