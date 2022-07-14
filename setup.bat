@echo off
mklink %AppData%\Code\User\settings.json .\config\vscode\User\settings.json

rem VSCode Extentions
for /f "delims=" %%a in (.\config\vscode\extensions.txt) do (
  code --install-extension %%a
)
