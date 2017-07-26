#region Dwa typy klas
enum Krasnal {
    Szermierz
    Rzeźnik
    Pracz_Odrzański
    Syzyfek
}

[Krasnal]::Rzeźnik

class Foo {
    # Właściwość
    [String]$Bar
    
    # Metoda
    [String] ShowBar () {
        return $this.Bar
    }
    
    # Konstruktor
    Foo ([String]$bar) {
        $this.Bar = $bar
    }
    
    # Domyślny konstruktor - konieczny jeśli definiujemy własne...
    Foo () {}
}

[Foo]::new('Coś')
Write-Host ('=' * 20)
$foo = [Foo]::new()
$foo.Bar = 'CośInnego'
$foo.ShowBar()

[Foo]@{
    Bar = 'Ale...'
}

#region Dziedziczenie

class bar : foo {}
[bar]@{
    Bar = 'foo'
}

class WuWuWu : System.Net.WebClient {
    [string] ZapiszDoTempa ([String]$Address) {
        $temp = New-TemporaryFile
        $this.DownloadFile($Address, $temp.FullName)
        return $temp.FullName
    }
}

$www = [WuWuWu]::new()
$www.ZapiszDoTempa('http://www.google.com')
