# Loads YAML configuration for solution structure
# Requires powershell-yaml module: Install-Module -Name powershell-yaml -Scope CurrentUser

# Import the module
Import-Module powershell-yaml

# Load YAML config
$configPath = Join-Path -Path (Get-Location) -ChildPath 'settings.yaml'
if (-not (Test-Path $configPath)) {
    Write-Host "YAML config file not found: $configPath"
    exit 1
}
$config = ConvertFrom-Yaml (Get-Content $configPath -Raw)

# Assign variables from config
$Directories = $config.Directories
$toCopyByForce = $config.ToCopyByForce
$toCopy = $config.ToCopy
$cleanArchitectureDomainDirectories = $config.CleanArchitectureDomainDirectories
$cleanArchitectureApplicationDirectories = $config.CleanArchitectureApplicationDirectories
$cleanArchitectureInfrastructureDirectories = $config.CleanArchitectureInfrastructureDirectories
$cleanArchitectureInfrastructureDataDirectories = $config.CleanArchitectureInfrastructureDataDirectories
