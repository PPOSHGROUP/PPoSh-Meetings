using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace System.Collections
using namespace System.Text

function Should-HaveHelp {
<#
    .Synopsis
    Help description bla bla bla.

    .Description
    Do I even care...?
#>

    param (
        # Actual value of the 
        [String]$ActualValue,

        # Number of examples
        [ValidateRange(1, [Int]::MaxValue)]
        [Int]$Examples,

        # Switch that enables -Not
        [switch]$Negate,

        # Additional explanation
        [String]$Because
    )

    $issues = [ArrayList]::new()
    try {
        $command = Get-Command -Name $ActualValue -ErrorAction Stop
    } catch {
        $null = $issues.Add("Command $command not found")
    }

    if ($command) {
        $help = Get-Help -Name $ActualValue
    }

    if ($help) {
        if (-not $help.Description) {
            $null = $issues.Add('Description missing')
        }

        if ($Examples -gt ($actualExampleCount = @($ActualValue.Examples.Example).Count)) {
            $null = $issues.Add("Expected $Examples examples for command $ActualValue but got $actualExampleCount instead")
        }

        $help.parameters.parameter |
            Where-Object {
                $_.Name -and $_.Name -notin 'WhatIf','Confirm'
            } |
            ForEach-Object {
                if (-not $_.Description) {
                    $null = $issues.Add("Help description for parameter $($_.Name) is not set")
                }
            }
    } else {
        $null = $issues.Add("Help for command $ActualValue doesn't exist")
    }

    if ($Negate) {
        throw "Not supported!"
    }

    [PSCustomObject]@{
        Succeeded = -not $issues.Count
        FailureMessage = @"
$(
    if ($Because) {
        "Reason: $Because"
    }
)
Issues found:`n$(
    $issues -join "`n"
)
"@
    }
}

function Should-PassAnalyzerRule {
    param (
        [String]$ActualValue,
        [String[]]$RuleList,
        [switch]$Negate,
        [String]$Because
    )
    $testResults = @(Invoke-ScriptAnalyzer -Path $ActualValue -IncludeRule $RuleList)
    if ($testResults) {
        $failedMessage = @"
Expected to pass following Script Analyzer rules: $($RuleList -join ', ').
            $(
                if ($Because) {
                    "Reason: $Because."
                }
            )
            $(
"Found {0} issues:`n{1}" -f 
                @(
                    $testResults.Count
                    $testResults.Foreach{ 
                        "Script: $($_.ScriptPath) Line: $($_.Line) - $($_.Message)"
                    } -join "`n"
                )
            )
"@
        [PSCustomObject]@{
            Succeeded = $false
            FailureMessage = $failedMessage
        }
    } else {
        [PSCustomObject]@{
            Succeeded = $true
            FailureMessage = $null
        }
    }
}

function Should-UseDotSourcing {
    param (
        [FunctionInfo]$ActualValue,
        [switch]$Negate,
        [String]$Because
    )

    if ($Negate) {
        throw "Not supported!"
    }

    if ($Because) {
        throw "I'm to lazy^H^H^H^Hawesome to write the code for it, deal with it!"
    }

    $succeeded = $false
    $name = $ActualValue.Name
    $failureMessage = if ($filePath = $ActualValue.ScriptBlock.File) {
        $file = Get-Item -LiteralPath $filePath
        if ($file.BaseName -eq $ActualValue.Name) {
            $succeeded = $true
            ''
        } else {
            "Expected function $Name to be defined in the file $Name.ps1, but it was defined in $($file.Name) instead."
        }
    } else {
        "Expected function $Name to be dot-sourced but it wasn't."
    }

    [PSCustomObject]@{
        Succeeded = $succeeded
        FailureMessage = $failureMessage
    }
}

