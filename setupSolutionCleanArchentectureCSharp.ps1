# This script sets up a clean architecture solution structure for a C# project.
# It creates necessary directories, hard links, and copies files from a default source.

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

# Define the root path where the original files are located
$defaultFilesRoot = "..\Dotnet.DefaultFiles"

$Directories = @(
    ".github",
    "src",
    "tests",
    "docs"
)

$toHardlink = @(
    ".gitignore",
    "LICENSE",
    "Directory.Build.targets",
    ".github/copilot-instructions.md",
    ".github/instructions",
    ".github/prompts"
)

$toCopy = @(
    "Directory.Build.props",
    "Directory.Packages.props",
    ".gitignore"
)

function EnsureDirectoriesExist {
    param (
        [string[]]$Directories
    )
    foreach ($dir in $Directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
            Write-Host "Created $dir directory."
        } else {
            Write-Host "$dir directory already exists. Skipping."
        }
    }
}

function CreateHardLink {
    param (
      [string[]]$HardLinks
    )
    foreach ($link in $HardLinks) {
        $source = Join-Path -Path $defaultFilesRoot -ChildPath $link
        $destination = Join-Path -Path "." -ChildPath $link
        if (Test-Path -Path $destination) {
            Write-Host "File '$destination' already exists. Skipping."
        } elseif ((Test-Path $source) -and ((Get-Item $source).PSIsContainer -eq $false)) {
            New-Item -ItemType HardLink -Path $destination -Target $source
            Write-Host "Created hard link for '$destination'."
        } elseif ((Test-Path $source) -and ((Get-Item $source).PSIsContainer -eq $true)) {
            # If source is a directory, recursively create hard links for all files
            $files = Get-ChildItem -Path $source -Recurse -File
            foreach ($file in $files) {
                $relativePath = $file.FullName.Substring($source.Length).TrimStart('\','/')
                $destFile = Join-Path -Path $destination -ChildPath $relativePath
                $destDir = Split-Path -Path $destFile -Parent
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir | Out-Null
                }
                if (Test-Path $destFile) {
                    Write-Host "File '$destFile' already exists. Skipping."
                } else {
                    New-Item -ItemType HardLink -Path $destFile -Target $file.FullName
                    Write-Host "Created hard link for '$destFile'."
                }
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
                $referenceFolder = $proj.ProjectReference.Split('.')[-1]
                $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($proj.ProjectReference).csproj"
                dotnet add $projFile reference $referenceProjFile
            }
            AddProjectToSolution -ProjectPath (Join-Path -Path $proj.Path -ChildPath "$($proj.Name).csproj")
            Write-Host "Created $($proj.Name) project in $($proj.Path)"
        } else {
            Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
        }
    }
}

function CreateBlazorProject {
    param (
        [string]$SolutionName
    )
    $srcPath = "src"
    $project = @{ Name = "$SolutionName.Web"; Path = "$srcPath/Web"; Template = "blazor"; Options = @("--interactivity",  "Auto"); ProjectReference = "$SolutionName.Application" }
    if (-not (Test-Path $project.Path)) {
        dotnet new $($project.Template) -n $($project.Name) -o $($project.Path) $($project.Options)
        if ($project.ProjectReference) {
            $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name).csproj"
            $referenceFolder = $project.ProjectReference.Split('.')[-1]
            $referenceProjFile = Join-Path -Path "src" -ChildPath "$referenceFolder/$($project.ProjectReference).csproj"
            dotnet add $projFile reference $referenceProjFile
        }
        Write-Host "Created $($proj.Name) project in $($proj.Path)"
    } else {
        Write-Host "$($proj.Name) project already exists in $($proj.Path). Skipping."
    }
    # add all project to solution
    $projFile = Join-Path -Path $project.Path -ChildPath "$($project.Name).csproj"
    if (Test-Path $projFile) {
        dotnet sln add $projFile
        Write-Host "Added $($proj.Name) to solution."
    } else {
        Write-Host "Project file $projFile does not exist. Skipping adding to solution."
    }
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web/$($project.Name).csproj")
    AddProjectToSolution -ProjectPath (Join-Path -Path $srcPath -ChildPath "Web/$SolutionName.Web/$($project.Name).Client.csproj")
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
    $archivePath = "$defaultFilesRoot.tar.gz"
    curl -L -o $archivePath https://github.com/TirsvadCLI/Dotnet.DefaultFiles/archive/refs/tags/v0.1.0.tar.gz
    tar -xzf $archivePath -C ..
    $extractedDir = "..\Dotnet.DefaultFiles-0.1.0"
    if (Test-Path $extractedDir) {
        Rename-Item -Path $extractedDir -NewName (Split-Path $defaultFilesRoot -Leaf)
    }
    Remove-Item $archivePath
}

if ($taskList -contains "files") {
    EnsureDirectoriesExist -Directories $Directories
    CreateHardLink -HardLinks $toHardlink
    CopyDefaultFiles -Files $toCopy
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
