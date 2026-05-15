<#
 # .SYNOPSIS
 #  CI/CD automation script for the Slottets Drifttavlen project.
 # .DESCRIPTION
 #   This script automates the build, test, and deployment process using Docker and PowerShell.
 #   It also ensures all text files use LF line endings before running CI/CD steps.
 # .NOTES
 #   Author: Jens Tirsvad Nielsen
 #   Last Updated: 2026-05-15
 #>

# Install powershell-yaml module if not already installed
Install-Module -Name powershell-yaml -Scope CurrentUser -Force

<#
 # .SYNOPSIS
 #   Get settings from settings.yaml file.
 # .DESCRIPTION
 #   Reads the settings.yaml file and returns its content as a raw string.
 #>
function Get-Settings {
    $settingsPath = "settings.yaml"
    if (Test-Path $settingsPath) {
        return Get-Content $settingsPath -Raw | ConvertFrom-Yaml
    } else {
        Write-Host "settings.yaml not found. Please create the file with the necessary configuration."
        exit 1
    }
}

<#
 # .SYNOPSIS
 #   Ensures that the CI/CD pipeline is not running on the main branch.
 # .DESCRIPTION
 #   Checks the current Git branch and exits with an error if it is "main" to prevent unintended deployments.
 #>
function Test-NotOnMainBranch {
    $branch = git rev-parse --abbrev-ref HEAD
    if ($branch -eq "main") {
        Write-Host "CI/CD should not run on the main branch. Exiting."
        exit 1
    }
}

<#
 # .SYNOPSIS
 #   Ensures there are no uncommitted changes in the repository.
 # .DESCRIPTION
 #   Checks for uncommitted changes and exits with an error if any are found.
 #>
function Test-NoUncommittedChanges {
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Host "There are uncommitted changes. Please commit or stash them before running CI/CD."
        exit 1
    }
}

<#
 # .SYNOPSIS
 #   Converts all text file line endings in the repository to LF (Unix style).
 # .DESCRIPTION
 #   Recursively scans all files (excluding .git directory) and replaces CRLF or CR line endings with LF.
 #>
function Convert-LineEndingsToLF {
    $gitFiles = git ls-files
    foreach ($relativePath in $gitFiles) {
        $fullPath = Join-Path -Path (Get-Location) -ChildPath $relativePath
        if (Test-Path $fullPath) {
            $lines = Get-Content $fullPath
            $lfContent = ($lines -join "`n") + "`n"
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($fullPath, $lfContent, $utf8NoBom)
        }
    }
    Write-Host "All git-tracked file line endings converted to LF."
}

<#
 # .SYNOPSIS
 #   Starts the SQL Server container if it is not already running.
 # .DESCRIPTION
 #   Checks the status of the specified SQL Server container and starts it using Docker Compose if it
 #>
function Start-SqlServer {
    param(
        [string]$ContainerName
    )
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "No SQL Server container name specified. Skipping SQL Server startup."
        return
    }
    $containerStatus = docker ps --filter "name=$ContainerName" --filter "status=running" --format "{{.Names}}"
    if ($containerStatus -eq $ContainerName) {
        # The container is running
    } else {
        # The container is NOT running
        Start-Process "docker-compose" -ArgumentList "up --menu=false --build $ContainerName"
    }
}

<#
 # .SYNOPSIS
 #   Retrieves the database container name from settings.
 # .DESCRIPTION
 #   Extracts the database container name from the settings object, if it exists.
 #>
function Get-DatabaseContainerName {
    param (
        [string]$settings
    )
    if ($settings.Docker -and $settings.Docker.Container -and $settings.Docker.Container.Database) {
        return $settings.Docker.Container.Database.Trim()
    }
    return $null
}

function Get-TestContainerName {
    param (
        [string]$settings
    )
    if ($settings.Docker -and $settings.Docker.Container -and $settings.Docker.Container.Test) {
        return $settings.Docker.Container.Test.Trim()
    }
    return $null
}

<#
 # .SYNOPSIS
 #   Runs the tests stage using Docker Compose and handles errors.
 # .DESCRIPTION
 #   Executes the tests-stage target and exits if the tests fail.
 #>
function Invoke-TestsStage {
    param(
        [string]$ContainerName
    )
    docker-compose --profile test up --menu=false --build --exit-code-from $ContainerName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Tests failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

<#
 # .SYNOPSIS
 #   Commits line ending fixes if there are any changes after conversion.
 # .DESCRIPTION
 #   Checks for changes and commits them with a standard message if present.
 #>
function Invoke-CommitLineEndingFixIfNeeded {
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        git add .
        git commit --amend --no-edit
    }
}

########################################
# Main CI/CD Script
########################################

# Auto setup remote tracking branches on push
git config --global push.autoSetupRemote true

$settings = Get-Settings

Test-NotOnMainBranch
Test-NoUncommittedChanges
Convert-LineEndingsToLF

# Start SQL Server only if Database:ContainerName is not empty
$dbContainerName = Get-DatabaseContainerName $settings
if (-not [string]::IsNullOrWhiteSpace($dbContainerName)) {
    Start-SqlServer -ContainerName $dbContainerName
}

$testContainerName = Get-TestContainerName $settings
if (-not [string]::IsNullOrWhiteSpace($testContainerName)) {
    Invoke-TestsStage -ContainerName $testContainerName
}

Invoke-CommitLineEndingFixIfNeeded
git push
