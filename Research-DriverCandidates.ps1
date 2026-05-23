[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CandidatesCsv,

    [string]$OutputCsv = '',
    [string]$PublicOutputCsv = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $OutputCsv) {
    $directory = Split-Path -Parent $CandidatesCsv
    $OutputCsv = Join-Path $directory 'driverstore-research-review.csv'
}

if (-not $PublicOutputCsv) {
    $directory = Split-Path -Parent $OutputCsv
    $PublicOutputCsv = Join-Path $directory 'driverstore-research-public.csv'
}

$rows = @(Import-Csv -Path $CandidatesCsv)
$index = 0
$reviewRows = foreach ($row in $rows) {
    $index++
    $researchId = if ($row.PSObject.Properties.Name -contains 'ResearchId' -and $row.ResearchId) {
        [string]$row.ResearchId
    } else {
        'DRV-{0:D4}' -f $index
    }

    $provider = [string]$row.Provider
    $originalName = [string]$row.OriginalName
    $driverVersion = [string]$row.DriverVersion
    $className = [string]$row.ClassName

    $webQuery = '"' + $provider + '" "' + $originalName + '" "' + $driverVersion + '" driver'
    $vendorQuery = '"' + $provider + '" "' + $originalName + '" support driver download'
    $legacyQuery = '"' + $originalName + '" "' + $className + '" legacy Windows XP Windows 7 required'

    [pscustomobject]@{
        ResearchId = $researchId
        PublishedName = $row.PublishedName
        OriginalName = $row.OriginalName
        Provider = $row.Provider
        ClassName = $row.ClassName
        DriverDate = $row.DriverDate
        DriverVersion = $row.DriverVersion
        KeepPublishedName = $row.KeepPublishedName
        KeepDriverDate = $row.KeepDriverDate
        KeepDriverVersion = $row.KeepDriverVersion
        Reason = $row.Reason
        WebSearchQuery = $webQuery
        VendorSearchQuery = $vendorQuery
        LegacySearchQuery = $legacyQuery
        WebResearchStatus = 'PendingResearch'
        DriverAssessment = 'UnknownKeep'
        LatestVersionFound = ''
        LatestDriverDateFound = ''
        EvidenceUrl1 = ''
        EvidenceUrl2 = ''
        EvidenceSourceType = ''
        LegacyRisk = 'Unknown'
        ResearchNotes = ''
        DeleteApproved = 'FALSE'
    }
}

$reviewRows | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
$publicRows = foreach ($row in $reviewRows) {
    [pscustomobject]@{
        ResearchId = $row.ResearchId
        DriverName = $row.OriginalName
        WebSearchQuery = '"' + $row.OriginalName + '" driver'
        LegacySearchQuery = '"' + $row.OriginalName + '" legacy Windows XP Windows 7 required'
        WebResearchStatus = 'PendingResearch'
        DriverAssessment = 'UnknownKeep'
        LatestVersionFound = ''
        LatestDriverDateFound = ''
        EvidenceUrl1 = ''
        EvidenceUrl2 = ''
        EvidenceSourceType = ''
        LegacyRisk = 'Unknown'
        ResearchNotes = ''
        DeleteApproved = 'FALSE'
    }
}
$publicRows | Export-Csv -Path $PublicOutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Research review CSV: $OutputCsv"
Write-Host "Public anonymized research CSV: $PublicOutputCsv"
Write-Host 'Fill the research fields before deletion. Keep DeleteApproved=FALSE unless evidence confirms this is only an outdated duplicate.'

