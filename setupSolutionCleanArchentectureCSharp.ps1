<#
.SYNOPSIS
    Sets up a Clean Architecture solution structure for a C# project.

.DESCRIPTION
    This script automates the creation of a Clean Architecture .NET solution, including directory structure, project scaffolding, and default file setup.
    It supports initializing solution files, creating hard links and copies of default files, and adding Blazor or Web API projects as needed.
    The script is intended for use in repositories following the Tirsvad Clean Architecture conventions.

    Directory and file structure configuration is now loaded from a YAML file (solution-structure.config.yaml) using the powershell-yaml module.

    You must have powershell-yaml installed:
        Install-Module -Name powershell-yaml -Scope CurrentUser

.PARAMETER Files
    Switch. If specified, only creates directories, hardlinks, and copies default files.

.PARAMETER Arch
    Switch. If specified, only sets up Clean Architecture solution and projects (Domain, Application, Infrastructure).

.PARAMETER Blazor
    Switch. If specified, sets up Clean Architecture and adds Blazor WebAssembly and server projects (frontend/backend) including API.

.PARAMETER WebApi
    Switch. If specified, sets up Clean Architecture and adds a Web API project (backend) including architecture setup and files.

.PARAMETER Help
    Switch. If specified, shows usage instructions and exits.

.PARAMETER DefaultFilesSrc
    String. Optional path to a custom source for default files. If not provided, the script will clone or update the default files repository as needed.

.EXAMPLE
    ./setupSolutionCleanArchentectureCSharp.ps1
    # Runs the default setup: creates directories, copies files, and sets up Clean Architecture projects.

.EXAMPLE
    ./setupSolutionCleanArchentectureCSharp.ps1 -Files
    # Only creates directories, hardlinks, and copies default files.

.EXAMPLE
    ./setupSolutionCleanArchentectureCSharp.ps1 -Blazor
    # Sets up Clean Architecture and adds Blazor frontend/backend projects.

.NOTES
    - Requires Git, .NET SDK, and powershell-yaml module installed.
    - Loads directory and file structure from solution-structure.config.yaml.
    - Clones or updates the Dotnet.DefaultFiles repository for default file templates if not present.
    - Solution file is named [solutionname].slnx, matching the root folder name.
    - Follows conventions described in .github/copilot-instructions.md.
    - All source code is placed under 'src/', and all test projects under 'tests/'.
    - Uses solution-wide MSBuild props/targets and supports containerization via Docker.
    - For more details, see README.md and docs/.
#>

param (
  [switch]$Files,
  [switch]$Arch,
  [switch]$Blazor,
  [switch]$WebApi,
  [switch]$Identity,
  [switch]$Help,
  [string]$SolutionFile,
  [String]$Framework = "net10.0"
)

# Install powershell-yaml module if not already installed
Install-Module -Name powershell-yaml -Scope CurrentUser -Force

function Get-DefaultSource {
  param (
    [string]$DefaultFilesRoot
  )
  if ([string]::IsNullOrWhiteSpace($DefaultFilesRoot)) {
    $parentPath = Join-Path -Path (Get-Location) -ChildPath ".."
    if (Test-Path $parentPath) {
        $Subfolder = (Get-Item -Path $parentPath).FullName
        Write-Host "Parent path found: $Subfolder"
    } else {
        $Subfolder = ""
        Write-Host "Parent path '$parentPath' does not exist. Cannot determine subfolder. Exiting."
        exit(1)
    }
    Write-Host "No DefaultFilesSrc provided. Using default path: $Subfolder\TirsvadCLI.Dotnet.DefaultFiles"
    $DefaultFilesRoot = Join-Path -Path "$Subfolder" -ChildPath "TirsvadCLI.Dotnet.DefaultFiles"
    if (-not (Test-Path "$DefaultFilesRoot")) {
      Write-Host "TirsvadCLI.Dotnet.DefaultFiles not found. Cloning from GitHub..."
      Push-Location ..
      git clone https://github.com/TirsvadCLI/Dotnet.DefaultFiles.git $DefaultFilesRoot | Out-Null
      Pop-Location
    } else {
      Write-Host "TirsvadCLI.Dotnet.DefaultFiles already exists. Pulling latest changes from GitHub..."
      Push-Location ../TirsvadCLI.Dotnet.DefaultFiles
      git pull origin main | Out-Null
      Pop-Location
    }
  } else {
    if (-not (Test-Path "$DefaultFilesRoot")) {
      Write-Host "Provided DefaultFilesSrc path '$DefaultFilesRoot' does not exist. Exiting."
      exit(1)
    }
  }
  Write-Host ""
  Write-Host "Using DefaultFiles root: $DefaultFilesRoot"
  return $DefaultFilesRoot
}

