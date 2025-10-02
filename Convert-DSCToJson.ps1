<#
.SYNOPSIS
    Converts a DSC (Desired State Configuration) PowerShell file to JSON format.

.DESCRIPTION
    This script takes a DSC configuration PowerShell file and converts it to JSON format.
    It compiles the DSC configuration and exports the resulting configuration data to JSON.

.PARAMETER ConfigurationFile
    The path to the DSC configuration PowerShell file (.ps1).

.PARAMETER OutputPath
    The path where the JSON output file should be saved. If not specified, outputs to console.

.PARAMETER ConfigurationName
    The name of the configuration to compile. If not specified, attempts to detect it automatically.

.PARAMETER ConfigurationData
    Optional configuration data to pass to the DSC configuration.

.EXAMPLE
    .\Convert-DSCToJson.ps1 -ConfigurationFile ".\MyConfig.ps1" -OutputPath ".\output.json"

.EXAMPLE
    .\Convert-DSCToJson.ps1 -ConfigurationFile ".\MyConfig.ps1" -ConfigurationName "WebServerConfig"

.NOTES
    Author: Vinny Martins
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Path to the DSC configuration file")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ConfigurationFile,

    [Parameter(Mandatory = $false, HelpMessage = "Path to save the JSON output")]
    [string]$OutputPath,

    [Parameter(Mandatory = $false, HelpMessage = "Name of the configuration to compile")]
    [string]$ConfigurationName,

    [Parameter(Mandatory = $false, HelpMessage = "Configuration data hashtable")]
    [hashtable]$ConfigurationData
)

function Get-ConfigurationNameFromFile {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw
    
    # Match pattern: Configuration <Name> {
    if ($content -match "Configuration\s+(\w+)\s*(?:\(.*?\))?\s*\{") {
        return $Matches[1]
    }
    
    return $null
}

function Convert-DSCConfigurationToJson {
    param(
        [string]$FilePath,
        [string]$ConfigName,
        [hashtable]$ConfigData
    )
    
    try {
        # Dot-source the configuration file to load it into memory
        Write-Verbose "Loading configuration file: $FilePath"
        . $FilePath
        
        # If no configuration name provided, try to detect it
        if (-not $ConfigName) {
            $ConfigName = Get-ConfigurationNameFromFile -FilePath $FilePath
            if (-not $ConfigName) {
                throw "Could not detect configuration name. Please specify using -ConfigurationName parameter."
            }
            Write-Verbose "Detected configuration name: $ConfigName"
        }
        
        # Check if the configuration function exists
        if (-not (Get-Command -Name $ConfigName -ErrorAction SilentlyContinue)) {
            throw "Configuration '$ConfigName' not found in file '$FilePath'"
        }
        
        # Create a temporary output directory
        $tempPath = Join-Path -Path $env:TEMP -ChildPath "DSC_$(Get-Random)"
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
        Write-Verbose "Created temporary directory: $tempPath"
        
        try {
            # Compile the configuration
            Write-Verbose "Compiling configuration: $ConfigName"
            if ($ConfigData) {
                & $ConfigName -OutputPath $tempPath -ConfigurationData $ConfigData
            }
            else {
                & $ConfigName -OutputPath $tempPath
            }
            
            # Find the MOF file
            $mofFiles = Get-ChildItem -Path $tempPath -Filter "*.mof" -File
            
            if ($mofFiles.Count -eq 0) {
                throw "No MOF files were generated. Configuration compilation may have failed."
            }
            
            # Read and parse MOF files
            $configurations = @()
            
            foreach ($mofFile in $mofFiles) {
                Write-Verbose "Processing MOF file: $($mofFile.Name)"
                $mofContent = Get-Content -Path $mofFile.FullName -Raw
                
                $configObject = [PSCustomObject]@{
                    NodeName     = $mofFile.BaseName
                    MofContent   = $mofContent
                    Resources    = @()
                }
                
                # Parse MOF content to extract resource information
                $resourcePattern = 'instance of (\S+)(?: as \$\w+)?\s*\{([^}]+)\}'
                $matches = [regex]::Matches($mofContent, $resourcePattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
                
                foreach ($match in $matches) {
                    $resourceType = $match.Groups[1].Value
                    $resourceBody = $match.Groups[2].Value
                    
                    $properties = @{}
                    $propertyPattern = '(\w+)\s*=\s*("(?:[^"\\]|\\.)*"|\{[^}]*\}|[^;]+);'
                    $propMatches = [regex]::Matches($resourceBody, $propertyPattern)
                    
                    foreach ($propMatch in $propMatches) {
                        $propName = $propMatch.Groups[1].Value
                        $propValue = $propMatch.Groups[2].Value.Trim().TrimEnd(';')
                        
                        # Remove quotes from string values
                        if ($propValue -match '^"(.*)"$') {
                            $propValue = $Matches[1]
                        }
                        
                        $properties[$propName] = $propValue
                    }
                    
                    $configObject.Resources += [PSCustomObject]@{
                        ResourceType = $resourceType
                        Properties   = $properties
                    }
                }
                
                $configurations += $configObject
            }
            
            # Create the final output object
            $output = [PSCustomObject]@{
                ConfigurationName = $ConfigName
                GeneratedDate     = (Get-Date).ToString("o")
                Nodes             = $configurations
            }
            
            return $output
        }
        finally {
            # Clean up temporary directory
            if (Test-Path $tempPath) {
                Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Verbose "Cleaned up temporary directory"
            }
        }
    }
    catch {
        Write-Error "Failed to convert DSC configuration: $_"
        throw
    }
}

# Main execution
try {
    Write-Verbose "Starting DSC to JSON conversion"
    Write-Verbose "Configuration file: $ConfigurationFile"
    
    $result = Convert-DSCConfigurationToJson -FilePath $ConfigurationFile -ConfigName $ConfigurationName -ConfigData $ConfigurationData
    
    # Convert to JSON with nice formatting
    $jsonOutput = $result | ConvertTo-Json -Depth 10
    
    if ($OutputPath) {
        # Save to file
        $jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "Configuration successfully converted and saved to: $OutputPath" -ForegroundColor Green
    }
    else {
        # Output to console
        Write-Output $jsonOutput
    }
}
catch {
    Write-Error "An error occurred during conversion: $_"
    exit 1
}
