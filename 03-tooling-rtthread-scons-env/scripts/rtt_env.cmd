@echo off
REM rtt_env.cmd - Load RT-Thread Env into current CMD session (no new window)
REM Usage:
REM   rtt_env.cmd
REM   rtt_env.cmd scons --pyconfig
REM   rtt_env.cmd scons --target=eclipse
REM   "terminal.integrated.profiles.windows": {
REM       "RTT Env (CMD)": {
REM       "path": "C:\\Windows\\System32\\cmd.exe",
REM       "args": [
REM           "/k",
REM           "call",
REM           "${workspaceFolder}\\rt-thread\\rtt_env.cmd"
REM       ]
REM       },
REM   }

set "PROJECT_DIR=%CD%"

REM 1) Decide Env root: prefer RTT_ENV_HOME, else use your fixed path
set "ENV_ROOT="
if not "%RTT_ENV_HOME%"=="" set "ENV_ROOT=%RTT_ENV_HOME%"
if "%ENV_ROOT%"=="" set "ENV_ROOT=D:\RT-ThreadStudio\platform\env_released\env"

REM 2) Pick init script: prefer env-init.bat (v2.x), fallback to env.bat
set "ENV_INIT="
if exist "%ENV_ROOT%\tools\bin\env-init.bat" set "ENV_INIT=%ENV_ROOT%\tools\bin\env-init.bat"
if "%ENV_INIT%"=="" if exist "%ENV_ROOT%\env.bat" set "ENV_INIT=%ENV_ROOT%\env.bat"

if "%ENV_INIT%"=="" (
  echo [rtt_env] ERROR: Cannot find env-init.bat or env.bat under:
  echo [rtt_env]   "%ENV_ROOT%"
  echo [rtt_env] Tip: Set RTT_ENV_HOME, e.g.
  echo [rtt_env]   setx RTT_ENV_HOME "D:\RT-ThreadStudio\platform\env_released\env"
  exit /b 1
)

REM 3) IMPORTANT: use CALL so environment changes stay in this CMD session
call "%ENV_INIT%"
if errorlevel 1 (
  echo [rtt_env] ERROR: Env init failed: "%ENV_INIT%"
  exit /b %errorlevel%
)

REM 4) Return to where user launched this script
cd /d "%PROJECT_DIR%"

REM 5) If args provided, execute command after env loaded
if not "%~1"=="" (
  call %*
  exit /b %errorlevel%
)

echo [rtt_env] OK: Env loaded in this CMD session.
exit /b 0
