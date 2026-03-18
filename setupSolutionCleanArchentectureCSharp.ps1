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

.PARAMETER blazor
    Switch. If specified, sets up Clean Architecture and adds Blazor WebAssembly and server projects (frontend/backend) including API.

.PARAMETER api
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
  [switch]$blazor,
  [switch]$api,
  [switch]$Help,
  [string]$DefaultFilesSrc
)

# Print help message and exit if argument is 'help'
if ($Help) {
  Write-Host "Usage: setupSolutionCleanArchentectureCSharp.ps1 Command"
  Write-Host "Switches:"
  Write-Host "  files   - Only create directories, hardlink, and copy default files"
  Write-Host "  arch    - Only setup Clean Architecture solution and projects (Domain, Application, Infrastructure)"
  Write-Host "  blazor  - Add Blazor WebAssembly and server project (frontend/backend) including architecture setup and files"
  Write-Host "  api     - Add Web API project (backend) including architecture setup and files"
  Write-Host "  help    - Show this help message"
  exit
}

$taskList = @()

# Add Argument Command to taskList using a case structure
if ($blazor) {
  $taskList += "blazor"
  $taskList += "arch"
  $taskList += "files"
} elseif ($api) {
  $taskList += "api"
  $taskList += "arch"
  $taskList += "files"
} elseif ($Arch) {
  $taskList += "arch"
} elseif ($Files) {
  $taskList += "files"
} else {
  # Default to all if no specific command is provided
  $taskList += "files"
  $taskList += "arch"
}

if( "$DefaultFilesSrc" -ne "") {
  if (!Test-Path "$DefaultFilesSrc") {
    Write-Host "Provided DefaultFilesSrc path '$DefaultFilesSrc' does not exist. Exiting."
  }
} else {
  $subfolder = Split-Path -Path (Get-Location) -Leaf
  $defaultFilesProject = join-path -path $subfolder -childpath "TirsvadCLI.Dotnet.DefaultFiles"
}


# Define the root path where the original files are located
if ($DefaultFilesSrc) {
  $defaultFilesRoot = $DefaultFilesSrc
  Write-Host "Using custom DefaultFilesSrc: $defaultFilesRoot"
} else {
  if (-not (Test-Path "$defaultFilesProject")) {
    Write-Host "TirsvadCLI.Dotnet.DefaultFiles not found. Cloning from GitHub..."
    Push-Location ..
    git clone https://github.com/TirsvadCLI/Dotnet.DefaultFiles.git
    mv "Dotnet.DefaultFiles" "$defaultFilesProject"
    Pop-Location
  } else {
    Write-Host "TirsvadCLI.Dotnet.DefaultFiles already exists. Pulling latest changes from GitHub..."
    Push-Location ..
    git pull origin main
    Pop-Location
  }
  $defaultFilesRoot = (Get-Item "..\$defaultFilesProject").FullName
}

$Directories = @(
  ".github",
  ".github/instructions",
  ".github/prompts",
  ".github/agents",
  "src",
  "tests",
  "docs",
  "docs/doxygen"
)

