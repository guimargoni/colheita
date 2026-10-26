@echo off
powershell.exe -NoProfile -File "%~dp0tools\play_land.ps1" -Fast
if errorlevel 1 pause