<#
    Creates a list of tasks to perform based on the provided switches.
    .PARAMETER Files
        Switch. If specified, includes file setup tasks.
    .PARAMETER Arch
        Switch. If specified, includes architecture setup tasks.
    .PARAMETER Blazor
        Switch. If specified, includes Blazor project setup tasks.
    .PARAMETER WebApi
        Switch. If specified, includes API project setup tasks.
    .PARAMETER Help
        Switch. If specified, includes help task.
#>
function New-TaskList {
  param (
    [switch]$Files,
    [switch]$Arch,
    [switch]$Blazor,
    [switch]$WebApi,
    [switch]$Identity,
    [switch]$Help
  )
  $taskList = @()
  if ($Blazor) {
    $taskList += "blazor"
  } 
  if ($WebApi) {
    $taskList += "webapi"
  }
  if ($Identity) {
    $taskList += "identity"
  }
  if ($Arch) {
    $taskList += "arch"
  }
  if ($Files) {
    $taskList += "files"
  } 
  return $taskList
}

<#*
 * @brief Displays usage instructions for the script.
 * @details Provides information on available switches and parameters.
 #>
function Show-Help {
  Write-Host "Usage: setupSolutionCleanArchentectureCSharp.ps1 Command"
  Write-Host "Switches:"
  Write-Host "  -Files   # Only create directories, hardlink, and copy default files"
  Write-Host "  -Arch    # Only setup Clean Architecture solution and projects (Domain, Application, Infrastructure)"
  Write-Host "  -Blazor  # Add Blazor WebAssembly and server project (frontend/backend) including architecture setup and files"
  Write-Host "  -WebApi  # Add Web API project (backend) including architecture setup and files"
  Write-Host "  -Help    # Show this help message"
  Write-Host "If no switches are provided, the script will run with default settings (Arch and Files)."
  Write-Host "Param:"
  Write-Host "  -DefaultFilesSrc <path>  # Optional path to custom default files source. If not provided, the script will clone or update the default files repository as needed."
  Write-Host "  -SolutionFile <path>     # Optional path to the solution file. If not provided, it will be named [solutionname].slnx based on the root folder name."
  Write-Host "  -Framework <framework>   # Optional target framework for projects (default: net10.0 )"
  Write-Host "Example: ./setupSolutionCleanArchentectureCSharp.ps1 -Blazor"
}

<#
    Adds a project to the solution file, optionally under a solution folder.
    .PARAMETER SolutionFile
        Path to the solution file.
    .PARAMETER ProjectPath
        Path to the project file to add.
    .PARAMETER SolutionFolder
        Solution folder to add the project under (optional).
#>
function Add-ProjectToSolution {
  param (
    [string]$SolutionFile,
    [string]$ProjectPath,
    [string]$SolutionFolder
  )
  $solutionName = Split-Path -Path (Get-Location) -Leaf
  if (Test-Path $SolutionFile) {
    if ($SolutionFolder) {
      dotnet sln $SolutionFile add $ProjectPath --solution-folder $SolutionFolder  | Out-Null
    } else {
      dotnet sln $SolutionFile add $ProjectPath | Out-Null
    }
    Write-Host "Added project at '$ProjectPath' to solution '$SolutionFile'."
  } else {
    Write-Host "Solution file '$SolutionFile' does not exist. Cannot add project."
  }
}

<#
    Creates Clean Architecture projects (Domain, Application, Infrastructure, and their test projects).
    Adds references and folders as needed.
    .PARAMETER SolutionName
        Name of the solution (used for project naming).
