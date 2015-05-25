# Location for chocolatey and npm repositories.
$global:root = $env:USERPROFILE

# Known locations.
$global:chocolateyRoot = "$root\.chocolatey"
$global:npmCache = "$root\.npm"
$global:npmRepository = "$root\.npmrepo"
$global:dnxRoot = "$env:USERPROFILE\.dnx"

# Set of NPM modules installed globally by default.
$global:defaultNpmModules = @("typescript", "yo", "bower", "gulp", "gulp-watch", "gulp-typescript", "tsd", "grunt-cli", "generator-aspnet")
