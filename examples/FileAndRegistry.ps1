Configuration FileAndRegistry
{
    param(
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $NodeName
    {
        File DirectoryExample
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = 'C:\ExampleDirectory'
        }

        File FileExample
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = 'C:\ExampleDirectory\example.txt'
            Contents        = 'This is example content'
            DependsOn       = '[File]DirectoryExample'
        }

        Registry RegistryExample
        {
            Ensure    = 'Present'
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\ExampleKey'
            ValueName = 'ExampleValue'
            ValueData = 'ExampleData'
        }

        Script ScriptExample
        {
            SetScript  = {
                Write-Verbose "Setting configuration"
            }
            TestScript = {
                return $false
            }
            GetScript  = {
                return @{ Result = 'Script executed' }
            }
        }
    }
}
