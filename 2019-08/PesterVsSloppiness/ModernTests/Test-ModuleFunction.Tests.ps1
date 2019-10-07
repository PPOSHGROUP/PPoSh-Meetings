using namespace System.Management.Automation
using namespace System.Management.Automation.Language
param (
    [String]$ModuleName = '*',
    [String]$FunctionName = '*'
)

foreach ($file in Get-ChildItem -Path "$PSScriptRoot\..\$ModuleName\$ModuleName.psd1") {
    if (
        $file.Basename -ne $file.Directory.Name -or 
        -not (Get-ChildItem -Path "$($file.DirectoryName)\$FunctionName.ps1")
    ) {
        Write-Host "File $($file.Name) doesn't contain any functions or it's not a module manifest"
        continue
    }

    $testedModuleName = $file.Basename
    Describe "Testing module $testedModuleName" {
        It 'Can be imported without errors' {
            { Import-Module $file.FullName -ErrorAction Stop -Force} | Should -Not -Throw
        }
    }

    foreach (
        $function in (
            Get-Command -Module $testedModuleName -CommandType Function |
            Where-Object Name -Like $FunctionName
        )
    ) {
        $testedFunctionName = $function.Name
        Describe "Testing function $testedFunctionName defined in module $testedModuleName" {
            $ast = [Parser]::ParseFile( 
                "$($file.Directory.FullName)\$testedFunctionName.ps1",
                [ref]$null,
                [ref]$null
            )

            $functions  = $ast.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [FunctionDefinitionAst]
                },
                $true
            )

            $parameters = $ast.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [ParameterAst]
                },
                $true
            )

            $variables  = $ast.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [VariableExpressionAst]
                },
                $true
            )

            It "Has correct help for command $testedFunctionName" {
                $testedFunctionName | Should -HaveHelp -Examples 1
            }

            It "Uses dot-sourcing for function $($function.Name) correctly" {
                $function | Should -UseDotSourcing
            }

            It "Uses CmdletBinding for function $($function.Name) correctly " {
                $function | Should -UseCmdletBinding -DangerousVerbs New, Remove, Set, Stop, Invoke
            }

            # Test the parameters defined in the function, parameters from subfunctions are not evaluated.
            $functionParameters = (
                $functions | Where-Object { $_.Name -eq $testedFunctionName }
            ).Body.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [ParameterAst]
                },
                $false
            )

            $parameterNames = foreach ($parameter in $functionParameters) {
                ($parameterName = $parameter.Name.VariablePath.UserPath)
                if (
                    -not (
                        $variables | Where-Object {
                            $_.VariablePath.UserPath -eq 'PSBoundParameters'
                        }
                    ).Splatted
                ) {
                    It "Uses parameter $parameterName in code" {
                        (
                            (
                                (
                                    $variables.VariablePath.UserPath | Where-Object {$_ -eq $parameterName}
                                ) | Measure-Object
                            ).Count -ge 2
                        ) -or
                        $variables.VariablePath.UserPath -contains 'PSBoundParameters' | Should -BeTrue
                    }
                }

                It "Has a datatype assigned to parameter $parameterName" {
                    $parameter.Attributes | Where-Object {
                        $_.psobject.properties.name -notcontains 'NamedArguments'
                    } | Should -Not -BeNullOrEmpty
                }

                It "Uses PascalCase for parameter $parameterName" {
                    $parameterName | Should -MatchExactly '^[A-Z].*'
                }
            }

            foreach ($variable in $variables) {
                $variableName = $variable.VariablePath.UserPath
                if ($variableName -in $parameterNames) {
                    continue
                }
                It "Uses camelCase for variable $variableName" {
                     $variableName | Should -MatchExactly '^[a-z]'
                }
            }

            # PSScriptAnalyzer rules included in module test.
            $analyzerRules = @(
                'PSUseDeclaredVarsMoreThanAssigments'
                'PSShouldProcess'
                'PSUsePSCredentialType'
                'PSUseSingularNouns'
                'PSUseOutputTypeCorrectly'
                'PSUseApprovedVerbs'
            )

            It "Should pass analyzer rules for $testedFunctionName script file" {
                "$($file.Directory.FullName)\$testedFunctionName.ps1" | 
                    Should -PassAnalyzerRule -RuleList $analyzerRules
            }
        }
    }
}