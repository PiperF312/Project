📖 README – Verification & Licensing System
Overview
This repository provides a verification system that issues and validates license cards.

Everyone is free to download and use this code as long as they follow the rules.

The rules are simple: do not edit, tamper, or redistribute modified versions of the system.

The system ensures that all projects run only when a valid license card is present.

Files in This Repository
CardTool.ps1 → PowerShell script that generates and validates license cards.

MainLauncher.bat → Licensing app that creates your card if missing and validates it.

LICENSE.txt → Legal agreement covering usage of the system.

How It Works
Generate a License Card

Run MainLauncher.bat.

If no card exists, it will create one (USER123.vcard by default).

Cards include a tester ID, customer ID, issue date, expiry date, and signature.

Validate a License Card

Each time you run MainLauncher.bat, the card is checked.

If expired or tampered with, the system will reject it.

Integration Into Projects

All your projects are BAT‑file based.

To integrate licensing, copy CardTool.ps1 into the project folder.

Add a launcher BAT file (example below) that checks for the card before running your app.

bat
@echo off
setlocal
set CARD_TOOL=%~dp0CardTool.ps1
set TESTER_ID=USER123
set CARD_FILE=%~dp0%TESTER_ID%.vcard
set APP_EXE=%~dp0MyApp.exe

if not exist "%CARD_FILE%" (
    echo ERROR: No license card found. Please paste your card here.
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%CARD_TOOL%" validate -CardPath "%CARD_FILE%"
if errorlevel 1 (
    echo ERROR: License invalid or expired.
    pause
    exit /b 1
)

echo License valid. Launching app...
start "" "%APP_EXE%"
endlocal
Managing Cards

You can easily upload or remove the .vcard file in any project folder.

Removing the card disables the project until a valid card is restored.

This gives you full control over who can run your projects.

Rules
✅ You may download and use this system freely.

❌ You may not edit or tamper with the verification code.

✅ You may integrate it into your own BAT‑file projects.

❌ You may not redistribute altered versions of the system.

Why BAT Files?
All projects are run by BAT files for security reasons. This makes it easy to:

Control execution flow.

Require the license card before launching.

Add/remove cards quickly without touching the core app.

⚡ With this README in place, anyone visiting your GitHub will understand:

What the system is.

How to use it.

How to integrate it into their own projects.

The rules they must follow.
