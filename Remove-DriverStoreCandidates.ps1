[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CandidatesCsv,

    [switch]$Execute,
    [switch]$ForceDelete,
    [switch]$AllowUnreviewed
)

$moduleScript = Join-Path $PSScriptRoot 'modules\driverstore\Remove-DriverStoreCandidates.ps1'
& $moduleScript -CandidatesCsv $CandidatesCsv -Execute:$Execute -ForceDelete:$ForceDelete -AllowUnreviewed:$AllowUnreviewed -WhatIf:$WhatIfPreference
exit $LASTEXITCODE
