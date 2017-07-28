[DscResource()]
class Zasob {}

[DscResource()]
class ZasobMetody : Zasob {
    [ZasobMetody] Get () {
        return @{

        }
    }
    
    [bool] Test () {
        return $false
    }
    
    [void] Set () {
    
    }
}

[DscResource()] 
class ZasobWlasciwosci : ZasobMetody {
    [DscProperty(Key)]
    [String]$Kluczowa
    
    [DscProperty(Mandatory)]
    [String]$Wymagana
    
    [DscProperty(NotConfigurable)]
    [String]$TylkoDoOdczytu
    
    [DscProperty()]
    [String]$Zwykla
}