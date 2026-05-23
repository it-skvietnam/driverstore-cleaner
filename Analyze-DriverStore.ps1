[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot 'reports'),
    [string]$SessionId = (Get-Date -Format 'yyyyMMdd-HHmmss'),
    [switch]$IncludeRiskyClasses
)

$moduleScript = Join-Path $PSScriptRoot 'modules\driverstore\Analyze-DriverStore.ps1'
& $moduleScript -OutputDir $OutputDir -SessionId $SessionId -IncludeRiskyClasses:$IncludeRiskyClasses
exit $LASTEXITCODE
