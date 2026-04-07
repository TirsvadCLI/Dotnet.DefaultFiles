<#
.SYNOPSIS
    Sets up a Clean Architecture solution structure for a C# project.

.DESCRIPTION
    This script automates the creation of a Clean Architecture .NET solution, including directory structure, project scaffolding, and default file setup.
    It supports initializing solution files, creating hard links and copies of default files, and adding Blazor or Web API projects as needed.
    The script is intended for use in repositories following the Tirsvad Clean Architecture conventions.

.PARAMETER Files
    Switch. If specified, only creates directories, hardlinks, and copies default files.

.PARAMETER Arch
    Switch. If specified, only sets up Clean Architecture solution and projects (Domain, Application, Infrastructure).

.PARAMETER Blazor
    Switch. If specified, sets up Clean Architecture and adds Blazor WebAssembly and server projects (frontend/backend) including API.

.PARAMETER Api
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
    ./setupSolutionCleanArchentectureCSharp.ps1 -blazor
    # Sets up Clean Architecture and adds Blazor frontend/backend projects.

.NOTES
    - Requires Git and .NET SDK installed.
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
  [switch]$Api,
  [switch]$Help,
  [string]$DefaultFilesRoot,
  [string]$SolutionFile,
  [String]$Framework = "net10.0"
)

if ($lower -in @('blazor','api','arch','files','help')) {
  switch ($lower) {
    'blazor' { $Blazor = $true; $Arch = $true; $Files = $true }
    'api'    { $Api    = $true; $Arch = $true; $Files = $true }
    'arch'   { $Arch   = $true }
    'files'  { $Files  = $true }
    'help'   { $Help   = $true }
  }
} else {
  $Arch = $true
  $Files = $true
}

<#
    Creates a list of tasks to perform based on the provided switches.
    .PARAMETER Files
        Switch. If specified, includes file setup tasks.
    .PARAMETER Arch
        Switch. If specified, includes architecture setup tasks.
    .PARAMETER Blazor
        Switch. If specified, includes Blazor project setup tasks.
    .PARAMETER Api
        Switch. If specified, includes API project setup tasks.
    .PARAMETER Help
        Switch. If specified, includes help task.
#>
function Create-TaskList {
  param (
    [switch]$Files,
    [switch]$Arch,
    [switch]$Blazor,
    [switch]$Api,
    [switch]$Help
  )
  $taskList = @()
  if ($Blazor) {
    $taskList += "blazor"
  } 
  if ($Api) {
    $taskList += "api"
  } 
  if ($Arch) {
    $taskList += "arch"
  } 
  if ($Files) {
    $taskList += "files"
  } 
  return $taskList
}

<#
    Displays usage instructions for the script.
#>
function Write-help {
  Write-Host "Usage: setupSolutionCleanArchentectureCSharp.ps1 Command"
  Write-Host "Switches:"
  Write-Host "  files   - Only create directories, hardlink, and copy default files"
  Write-Host "  arch    - Only setup Clean Architecture solution and projects (Domain, Application, Infrastructure)"
  Write-Host "  blazor  - Add Blazor WebAssembly and server project (frontend/backend) including architecture setup and files"
  Write-Host "  api     - Add Web API project (backend) including architecture setup and files"
  Write-Host "  help    - Show this help message"
}

<#
  This function checks for the presence of the default files directory.
  If it doesn't exist, it clones the repository from GitHub.
  If it does exist, it pulls the latest changes.
  If a custom path is provided, it validates that the path exists.
#>
<#
    Checks for the presence of the default files directory.
    If it doesn't exist, clones the repository from GitHub.
    If it does exist, pulls the latest changes.
    If a custom path is provided, validates that the path exists.
    .PARAMETER DefaultFilesRoot
        String. Optional path to the default files root directory.
