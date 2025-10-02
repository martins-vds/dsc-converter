# Quick Start Guide

This guide will help you get started with the DSC Converter tool in under 5 minutes.

## Step 1: Validate a DSC Configuration (Any Platform)

Run the validation tool on one of the example configurations:

```powershell
.\Test-DSCScript.ps1 -ConfigurationFile ".\examples\SimpleService.ps1"
```

Expected output:
```
✓ Configuration block found: SimpleService
✓ Node block(s) found
✓ Import-DscResource statement found
✓ DSC resources found: Service
✓ Balanced braces
✓ Valid PowerShell file extension (.ps1)
```

## Step 2: Convert to JSON (Windows Only)

Convert one of the example configurations to JSON:

```powershell
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\examples\SimpleService.ps1" -OutputPath ".\output.json"
```

## Step 3: View the Output

Open the generated `output.json` file to see your DSC configuration in JSON format.

## What's Next?

1. **Try other examples**: Run the converter on `SimpleWebServer.ps1` or `FileAndRegistry.ps1`
2. **Convert your own configs**: Point the tool to your existing DSC configuration files
3. **Customize output**: Use the `-Verbose` parameter to see detailed conversion steps

## Common Commands

```powershell
# Validate syntax (cross-platform)
.\Test-DSCScript.ps1 -ConfigurationFile ".\path\to\config.ps1"

# Convert to JSON and save to file (Windows)
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\path\to\config.ps1" -OutputPath ".\output.json"

# Convert with verbose output (Windows)
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\path\to\config.ps1" -Verbose

# Display JSON in console (Windows)
.\Convert-DSCToJson.ps1 -ConfigurationFile ".\path\to\config.ps1"
```

## Need Help?

See the [README.md](README.md) for complete documentation, troubleshooting tips, and advanced usage examples.
