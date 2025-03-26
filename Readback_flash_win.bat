@echo off
title 📱 Fastboot Readback Flashing 🚀
chcp 65001 >nul 2>&1  :: Enable UTF-8 for emoji support

:: Ensure script runs as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔴 Please run this script as Administrator!
    pause
    exit /b
)

:: Initialize log file
set "LOG_FILE=%~dp0flash_log.txt"
echo ============================================= > "%LOG_FILE%"
echo   🚀 Fastboot Readback Flashing Log          >> "%LOG_FILE%"
echo ============================================= >> "%LOG_FILE%"
echo Started: %DATE% %TIME%                        >> "%LOG_FILE%"
echo.                                             >> "%LOG_FILE%"

:: Clear screen & show banner
cls
echo =============================================
echo   🚀 Fastboot Readback Flashing  
echo =============================================
echo   📂 Checking Environment...
echo.

:: Set working directory
set "WORK_DIR=%~dp0"
cd /d "%WORK_DIR%" 2>nul || (
    echo ❌ [ERROR] Failed to set working directory!
    echo ❌ [ERROR] Failed to set working directory! >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: ------------------------
:: PLATFORM TOOLS DETECTION
:: ------------------------
set "fastboot=platform-tools-latest\platform-tools\fastboot.exe"
set "adb=platform-tools-latest\platform-tools\adb.exe"

if not exist "%fastboot%" (
    echo 🔍 Platform-tools not found! Downloading...
    echo 🔍 Platform-tools not found! Downloading... >> "%LOG_FILE%"
    curl --ssl-no-revoke -L https://dl.google.com/android/repository/platform-tools-latest-windows.zip -o platform-tools.zip >> "%LOG_FILE%" 2>&1
    if exist platform-tools.zip (
        echo ✅ Platform-tools downloaded. Extracting...
        powershell -Command "Expand-Archive -Path 'platform-tools.zip' -DestinationPath 'platform-tools-latest' -Force" >> "%LOG_FILE%" 2>&1
        del /f /q platform-tools.zip
    ) else (
        echo ❌ Error: Failed to download platform-tools!
        echo ❌ Error: Failed to download platform-tools! >> "%LOG_FILE%"
        exit /b 1
    )
) else (
    echo ✅ Platform-tools detected. Proceeding...
    echo ✅ Platform-tools detected. Proceeding... >> "%LOG_FILE%"
)

:: ------------------------
:: DEVICE MODE DETECTION
:: ------------------------
echo 🔍 Detecting device mode...
echo 🔍 Detecting device mode... >> "%LOG_FILE%"

:: Check if in ADB mode
%adb% get-state 2>nul | find "device" >nul
if %errorlevel% equ 0 (
    echo 🔄 Device in ADB mode, rebooting to bootloader...
    echo 🔄 Device in ADB mode, rebooting to bootloader... >> "%LOG_FILE%"
    %adb% reboot bootloader
    timeout /t 5 >nul
)

:: Check if in Fastboot mode
for /f "tokens=1" %%A in ('%fastboot% devices 2^>nul') do (
    set "DEVICE_ID=%%A"
)

if not defined DEVICE_ID (
    echo ❌ No device detected in Fastboot mode!
    echo ❌ No device detected in Fastboot mode! >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ Device detected: %DEVICE_ID%
echo ✅ Device detected: %DEVICE_ID% >> "%LOG_FILE%"

:: Check if in Fastbootd
%fastboot% getvar is-userspace 2>&1 | find "yes" >nul
if %errorlevel% equ 0 (
    echo 🔄 Device is in Fastbootd mode, rebooting to bootloader...
    echo 🔄 Device is in Fastbootd mode, rebooting to bootloader... >> "%LOG_FILE%"
    %fastboot% reboot bootloader
    timeout /t 5 >nul
)

:: ------------------------
:: BOOTLOADER UNLOCK CHECK
:: ------------------------
echo 🔍 Checking bootloader unlock status...
echo 🔍 Checking bootloader unlock status... >> "%LOG_FILE%"

%fastboot% getvar unlocked 2>&1 | find "unlocked: no" >nul
if %errorlevel% equ 0 (
    echo ❌ Bootloader is locked! Please unlock it before proceeding.
    echo ❌ Bootloader is locked! Please unlock it before proceeding. >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo ✅ Bootloader is unlocked!
echo ✅ Bootloader is unlocked! >> "%LOG_FILE%"
timeout /t 1 >nul

:: ------------------------
:: DEVICE FORMAT (ERASE USERDATA & METADATA)
:: ------------------------
echo ⚠️ Formatting device (Erasing userdata & metadata)...
echo ⚠️ Formatting device (Erasing userdata & metadata)... >> "%LOG_FILE%"
%fastboot% erase metadata >> "%LOG_FILE%" 2>&1
%fastboot% erase userdata >> "%LOG_FILE%" 2>&1
echo ✅ Format complete! Device is clean.
echo ✅ Format complete! Device is clean. >> "%LOG_FILE%"
timeout /t 1 >nul

:: ------------------------
:: FLASHING PROCESS START
:: ------------------------
cls
echo =============================================
echo   🚀 FLASHING STOCK FASTBOOT ROM  
echo =============================================
echo 🚀 Flashing Stock Fastboot ROM... >> "%LOG_FILE%"

:: Flashing Boot Partitions (A & B)
echo 🔄 Flashing Boot Partitions...
echo 🔄 Flashing Boot Partitions... >> "%LOG_FILE%"
for %%p in (boot dtbo init_boot vendor_boot vbmeta vbmeta_system vbmeta_vendor) do (
    echo    🔹 Flashing %%p_a...
    echo    🔹 Flashing %%p_a... >> "%LOG_FILE%"
    %fastboot% flash %%p_a %%p_a.img >> "%LOG_FILE%" 2>&1
    echo    🔹 Flashing %%p_b...
    echo    🔹 Flashing %%p_b... >> "%LOG_FILE%"
    %fastboot% flash %%p_b %%p_b.img >> "%LOG_FILE%" 2>&1
)
echo ✅ Boot partitions flashed!
echo ✅ Boot partitions flashed! >> "%LOG_FILE%"
timeout /t 1 >nul

:: Flashing Firmware (A & B)
echo 🔄 Flashing Firmware...
echo 🔄 Flashing Firmware... >> "%LOG_FILE%"
for %%p in (apusys audio_dsp ccu connsys_bt connsys_gnss connsys_wifi dpm gpueb gz lk logo mcupm mcf_ota md1img mvpu_algo pi_img scp spmfw sspm tee vcp) do (
    echo    🔹 Flashing %%p_a...
    echo    🔹 Flashing %%p_a... >> "%LOG_FILE%"
    %fastboot% flash %%p_a %%p_a.img >> "%LOG_FILE%" 2>&1
    echo    🔹 Flashing %%p_b...
    echo    🔹 Flashing %%p_b... >> "%LOG_FILE%"
    %fastboot% flash %%p_b %%p_b.img >> "%LOG_FILE%" 2>&1
)
echo ✅ Firmware flashed!
echo ✅ Firmware flashed! >> "%LOG_FILE%"
timeout /t 1 >nul

:: Flashing Logical Partitions
echo 🔄 Flashing Super Partition...
echo 🔄 Flashing Super Partition... >> "%LOG_FILE%"
%fastboot% flash super super.img >> "%LOG_FILE%" 2>&1
echo ✅ Super partition flashed!
echo ✅ Super partition flashed! >> "%LOG_FILE%"
timeout /t 1 >nul

:: ------------------------
:: FINALIZATION
:: ------------------------
echo 🔄 Setting Active Slot A...
%fastboot% --set-active=a >> "%LOG_FILE%" 2>&1
echo ✅ Slot A set as active!

echo 🔄 Rebooting Device...
%fastboot% reboot >> "%LOG_FILE%" 2>&1
echo ✅ Rebooting to System!
pause
exit