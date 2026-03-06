<#
.SYNOPSIS
Run RT-Thread `scons` via an RT-Thread Env batch loader from PowerShell.

.DESCRIPTION
Loads RT-Thread Env in a child `cmd.exe` session (so Python/SCons/Unix tools resolve correctly),
then invokes `scons -C <BSP> ...`.

.PARAMETER Bsp
RT-Thread BSP directory (must contain `SConstruct`). Default: current directory.

.PARAMETER EnvScript
Path to the Env loader batch file. If omitted, search upwards for `rt-thread\rtt_env.cmd` or `rtt_env.cmd`.

.PARAMETER SconsArgs
Additional arguments passed through to `scons` (as an explicit array).

.PARAMETER SconsArgsLine
Command-line snippet appended to `scons` and parsed by `cmd.exe` (recommended for flags like `-j8` / `--target=mdk5`).

.EXAMPLE
.\rtt-scons.ps1 -Bsp f407_boot -SconsArgsLine "-j8"

.EXAMPLE
.\rtt-scons.ps1 -Bsp f407_boot -SconsArgsLine "--target=mdk5"
#>
param(
    [Parameter()]
    [string]$Bsp = '.',

    [Parameter()]
    [string]$EnvScript,

    [Parameter()]
    [string]$SconsArgsLine = '',

    [Parameter()]
    [string[]]$SconsArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ExistingPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    return $resolved.Path
}

function Find-RttEnvScriptFromHere {
    param([Parameter(Mandatory = $true)][string]$StartDir)

    $current = Resolve-ExistingPath $StartDir
    while ($true) {
        $candidate1 = Join-Path $current '\scripts\rtt_env.cmd'
        if (Test-Path -LiteralPath $candidate1 -PathType Leaf) {
            return $candidate1
        }

        $candidate2 = Join-Path $current 'rtt_env.cmd'
        if (Test-Path -LiteralPath $candidate2 -PathType Leaf) {
            return $candidate2
        }

        $parent = Split-Path -Path $current -Parent
        if ($parent -eq $current) {
            break
        }
        $current = $parent
    }

    return $null
}

$bspDir = Resolve-ExistingPath $Bsp
if (-not (Test-Path -LiteralPath (Join-Path $bspDir 'SConstruct') -PathType Leaf)) {
    throw "BSP directory does not contain SConstruct: $bspDir"
}

if ([string]::IsNullOrWhiteSpace($EnvScript)) {
    $EnvScript = Find-RttEnvScriptFromHere -StartDir (Get-Location).Path
}
if ([string]::IsNullOrWhiteSpace($EnvScript)) {
    throw "Cannot find RT-Thread Env loader (\\scripts\\rtt_env.cmd). Pass -EnvScript or run in an RTT Env CMD terminal."
}
$EnvScript = Resolve-ExistingPath $EnvScript

if (-not [string]::IsNullOrWhiteSpace($SconsArgsLine)) {
    $cmdLine = "call ""$EnvScript"" scons -C ""$bspDir"" $SconsArgsLine"
    & cmd.exe /c $cmdLine
    exit $LASTEXITCODE
}

$cmdArgs = @('/c', 'call', $EnvScript, 'scons', '-C', $bspDir) + $SconsArgs
& cmd.exe @cmdArgs
exit $LASTEXITCODE
