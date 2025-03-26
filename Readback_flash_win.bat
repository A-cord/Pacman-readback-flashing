@echo off
title FASTBOOT READBACK FLASHING
setlocal EnableDelayedExpansion

:: -----------------------------
:: LOGGING SETUP
:: -----------------------------
set LOG_FILE=%CD%\flash_log.txt
echo ====== Flashing Log Started at %DATE% %TIME% ====== > "%LOG_FILE%"

:: -----------------------------
:: ASCII HEADER
:: -----------------------------
echo =====================================================
echo =          FASTBOOT READBACK FLASHING               =
echo =              Nothing Phone 2a                     =
echo =====================================================
echo.

:: -----------------------------
:: CHECK DEVICE MODE & BOOTLOADER STATUS
:: -----------------------------
:DetectMode
echo [INFO] Detecting device mode...
adb get-state >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Device in ADB mode, rebooting to bootloader...
    adb reboot bootloader
    timeout /t 8 >nul
    goto DetectMode
)

fastboot getvar current-slot >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] No device detected in fastboot mode! Ensure it's connected.
    pause
    exit /b 1
)

fastboot flashing get_unlock_ability >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Bootloader is locked! Unlock before proceeding.
    pause
    exit /b 1
)

echo [INFO] Device in fastboot mode and bootloader is unlocked.

:: -----------------------------
:: FORMAT DEVICE (ERASE USERDATA & METADATA)
:: -----------------------------
echo =====================================================
echo =                 FORMATTING DEVICE                  =
echo =====================================================
fastboot erase userdata
fastboot erase metadata
if %errorlevel% neq 0 (
    echo [ERROR] Formatting failed!
    pause
    exit /b 1
)
echo [SUCCESS] Data & Metadata erased.

:: -----------------------------
:: FLASHING PARTITIONS WITH ANIMATION
:: -----------------------------
set "spinChars=[ -  ][ \  ][ |  ][ /  ]"
set /a spin=0

:FlashLoop
for %%p in (boot dtbo init_boot vendor_boot vbmeta vbmeta_system vbmeta_vendor) do (
    for %%s in (a b) do (
        set /a spin=0
        call :AnimatedText "Flashing %%p_%%s..."
        fastboot flash %%p_%%s %%p_%%s.img > nul 2>&1 
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to flash %%p_%%s!
            pause
            exit /b 1
        )
        echo [SUCCESS] %%p_%%s flashed!
    )
)

for %%p in (apusys audio_dsp ccu connsys_bt connsys_gnss connsys_wifi dpm gpueb gz lk logo mcupm mcf_ota md1img mvpu_algo pi_img scp spmfw sspm tee vcp) do (
    for %%s in (a b) do (
        set /a spin=0
        call :AnimatedText "Flashing %%p_%%s..."
        fastboot flash %%p_%%s %%p_%%s.img > nul 2>&1 
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to flash %%p_%%s!
            pause
            exit /b 1
        )
        echo [SUCCESS] %%p_%%s flashed!
    )
)

echo =====================================================
echo =             FLASHING SUPER PARTITION             =
echo =====================================================
call :AnimatedText "Flashing super.img..."
fastboot flash super super.img > nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to flash super.img!
    pause
    exit /b 1
)
echo [SUCCESS] Super partition flashed.

:: -----------------------------
:: REBOOT DEVICE
:: -----------------------------
echo =====================================================
echo =                REBOOTING DEVICE                   =
echo =====================================================
fastboot reboot
if %errorlevel% neq 0 (
    echo [ERROR] Reboot failed!
    pause
    exit /b 1
)
echo [SUCCESS] Device rebooted successfully.

echo =====================================================
echo =              FLASHING COMPLETE!                   =
echo =       Log saved to flash_log.txt                  =
echo =====================================================

pause
exit /b

:: -----------------------------
:: ANIMATED TEXT FUNCTION
:: -----------------------------
:AnimatedText
setlocal
set "message=%~1"
set /a spin=0
for /L %%i in (1,1,5) do (
    set /p=!message! !spinChars:~%spin%,7%! <nul
    set /a spin=(spin+1)%%4
    timeout /t 1 >nul
    echo.
)
exit /b