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

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $OutputCsv) {
    $directory = Split-Path -Parent $PrivateCsv
    $OutputCsv = Join-Path $directory 'driverstore-research-merged.csv'
}

$privateRows = @(Import-Csv -Path $PrivateCsv)
$publicRows = @(Import-Csv -Path $PublicCsv)
$publicById = @{}

foreach ($row in $publicRows) {
    $id = [string]$row.ResearchId
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Warning 'Skipping public row with empty ResearchId.'
        continue
    }
    $publicById[$id] = $row
}

$mergedRows = foreach ($private in $privateRows) {
    $id = [string]$private.ResearchId
    if (-not $publicById.ContainsKey($id)) {
        Write-Warning "No public review found for $id; keeping private row unchanged."
        $private
        continue
    }

    $public = $publicById[$id]
    foreach ($field in @(
        'WebResearchStatus',
        'DriverAssessment',
        'LatestVersionFound',
        'LatestDriverDateFound',
        'EvidenceUrl1',
        'EvidenceUrl2',
        'EvidenceSourceType',
        'LegacyRisk',
        'ResearchNotes',
        'DeleteApproved'
    )) {
        if ($private.PSObject.Properties.Name -contains $field -and $public.PSObject.Properties.Name -contains $field) {
            $private.$field = $public.$field
        }
    }
    $private
}

$mergedRows | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Merged private review CSV: $OutputCsv"
Write-Host 'Use this merged private CSV for dry-run or deletion.'
