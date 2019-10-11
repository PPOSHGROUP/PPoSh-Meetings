@{
    RootModule = 'MyModule.psm1'
    ModuleVersion = '1.0.0'
    GUID = '1db89920-6552-4b78-9a59-04f477557bda'
    Author = 'bielawb'
    CompanyName = 'Optiver'
    Copyright = '(c) 2019 bielawb. All rights reserved.'
    FunctionsToExport = @(
        'Get-OPFullHelp'
        'Get-OPNoHelp'
        'Get-OPPartialHelp'
        'Sort-OPKids'
    )
}
