<#
.SYNOPSIS
Defines parameters for the Clean Architecture setup script.

.DESCRIPTION
This parameter block declares the input parameters for the CleanArchitecture.ps1 script, which is used to scaffold or modify a Clean Architecture solution structure. The parameters allow the user to control whether default files are included and to specify the root directory for the Clean Architecture solution.

.PARAMETER ExcludeDefaultFiles
Optional switch. If specified, the script will not generate or modify default files (such as interfaces) in the solution structure.

.PARAMETER CleanArchitectureRoot
Optional string. Specifies the root directory path where the Clean Architecture solution structure will be created or modified.

.EXAMPLE
.\CleanArchitecture.ps1 -CleanArchitectureRoot "C:\Projects\MySolution" -ExcludeDefaultFiles

Runs the script to set up the Clean Architecture structure at the specified root, excluding default files.

.NOTES
- Follows Clean Architecture conventions as described in the project documentation.
- See .github/copilot-instructions.md for architectural and documentation standards.
#>
param (
  [switch]$ExcludeDefaultFiles
  [string]$CleanArchitectureRoot
)

$DomainRoot = Join-Path -Path $CleanArchitectureRoot -ChildPath "Domain"
$DomainEntitiesRoot = Join-Path -Path $DomainRoot -ChildPath "Entities"
$ApplicationRoot = Join-Path -Path $CleanArchitectureRoot -ChildPath "Application"
$InfrastructureRoot = Join-Path -Path $CleanArchitectureRoot -ChildPath "Infrastructure"

function WaitForFileRelease {
  param (
    [string]$File
  )
  # Wait for file to be released
  $maxTries = 10
  $tries = 0
  while ($true) {
    try {
      $IEntitiesPath = Join-Path $DomainEntitiesRoot "IEntities.cs"
      $IEntitiesContent = Get-Content $IEntitiesPath
      break
    } catch {
      Start-Sleep -Milliseconds 500
      $tries++
      if ($tries -ge $maxTries) {
        throw "Could not access IEntities.cs after $maxTries tries."
      }
    }
  }
}

if ( -not ($ExcludeDefaultFiles))
{
  Push-Location $DomainEntitiesRoot
  dotnet new interface -n IEntities;
  $IEntitiesPath = Join-Path $DomainEntitiesRoot "IEntities.cs"
  $IEntitiesContent = Get-Content $IEntitiesPath
  WaitForFileRelease -File $IEntitiesPath
  $InsertLines = @(

    "[Key]"
    "public Guid Id { get; set; }"
  )
  $UpdatedContent = $IEntitiesContent[0..3] + $InsertLines + $IEntitiesContent[4..($IEntitiesContent.Count-1)]
  Set-Content $IEntitiesPath $UpdatedContent
  Pop-Location
}
