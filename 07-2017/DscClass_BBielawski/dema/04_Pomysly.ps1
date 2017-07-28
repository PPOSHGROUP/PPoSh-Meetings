# Dziedziczenie po użytecznych klasach
[DscResource()]
class ŚmieciowyPlik : System.Net.WebClient {
    [DscProperty(Key)]
    [String]$Address
    
    [DscProperty(Mandatory)]
    [String]$Path
    
    [DscProperty(NotConfigurable)]
    [String]$Hash
    
    [ŚmieciowyPlik] Get () {
        return @{
            Address = $this.Address
            Path = $this.Path
            Hash = $this.GetLocalHash()
        }
    }
    
    [bool] Test () {
        if (Test-Path -LiteralPath $this.Path) {
            return ($this.GetRemoteHash() -eq $this.GetRemoteHash())
        } else {
            return $false
        }
    }
    
    [void] Set () {
        $this.DownloadFile($this.Address, $this.Path)
    }
    
    [String] GetLocalHash () {
        $fileHash = Get-FileHash -LiteralPath $this.Path -Algorithm MD5
        return $fileHash.Hash
    }
    
    [String] GetRemoteHash () {
        $checksumAddress = '{0}.checksum' -f $this.Address
        $string = $this.DownloadString($checksumAddress)
        return $string.Trim()
    }
}

# Dziedziczenie z innego zasobu
[DscResource()]
class ŚmieciowaKonfiguracja : ŚmieciowyPlik {
    [DscProperty(Mandatory)]
    [string]$SetScript
    
    [void] Set () {
        ([ŚmieciowyPlik]$this).Set()
        $script = [scriptblock]::Create($this.SetScript)
        $null = & $script
    }
}

# Korzystanie z get() w test() i set()

[DscResource()]
class KilkaParametrów {
    [DscProperty(Key)]
    [String]$Klucz
    
    [DscProperty()]
    [String]$Pierwszy
    
    [DscProperty()]
    [String]$Drugi
    
    [KilkaParametrów] Get () {
        return @{
            Klucz = $this.Klucz
            Pierwszy = Get-Pierwszy
            Drugi = Get-Drugi
        }
    }
    
    [bool] Test () {
        $current = $this.Get()
        return (
            $this.Pierwszy -eq $current.Pierwszy -and
            $this.Drugi -eq $current.Drugi
        )
    }
    
    [void] Set() {
        $current = $this.Get()
        
        if ($current.Pierwszy -ne $this.Pierwszy) {
            Set-Pierwszy -Value $this.Pierwszy 
        }
        
        if ($current.Drugi -ne $this.Drugi) {
            Set-Drugi -Value $this.Drugi
        }
    }
}

# Inne
# -- korzystanie z metod/właściwości pomocniczych
# -- stałe jako właściwości klasy bez oznaczeń [DscResource]
# -- ...