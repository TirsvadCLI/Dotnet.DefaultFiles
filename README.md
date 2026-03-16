# Dotnet.DefaultFiles

This repository provides a template for initializing .NET projects with default files and a setup script. It is designed to help developers quickly scaffold a new solution following Clean Architecture principles, including recommended folder structure, configuration, and build scripts.

## Table of Contents
- [Overview](#overview)
- [Setup & Usage](#setup--usage)
- [Default Files Included](#default-files-included)
- [Workflow](#workflow)

## Overview
Dotnet.DefaultFiles serves as a starting point for .NET development. It includes:
- Standard files for solution and project setup
- PowerShell script for creating a new Clean Architecture project

## Setup & Usage
### Initializing a New Project
1. Create a folder with the name of your new solution.
2. Download the `setupSolutionCleanArchentectureCSharp.ps1` script from this repository and place it in the new folder.
```powershell
  curl -LJO https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/refs/heads/main/setupSolutionCleanArchentectureCSharp.ps1
```
3. Run the provided PowerShell script to scaffold a new solution:
```powershell
./setupSolutionCleanArchentectureCSharp.ps1
```
This will create the recommended folder structure, add default files, and configure the solution for Clean Architecture.

### Customizing
- Edit configuration files as needed (e.g., `global.json`, `Directory.Build.props`).
- Add or update environment variables for your setup.

## Default Files Included
- `global.json`: .NET SDK version management
- `Directory.Build.props` / `Directory.Build.targets`: Solution-wide build settings
- `.gitignore`: Standard ignore rules
- `nuget.config`: Custom NuGet feeds
- Example scripts for setup and build

## Workflow
1. Clone this template repository.
2. Run the setup script to create your new project.
3. Configure environment variables and settings.
4. Build and test your solution using standard .NET CLI commands:
   ```sh
   dotnet build [solutionname].slnx
   dotnet test [solutionname].slnx
   ```
5. Update documentation and configuration as your project evolves.

## Best Practices
- Keep source code in `src/`, tests in `tests/`.
- Use environment variables for sensitive data.
- Update `README.md` with any new setup or usage instructions.

For more details, see the [Microsoft documentation](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/) and Clean Architecture guides.
