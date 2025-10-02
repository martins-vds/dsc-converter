Configuration SimpleWebServer
{
    param(
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature IIS
        {
            Ensure = 'Present'
            Name   = 'Web-Server'
        }

        WindowsFeature AspNet45
        {
            Ensure = 'Present'
            Name   = 'Web-Asp-Net45'
        }

        File WebsiteContent
        {
            Ensure          = 'Present'
            SourcePath      = 'C:\Source\Website'
            DestinationPath = 'C:\inetpub\wwwroot'
            Recurse         = $true
            Type            = 'Directory'
        }
    }
}
