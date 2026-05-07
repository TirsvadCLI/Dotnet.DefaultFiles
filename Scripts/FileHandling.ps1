# File handling utilities for Clean Architecture setup
# Exports: Build-Directories, CopyFileAndFolders, Get-DefaultSource

function New-Directories {
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

function Copy-FileAndFolders {
  param (
    [string[]]$Files,
    [string]$DefaultFilesRoot,
    [bool]$Force = $false
  )
  foreach ($file in $Files) {
    Write-Host "Processing '$file'..."
    $source = Join-Path -Path $DefaultFilesRoot -ChildPath $file
    $destination = Join-Path -Path "." -ChildPath $file
    if (Test-Path -Path $source) {
      if ((Get-Item $source).PSIsContainer) {
        $source = Join-Path -Path $source -ChildPath "*"
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
