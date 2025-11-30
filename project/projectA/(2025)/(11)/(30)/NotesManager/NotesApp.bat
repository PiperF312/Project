@echo off
echo ============================================
echo   Notes Manager Application
echo ============================================
set /p note=Enter a note to save: 
echo %note% >> "%~dp0notes.txt"
echo Note saved to notes.txt
pause
