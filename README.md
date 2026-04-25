[![Downloads][Downloads-shield]][Downloads-url]
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

# Dotnet.DefaultFiles
<img  style="float: left; margin: 5px 10px 0 0;" src="https://raw.githubusercontent.com/TirsvadCLI/Logo/refs/heads/main/images/logo/64x64/logo.png">
This repository provides a template for initializing .NET projects with default files and a setup script. It is designed to help developers quickly scaffold a new solution following Clean Architecture principles, including recommended folder structure, configuration, and build scripts.

## 📚 Table of Contents

- [Overview](#overview)
- [Solution Goals](#solution-goals)
- [Setup & Usage](#setup--usage)
- [Script Arguments and Usage](#script-arguments-and-usage)
- [Default Files Included](#default-files-included)
- [Best Practices](#best-practices)
- [Copilot Agents, Instructions and Prompts](#copilot-agents)
- [License](#license)
- [Contact](#contact)
- [Acknowledgements](#acknowledgements)

<a name="overview"></a>
## 🚀 Overview

Dotnet.DefaultFiles serves as a starting point for .NET development. It includes:
- Standard files for solution and project setup
- PowerShell script for creating a new Clean Architecture project
- Quality criteria for artifacts and code
- Copilot agents, instructions and prompts for generating artifacts, code and documentation.

<a name="solution-goals"></a>
## 🎯 Solution Goals

- Provide a consistent starting point for .NET projects
- Encourage best practices in project structure and configuration
- Facilitate quick setup of Clean Architecture solutions
- Include tools and resources for maintaining code quality and documentation
- Support both Blazor and Web API project types with Clean Architecture principles
- Offer flexibility through script arguments for different project needs

<a name="setup--usage"></a>
## Setup & Usage


### Initializing a New Project
1. Create a folder with the name of your new solution. (e.g., `mkdir MyNewSolution`)
2. Go to the new folder. (e.g., `cd MyNewSolution`)

#### Windows PowerShell
3. Download and run the setup script to scaffold your solution. The script uses a YAML configuration file (`solution-structure.config.yaml`) to define the directory and file structure, which is loaded by `import-yaml-config.ps1`:
  - Scaffold a new solution with Clean Architecture principles:
  ```powershell
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/refs/heads/main/settings.yaml" -OutFile "settings.yaml"
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/refs/heads/main/import-yaml-config.ps1" -OutFile "import-yaml-config.ps1"
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/refs/heads/main/setupSolutionCleanArchentectureCSharp.ps1" -OutFile "setupSolutionCleanArchentectureCSharp.ps1"
  .\setupSolutionCleanArchentectureCSharp.ps1
  ```
  - Scaffold a new Blazor project with Clean Architecture principles and WebApi:
  ```powershell
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TirsvadCLI/Dotnet.DefaultFiles/refs/heads/main/setupSolutionCleanArchentectureCSharp.ps1" -OutFile "setupSolutionCleanArchentectureCSharp.ps1"
  .\setupSolutionCleanArchentectureCSharp.ps1 -Blazor -WebApi
  ```

This will create the recommended folder structure, add default files, and configure the solution for Clean Architecture, all based on the YAML configuration.

The folder structure will be created as follows:

<a name="script-arguments-and-usage"></a>
## 🛠️ Script Arguments and Usage

The `setupSolutionCleanArchentectureCSharp.ps1` script supports several arguments to customize the solution setup:

**Arguments:**

| Switch         | Description                                                                                       |
|---------------|----------------------------------------------------------------------------------------------------|
| `-Files`      | Only create directories, hardlink, and copy default files.                                         |
| `-Arch`       | Only set up Clean Architecture solution and projects (Domain, Application, Infrastructure).        |
| `-Blazor`     | Set up Clean Architecture and add Blazor WebAssembly and server projects (frontend/backend)        |
| `-WebApi`     | Set up Clean Architecture and add a Web API project                                                |
| `-Help`       | Show usage instructions and exit.                                                                  |
| `-DefaultFilesRoot <path>` | Optional path to a custom source for default files.                                    |
| `-SolutionFile <file>`     | Optional custom solution file name.                                                   |
| `-Framework <version>`     | Optional .NET target framework (default: net10.0).                                    |

**Examples:**

```powershell
# Default setup: directories, files, and Clean Architecture projects
./setupSolutionCleanArchentectureCSharp.ps1

# Only create directories and copy default files
./setupSolutionCleanArchentectureCSharp.ps1 -Files

# Only set up Clean Architecture projects (no file copying)
./setupSolutionCleanArchentectureCSharp.ps1 -Arch

# Set up Clean Architecture and add Blazor frontend/backend
./setupSolutionCleanArchentectureCSharp.ps1 -Blazor

# Set up Clean Architecture and add Web API backend
./setupSolutionCleanArchentectureCSharp.ps1 -WebApi

# Show help
./setupSolutionCleanArchentectureCSharp.ps1 -Help

# Use a custom default files source and solution file name
./setupSolutionCleanArchentectureCSharp.ps1 -DefaultFilesRoot "../MyDefaults" -SolutionFile "MySolution.slnx"
```

```plaintext
MyBlazorApp/
├── src/
│   ├── Domain/                                     # Business logic and entities
│   │   ├── Entities/                               # Domain entities
│   │   ├── Interfaces/                             # Domain interfaces
│   │   └── ValueObjects/                           # Domain value objects
│   ├── Application/                                # Application services and use cases
│   │   ├── Services/                               # Application services
│   │   ├── Helpers/                                # Application helpers
│   │   ├── Managers/                               # Application managers
│   │   ├── Mappers/                                # Application mappers
│   │   ├── DTOs/                                   # Data transfer objects
│   │   └── Interfaces/                             # Application interfaces
│   ├── Infrastructure/                             # Data access, external services
│   │   ├── Persistence/                            # Database context and repositories
│   │   │   └── Configuration/                      # Database configuration files 
│   │   └── Repositories/                           # Repository implementations
│   ├── Web/                                        # Web UI projects (if selected)
│   │   ├── MyBlazorApp.Web/                        # Blazor project
│   │   └── MyBlazorApp.Web.Client/                 # Blazor WebAssembly project
│   └── WebApi                                      # Web API project (if selected)
├── docs/                                           # Documentation and design files
├── tests/                                          # Test projects
└── .github                                         # GitHub configuration files
```

### Customizing

- Edit configuration files as needed (e.g., `global.json`, `Directory.Build.props`).
- Add or update environment variables for your setup.

<a name="default-files-included"></a>

## Default Files Included

- `global.json`: .NET SDK version management
- `Directory.Build.props` / `Directory.Build.targets`: Solution-wide build settings
- `.gitignore`: Standard ignore rules
- `nuget.config`: Custom NuGet feeds
- Example scripts for setup and build

<a name="github-folder"></a>
## 📂 The `.github` Folder

The `.github` directory contains configuration, automation, and documentation resources that support development workflows and code quality:

- **Copilot Instructions & Agents**:  
  - `.github/copilot-instructions.md` defines repository-wide rules for Copilot agents, including Clean Architecture conventions, folder structure, and documentation standards.
  - `.github/instructions/` contains detailed instructions and prompts for Copilot agents, such as how to generate or validate domain models, documentation, and code artifacts.
  - Agent prompt files (e.g., `dm-artifact.agent.md`) provide reusable templates for generating domain model documentation and other artifacts.
- **Workflow & Community Files**:  
  - GitHub Actions workflows (if present) automate CI/CD, testing, and other tasks.
  - Issue and pull request templates help standardize contributions.
  - Configuration files for repository settings and community standards.

These resources ensure consistency, automate repetitive tasks, and provide guidance for both humans and AI agents working in the repository.

For more details, see the `.github/` directory and referenced documentation.

<a name="best-practices"></a>
## Best Practices

- Keep source code in `src/`, tests in `tests/`.
- Use environment variables for sensitive data.
- Update `README.md` with any new setup or usage instructions.

For more details, see the [Microsoft documentation](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/) and Clean Architecture guides.

<a name="github-pages"></a>
## 🌐 GitHub Pages & Google Site Verification

If you use GitHub Pages to publish documentation or a project site, you can add a `google*.html` file (such as `googleXXXX.html`) to the repository root or the `docs/` folder. This file is used by Google for site verification and enables Google Search Console or Analytics to collect statistics about your site.

**How to add Google verification:**
- Download the HTML verification file from Google Search Console (it will be named like `googleXXXXXXXXXXXX.html`).
- Place the file in the `shared/github-pages/` folder.
- Commit and push the file to your repository.
- Google will then be able to verify your site and collect statistics.

This is useful for tracking site traffic, indexing, and using other Google webmaster tools with your GitHub Pages site.

<a name="copilot-agents"></a>
## 🤖 Copilot Agents, Instructions and Prompts
The repository also includes Copilot agents, instructions and prompts to assist developers in generating artifacts, code and documentation. These resources can be found in the `.github/` directory and are designed to enhance productivity and ensure consistency across projects.

### Agent Examples:
#### Domain Model Agent
Generates, validates, and maintains domain model (DM) documentation in markdown, following strict content, structure, and naming conventions for clarity and consistency. It analyses business case, identifies domain entities and relationships, and produces DM artifacts that align with the project’s domain language and requirements. The agent ensures that DM files are correctly named, versioned, and structured according to the instructions, and it validates the content for completeness and clarity without evaluating quality criteria.

**Example Usage:**
```
#dm-artifact.agent.md
Create DM
```

<a name="license"></a>
## 📄 License
Distributed under the AGPL-3.0 [License][license-url].

<a name="contact"></a>
## 📬 Contact
Jens Tirsvad Nielsen - [LinkedIn][linkedin-url]

<a name="acknowledgements"></a>
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
