@echo off
REM === Navigate to the folder where this batch file lives ===
cd /d "%~dp0"

REM === Run the bot script inside the Bot folder ===
python Bot\bot.py

REM === Keep window open after execution ===
pause
