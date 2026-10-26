@echo off
powershell.exe -NoProfile -File "%~dp0tools\play_cultures.ps1" -Fast
if errorlevel 1 pause
