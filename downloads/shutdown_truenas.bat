@echo off


set VMNAME=TrueNAS
set VBM=C:\PROGRA~1\Oracle\VIRTUA~1\VBOXMA~1.EXE
set LOGFILE=C:\Scripts\truenas_Scripts\truenas_log.txt

echo ~ >> "%LOGFILE%"
echo [%date% %time%] Executing shutdown_truenas.bat >> "%LOGFILE%"
echo [%date% %time%] Requesting shutdown for %VMNAME%... >> "%LOGFILE%"

"%VBM%" controlvm "%VMNAME%" acpipowerbutton >> "%LOGFILE%" 2>&1

REM Wait for VM to shut down (max 10 minutes)
for /L %%I in (1,1,120) do (
    "%VBM%" showvminfo "%VMNAME%" --machinereadable | findstr /B /C:"VMState=" > "%TEMP%\vmstate.txt"
    findstr /C:"poweroff" "%TEMP%\vmstate.txt" >NUL
    if not errorlevel 1 (
        echo [%date% %time%] VM is powered off. >> "%LOGFILE%"
        goto END
    )
    timeout /t 5 >NUL
)

echo [%date% %time%] WARNING: Timeout waiting for shutdown. >> "%LOGFILE%"

:END
echo [%date% %time%] Shutdown script completed. >> "%LOGFILE%"
exit /b 0