$toHardlink = @(
  ".github/copilot-instructions.md",
  ".github/instructions",
  ".github/prompts",
  ".github/agents"
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

function CreateHardLinksForFiles {
  param (
    [string]$source,
    [string]$destination
  )
  if (Test-Path -Path $destination) {
    Write-Host "File '$destination' already exists. Skipping."
  } else {
    New-Item -ItemType HardLink -Path $destination -Target $source
    Write-Host "Created hard link for '$destination'."
  }
}

function CreateHardLink {
  param (
    [string[]]$HardLinks
  )
  foreach ($link in $HardLinks) {
    $source = Join-Path -Path $defaultFilesRoot -ChildPath $link
    Write-Host "Processing '$link' for hard linking..."
    Write-Host "Source path for '$link' is '$source'."
    $destination = Join-Path -Path "." -ChildPath $link
    Write-Host "Destination path for '$link' is '$destination'."
    if ((Test-Path $source) -and ((Get-Item $source).PSIsContainer -eq $false)) {
      CreateHardLinksForFiles -Source $source -Destination $destination
    } elseif ((Test-Path $source) -and ((Get-Item $source).PSIsContainer -eq $true)) {
      Write-Host "Source '$source' is a directory. Recursively creating hard links for all files in the directory."
      $files = Get-ChildItem -Path $source -Recurse -File
      foreach ($file in $files) {
        # get relative path after folder $defaultFilesProject in $file
        $index = $file.FullName.IndexOf($defaultFilesProject)
        if ($index -ge 0) {
          $relativePath = $file.FullName.Substring($index + $defaultFilesProject.Length).TrimStart('\','/')
        } else {
          $relativePath = $file.FullName
        }
        #Write-Host "Processing file '$($file.FullName)' for hard linking..."
        $destination = Join-Path -Path "." -ChildPath $relativePath
        if (Test-Path $destination) {
          $destinationFullPath = (Resolve-Path $destination).Path
        } else {
          $destinationFullPath = Join-Path -Path (Get-Location) -ChildPath $relativePath
        }
        Write-Host "Source file '$($file.FullName)' will be linked to '$destinationFullPath'."
        CreateHardLinksForFiles -Source $file.FullName -Destination $destinationFullPath
      }
    } else {
      Write-Host "Source '$source' does not exist. Skipping."
    }
  }
}

function CopyDefaultFiles {
  param (
    [string[]]$Files
  )
  foreach ($file in $Files) {
    $source = Join-Path -Path $defaultFilesRoot -ChildPath $file
    $destination = Join-Path -Path "." -ChildPath $file
    if (Test-Path -Path $destination) {
      Write-Host "File '$destination' already exists. Skipping."
    } else {
      Copy-Item -Path $source -Destination $destination
      Write-Host "Copied '$file'."
    }
  }
}

function AddProjectToSolution {
  param (
    [string]$ProjectPath,
    [string]$SolutionFolder
  )
  $solutionName = Split-Path -Path (Get-Location) -Leaf
  $solutionFile = "$solutionName.slnx"
  if (Test-Path $solutionFile) {
    if ($SolutionFolder) {
      dotnet sln $solutionFile add $ProjectPath --solution-folder $SolutionFolder
    } else {
      dotnet sln $solutionFile add $ProjectPath
    }
    Write-Host "Added project at '$ProjectPath' to solution '$solutionFile'."
  } else {
    Write-Host "Solution file '$solutionFile' does not exist. Cannot add project."
  }
}

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
      dotnet new $($proj.Template) -n $($proj.Name) -o $($proj.Path)
      if ($proj.ProjectReference) {
        $projFile = Join-Path -Path $proj.Path -ChildPath "$($proj.Name).csproj"
        $referenceFolder = ($proj.ProjectReference.Split('.') | Select-Object -Last 1)
        $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($proj.ProjectReference).csproj"
        dotnet add $projFile reference $referenceProjFile
      }
      AddProjectToSolution -ProjectPath (Join-Path -Path $proj.Path -ChildPath "$($proj.Name).csproj") -SolutionFolder $proj.SolutionFolder
      Write-Host "Created $($proj.Name) project in $($proj.Path)"
    } else {
      Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
    }
  }
  CreateDirectories -Directories $cleanArchitectureDomainDirectories -AddGitkeep $true
  CreateDirectories -Directories $cleanArchitectureApplicationDirectories -AddGitkeep $true
  CreateDirectories -Directories $cleanArchitectureInfrastructureDirectories -AddGitkeep $true
}

function CreateBlazorProject {
  param (
    [string]$SolutionName
  )
  Write-Host "Creating Blazor WebAssembly and Server projects for $SolutionName..."
  $srcPath = "src"
  $project = @{ Name = "$SolutionName.Web"; Path = "$srcPath/Web"; Template = "blazor"; Options = @("--interactivity",  "Auto", "--use-program-main"); ProjectReference = "$SolutionName.Application" }
  if (-not (Test-Path "$($project.Path)")) {
    dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options)
    if ($project.ProjectReference) {
      $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name)/$($project.Name).csproj"
      $referenceFolder = $project.ProjectReference.Split('.')[-1]
      $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
      dotnet add $projFile reference $referenceProjFile
    }
    Write-Host "Created $($proj.Name) project in $($proj.Path)"
  } else {
    Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
  }
  # add all project to solution
  $projFile = Join-Path -Path "Web" -ChildPath "$project.Name.Web/$($project.Name).csproj"
  if (Test-Path $projFile) {
    dotnet sln add $projFile
    Write-Host "Added $($proj.Name) to solution."
  } else {
    Write-Host "Project file $projFile does not exist. Skipping adding to solution."
  }
  Write-Host (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName/$($project.Name).csproj")
  Write-Host (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Client/$($project.Name).client.csproj")
  AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web/$($project.Name).csproj") -SolutionFolder "src"
  AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web.Client/$($project.Name).Client.csproj") -SolutionFolder "src"
}

function CreateWebApiProject {
  param (
    [string]$SolutionName
  )
  $srcPath = "src"
  $project = @{ Name = "$SolutionName.WebApi"; Path = "$srcPath/WebApi"; Template = "webapi"; Options = @("--use-program-main"); ProjectReference = "$SolutionName.Application" }
  if (-not (Test-Path $project.Path)) {
    dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options)
    if ($project.ProjectReference) {
      $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name).csproj"
      $referenceFolder = $project.ProjectReference.Split('.')[-1]
      $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
      dotnet add $projFile reference $referenceProjFile
    }
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "WebApi/$($project.Name).csproj") -SolutionFolder "src"
    Write-Host "Created $($proj.Name) project in $($proj.Path)"
  } else {
    Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
  }
}

if (-not (Test-Path $defaultFilesRoot)) {
  Write-Host "Dotnet.DefaultFiles not found. Cloning from GitHub..."
  Push-Location ..
  git clone https://github.com/TirsvadCLI/Dotnet.DefaultFiles.git
  Pop-Location
}

dotnet new install xunit.v3.templates

if ($taskList -contains "files") {
  CreateDirectories -Directories $Directories
  CopyDefaultFiles -Files $toCopy
  CreateHardLink -HardLinks $toHardlink
}

if ($taskList -contains "arch") {
  $solutionName = Split-Path -Path (Get-Location) -Leaf
  $solutionFile = "$solutionName.slnx"
  if (-not (Test-Path $solutionFile)) {
    dotnet new sln -n $solutionName
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
