[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CandidatesCsv,

    [string]$OutputCsv = '',
    [string]$PublicOutputCsv = ''
)

$moduleScript = Join-Path $PSScriptRoot 'modules\driverstore\Research-DriverCandidates.ps1'
& $moduleScript -CandidatesCsv $CandidatesCsv -OutputCsv $OutputCsv -PublicOutputCsv $PublicOutputCsv
exit $LASTEXITCODE
