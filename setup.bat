@echo off
mklink %AppData%\Code\User\settings.json %~dp0\vscode\User\settings.json

rem VSCode Extentions
for /f "delims=" %%a in (.\vscode\extensions.txt) do (
  code --install-extension %%a
)
