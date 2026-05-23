[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$PrivateCsv,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$PublicCsv,

    [string]$OutputCsv = ''
)

$moduleScript = Join-Path $PSScriptRoot 'modules\driverstore\Merge-DriverResearchReview.ps1'
& $moduleScript -PrivateCsv $PrivateCsv -PublicCsv $PublicCsv -OutputCsv $OutputCsv
exit $LASTEXITCODE
