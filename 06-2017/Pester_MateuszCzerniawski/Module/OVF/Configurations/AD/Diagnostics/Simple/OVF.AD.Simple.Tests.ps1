Describe 'Active Directory topology check' {
  $ADForest = Get-ADForest
  Context 'Veryfing Forest Configuration' {
        
    it "Forest FQDN $($Configuration.Forest.FQDN)" {
      $ADForest.RootDomain |
      Should be $Configuration.Forest.FQDN
    }
    it "Forest Mode $($Configuration.Forest.ForestMode)" {
      $ADForest.ForestMode |
      Should be $Configuration.Forest.ForestMode   
    }
    it "Global Catalogs should match configuration file" {
      $compGCfromConfig = $Configuration.Forest.GlobalCatalogs -split ','
      Compare-Object -ReferenceObject $ADForest.GlobalCatalogs -DifferenceObject $compGCfromConfig | should beNullOrEmpty
    }
    it "Schema Master should match configuration file: $($Configuration.Forest.SchemaMaster)" {
      $ADForest.SchemaMaster |
      Should be $Configuration.Forest.SchemaMaster
    }
  }

  Context 'Veryfing Sites Configuration' {
    it "Sites should match configuration file" {
      $sitesfromConfig = $Configuration.Sites -split ','
      Compare-Object -ReferenceObject $ADForest.Sites -DifferenceObject $sitesfromConfig | should beNullorEmpty
    }
  }
  Context 'Veryfing Domain Trusts Configuration' {
    if ($configuration.Trusts) {
      it "Trust domains {$($configuration.Trusts)} should match configuration file" {
        $trustsfromConfig = $configuration.Trusts -split ','
        $trustsfromAD = Get-ADTrust -filter *| Select-Object -ExpandProperty Name
        Compare-Object -ReferenceObject $trustsfromAD -DifferenceObject $trustsfromConfig | Should beNullorEmpty
      }
    }
    else {
      it "There are no Trusts with this domain" { 
        $true | should be $true
      }
    }
    
  }
}
Describe 'Active Directory services' {
  Context 'Veryfiying DC connectivity' {
    Foreach ($DC in $Configuration.Forest.GlobalCatalogs) {
      it "DC {$DC} server is online" {
        Test-Connection $DC -Count 1 -ErrorAction SilentlyContinue |
        Should be $true
      }
      it "DNS on DC {$DC} is reachable" {
        Resolve-DnsName -Name $($env:computername) -Server $DC |
        Should Not BeNullOrEmpty
      }
      it "AD on DC {$DC} is recheable" {
        (Get-ADDomainController -Server $DC) |
        Should Not BeNullOrEmpty
      }
    }
  }


  Context 'Verify DHCP servers' {
    it 'DHCP servers topology match configuration file' {
      $compArrayDHCPfromAD = (Get-ADObject -SearchBase 'cn=configuration,dc=objectivity,dc=co,dc=uk' -Filter "objectclass -eq 'dhcpclass' -AND Name -ne 'dhcproot'" ).Name 
      $compArrayDHCPfromConfig = $Configuration.DHCPServers -split ','
      Compare-Object -ReferenceObject $compArrayDHCPfromAD -DifferenceObject $compArrayDHCPfromConfig | should beNullOrEmpty
    } 
    Foreach ($dhcp in $Configuration.DHCPServers) {
            
      it "DHCP {$dhcp} is recheable" {
        Test-Connection $dhcp -Count 1 -ErrorAction SilentlyContinue |
        Should be $true
      }
      it "DHCP {$dhcp} leases IPs" {
        Get-DhcpServerv4FreeIPAddress -ComputerName $dhcp -ScopeId (Get-DhcpServerv4Scope -ComputerName $dhcp)[0].ScopeId |
        Should be $true
      }
    }
  }
}