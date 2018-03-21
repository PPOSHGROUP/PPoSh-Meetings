#7 Przykładowe uzycie z Test-Connection

$Count = 1
[array]$jobs = @()

# Tablica z hostami do sprawdzania
[array]$dataTest = "www.o2.pl", "www.google.com", "www.facebook.com", "www.wp.pl", "www.mail.ru"

# Hasztabela dla parametrów
$testConnectionHash = [ordered]@{ Count = $Count ; Quiet = $false }

# Polecenie, które będzie wykonane jako pojedyńczy Job
$scriptBlock = {
    # Komenda po przekazaniu $testConnectionHash wygląda tak: Test-Connection $ComputerName $Count $Quiet
    # Uwaga na znaczek @ przy nazwie zmiennej
    Test-Connection @using:testConnectionHash
}

$dataTest | % {
    # Dodanie do Hasztabeli klucza o nazwie Computername i wartości kolejnego elemntu z tablicy

    $testConnectionHash.ComputerName = $_
    # Efekt: $testConnectionHash = @{ ComputerName = $_ ;  Count = $Count ; Quiet = $false }

    # Uruchamia się pojedńczy Job a następnie dodawany jest do tablicy aby potem wszystkie wygodnie wyświetlić
    # Wykonanie kolejnej pentli dla następnego elementu w tablicy nie czeka aż zakończy się poprzednie polecenie znajdujace się w ScriptBlock :-]
    [array]$jobs += Start-Job -Name $_ -ScriptBlock $scriptBlock -ArgumentList $testConnectionHash
}

#Po wyjściu z pętli $data, Job'y (zawarte w tablicy $Jobs) są już uruchomione i czekamy na ich zakończenie
Wait-Job -Job $jobs | Out-Null

# Pobieramy Job'y, wyświetlają się ich wyniki, przełacznik -Keep nie usuwa danych
Receive-Job -Job $jobs -Keep

# Pobieramy wszystkie lokalne Job'y a następnie kasujemy
Get-Job | Remove-Job -Force

function Test-AsyncConnection {
    [cmdletbinding()]
    param(
        [Parameter(Position = 0)][Alias("cn", "hostname", "server", "__SERVER")]
        $ComputerName,
        [Parameter(Position = 1)]
        $Count = 1
    )

    # Tablica z hostami do sprawdzania
    [array]$data = $ComputerName

    # Hasztabela dla parametrów
    $testConnectionHash = @{ Count = $Count ; Quiet = $false }

    # Polecenie, które będzie wykonane jako pojedyńczy Job
    $scriptBlock = {
        param ($testConnectionHash)
        # Komenda po przekazaniu $testConnectionHash wygląda tak: Test-Connection $ComputerName $Count $Quiet
        # Uwaga na znaczek @ przy nazwie zmiennej
        Test-Connection @testConnectionHash
    }

    $data | % {
        # Dodanie do Hasztabel klucza o nazwie Computername i wartości kolejnego elemntu z tablicy

        $testConnectionHash.ComputerName = $_
        # Efekt: $testConnectionHash = @{ ComputerName = $_ ;  Count = $Count ; Quiet = $false }

        # Uruchamia się pojedńczy Job a następnie dodawany jest do tablicy aby potem wszystkie wygodnie wyświetlić
        # Wykonanie kolejnej pentli dla następnego elementu w tablicy nie czeka aż zakończy się poprzednie polecenie znajdujace się w ScriptBlock :-]
        [array]$jobs += Start-Job -Name $_ -ScriptBlock $scriptBlock -ArgumentList $testConnectionHash
    }

    #Po wyjściu z pętli $data, Job'y (zawarte w tablicy $Jobs) są już uruchomione i czekamy na ich zakończenie
    Wait-Job -Job $jobs | Out-Null

    # Pobieramy Job'y, wyświetlają się ich wyniki, przełacznik -Keep nie usuwa danych
    Receive-Job -Job $jobs -Keep

    # Pobieramy wszystkie lokalne Job'y a następnie kasujemy
    Get-Job | Remove-Job -Force

}
$dataTest = "www.o2.pl", "www.google.com", "www.facebook.com", "www.wp.pl", "www.mail.ru"
Test-AsyncConnection -ComputerName $dataTest

Measure-Command {
    Test-AsyncConnection -ComputerName $dataTest -Count 10
} | Select-Object * -ExpandProperty Seconds

Measure-Command {
    $dataTest | % { Test-Connection -ComputerName $_ -Count 10 }
} | Select-Object * -ExpandProperty Seconds

