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
:: DEVICE PRE-CHECKS
:: ------------------------
echo.
echo 📌 Checking Requirements...
echo 📌 Checking Requirements... >> "%LOG_FILE%"

:: Bootloader Check
choice /m "Is your device bootloader unlocked?"
if %errorlevel% equ 2 (
    echo ❌ Bootloader must be unlocked to proceed.
    echo ❌ Bootloader must be unlocked to proceed. >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: Fastboot Mode Check
choice /m "Is your device in bootloader mode?"
if %errorlevel% equ 2 (
    echo ❌ Device must be in bootloader mode.
    echo ❌ Device must be in bootloader mode. >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: Fastboot Driver Check
choice /m "Are fastboot drivers installed?"
if %errorlevel% equ 2 (
    echo ❌ Install Google USB Drivers from:
    echo 🔗 https://developer.android.com/studio/run/win-usb
    echo ❌ Fastboot drivers missing! >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: Check Fastboot Device
for /f "tokens=1" %%A in ('%fastboot% devices 2^>nul') do (
    set "DEVICE_ID=%%A"
)
if not defined DEVICE_ID (
    echo ❌ No fastboot device detected!
    echo ❌ No fastboot device detected! >> "%LOG_FILE%"
    echo 🔍 Make sure the device is connected and in bootloader mode.
    pause
    exit /b 1
)

echo ✅ Device detected: %DEVICE_ID%
echo ✅ Device detected: %DEVICE_ID% >> "%LOG_FILE%"
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
echo 🔄 Setting Active Slot A... >> "%LOG_FILE%"
%fastboot% --set-active=a >> "%LOG_FILE%" 2>&1
echo ✅ Slot A set as active!
echo ✅ Slot A set as active! >> "%LOG_FILE%"

echo 🔄 Rebooting Device...
echo 🔄 Rebooting Device... >> "%LOG_FILE%"
%fastboot% reboot >> "%LOG_FILE%" 2>&1
echo ✅ Rebooting to System!
echo ✅ Rebooting to System! >> "%LOG_FILE%"

:: COMPLETION MESSAGE
cls
echo =============================================
echo   ✅ FASTBOOT READBACK FLASHING SUCCESSFUL!  
echo =============================================
echo 🎉 Your Nothing Phone 2a is now running the stock firmware.
echo ℹ️ Log file saved to flash_log.txt for reference.
echo ℹ️ You may now safely disconnect your device.
pause
exit