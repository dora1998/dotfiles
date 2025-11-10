Import-Module posh-git
Import-Module oh-my-posh
Import-Module Set-PsEnv
Set-Theme Paradox
Set-PsEnv

function CdByGhq { cd (ghq list -p | peco) }
sal cdg CdByGhq

function CustomSudo {Start-Process powershell.exe -Verb runas}
sal sudo CustomSudo