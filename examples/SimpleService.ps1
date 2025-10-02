Configuration SimpleService
{
    param(
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $NodeName
    {
        Service Spooler
        {
            Name        = 'Spooler'
            StartupType = 'Automatic'
            State       = 'Running'
        }

        Service BITS
        {
            Name        = 'BITS'
            StartupType = 'Automatic'
            State       = 'Running'
        }
    }
}
