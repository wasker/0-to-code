Import-Module .\settings.psm1
Import-Module .\envy.psm1

# Setup chocolatey in known location.
Set-Var -scope Process -name ChocolateyInstall -value "$chocolateyRoot"
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
Add-Path -scope Process -path "$chocolateyRoot\bin"

# Setup tools/bin root for portable packages.
Set-Var -scope Process -name ChocolateyBinRoot -value "$chocolateyToolsRoot"
Set-Var -scope User -name ChocolateyBinRoot -value "$chocolateyToolsRoot"
Add-Path -scope Process -path "$chocolateyToolsRoot"
Add-Path -scope User -path "$chocolateyToolsRoot"

# Allow uninstallers to be executed.
choco feature enable --name=autoUninstaller

# Setup ConEmu.
choco install conemu -y

# Install nodejs and configure NPM to use known locations.
Write-Host "Installing nodejs..."
$nodeRoot = "$env:ProgramFiles\nodejs"
$chocolateyRoot | .\Invoke-ElevatedCommand.ps1 { &"$input\bin\choco" install nodejs.install -y --ia "ADDLOCAL=NodeRuntime,npm" }
Add-Path -scope User -path "$nodeRoot"
Add-Path -scope Process -path "$nodeRoot"

# Setup local NPM cache and repository.
npm config set cache "$npmCache"
npm config set prefix "$npmRepository"
Add-Path -scope User -path "$npmRepository"

# Install default set of NPM modules.
npm install -g $defaultNpmModules

# Install git.
$gitRegistryKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1"
if ((Test-Path $gitRegistryKey) -eq $false) {
    New-Item -Path $gitRegistryKey
}
choco install git.install -y -params '"/GitAndUnixToolsOnPath /NoAutoCrlf"'

# Help git tools find correct locations.
Set-Var User HOME $root
&"$env:LOCALAPPDATA\Programs\Git\cmd\git" config --global credential.helper wincred

# Setup .NET.
&{$Branch='dev';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.ps1'))}
&"$dnxRoot\bin\dnvm" upgrade

# Install Visual Studio Code.
$vscodeRoot = "$env:LOCALAPPDATA\Code\bin"
choco install visualstudiocode -y
Add-Path -scope User -path "$vscodeRoot"

Write-Host "All done! Please close this window and start ConEmu."