#>
function New-CleanArchitectureProjects {
  param (
      [string]$SolutionName
  )
  $srcPath = "src"
  $testsPath = "tests"
  $projects = @(
    @{ Name = "$SolutionName.Domain"; Path = "$srcPath/Domain"; Template = "classlib"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Application"; Path = "$srcPath/Application"; Template = "classlib"; ProjectReference = "$SolutionName.Domain"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Infrastructure"; Path = "$srcPath/Infrastructure"; Template = "classlib"; ProjectReference = "$SolutionName.Application"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Infrastructure.Data"; Path = "$srcPath/Infrastructure.Data"; Template = "classlib"; ProjectReference = "$SolutionName.Infrastructure"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Domain.Tests"; Path = "$testsPath/Domain.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Domain"; SolutionFolder = "tests" },
    @{ Name = "$SolutionName.Application.Tests"; Path = "$testsPath/Application.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Application"; SolutionFolder = "tests" },
    @{ Name = "$SolutionName.Infrastructure.Tests"; Path = "$testsPath/Infrastructure.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Infrastructure"; SolutionFolder = "tests" },
    @{ Name = "$SolutionName.Infrastructure.Data.Tests"; Path = "$testsPath/Infrastructure.Data.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Infrastructure.Data"; SolutionFolder = "tests" }
  )
  foreach ($proj in $projects) {
    if (-not (Test-Path $proj.Path)) {
      dotnet new $($proj.Template) -n $($proj.Name) -o $($proj.Path) --framework $Framework | Out-Null
      if ($proj.ProjectReference) {
        $projFile = Join-Path -Path $proj.Path -ChildPath "$($proj.Name).csproj"
        $referenceFolder = ($proj.ProjectReference.Split('.') | Select-Object -Last 1)
        $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($proj.ProjectReference).csproj"
        dotnet add $projFile reference $referenceProjFile | Out-Null
      }
      AddProjectToSolution -ProjectPath (Join-Path -Path $proj.Path -ChildPath "$($proj.Name).csproj") -SolutionFolder $proj.SolutionFolder -SolutionFile "$SolutionFile"
      Write-Host "Created $($proj.Name) project in $($proj.Path)"
    } else {
      Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
    }
  }
  New-Directories -Directories $cleanArchitectureDomainDirectories -AddGitkeep $true
  New-Directories -Directories $cleanArchitectureApplicationDirectories -AddGitkeep $true
  New-Directories -Directories $cleanArchitectureInfrastructureDirectories -AddGitkeep $true
  New-Directories -Directories $cleanArchitectureInfrastructureDataDirectories -AddGitkeep $true
}

<#
    Creates Blazor WebAssembly and Server projects and adds them to the solution.
    .PARAMETER SolutionName
        Name of the solution (used for project naming).
