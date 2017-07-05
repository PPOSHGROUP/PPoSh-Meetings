Describe 'DHCP Service settings' {

  Context 'Verify service status' {
    it "Service should be running" {
      (Get-Service -ComputerName $DHCPConfiguration.Computername -Name Dhcp).Status  |
      Should be 'Running'
    }
    it "DNS Credentials should match configuration {$($DHCPConfiguration.DHCPServerDNSCredentials)}" {
      $DNSCredentials = Get-DhcpServerDnsCredential -ComputerName $DHCPConfiguration.Computername
      "$($DNSCredentials.DomainName)\$($DNSCredentials.Username)" |
      Should be $DHCPConfiguration.DHCPServerDNSCredentials
    }
    it "IP binding should match configuration {$($DHCPConfiguration.Binding)}" {
      (Get-DhcpServerv4Binding -ComputerName $DHCPConfiguration.Computername).IPAddress |
      should be $DHCPConfiguration.Binding
    }
  }
  Context 'Scopes tests' {
    it 'Check if any DHCP scope exists' {
      $Scopes = Get-DhcpServerv4Scope -ComputerName $DHCPConfiguration.Computername 
      $scopes | should be $true
    }
    foreach ($scope in (Get-DhcpServerv4Scope -ComputerName $DHCPConfiguration.Computername).ScopeId) {
      it "Checks if address lease in $scope is possible" {
        Get-DhcpServerv4FreeIPAddress -ComputerName $DHCPConfiguration.Computername -ScopeId $scope |
        should be $true
      }
    }
  }

  Context 'Reservation tests' {
    foreach ($scope in (Get-DhcpServerv4Scope -ComputerName $DHCPConfiguration.Computername).ScopeId) {
      $FreeIP = Get-DhcpServerv4FreeIPAddress -ComputerName $DHCPConfiguration.Computername -ScopeId $scope
      it "Checks if set reservations in $scope for $FreeIP is possible" {
        Add-DhcpServerv4Reservation -ComputerName $DHCPConfiguration.Computername -IPAddress $FreeIP -ClientId '0000000000AA' -ScopeId $scope 
        Get-DhcpServerv4Reservation -ComputerName $DHCPConfiguration.Computername -IPAddress $FreeIP |
        should be $true
      }
      it "Checks if remove reservation in $scope for $FreeIP is possible" {
        Remove-DhcpServerv4Reservation -ComputerName $DHCPConfiguration.Computername -ScopeId $scope -ClientID '0000000000AA' 
        Get-DhcpServerv4Reservation -ComputerName $DHCPConfiguration.Computername -IPAddress $FreeIP -ErrorAction SilentlyContinue | 
        should be $null
      }
    }
  }
  Context 'Configuration match tests' {
   # $Scopes = Get-DhcpServerv4Scope -ComputerName $DHCPConfiguration.Computername 
   $arrayScopeIDFromConfig = $DHCPScopes.ScopeID 
   $compareResult =  Compare-Object -ReferenceObject $scopes.ScopeId -DifferenceObject $arrayScopeIDFromConfig -IncludeEqual
    it "Check if all scopes have matching configuration files" {
      $compareResult | where {$_.cos -eq '=='} | should beNullOrEmpty
    } 

    foreach ($DHCPScope in $DHCPScopes) {
      $scopeTest = Get-DhcpServerv4Scope -computername $DHCPScope.ComputerName -ScopeId $DHCPScope.ScopeID -ErrorAction SilentlyContinue
      if ($scopeTest) { 
        it "Checking scope {$($DHCPScope.ScopeName)} configuration option match current state" {
        
        }
      }
      else {
      it "Scope {$($DHCPScope.ScopeName)} is not configured on {$($DHCPScope.ComputerName)}"
        $false | should be $true
      }
    }

  }

}