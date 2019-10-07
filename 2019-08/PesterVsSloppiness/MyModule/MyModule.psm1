foreach ($file in Get-ChildItem -Path $PSScriptRoot\*.ps1) {
    . $file.FullName
}