#>
function New-BlazorProject {
  param (
    [string]$SolutionName
  )
  Write-Host "Creating Blazor WebAssembly and Server projects for $SolutionName..."
  $srcPath = "src"
  $project = @{ Name = "$SolutionName.Web"; Path = "$srcPath/Web"; Template = "blazor"; Options = @("--interactivity",  "Auto", "--use-program-main"); ProjectReference = "$SolutionName.Application" }
  if (-not (Test-Path "$($project.Path)")) {
    dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options) | Out-Null
    if ($project.ProjectReference) {
      $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name)/$($project.Name).csproj"
      $referenceFolder = $project.ProjectReference.Split('.')[-1]
      $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
      dotnet add $projFile reference $referenceProjFile | Out-Null
    }
    Write-Host "Created $($proj.Name) project in $($proj.Path)"
  } else {
    Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
  }
  # add all project to solution
  $projFile = Join-Path -Path "Web" -ChildPath "$project.Name.Web/$($project.Name).csproj"
  if (Test-Path $projFile) {
    dotnet sln add $projFile | Out-Null
    Write-Host "Added $($proj.Name) to solution."
  } else {
    Write-Host "Project file $projFile does not exist. Skipping adding to solution."
  }
  Write-Host (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName/$($project.Name).csproj")
  Write-Host (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Client/$($project.Name).client.csproj")
  AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web/$($project.Name).csproj") -SolutionFolder "src" -SolutionFile "$SolutionFile"
  AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web.Client/$($project.Name).Client.csproj") -SolutionFolder "src" -SolutionFile "$SolutionFile"
}

<#
    Creates a Web API project and adds it to the solution.
    .PARAMETER SolutionName
        Name of the solution (used for project naming).
#>
function New-WebWebApiProject {
  param (
    [string]$SolutionName
  )
  $srcPath = "src"
  $project = @{ Name = "$SolutionName.WebWebApi"; Path = "$srcPath/WebWebApi"; Template = "webwebapi"; Options = @("--use-program-main"); ProjectReference = "$SolutionName.Application" }
  if (-not (Test-Path $project.Path)) {
    dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options) | Out-Null
    if ($project.ProjectReference) {
      $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name).csproj"
      $referenceFolder = $project.ProjectReference.Split('.')[-1]
      $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
      dotnet add $projFile reference $referenceProjFile | Out-Null
    }
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "WebWebApi/$($project.Name).csproj") -SolutionFolder "src" -SolutionFile "$SolutionFile"
    Write-Host "Created $($proj.Name) project in $($proj.Path)"
  } else {
    Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
  }
}

# Print help message and exit if argument is 'help'

if ($Help) {
  Show-Help
  exit
}

$taskList = New-TaskList -Files:$Files -Arch:$Arch -Blazor:$Blazor -WebApi:$WebApi -Help:$Help
$DefaultFilesRoot = Get-DefaultSource -DefaultFilesRoot $DefaultFilesRoot
Write-Host "DefaultFiles root: $DefaultFilesRoot"

# Import file handling functions BEFORE using Copy-FileAndFolders
. "$DefaultFilesRoot/Scripts/FileHandling.ps1"

# Check if we have a settings.yaml file in the current directory. if not we copy it from $DefaultFilesRoot
if (-not (Test-Path "settings.yaml")) {
  Write-Host "settings.yaml not found in current directory. Copying from $DefaultFilesRoot..."
  Copy-FileAndFolders -Files @("settings.yaml") -DefaultFilesRoot $DefaultFilesRoot
} else {
  Write-Host "settings.yaml already exists in current directory. Skipping copy."
}

# Load YAML config for directories and files
. "$DefaultFilesRoot/import-yaml-config.ps1"

# Set default switches if none are provided
if (-not ($WebApi -or $Blazor -or $Help -or $Files -or $Arch)) {
    $Arch = $true
    $Files = $true
} elseif ($WebApi -or $Blazor) {
    $Arch = $true
    $Files = $true
}

if ([string]::IsNullOrWhiteSpace($SolutionFile)) {
  $solutionName = Split-Path -Path (Get-Location) -Leaf
  $SolutionFile = Join-Path -Path (Get-Location) -ChildPath "$solutionName.slnx"
}

dotnet new install xunit.v3.templates | Out-Null


if ($taskList -contains "files") {
  New-Directories -Directories $Directories
  Copy-FileAndFolders -Files $toCopy -DefaultFilesRoot $DefaultFilesRoot
  Copy-FileAndFolders -Files $toCopyByForce -DefaultFilesRoot $DefaultFilesRoot -Force $true
}

if ($taskList -contains "arch") {
  $solutionName = Split-Path -Path (Get-Location) -Leaf
  $solutionFile = "$solutionName.slnx"
  if (-not (Test-Path $solutionFile)) {
    dotnet new sln -n $solutionName | Out-Null
    Write-Host "Created solution: $solutionFile"
  } else {
    Write-Host "Solution $solutionFile already exists. Skipping."
  }
}

If ($taskList -contains "arch") {
  New-CleanArchitectureProjects -SolutionName $solutionName
}

If ($taskList -contains "blazor") {
  New-BlazorProject -SolutionName $solutionName
}

if ($taskList -contains "webwebwebapi") {
  New-WebWebApiProject -SolutionName $solutionName
}
