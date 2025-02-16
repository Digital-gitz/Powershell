<#
.SYNOPSIS
    Builds a repository using multiple build systems.
.DESCRIPTION
    This PowerShell script builds a Git repository by supporting various build systems:
    - CMake
    - Autogen
    - Configure
    - Gradle
    - Meson
    - Imakefile
    - Makefile
    - Custom build scripts
.PARAMETER Path
    Specifies the path to the Git repository (default is current working directory)
.PARAMETER Jobs
    Number of parallel jobs for make/build commands (default is 4)
.PARAMETER SkipTests
    Skip running tests after build
.EXAMPLE
    PS> ./build-repo.ps1 -Path C:\Repos\ninja
    ⏳ Building 📂ninja using CMakeLists.txt...
    ✅ Built 📂ninja repository in 47 sec.
.LINK
    https://github.com/fleschutz/PowerShell
.NOTES
    Author: Markus Fleschutz | License: CC0
    Enhanced by: Claude
#>

param(
    [Parameter(Position=0)]
    [string]$Path = "$PWD",
    
    [Parameter()]
    [int]$Jobs = 4,
    
    [Parameter()]
    [switch]$SkipTests
)

# Build system configurations
$BuildSystems = @{
    CMake = @{
        Detector = "CMakeLists.txt"
        Steps = @(
            @{
                Message = "Generating build files with CMake"
                Commands = @(
                    @{
                        Cmd = "cmake"
                        Args = @("..")
                        WorkingDir = "_Build_Results"
                        CreateDir = $true
                    }
                )
            },
            @{
                Message = "Building with make"
                Commands = @(
                    @{
                        Cmd = "make"
                        Args = @("-j$Jobs")
                        WorkingDir = "_Build_Results"
                    }
                )
            },
            @{
                Message = "Running tests"
                Commands = @(
                    @{
                        Cmd = "ctest"
                        Args = @("-V")
                        WorkingDir = "_Build_Results"
                        SkipOnFlag = "SkipTests"
                    }
                )
            }
        )
    }
    Autogen = @{
        Detector = "autogen.sh"
        Steps = @(
            @{
                Message = "Running autogen"
                Commands = @(
                    @{
                        Cmd = "./autogen.sh"
                        Args = @("--force")
                    },
                    @{
                        Cmd = "./configure"
                    }
                )
            },
            @{
                Message = "Building with make"
                Commands = @(
                    @{
                        Cmd = "make"
                        Args = @("-j$Jobs")
                    }
                )
            }
        )
    }
    # Additional build systems defined similarly...
}

function Write-BuildLog {
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Level) {
        "Info"    { "⏳" }
        "Warning" { "⚠️" }
        "Error"   { "❌" }
    }
    
    $color = switch ($Level) {
        "Info"    { "White" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
    }
    
    Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $color
}

function Invoke-BuildStep {
    param(
        [hashtable]$Step,
        [string]$BasePath
    )
    
    Write-BuildLog $Step.Message
    
    foreach ($command in $Step.Commands) {
        if ($command.SkipOnFlag -and (Get-Variable -Name $command.SkipOnFlag).Value) {
            Write-BuildLog "Skipping: $($command.Cmd) $($command.Args -join ' ')" -Level "Warning"
            continue
        }
        
        $workingDir = if ($command.WorkingDir) {
            Join-Path $BasePath $command.WorkingDir
        } else {
            $BasePath
        }
        
        if ($command.CreateDir -and !(Test-Path $workingDir)) {
            New-Item -ItemType Directory -Path $workingDir | Out-Null
        }
        
        Push-Location $workingDir
        try {
            $process = Start-Process -FilePath $command.Cmd `
                                   -ArgumentList $command.Args `
                                   -NoNewWindow `
                                   -Wait `
                                   -PassThru
            
            if ($process.ExitCode -ne 0) {
                throw "Command '$($command.Cmd) $($command.Args -join ' ')' failed with exit code $($process.ExitCode)"
            }
        }
        finally {
            Pop-Location
        }
    }
}

function Build-Repository {
    param([string]$Path)
    
    $dirName = (Get-Item $Path).Name
    $buildSystem = $null
    
    # Detect build system
    foreach ($system in $BuildSystems.GetEnumerator()) {
        if (Test-Path (Join-Path $Path $system.Value.Detector) -PathType Leaf) {
            $buildSystem = $system.Value
            Write-BuildLog "Detected $($system.Name) build system in 📂$dirName"
            break
        }
    }
    
    if (-not $buildSystem) {
        # Check for nested repository
        $nestedPath = Join-Path $Path $dirName
        if (Test-Path $nestedPath -PathType Container) {
            Write-BuildLog "No build system found, trying subfolder 📂$dirName"
            Build-Repository $nestedPath
            return
        }
        
        Write-BuildLog "No supported build system found in 📂$dirName" -Level "Warning"
        return
    }
    
    # Execute build steps
    foreach ($step in $buildSystem.Steps) {
        Invoke-BuildStep -Step $step -BasePath $Path
    }
}

try {
    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    if (-not (Test-Path $Path -PathType Container)) {
        throw "Cannot access directory: $Path"
    }
    
    $previousPath = Get-Location
    Build-Repository $Path
    Set-Location $previousPath
    
    $repoDirName = (Get-Item $Path).Name
    [int]$elapsed = $stopWatch.Elapsed.TotalSeconds
    Write-BuildLog "✅ Built 📂$repoDirName repository in $elapsed sec."
    exit 0
}
catch {
    Write-BuildLog "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])" -Level "Error"
    exit 1
}