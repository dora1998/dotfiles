New-Item -Type SymbolicLink $home\OneDrive\ドキュメント\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Value .\Microsoft.PowerShell_profile.ps1

# Install Scoop
iwr -useb get.scoop.sh | iex

# Enable extra buckets
scoop install git
scoop bucket add extras
# Install scoop-viewer
scoop bucket add viewer https://github.com/prezesp/scoop-viewer-bucket
scoop install scoop-viewer

# Install posh-git
scoop install conemu
Install-Module posh-git -Scope CurrentUser
# Install oh-my-posh
Install-Module oh-my-posh -Scope CurrentUser