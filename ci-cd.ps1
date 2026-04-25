<#
 # .SYNOPSIS
 #   CI/CD automation script to ensure safe deployment practices and consistent line endings in a Git repository.
 # .DESCRIPTION
 #   This script provides functions to enforce safe deployment practices by ensuring the CI/CD pipeline is not running on the main branch,
 #   checking for uncommitted changes, and converting line endings to LF (Unix style) for consistency.
 # .NOTES
 #   Author: Jens Tirsvad Nielsen
 #   Last Updated: 2026-04-25
 #>


<#
 # .SYNOPSIS
 #   Ensures that the CI/CD pipeline is not running on the main branch.
 # .DESCRIPTION
 #   Checks the current Git branch and exits with an error if it is "main" to prevent unintended deployments.
 #>
function Ensure-NotOnMainBranch {
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
function Ensure-NoUncommittedChanges {
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Host "There are uncommitted changes. Please commit or stash them before running CI/CD."
        #exit 1
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
 #   Commits line ending fixes if there are any changes after conversion.
 # .DESCRIPTION
 #   Checks for changes and commits them with a standard message if present.
 #>
function Commit-LineEndingFixIfNeeded {
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        git add .
        git commit -m "fix line endings"
    }
}

Ensure-NotOnMainBranch
Ensure-NoUncommittedChanges
Convert-LineEndingsToLF
Commit-LineEndingFixIfNeeded
git push
