@echo off
title 📱 Fastboot Readback Flashing 🚀
chcp 65001 >nul 2>&1  :: Enable UTF-8 for emoji support

:: Ensure the script runs as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔴 Please run this script as Administrator!
    pause
    exit /b
)

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
    pause
    exit /b 1
)

:: ------------------------
:: PLATFORM TOOLS DETECTION
:: ------------------------
set "fastboot=platform-tools-latest\platform-tools\fastboot.exe"
if not exist "%fastboot%" (
    echo 🔍 Platform-tools not found! Downloading...
    curl --ssl-no-revoke -L https://dl.google.com/android/repository/platform-tools-latest-windows.zip -o platform-tools.zip
    if exist platform-tools.zip (
        echo ✅ Platform-tools downloaded. Extracting...
        powershell -Command "Expand-Archive -Path 'platform-tools.zip' -DestinationPath 'platform-tools-latest' -Force"
        del /f /q platform-tools.zip
    ) else (
        echo ❌ Error: Failed to download platform-tools!
        exit /b 1
    )
) else (
    echo ✅ Platform-tools detected. Proceeding...
)

:: ------------------------
:: DEVICE PRE-CHECKS
:: ------------------------
echo.
echo 📌 Checking Requirements...

:: Bootloader Check
choice /m "Is your device bootloader unlocked?"
if %errorlevel% equ 2 (
    echo ❌ Bootloader must be unlocked to proceed.
    pause
    exit /b 1
)

:: Fastboot Mode Check
choice /m "Is your device in bootloader mode?"
if %errorlevel% equ 2 (
    echo ❌ Device must be in bootloader mode.
    pause
    exit /b 1
)

:: Fastboot Driver Check
choice /m "Are fastboot drivers installed?"
if %errorlevel% equ 2 (
    echo ❌ Install Google USB Drivers from:
    echo 🔗 https://developer.android.com/studio/run/win-usb
    pause
    exit /b 1
)

:: Check Fastboot Device
for /f "tokens=1" %%A in ('%fastboot% devices 2^>nul') do (
    set "DEVICE_ID=%%A"
)
if not defined DEVICE_ID (
    echo ❌ No fastboot device detected!
    echo 🔍 Make sure the device is connected and in bootloader mode.
    pause
    exit /b 1
)

echo ✅ Device detected: %DEVICE_ID%
timeout /t 1 >nul

:: ------------------------
:: FLASHING PROCESS START
:: ------------------------
cls
echo =============================================
echo   🚀 FLASHING STOCK FASTBOOT ROM  
echo =============================================

:: Flashing Boot Partitions (A & B)
echo 🔄 Flashing Boot Partitions...
for %%p in (boot dtbo init_boot vendor_boot vbmeta vbmeta_system vbmeta_vendor) do (
    echo    🔹 Flashing %%p_a...
    %fastboot% flash %%p_a %%p_a.img >nul
    echo    🔹 Flashing %%p_b...
    %fastboot% flash %%p_b %%p_b.img >nul
)
echo ✅ Boot partitions flashed!
timeout /t 1 >nul

:: Flashing Firmware (A & B)
echo 🔄 Flashing Firmware...
for %%p in (apusys audio_dsp ccu connsys_bt connsys_gnss connsys_wifi dpm gpueb gz lk logo mcupm mcf_ota md1img mvpu_algo pi_img scp spmfw sspm tee vcp) do (
    echo    🔹 Flashing %%p_a...
    %fastboot% flash %%p_a %%p_a.img >nul
    echo    🔹 Flashing %%p_b...
    %fastboot% flash %%p_b %%p_b.img >nul
)
echo ✅ Firmware flashed!
timeout /t 1 >nul

:: Flashing Logical Partitions
echo 🔄 Flashing Super Partition...
%fastboot% flash super super.img >nul
echo ✅ Super partition flashed!
timeout /t 1 >nul

:: ------------------------
:: FINALIZATION
:: ------------------------
echo 🔄 Setting Active Slot A...
%fastboot% --set-active=a >nul
echo ✅ Slot A set as active!

echo 🔄 Rebooting Device...
%fastboot% reboot >nul
echo ✅ Rebooting to System!

:: COMPLETION MESSAGE
cls
echo =============================================
echo   ✅ FASTBOOT READBACK FLASHING SUCCESSFUL!  
echo =============================================
echo 🎉 Your Nothing Phone 2a is now running the stock firmware.
echo ℹ️ You may now safely disconnect your device.
pause
exit