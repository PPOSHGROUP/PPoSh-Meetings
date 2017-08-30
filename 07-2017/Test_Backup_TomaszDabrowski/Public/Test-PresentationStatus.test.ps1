Clear-Host
Describe -Name 'Presentation Test' -Fixture {
  Context -Name 'PowerShell environment' -Fixture {
    It -name 'Should be using the right username' -test {whoami.exe | Should Be 'Objectivity\tdabrowski_admin'}
    It -name 'Should be using ObjectivityAdminTools module' -test { (Get-Module -Name ObjectivityAdminTools).Count | Should Be 1}
    }
  Context -Name 'Presentation' -Fixture {
    It -name 'Should have PowerPoint Open' -test {(Get-Process -Name POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty}
    It -name 'Should have One PowerPoint Open' -test {(Get-Process -Name POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1}
    It -name 'Should have the correct PowerPoint Presentation Open' -test {(Get-Process -Name POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'PPOSH_Function.pptx - PowerPoint'}
  }
  Context -Name 'Windows environment' -Fixture {
    It -name 'Mail Should be closed' -test {(Get-Process -Name Outlook -ErrorAction SilentlyContinue).Count | Should Be 0}
    It -name 'Tweetium should be closed' -test {(Get-Process -Name WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0}
    It -name 'Slack should be closed' -test {(Get-Process -Name slack* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'Skype should be closed' -test {(Get-Process -Name Skype* -ErrorAction SilentlyContinue).Count | Should BE 0}
  }
  Context -Name 'Windows environment' -Fixture {
    It -name 'Should have DNS Servers for correct interface' -test {(Get-DnsClientServerAddress -InterfaceAlias 'Ethernet').Serveraddresses | Should Be @('10.2.6.50','10.2.6.49','10.3.6.50','10.5.6.50')}
    It -name 'Should have correct gateway for alias' -test {(Get-NetIPConfiguration -InterfaceAlias 'Ethernet').Ipv4DefaultGateway.NextHop | Should Be '10.2.254.254'}
  }
  Context -Name 'Files' -Fixture {
  $Files = 12
    It -name 'Should exist file PPOSH_Function.pptx' -test {Test-path -Path 'C:\Users\tdabrowski\Desktop\PPoSh\03\PPOSH_Function.pptx' | Should Be True }
    It -name "Should exist $Files files" -test {(Get-ChildItem -Path 'C:\Users\tdabrowski\Desktop\PPoSh\03' -Recurse).Count | Should Be $Files}
  }
}