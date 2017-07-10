#region LoadScript
# The entire script will be executed to load all functions into memory
. ($PSCommandPath -replace '\.tests\.ps1$', '.ps1')
#endregion

# describes the function Show-Hello
Describe -Name 'Show-Hello' -Fixture {
  # scenario 1: call the function without arguments
  Context -Name 'Running without arguments' -Fixture {
    # test 1: it does not throw an exception:
    It -Name 'runs without errors' -Test {
      # Gotcha: to use the "Should Not Throw" assertion, make sure you place the command in a scriptblock (braces):
      { Show-Hello } | Should Not Throw
    }
    It -Name 'does something useful' -Test {
      # call function Show-Hello and pipe the result to an assertion
      { Show-Hello } | Should Be $false
    }
    # test 2: it returns something:
    It -Name 'does return anything' -Test {Show-Hello | Should Not BeNullOrEmpty}
  }
  Context -Name 'Running with arguments' -Fixture {
    It -Name 'does something useful' -Test {{ Show-Hello -From 'WhatEver' }| Should Be $true}
    It -Name 'with no input returns a phrase' -Test {Show-Hello | Should Be 'Hello from'}
    It -Name 'with no input returns a phrase' -Test {Show-Hello | Should Be 'Hello from '}
    It -Name 'with a name returns the standard phrase with that name' -Test {Show-Hello -From 'Venus' | Should Be 'Hello from Venus'}
    It -Name 'with a name returns something that ends with name' -Test {Show-Hello -From 'Mars' | Should Match '.*Mars'}
  }
}
