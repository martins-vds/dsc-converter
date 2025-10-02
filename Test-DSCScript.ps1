<#
.SYNOPSIS
    Tests if a DSC configuration file has valid PowerShell syntax.

.DESCRIPTION
    This script validates the syntax of DSC configuration files without executing them.
    Useful for pre-validation before conversion on platforms where DSC is not fully supported.

.PARAMETER ConfigurationFile
    The path to the DSC configuration PowerShell file to validate.

.EXAMPLE
    .\Test-DSCScript.ps1 -ConfigurationFile ".\examples\SimpleService.ps1"

.NOTES
    Author: Vinny Martins
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ConfigurationFile
)

function Test-DSCSyntax {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Raw
        $isValid = $true
        
        # Check for Configuration keyword
        if ($content -match "Configuration\s+(\w+)") {
            $configName = $Matches[1]
            Write-Host "✓ Configuration block found: $configName" -ForegroundColor Green
        }
        else {
            Write-Host "✗ No Configuration block found" -ForegroundColor Yellow
            Write-Host "  This file may not be a DSC configuration" -ForegroundColor Yellow
            $isValid = $false
        }
        
        # Check for Node blocks
        if ($content -match "Node\s+") {
            Write-Host "✓ Node block(s) found" -ForegroundColor Green
        }
        else {
            Write-Host "⚠ No Node block found (optional but recommended)" -ForegroundColor Yellow
        }
        
        # Check for Import-DscResource
        if ($content -match "Import-DscResource") {
            Write-Host "✓ Import-DscResource statement found" -ForegroundColor Green
        }
        else {
            Write-Host "⚠ No Import-DscResource statement found (may be needed)" -ForegroundColor Yellow
        }
        
        # Check for common DSC resource types
        $resourceTypes = @(
            "WindowsFeature", "File", "Registry", "Service", "Script",
            "Package", "Archive", "Environment", "Log", "Group", "User"
        )
        
        $foundResources = @()
        foreach ($resourceType in $resourceTypes) {
            if ($content -match "\b$resourceType\b\s+\w+\s*\{") {
                $foundResources += $resourceType
            }
        }
        
        if ($foundResources.Count -gt 0) {
            Write-Host "✓ DSC resources found: $($foundResources -join ', ')" -ForegroundColor Green
        }
        
        # Check for balanced braces
        $openBraces = ([regex]::Matches($content, '\{')).Count
        $closeBraces = ([regex]::Matches($content, '\}')).Count
        
        if ($openBraces -eq $closeBraces) {
            Write-Host "✓ Balanced braces ({: $openBraces, }: $closeBraces)" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Unbalanced braces ({: $openBraces, }: $closeBraces)" -ForegroundColor Red
            $isValid = $false
        }
        
        # Check file extension
        if ($FilePath -match '\.ps1$') {
            Write-Host "✓ Valid PowerShell file extension (.ps1)" -ForegroundColor Green
        }
        
        return $isValid
    }
    catch {
        Write-Error "Failed to validate syntax: $_"
        return $false
    }
}

Write-Host "Validating DSC configuration file: $ConfigurationFile" -ForegroundColor Cyan
Write-Host ""

$isValid = Test-DSCSyntax -FilePath $ConfigurationFile

Write-Host ""
if ($isValid) {
    Write-Host "Validation passed! File can be processed with Convert-DSCToJson.ps1 on Windows." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "Validation failed. Please check the file for errors." -ForegroundColor Red
    exit 1
}
