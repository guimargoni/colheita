@echo off
rem Versao integrada: temas e skins em Ajustes, Aparencia. -TwoPlayers -Fast testa duas contas.
powershell.exe -NoProfile -File "%~dp0tools\play_colheita.ps1" %*
pause
