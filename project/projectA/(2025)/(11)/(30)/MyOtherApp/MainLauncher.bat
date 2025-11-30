@echo off
setlocal

REM === CONFIG ===
set CARD_TOOL=%~dp0CardTool.ps1
set TESTER_ID=USER123
set CARD_FILE=%USERPROFILE%\Desktop\%TESTER_ID%.vcard

REM === STEP 1: Generate card if missing ===
if not exist "%CARD_FILE%" (
    echo No license card found. Generating new card for %TESTER_ID%...
    powershell -ExecutionPolicy Bypass -File "%CARD_TOOL%" generate -TesterId "%TESTER_ID%" -DaysValid 365 -OutPath "%CARD_FILE%"
)

REM === STEP 2: Validate card ===
powershell -ExecutionPolicy Bypass -File "%CARD_TOOL%" validate -CardPath "%CARD_FILE%"
if errorlevel 1 (
    echo License invalid or expired. Please regenerate your card.
    pause
    exit /b 1
)

REM === STEP 3: Licensing app runs freely (no license check for itself) ===
echo License card valid. This licensing app is the exception — it runs without needing a license.
echo It has generated/validated your card: %CARD_FILE%
pause

endlocal
