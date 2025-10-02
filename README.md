# DSC Converter

A PowerShell tool for converting DSC (Desired State Configuration) PowerShell files into JSON format.

## Overview

This tool allows you to compile DSC configuration scripts and export them to JSON format, making it easier to:
- Document your DSC configurations
- Share configurations in a readable format
- Integrate with other tools that consume JSON
- Archive and version control configuration states

## Prerequisites

- **Windows PowerShell 5.1 or later** (DSC compilation requires Windows)
- PowerShell Core 7+ can be used for syntax validation only
- DSC resources referenced in your configuration files must be installed

**Note:** The `Convert-DSCToJson.ps1` script requires Windows PowerShell with DSC support for full functionality. The `Test-DSCScript.ps1` validation script can run on any platform.

## Installation

Clone this repository:

```bash
git clone https://github.com/martins-vds/dsc-converter.git
cd dsc-converter
```

## Usage

### Validate DSC Configuration Syntax

Before converting, you can validate your DSC configuration syntax (works on all platforms):

```powershell
.\Test-DSCScript.ps1 -ConfigurationFile ".\examples\SimpleWebServer.ps1"
```

### Basic Usage (Windows only)

Convert a DSC configuration file to JSON and display output in console:

```powershell
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\examples\SimpleWebServer.ps1"
```

### Save to File

Convert and save the output to a JSON file:

```powershell
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\examples\SimpleWebServer.ps1" -OutputPath ".\output.json"
```

### Specify Configuration Name

If your file contains multiple configurations or the auto-detection fails, specify the configuration name:

```powershell
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\examples\SimpleWebServer.ps1" -ConfigurationName "SimpleWebServer"
```

### Verbose Output

Get detailed information about the conversion process:

```powershell
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\examples\SimpleWebServer.ps1" -Verbose
```

### With Configuration Data

Pass configuration data to your DSC configuration:

```powershell
$configData = @{
    AllNodes = @(
        @{
            NodeName = "Server01"
            Role     = "WebServer"
        }
    )
}

.\Convert-DSCToJson.ps1 -ConfigurationFile ".\examples\SimpleWebServer.ps1" -ConfigurationData $configData
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ConfigurationFile` | Yes | Path to the DSC configuration PowerShell file (.ps1) |
| `OutputPath` | No | Path where the JSON output file should be saved. If not specified, outputs to console |
| `ConfigurationName` | No | Name of the configuration to compile. If not specified, attempts auto-detection |
| `ConfigurationData` | No | Optional configuration data hashtable to pass to the DSC configuration |

## Examples

This repository includes sample DSC configurations in the `examples` folder:

- **SimpleWebServer.ps1** - Basic IIS web server configuration
- **FileAndRegistry.ps1** - File and registry resource examples
- **SimpleService.ps1** - Windows service configuration

### Example Output

The JSON output includes:
- Configuration name
- Generation timestamp
- Node configurations
- Resource details with all properties

```json
{
  "ConfigurationName": "SimpleWebServer",
  "GeneratedDate": "2025-01-01T12:00:00.0000000Z",
  "Nodes": [
    {
      "NodeName": "localhost",
      "Resources": [
        {
          "ResourceType": "MSFT_WindowsFeature",
          "Properties": {
            "Name": "Web-Server",
            "Ensure": "Present"
          }
        }
      ]
    }
  ]
}
```

## How It Works

1. The script loads your DSC configuration file
2. Auto-detects or uses the specified configuration name
3. Compiles the DSC configuration to generate MOF files
4. Parses the MOF files to extract resource information
5. Converts the data to JSON format
6. Outputs to console or saves to a file

## Validation Script

The `Test-DSCScript.ps1` script provides cross-platform syntax validation for DSC configuration files:

```powershell
.\Test-DSCScript.ps1 -ConfigurationFile ".\examples\SimpleService.ps1"
```

This script checks for:
- Configuration block presence
- Node blocks
- Import-DscResource statements
- Common DSC resources
- Balanced braces
- Valid PowerShell file extension

The validation script works on Windows, Linux, and macOS.

## Troubleshooting

### Platform Requirements

**Error:** "Unable to find DSC schema store" or similar DSC-related errors

**Solution:** The conversion script requires Windows PowerShell with DSC support. Use the `Test-DSCScript.ps1` for cross-platform syntax validation only.

### Configuration name not detected

If auto-detection fails, explicitly specify the configuration name:

```powershell
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\myconfig.ps1" -ConfigurationName "MyConfigName"
```

### Missing DSC resources

Ensure all DSC resources referenced in your configuration are installed:

```powershell
# List installed DSC resources
Get-DscResource

# Install a specific DSC resource module
Install-Module -Name <ModuleName>
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Vinny Martins

## Acknowledgments

- Built for the PowerShell DSC community
- Inspired by the need for better DSC configuration documentation