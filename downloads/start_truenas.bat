@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: CONFIG
:: ============================================================
set "VMNAME=TrueNAS"
set "VB_DIR=C:\Program Files\Oracle\VirtualBox"
set "VBM=%VB_DIR%\VBoxManage.exe"
set "LOGFILE=C:\Scripts\truenas_Scripts\truenas_log.txt"

:: ============================================================
:: LOG HEADER
:: ============================================================
echo ~ >> "%LOGFILE%"
echo [%date% %time%] Executing start_truenas.bat >> "%LOGFILE%"
echo [%date% %time%] Preparing to start VM '%VMNAME%'... >> "%LOGFILE%"

:: ============================================================
:: STEP 1 — Wait after wake (VirtualBox needs time)
:: ============================================================
echo [%date% %time%] Waiting 15 seconds to allow system wake stabilizing... >> "%LOGFILE%"
timeout /t 15 /nobreak >nul

:: ============================================================
:: STEP 2 — Verify VBoxManage exists
:: ============================================================
if not exist "%VBM%" (
echo [%date% %time%] ERROR: VBoxManage.exe not found at %VBM% >> "%LOGFILE%"
exit /b 1
)

:: ============================================================
:: STEP 3 — CHANGE DIRECTORY to VirtualBox folder
:: ============================================================
echo [%date% %time%] Switching directory to VirtualBox install folder... >> "%LOGFILE%"
cd /d "%VB_DIR%"

:: ============================================================
:: STEP 4 — SAFE START WITH WATCHDOG TIMEOUT (no hangs)
:: ============================================================
echo [%date% %time%] Issuing VM start command with watchdog timeout... >> "%LOGFILE%"

:: Start VBoxManage in background
start "" /b cmd /c ""%VBM%" startvm "%VMNAME%" --type headless" >> "%LOGFILE%" 2>&1

:: Wait up to 20 seconds for it to complete
set /a WAITED=0
:WAIT_LOOP
if %WAITED% GEQ 20 goto TIMEOUT_EXIT

:: Check if VBoxManage is still running
tasklist | findstr /i "VBoxManage.exe" >nul
if errorlevel 1 goto DONE_STARTING

timeout /t 1 >nul
set /a WAITED+=1
goto WAIT_LOOP

:TIMEOUT_EXIT
echo [%date% %time%] WARNING: VBoxManage hung; terminating process... >> "%LOGFILE%"
taskkill /im VBoxManage.exe /f >> "%LOGFILE%" 2>&1
goto DONE_STARTING

:DONE_STARTING
echo [%date% %time%] VM start command complete (watchdog safe). >> "%LOGFILE%"


:: ============================================================
:: STEP 5 — Confirm VM entered running state
:: ============================================================
echo [%date% %time%] Checking VM state... >> "%LOGFILE%"

"%VBM%" showvminfo "%VMNAME%" --machinereadable | findstr /i "VMState="running"" >nul

if errorlevel 1 (
echo [%date% %time%] WARNING: VM did not report running state yet. >> "%LOGFILE%"
) else (
echo [%date% %time%] VM is now RUNNING. >> "%LOGFILE%"
)

:: ============================================================
:: DONE
:: ============================================================
echo [%date% %time%] start_truenas.bat finished cleanly. >> "%LOGFILE%"
exit /b 0
