[DSCResource()]
class MojZasob {
    [DscProperty(Key)]
    [String]$MojKlucz

    [MojZasob] Get () {
        return @{
            MojKlucz = $this.MojKlucz
        }
    }

    [bool] Test () {
        return $false
    }

    [void] Set () {
    
    }
}