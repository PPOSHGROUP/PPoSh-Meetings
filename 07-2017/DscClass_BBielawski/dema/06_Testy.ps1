using module MojeZasoby\MojeZasoby.psd1
$data = Import-PowerShellDataFile -LiteralPath MojeZasoby\MojeZasoby.psd1
Describe "Testujemy klasy w module DSC" {
    switch ($data.DscResourcesToExport) {
        MojZasob {
            $mojZasob = [MojZasob]@{
                MojKlucz = 'Test'
            }
            
            Context "Testujemy Get zasobu $_" {
                It "Klucz to klucz..." {
                    $wynik = $mojZasob.Get()
                    $wynik.MojKlucz | Should Be Test
                }
            }
            
            Context "Testujemy Test zasobu $_" {
                It "Zawsze jest źle..." {
                    $mojZasob.Test() | Should Be $false
                }
            }
            
            Context "Testujemy Set zasobu $_" {
                Mock -CommandName Get-Date
                It "Uruchamia Get-Date w set" {
                    $mojZasob.Set()
                    Assert-MockCalled -CommandName Get-Date -Exactly 1 -Scope It
                }
                
                # nie ma mocków dla metod, więc...
                
                $mojZasob | Add-Member -MemberType ScriptMethod -Name NazwaMetodyPomocniczej -Value {
                    Set-Content TestDrive:\foo.bar
                } -Force
            }
        }
        
        default {
            throw "Zasób $_ nie posiada testów!"
        }
    }
}
