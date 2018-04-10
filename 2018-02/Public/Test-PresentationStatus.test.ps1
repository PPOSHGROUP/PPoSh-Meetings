Clear-Host
Describe -Name 'Presentation Test' -Fixture {
  Context -Name 'PowerShell environment' -Fixture {
    It -name 'Should be using the right username' -test {whoami.exe | Should Be 'Objectivity\tdabrowski_admin'}
    It -name 'Should be using ObjectivityAdminTools module' -test { (Get-Module -Name ObjectivityAdminTools).Count | Should Be 1}
    }
  Context -Name 'Presentation' -Fixture {
    It -name 'Should have PowerPoint Open' -test {(Get-Process -Name POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty}
    It -name 'Should have One PowerPoint Open' -test {(Get-Process -Name POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1}
    It -name 'Should have the correct PowerPoint Presentation Open' -test {(Get-Process -Name POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'PPOSH_EmplLeave.pptx - PowerPoint'}
  }
  Context -Name 'Windows environment' -Fixture {
    It -name 'Mail Should be closed' -test {(Get-Process -Name Outlook -ErrorAction SilentlyContinue).Count | Should Be 0}
    It -name 'Tweetium should be closed' -test {(Get-Process -Name WWAHost* -ErrorAction SilentlyContinue).Count | Should Be 0}
    It -name 'Slack should be closed' -test {(Get-Process -Name slack* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'Skype should be closed' -test {(Get-Process -Name lync* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'Teams should be closed' -test {(Get-Process -Name Teams* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'Screenpresso should be closed' -test {(Get-Process -Name Screenpresso* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'FireFox should be closed' -test {(Get-Process -Name FireFox* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'Chrome should be closed' -test {(Get-Process -Name Chrome* -ErrorAction SilentlyContinue).Count | Should BE 0}
    It -name 'SRecorder should be opened' -test {(Get-Process -Name SRecorder* -ErrorAction SilentlyContinue).Count | Should BE 1}
    It -name 'KeePass should be opened' -test {(Get-Process -Name KeePass -ErrorAction SilentlyContinue).Count | Should BE 1}
    It -name 'Edge should be opened' -test {(Get-Process -Name MicrosoftEdge -ErrorAction SilentlyContinue).Count | Should BE 1}
  }
  Context -Name 'Windows environment' -Fixture {
    if((Get-NetIPAddress).IPAddress -match '10.2.') {
      It -name 'Should have DNS Servers for correct interface (Work)' -test {(Get-DnsClientServerAddress -InterfaceAlias 'Ethernet').Serveraddresses | Should Be @('10.2.6.50','10.2.6.49','10.3.6.50','10.5.6.50')}
      It -name 'Should have correct gateway for alias (Work)' -test {(Get-NetIPConfiguration -InterfaceAlias 'Ethernet').Ipv4DefaultGateway.NextHop | Should Be '10.2.254.254'}
    }
        elseif((Get-NetIPAddress).IPAddress -match '172.') {
      It -name 'Should have DNS Servers for correct interface (Home)' -test {(Get-DnsClientServerAddress -InterfaceAlias 'Ethernet').Serveraddresses | Should Be @('172.28.55.1')}
      It -name 'Should have correct gateway for alias (Home)' -test {(Get-NetIPConfiguration -InterfaceAlias 'Ethernet').Ipv4DefaultGateway.NextHop | Should Be '172.28.55.1'}
    }
  }
  Context -Name 'Files' -Fixture {
  $Files = 5
    It -name 'Should exist file PPOSH_Function.pptx' -test {Test-path -Path 'C:\Users\tdabrowski\Desktop\PPoSh\08\PPOSH_EmplLeave.pptx' | Should Be True }
    It -name "Should exist $Files files" -test {(Get-ChildItem -Path 'C:\Users\tdabrowski\Desktop\PPoSh\08' -Recurse).Count | Should Be $Files}
  }
}