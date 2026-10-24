@echo off
powershell.exe -NoProfile -File "%~dp0tools\play_care.ps1" -Fast
if errorlevel 1 pause
