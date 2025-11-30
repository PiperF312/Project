@echo off
setlocal

set CARD_TOOL=%~dp0CardTool.ps1
set TESTER_ID=USER123
set CARD_FILE=%~dp0%TESTER_ID%.vcard
set APP_EXE=%~dp0NotesApp.bat

echo ============================================
echo   Notes Manager Launcher
echo ============================================

REM === STEP 1: Check for license card ===
if not exist "%CARD_FILE%" (
    echo ERROR: No license card found in this folder.
    pause
    exit /b 1
)

REM === STEP 2: Validate license card ===
powershell -ExecutionPolicy Bypass -File "%CARD_TOOL%" validate -CardPath "%CARD_FILE%"
if errorlevel 1 (
    echo ERROR: License invalid or expired.
    pause
    exit /b 1
)

REM === STEP 3: Launch Notes App ===
echo License valid. Launching Notes Manager...
call "%APP_EXE%"

pause
endlocal
