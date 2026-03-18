<#
.SYNOPSIS
    Sets up a Clean Architecture solution structure for a C# project.

.DESCRIPTION
    This script automates the creation of a Clean Architecture .NET solution, including directory structure, project scaffolding, and default file setup.
    It supports initializing solution files, creating hard links and copies of default files, and adding Blazor or Web API projects as needed.
    The script is intended for use in repositories following the Tirsvad Clean Architecture conventions.

.PARAMETER Command
    The main command to execute. Supported values:
        files   - Only create directories, hardlink, and copy default files.
        arch    - Only setup Clean Architecture solution and projects (Domain, Application, Infrastructure).
        all     - Run both files and architecture setup (default).
        blazor  - Add Blazor WebAssembly and server project (frontend/backend) including API.
        api     - Add Web API project (backend) including architecture setup and files.
        help    - Show usage instructions.

.EXAMPLE
    ./setupSolutionCleanArchentectureCSharp.ps1
    # Runs the default setup: creates directories, copies files, and sets up Clean Architecture projects.

.EXAMPLE
    ./setupSolutionCleanArchentectureCSharp.ps1 files
    # Only creates directories, hardlinks, and copies default files.

.EXAMPLE
    ./setupSolutionCleanArchentectureCSharp.ps1 blazor
    # Sets up Clean Architecture and adds Blazor frontend/backend projects.

.NOTES
    - Requires Git and .NET SDK installed.
    - Clones or updates the Dotnet.DefaultFiles repository for default file templates.
    - Solution file is named [solutionname].slnx, matching the root folder name.
    - Follows conventions described in .github/copilot-instructions.md.

#>

# Print help message and exit if argument is 'help'
if ($args.Count -gt 0 -and $args[0].ToLower() -eq "help") {
    Write-Host "Usage: setupSolutionCleanArchentectureCSharp.ps1 Command"
    Write-Host "Commands:"
    Write-Host "  Files and solution handling (files, arch, all)"
    Write-Host "    files - Only create directories, hardlink, and copy default files"
    Write-Host "    arch  - Only setup Clean Architecture solution and projects (Domain, Application, Infrastructure)"
    Write-Host "    all   - Run both files and architecture setup (default)"
    Write-Host "  Add project"
    Write-Host "    blazor - Add Blazor WebAssembly and server project (frontend/backend) include api"
    Write-Host "    api    - Add Web API project (backend) include architecture setup and files"
    Write-Host "  help  - Show this help message"
    exit
}

$taskList = @()

# Add Argument Command to taskList using a case structure
if ($args.Count -gt 0) {
    switch ($args[0].ToLower()) {
        'files'   { $taskList += 'files' }
        'arch'    { $taskList += 'arch' }
        'all'     { $taskList += @('files', 'arch') }
        'blazor'  { $taskList += @('files', 'arch', 'blazor', 'api') }
        'api'     { $taskList += @('files', 'arch', 'api') }
        default   { $taskList += $args[0].ToLower() }
    }
} else {
    $taskList += 'all'
}

$defaultFilesProject = "Dotnet.DefaultFiles"

if (-not (Test-Path "$defaultFilesProject")) {
    Write-Host "Dotnet.DefaultFiles not found. Cloning from GitHub..."
    Push-Location ..
    git clone https://github.com/TirsvadCLI/Dotnet.DefaultFiles.git
    Pop-Location
} else {
    Write-Host "Dotnet.DefaultFiles already exists. Pulling latest changes from GitHub..."
    Push-Location ..
    git pull origin main
    Pop-Location
}

# Define the root path where the original files are located
#$defaultFilesRoot = "..\Dotnet.DefaultFiles"
# get real path of defaultFilesRoot
$defaultFilesRoot = (Get-Item "..\$defaultFilesProject").FullName

$Directories = @(
    ".github",
    ".github/instructions",
    ".github/prompts",
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
        [string]$ProjectPath
    )
    $solutionName = Split-Path -Path (Get-Location) -Leaf
    $solutionFile = "$solutionName.slnx"
    if (Test-Path $solutionFile) {
        dotnet sln add $ProjectPath
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
        @{ Name = "$SolutionName.Domain"; Path = "$srcPath/Domain"; Template = "classlib" },
        @{ Name = "$SolutionName.Application"; Path = "$srcPath/Application"; Template = "classlib"; ProjectReference = "$SolutionName.Domain" },
        @{ Name = "$SolutionName.Infrastructure"; Path = "$srcPath/Infrastructure"; Template = "classlib"; ProjectReference = "$SolutionName.Application" },
        @{ Name = "$SolutionName.Application.Tests"; Path = "$testsPath/Application.Tests"; Template = "xunit"; ProjectReference = "$SolutionName.Application" },
        @{ Name = "$SolutionName.Infrastructure.Tests"; Path = "$testsPath/Infrastructure.Tests"; Template = "xunit"; ProjectReference = "$SolutionName.Infrastructure" }
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
            AddProjectToSolution -ProjectPath (Join-Path -Path $proj.Path -ChildPath "$($proj.Name).csproj")
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
    $project = @{ Name = "$SolutionName"; Path = "$srcPath/Web"; Template = "blazor"; Options = @("--interactivity",  "Auto"); ProjectReference = "$SolutionName.Application" }
    if (-not (Test-Path "$($project.Path)")) {
        dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options)
        if ($project.ProjectReference) {
            $projFile = Join-Path -Path $project.Path -ChildPath "/$($project.Name).Web/$($project.Name).csproj"
            $referenceFolder = $project.ProjectReference.Split('.')[-1]
            $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
            dotnet add $projFile reference $referenceProjFile
        }
        Write-Host "Created $($proj.Name) project in $($proj.Path)"
    } else {
        Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
    }
    # add all project to solution
    $projFile = Join-Path -Path "Web" -ChildPath "TirsvadCLI.TestingScript.Web/$($project.Name).csproj"
    if (Test-Path $projFile) {
        dotnet sln add $projFile
        Write-Host "Added $($proj.Name) to solution."
    } else {
        Write-Host "Project file $projFile does not exist. Skipping adding to solution."
    }
    Write-Host (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web/$($project.Name).csproj")
    Write-Host (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web.Client/$($project.Name).client.csproj")
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web/$($project.Name).csproj")
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web.Client/$($project.Name).Client.csproj")
}

function CreateWebApiProject {
    param (
        [string]$SolutionName
    )
    $srcPath = "src"
    $project = @{ Name = "$SolutionName.WebApi"; Path = "$srcPath/WebApi"; Template = "webapi"; ProjectReference = "$SolutionName.Application" }
    if (-not (Test-Path $project.Path)) {
        dotnet new $($project.Template) -n $($project.Name) -o $($project.Path)
        if ($project.ProjectReference) {
            $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name).csproj"
            $referenceFolder = $project.ProjectReference.Split('.')[-1]
            $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
            dotnet add $projFile reference $referenceProjFile
        }
        AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "WebApi/$($project.Name).csproj")
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
