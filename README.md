[![Downloads][Downloads-shield]][Downloads-url][![Contributors][contributors-shield]][contributors-url][![Forks][forks-shield]][forks-url][![Stargazers][stars-shield]][stars-url][![Issues][issues-shield]][issues-url][![License][license-shield]][license-url][![LinkedIn][linkedin-shield]][linkedin-url]

# ![logo][logo] Dotnet.DefaultFiles

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

#### Example with a blazor project:

We will create a new folder named `MyBlazorApp`, download the setup script, and run it to scaffold a new Blazor project with Clean Architecture principles:

```powershell
mkdir MyBlazorApp
cd MyBlazorApp
curl -LJO https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/refs/heads/main/setupSolutionCleanArchentectureCSharp.ps1
./setupSolutionCleanArchentectureCSharp.ps1 blazor
```

The folder structure will be created as follows:

```plaintext
MyBlazorApp/
├── src/
│   ├── Domain/                                     # Business logic and entities
│   ├── Application/                                # Application services and use cases
│   ├── Infrastructure/                             # Data access, external services
│   ├── Web/                                        # Web UI projects
│   │   ├── TirsvadCLI.TestingScript.Web/           # Blazor project
│   │   └── TirsvadCLI.TestingScript.Web.Client/    # Blazor WebAssembly project
│   └── WebApi                                      # Web API project
├── docs/                                           # Documentation and design files
├── tests/                                          # Test projects
└── .github                                         # GitHub configuration files
```

### Customizing

- Edit configuration files as needed (e.g., `global.json`, `Directory.Build.props`).
- Add or update environment variables for your setup.

## Default Files Included

- `global.json`: .NET SDK version management
- `Directory.Build.props` / `Directory.Build.targets`: Solution-wide build settings
- `.gitignore`: Standard ignore rules
- `nuget.config`: Custom NuGet feeds
- Example scripts for setup and build

## Best Practices

- Keep source code in `src/`, tests in `tests/`.
- Use environment variables for sensitive data.
- Update `README.md` with any new setup or usage instructions.

For more details, see the [Microsoft documentation](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/) and Clean Architecture guides.

## License
Distributed under the AGPL-3.0 [License][license-url].

## Contact
Jens Tirsvad Nielsen - [LinkedIn][linkedin-url]

## Acknowledgements
- [Microsoft Blazor Documentation](https://learn.microsoft.com/aspnet/core/blazor/)
- [Clean Architecture Guide](https://learn.microsoft.com/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures)

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/TirsvadCLI/Dotnet.DefaultFiles?style=for-the-badge
[contributors-url]: https://github.com/TirsvadCLI/Dotnet.DefaultFiles/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/TirsvadCLI/Dotnet.DefaultFiles?style=for-the-badge
[forks-url]: https://github.com/TirsvadCLI/Dotnet.DefaultFiles/network/members
[stars-shield]: https://img.shields.io/github/stars/TirsvadCLI/Dotnet.DefaultFiles?style=for-the-badge
[stars-url]: https://github.com/TirsvadCLI/Dotnet.DefaultFiles/stargazers
[issues-shield]: https://img.shields.io/github/issues/TirsvadCLI/Dotnet.DefaultFiles?style=for-the-badge
[issues-url]: https://github.com/TirsvadCLI/Dotnet.DefaultFiles/issues
[license-shield]: https://img.shields.io/github/license/TirsvadCLI/Dotnet.DefaultFiles?style=for-the-badge
[license-url]: https://github.com/TirsvadCLI/Dotnet.DefaultFiles/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/jens-tirsvad-nielsen-13b795b9/
[githubIssue-url]: https://github.com/TirsvadCLI/Dotnet.AnsiCode/issues/
[repos-size-shield]: https://img.shields.io/github/repo-size/TirsvadCLI/Dotnet.DefaultFiles?style=for-the-badg

[logo]: https://raw.githubusercontent.com/TirsvadCLI/Logo/main/images/logo/32x32/logo.png "Logo"

<!--[nuget-shield]: https://img.shields.io/nuget/dt/TirsvadCLI.DefaultFiles?style=for-the-badge-->
<!--[nuget-url]: https://www.nuget.org/packages/TirsvadCLI.DefaultFiles/-->

[Downloads-shield]: https://img.shields.io/github/downloads/TirsvadCLI/Dotnet.DefaultFiles/total?style=for-the-badge
[Downloads-url]: https://github.com/TirsvadCLI/Dotnet.DefaultFiles/releases

[screenshot1]: https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/main/image/small/Screenshot1.png
[screenshot1-url]: https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/main/image/Screenshot1.png