function Should-UseCmdletBinding {
    param (
        [FunctionInfo]$ActualValue,
        [String[]]$DangerousVerbs
    )

    $succeeded = $false

    $failureMessage = if ($ActualValue.CmdletBinding) {
        if ($ActualValue.Verb -in $DangerousVerbs) {
            $cmdletBindingAttribute = $ActualValue.ScriptBlock.Attributes.Where{
                $_.TypeId.Name -eq 'CmdletBindingAttribute' 
            }
            if ($cmdletBindingAttribute.SupportsShouldProcess) {
                $succeeded = $true
                ''
            } else {
                "Expected commands with verb $($ActualValue.Verb) to SupportShouldProcess but $($ActualValue.Name) is not."
            }
        } else {
            $succeeded = $true
            ''
        }
    } else {
        "Expected function $($ActualValue.Name) to use CmldetBinding but it's not."
    }

    [PSCustomObject]@{
        Succeeded = $succeeded
        FailureMessage = $failureMessage
    }
}

function Should-BeCorrectManifest {
    param (
        [PSModuleInfo]$ActualValue,
        [String]$ProjectPage,
        [String[]]$FunctionNames
    )

    $failureMessages = [StringBuilder]::new()

    if ([string]::IsNullOrEmpty($ActualValue.Author)) {
        $failureMessages.AppendLine("- empty author")
    }

    if ([string]::IsNullOrEmpty($ActualValue.CompanyName)) {
        $failureMessages.AppendLine("- empty company name")
    }

    if ([string]::IsNullOrEmpty($ActualValue.Description)) {
        $failureMessages.AppendLine("- empty description")
    }

    if ([string]::IsNullOrEmpty($ActualValue.PrivateData.PSData.Tags)) {
        $failureMessages.AppendLine("- missing tags")
    }

    $projectUri = $ActualValue.PrivateData.PSData.ProjectUri

    if ([string]::IsNullOrEmpty($projectUri)) {
        $failureMessages.AppendLine("- missing project uri")
    } elseif ($projectUri -notmatch ([regex]::Escape($ProjectPage))) {
        $failureMessages.AppendLine("- project uri doesn't match $ProjectPage")
    }

    $versionString = $ActualValue.Version.ToString()

    if (($versionString.Split('.')).Count -ne 3) {
        $failureMessages.AppendLine("- version ($versionString) not in required format")
    }

    $exportedFunctions = $ActualValue.ExportedFunctions.Keys

    foreach ($function in $exportedFunctions) {
        if ($function -notin $FunctionNames) {
            $failureMessages.AppendLine("- function $function exported, but not defined")
        } elseif ([WildcardPattern]::ContainsWildcardCharacters($function)) {
            $failureMessages.AppendLine("- exporting $function with wildcards")
        }
    }

    foreach ($definedFunction in $FunctionNames) {
        if ($definedFunction -notin $exportedFunctions) {
            $failureMessages.AppendLine("- function $definedFunction defined, but not exported")
        }
    }

    [PSCustomObject]@{
        Succeeded = $failureMessages.Length -eq 0
        FailureMessage = "Incorrect manifest, issues found:`n$($failureMessages.ToString())"
    }
}

function Should-BeCorrectFunctionDefinition {
    param (
        [ScriptBlockAst]$ActualValue,
        [String]$Name
    )

    $failureMessages = [StringBuilder]::new()
    $functions = $ActualValue.FindAll(
        {
            param (
                $astItem
            ) 
            $astItem -is [FunctionDefinitionAst]
        },
        $false
    )

    $calls = $ActualValue.FindAll(
        {
            param (
                $astItem
            )
            $astItem -is [CommandAst] -and
            $astItem.CommandElements[0].Value -eq $Name
        },
        $false
    ).Extent.Text

    if ($extraFunctions = $functions.Where{ $_.Name -ne $Name }.Name) {
        $failureMessages.AppendLine("- extra functions: $($extraFunctions -join ', ')")
    }

    if ($calls) {
        $failureMessages.AppendLine("- function calls: $($calls -join ', ')")
    }

    [PSCustomObject]@{
        Succeeded = $failureMessages.Length -eq 0
        FailureMessage = "Incorrect function definition, issues found:`n$($failureMessages.ToString())"
    }
}

foreach ($shouldOperator in @(
    'BeCorrectFunctionDefinition'
    'BeCorrectManifest'
    'HaveHelp'
    'PassAnalyzerRule'
    'UseDotSourcing'
    'UseCmdletBinding'
)) {
    Add-AssertionOperator -Name $shouldOperator -Test (Get-Command -Name "Should-$shouldOperator").ScriptBlock
}

Export-ModuleMember -Function @() -Cmdlet @() -Alias @() -Variable @()