#>
function Fetch-DefaultSource {
  param (
    [string]$DefaultFilesRoot
  )
  if ([string]::IsNullOrWhiteSpace($DefaultFilesRoot)) {
    #$Subfolder =  Get-Item -Path (Join-Path -Path (Get-Location) -ChildPath "..").FullName
    $parentPath = Join-Path -Path (Get-Location) -ChildPath ".."
    if (Test-Path $parentPath) {
        $Subfolder = (Get-Item -Path $parentPath).FullName
        Write-Host "Parent path found: $Subfolder"
    } else {
        $Subfolder = ""
        Write-Host "Parent path '$parentPath' does not exist. Cannot determine subfolder. Exiting."
        exit(1)
    }
    Write-Host "No DefaultFilesSrc provided. Using default path: $Subfolder\\TirsvadCLI.Dotnet.DefaultFiles"
    $DefaultFilesRoot = Join-Path -Path "$Subfolder" -ChildPath "TirsvadCLI.Dotnet.DefaultFiles"
    # Define the root path where the original files are located
    if (-not (Test-Path "$DefaultFilesRoot")) {
      Write-Host "TirsvadCLI.Dotnet.DefaultFiles not found. Cloning from GitHub..."
      Push-Location ..
      git clone https://github.com/TirsvadCLI/Dotnet.DefaultFiles.git $DefaultFilesRoot | Out-Null
      #Write-Host $cloneOutput
      Pop-Location
    } else {
      Write-Host "TirsvadCLI.Dotnet.DefaultFiles already exists. Pulling latest changes from GitHub..."
      Push-Location ../TirsvadCLI.Dotnet.DefaultFiles
      git pull origin main | Out-Null
      #Write-Host $pullOutput
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

# Print help message and exit if argument is 'help'
if ($Help) {
  Write-help
  exit
}

$taskList = Create-TaskList -Files:$Files -Arch:$Arch -Blazor:$Blazor -Api:$Api -Help:$Help
$DefaultFilesRoot = Fetch-DefaultSource -DefaultFilesRoot $DefaultFilesRoot

Write-Host "DefaultFiles root: $DefaultFilesRoot"

if ([string]::IsNullOrWhiteSpace($SolutionFile)) {
  $solutionName = Split-Path -Path (Get-Location) -Leaf
  $SolutionFile = Join-Path -Path (Get-Location) -ChildPath "$solutionName.slnx"
}

$Directories = @(
  ".github",
  ".github/instructions",
  ".github/prompts",
  ".github/agents",
  "docs/quality-criteria",
  "docs/quality-criteria/hld",
  "docs/quality-criteria/lld",
  "docs/quality-criteria/code",
  "src",
  "tests",
  "docs",
  "docs/doxygen",
  "docs/adr",
  "docs/use-cases"
)

$toCopyByForce = @(
  ".github/copilot-instructions.md",
  ".github/instructions",
  ".github/prompts",
  ".github/agents",
  "docs/quality-criteria"
)

$toCopy = @(
  ".gitignore",
  "Directory.Build.targets",
  "Directory.Build.props",
  "Directory.Packages.props",
  "LICENSE",
  ".editorconfig"
)

$cleanArchitectureDomainDirectories = @(
  "src/Domain/Entities",
  "src/Domain/Interfaces",
  "src/Domain/ValueObjects"
)

$cleanArchitectureApplicationDirectories = @(
  "src/Application/Interfaces",
  "src/Application/Services",
  "src/Application/Managers",
  "src/Application/Helpers",
  "src/Application/DTOs",
  "src/Application/Mappers"
)

$cleanArchitectureInfrastructureDirectories = @(
  "src/Infrastructure/Persistents",
  "src/Infrastructure/Persistents/Configurations",
  "src/Infrastructure/Repositories"
)

<#
    Creates directories from a list. Optionally adds a .gitkeep file to each directory.
    .PARAMETER Directories
        Array of directory paths to create.
    .PARAMETER AddGitkeep
        Boolean. If true, adds a .gitkeep file to each directory.
#>
function CreateDirectories {
  param (
    [string[]]$Directories,
    [bool]$AddGitkeep = $false
  )
  foreach ($dir in $Directories) {
    if (-not (Test-Path $dir)) {
      New-Item -ItemType Directory -Path $dir | Out-Null
      if ($AddGitkeep) {
        $gitkeepPath = Join-Path -Path $dir -ChildPath ".gitkeep"
        New-Item -ItemType File -Path $gitkeepPath | Out-Null
      }
      Write-Host "Created $dir directory."
    } else {
      Write-Host "$dir directory already exists. Skipping."
    }
  }
}

function CopyFileAndFolders {
  param (
    [string[]]$Files,
    [bool]$Force = $false
  )

  foreach ($file in $Files) {
    Write-Host "Processing '$file'..."
    $source = Join-Path -Path $DefaultFilesRoot -ChildPath $file
    $destination = Join-Path -Path "." -ChildPath $file
    if (Test-Path -Path $source) {
      if ((Get-Item $source).PSIsContainer) {
        if ($Force) {
          Copy-Item -Path "$source" -Destination "$destination" -Recurse -Force  | Out-Null
          Write-Host "Copied directory '$file' with force."
        } else {
          Copy-Item -Path "$source" -Destination "$destination" -Recurse | Out-Null
          Write-Host "Copied directory '$file'."
        }
      } else {
        if ($Force) {
          Copy-Item -Path "$source" -Destination "$destination" -Force | Out-Null
          Write-Host "Copied file '$file' with force."
        } else {
          Copy-Item -Path "$source" -Destination "$destination" | Out-Null
          Write-Host "Copied file '$file'."
        }
      }
    } else {
      Write-Host "Source '$source' does not exist. Skipping."
      exit(1)
    }
  }
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
function AddProjectToSolution {
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
function CreateCleanArchitectureProjects {
  param (
      [string]$SolutionName
  )
  $srcPath = "src"
  $testsPath = "tests"
  $projects = @(
    @{ Name = "$SolutionName.Domain"; Path = "$srcPath/Domain"; Template = "classlib"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Application"; Path = "$srcPath/Application"; Template = "classlib"; ProjectReference = "$SolutionName.Domain"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Infrastructure"; Path = "$srcPath/Infrastructure"; Template = "classlib"; ProjectReference = "$SolutionName.Application"; SolutionFolder = "src" },
    @{ Name = "$SolutionName.Domain.Tests"; Path = "$testsPath/Domain.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Domain"; SolutionFolder = "tests" },
    @{ Name = "$SolutionName.Application.Tests"; Path = "$testsPath/Application.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Application"; SolutionFolder = "tests" },
    @{ Name = "$SolutionName.Infrastructure.Tests"; Path = "$testsPath/Infrastructure.Tests"; Template = "xunit3"; ProjectReference = "$SolutionName.Infrastructure"; SolutionFolder = "tests" }
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
  CreateDirectories -Directories $cleanArchitectureDomainDirectories -AddGitkeep $true
  CreateDirectories -Directories $cleanArchitectureApplicationDirectories -AddGitkeep $true
  CreateDirectories -Directories $cleanArchitectureInfrastructureDirectories -AddGitkeep $true
}

<#
    Creates Blazor WebAssembly and Server projects and adds them to the solution.
    .PARAMETER SolutionName
        Name of the solution (used for project naming).
#>
function CreateBlazorProject {
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
function CreateWebApiProject {
  param (
    [string]$SolutionName
  )
  $srcPath = "src"
  $project = @{ Name = "$SolutionName.WebApi"; Path = "$srcPath/WebApi"; Template = "webapi"; Options = @("--use-program-main"); ProjectReference = "$SolutionName.Application" }
  if (-not (Test-Path $project.Path)) {
    dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options) | Out-Null
    if ($project.ProjectReference) {
      $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name).csproj"
      $referenceFolder = $project.ProjectReference.Split('.')[-1]
      $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
      dotnet add $projFile reference $referenceProjFile | Out-Null
    }
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "WebApi/$($project.Name).csproj") -SolutionFolder "src" -SolutionFile "$SolutionFile"
    Write-Host "Created $($proj.Name) project in $($proj.Path)"
  } else {
    Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
  }
}

dotnet new install xunit.v3.templates | Out-Null

if ($taskList -contains "files") {
  CreateDirectories -Directories $Directories
  CopyFileAndFolders -Files $toCopy
  CopyFileAndFolders -Files $toCopyByForce -Force $true
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
  CreateCleanArchitectureProjects -SolutionName $solutionName
}

If ($taskList -contains "blazor") {
  CreateBlazorProject -SolutionName $solutionName
}

if ($taskList -contains "api") {
  CreateWebApiProject -SolutionName $solutionName
}
