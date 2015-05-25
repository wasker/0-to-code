<#

.SYNOPSIS

Manipulates machine, user or process environment.

.EXAMPLE

PS > Get-Var -scope Machine -name PROCESSOR_REVISION
PS > Set-Var -scope User -name TEST -value "Hello world"
PS > Get-Path -scope Process
PS > Add-Path -scope User -path "C:\test"
PS > Add-Path -scope Machine -path "C:\test" -prefix "PSModule"
PS > Remove-Path -scope User -path "C:\test"

#>

function Get-Var {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.EnvironmentVariableTarget]$scope,
        [Parameter(Mandatory = $false)]
        [String]$name
    )

    if ($name -eq ""){
        [System.Environment]::GetEnvironmentVariables($scope).GetEnumerator() | Sort-Object Name
    }
    else {
        [System.Environment]::GetEnvironmentVariable($name, $scope)
    }
}

function Set-Var {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.EnvironmentVariableTarget]$scope,
        [Parameter(Mandatory = $true)]
        [String]$name,
        [Parameter(Mandatory = $false)]
        [String]$value
    )

    [System.Environment]::SetEnvironmentVariable($name, $value, $scope)
}

function Get-Path {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.EnvironmentVariableTarget]$scope,
        [Parameter(Mandatory = $false)]
        [String]$prefix
    )

    $paths = SplitPath -scope $scope -prefix $prefix

    $paths | foreach {
        $pathOut = New-Object psobject -Property @{
            Exists = ([System.IO.DirectoryInfo] $_).Exists
            Path = $_
        }

        $pathOut
    } | Format-Table @{Expression={$_.Exists};Label="Exists";Width=10;Alignment="Left"},Path
}

function Add-Path {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.EnvironmentVariableTarget]$scope,
        [Parameter(Mandatory = $true)]
        [String]$path,
        [Parameter(Mandatory = $false)]
        [String]$prefix
    )

    $paths = SplitPath -scope $scope -prefix $prefix
    $needle = NormalizePath -path $path

    $hasPath = $paths | foreach {
        $p = NormalizePath -path $_
        if ($p -like $needle) {
            $true
            return
        }
    }

    if ($hasPath -ne $true) {
        $paths += $path
        SetPath -scope $scope -value ($paths -join ";") -prefix $prefix
    }
}

function Remove-Path {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.EnvironmentVariableTarget]$scope,
        [Parameter(Mandatory = $true)]
        [String]$path,
        [Parameter(Mandatory = $false)]
        [String]$prefix
    )

    $paths = SplitPath -scope $scope -prefix $prefix
    $needle = NormalizePath -path $path

    $filteredPaths = $paths | foreach {
        $p = NormalizePath -path $_
        if (!($p -like $needle)) {
            $_
        }
    }

    SetPath -scope $scope -value ($filteredPaths -join ";") -prefix $prefix
}

Export-ModuleMember *-*

filter Invoke-Ternary ($Predicate, $Then, $Otherwise = $null) {
    if ($predicate -is [ScriptBlock]) { $predicate = &$predicate }

    if ($predicate) { 
        if($then -is [ScriptBlock]) { &$then }
        else { $then }
    } elseif($otherwise) { 
        if($otherwise -is [ScriptBlock]) { &$otherwise }
        else { $otherwise }
    }
}

filter Invoke-Coalescence($predicate, $alternative) {
    if($predicate -is [scriptblock]) { $predicate = &$predicate }

    Invoke-Ternary $predicate $predicate $alternative
}

set-alias ?: Invoke-Ternary -Option AllScope
set-alias ?? Invoke-Coalescence -Option AllScope

function SplitPath {
    param(
        [System.EnvironmentVariableTarget]$scope,
        [String]$prefix
    )

    $varprefix = (?? { $prefix } { "" })
    ,((?? { [System.Environment]::GetEnvironmentVariable($varprefix + "path", $scope) } { "" }).Split(";", [StringSplitOptions]::RemoveEmptyEntries))
}

function SetPath {
    param(
        [System.EnvironmentVariableTarget]$scope,
        [String]$value,
        [String]$prefix
    )

    $varprefix = (?? { $prefix } { "" })
    [System.Environment]::SetEnvironmentVariable($varprefix + "path", $value, $scope)
}

function NormalizePath{
    param(
        [String]$path
    )

    $needle = $path
    if (!$needle.EndsWith("\")) {
        $needle += "\"
    }

    $needle
}
