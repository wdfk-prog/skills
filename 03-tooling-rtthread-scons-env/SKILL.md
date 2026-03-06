---
name: 03-tooling-rtthread-scons-env
description: Build the RT-Thread BSP using SCons in a reliable Python environment (RT-Thread Env/RT-Thread Studio environment or system Python). Use it when running or troubleshooting `scons` (SConstruct/rtconfig.py) in the RT-Thread project, switching toolchains (RTT_CC/RTT_EXEC_PATH/RTT_ROOT), or generating IDE projects (mdk5/iar/eclipse).
---

# RT-Thread SCons + Python Env

## Overview

Build RT-Thread BSPs with `scons` using a predictable Python/SCons environment. Diagnose common failures caused by wrong Python, missing SCons, or misconfigured toolchain/env variables.

## Workflow

### 1) Identify the BSP root

- Find a directory that contains `SConstruct` (often also `rtconfig.py`).
- Treat that directory as the BSP root and run `scons` from there.
- If you need to run from a different directory, use `scons -C <dir>` (recommended for scripted builds).

PowerShell helpers:

- Locate BSP candidates: `Get-ChildItem -Recurse -Filter SConstruct`

### 2) Verify Python + SCons resolve to the intended ones

- Print the interpreter and version: `python -c "import sys; print(sys.executable); print(sys.version)"`
- Confirm SCons is installed and visible: `scons --version` (or `python -m scons --version` if wrapped)
- If multiple Pythons exist, prefer the one used by your RT-Thread Env setup.

### 3) Load RT-Thread Env on Windows (recommended)

Use an Env loader so you get a consistent Python, `scons`, and Unix-like tools (`sh`, `rm`, `find`) that many RT-Thread BSP scripts assume.

If the repo provides a helper batch script (example: `\/01-lang-bats-testing-patterns/rtt_env.cmd`), use it:

- Load env in an interactive CMD: `cmd.exe /k call scripts\\rtt_env.cmd`
- Run one command via env (good from PowerShell): `cmd.exe /c call scripts\\rtt_env.cmd scons -C f407_boot -j8`

If env is not found, set the env root and retry:

- Set once (example): `setx RTT_ENV_HOME "D:\\RT-ThreadStudio\\platform\\env_released\\env"`

Note: A batch file cannot modify the parent PowerShell process environment. Use `cmd.exe /k` (interactive) or execute the build through `cmd.exe /c` as shown above.

### 4) Build, clean, and generate IDE projects

Run these from the BSP root directory (or add `-C <bsp-dir>`):

- Build: `scons -j8`
- Clean: `scons -c`
- Verbose troubleshooting: `scons -Q` (quiet) or `scons -s` (silent) depending on your version
- Generate projects (common targets): `scons --target=mdk5`, `scons --target=iar`, `scons --target=eclipse`

### 5) Toolchain and environment variables (RT-Thread conventions)

- Select toolchain: `RTT_CC` (common values: `gcc`, `keil`, `iar`)
- Point to toolchain binaries: `RTT_EXEC_PATH` (must contain `arm-none-eabi-gcc` or vendor tools)
- Point to RT-Thread root: `RTT_ROOT` (directory containing `components/`, `tools/`, etc.)

Prefer environment variables over hardcoding paths when sharing projects across machines; keep `rtconfig.py` defaults as a fallback.

### 6) Triage checklist for common failures

- `scons` not found: ensure you are inside Env, or install into the active Python (`python -m pip install scons`).
- `arm-none-eabi-gcc` not found: set `RTT_EXEC_PATH` to the toolchain `bin/` directory (or fix `EXEC_PATH` in `rtconfig.py`).
- `RTT_ROOT not defined`: export `RTT_ROOT` to the RT-Thread root, or ensure `PROJECT_SOURCE_FOLDERS` covers your RT-Thread checkout.
- Unix tools missing on Windows (`find`, `rm`, `sh`): build inside RT-Thread Env, MSYS2, or WSL; avoid relying on plain `cmd`/PowerShell PATH.

## Included script

- `/scripts/rtt-scons.ps1`: Run `scons` through an RT-Thread Env batch loader from PowerShell.
