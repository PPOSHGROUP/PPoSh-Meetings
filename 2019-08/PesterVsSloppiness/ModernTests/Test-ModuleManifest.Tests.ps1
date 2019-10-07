using namespace System.Management.Automation.Language
using namespace System.Collections

param (
    $ModuleName = '*'
)


foreach ($manifest in Get-ChildItem $PSScriptRoot\..\$ModuleName\$ModuleName.psd1) {
    if ($manifest.Basename -ne $manifest.Directory.Name) {
        # Looks like this psd1 is not really a module manifest...
        continue
    }
    Describe "Testing Module Manifest Metadata: $($manifest.BaseName)" {
        It 'Has proper manifest' {
            { Test-ModuleManifest -Path $manifest.FullName } | Should -Not -Throw
        }

        Context "Testing properties within module manifest $($manifest.BaseName)" {
            $moduleInfo = Test-ModuleManifest -Path $manifest.FullName -ErrorAction SilentlyContinue
            $modulePath = $manifest.FullName | Split-Path -Parent 
            $fullPath = Join-Path -ChildPath $moduleInfo.RootModule -Path $modulePath

            $rootModuleAst = [Parser]::ParseFile(
                $fullPath,
                [ref]$null,
                [ref]$null
            )

            $astFunctionSearch = {
                param (
                    $astItem
                ) 
                $astItem -is [FunctionDefinitionAst]
            }

            $functionNames = [ArrayList]::new()

            foreach ($script in Get-ChildItem -Path "$modulePath\*.ps1" -Exclude '*.classes.ps1') {
                $scriptAst = [Parser]::ParseFile(
                    $script.FullName,
                    [ref]$null,
                    [ref]$null
                )

                $functions = $scriptAst.FindAll(
                    $astFunctionSearch,
                    $false
                )

                foreach ($name in $functions.Name) {
                    $null = $functionNames.Add($name)
                }

                It "Should contain a correct function definition in $($script.Name)" {
                    $scriptAst | Should -BeCorrectFunctionDefinition -Name $script.BaseName
                }
            }

            It 'Should have correct manifest' {
                $moduleInfo | Should -BeCorrectManifest -ProjectPage https://github.com -FunctionNames $functionNames
            }
        }
    }
}
