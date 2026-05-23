[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot 'reports'),
    [string]$SessionId = (Get-Date -Format 'yyyyMMdd-HHmmss'),
    [switch]$IncludeRiskyClasses
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertFrom-PnpUtilEnumDrivers {
    param([string[]]$Lines)

    $drivers = New-Object System.Collections.Generic.List[object]
    $current = [ordered]@{}

    foreach ($line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($current.Count -gt 0) {
                $drivers.Add([pscustomobject]$current)
                $current = [ordered]@{}
            }
            continue
        }

        if ($line -match '^\s*([^:]+?)\s*:\s*(.*)\s*$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $current[$key] = $value
        }
    }

    if ($current.Count -gt 0) {
        $drivers.Add([pscustomobject]$current)
    }

    foreach ($driver in $drivers) {
        $versionText = Get-FieldValue $driver @('Driver Version')
        $date = $null
        $version = $null

        if ($versionText -match '^(?<date>\S+)\s+(?<version>.+)$') {
            [datetime]$parsedDate = [datetime]::MinValue
            if ([datetime]::TryParse($matches.date, [ref]$parsedDate)) {
                $date = $parsedDate
            }
            $version = $matches.version
        }

        [pscustomobject]@{
            PublishedName = Get-FieldValue $driver @('Published Name')
            OriginalName = Get-FieldValue $driver @('Original Name')
            Provider = Get-FieldValue $driver @('Driver Package Provider', 'Provider Name')
            ClassName = Get-FieldValue $driver @('Class Name')
            ClassGuid = Get-FieldValue $driver @('Class GUID')
            DriverVersionText = $versionText
            DriverDate = $date
            DriverVersion = $version
            SignerName = Get-FieldValue $driver @('Signer Name')
        }
    }
}

function Get-FieldValue {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string[]]$Names
    )

    foreach ($name in $Names) {
        if ($Object.PSObject.Properties.Name -contains $name) {
            return [string]$Object.$name
        }
    }

    return ''
}

function Get-DriverGroupKey {
    param([Parameter(Mandatory)]$Driver)

    $original = if ($Driver.OriginalName) { $Driver.OriginalName } else { 'unknown-inf' }
    $provider = if ($Driver.Provider) { $Driver.Provider } else { 'unknown-provider' }
    $class = if ($Driver.ClassName) { $Driver.ClassName } else { 'unknown-class' }
    return "$provider|$class|$original"
}

function Export-PublicResearchCsv {
    param(
        [Parameter(Mandatory)][object[]]$Rows,
        [Parameter(Mandatory)][string]$Path
    )

    $headers = @(
        'ResearchId',
        'DriverName',
        'WebSearchQuery',
        'LegacySearchQuery',
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
    )

    if ($Rows.Count -eq 0) {
        ($headers -join ',') | Set-Content -Path $Path -Encoding UTF8
        return
    }

    $Rows | Select-Object $headers | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$rawPath = Join-Path $OutputDir 'driverstore-raw.txt'
$allPath = Join-Path $OutputDir 'driverstore-all.csv'
$candidatePath = Join-Path $OutputDir 'driverstore-candidates.csv'
$reviewPath = Join-Path $OutputDir 'driverstore-research-review.csv'
$sessionDir = Join-Path (Join-Path $OutputDir 'sessions') $SessionId
$privateReviewPath = Join-Path $sessionDir 'driverstore-research-private.csv'
$publicReviewPath = Join-Path $sessionDir 'driverstore-research-public.csv'

New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null

$rawLines = & pnputil /enum-drivers
$rawLines | Set-Content -Path $rawPath -Encoding UTF8

$drivers = @(ConvertFrom-PnpUtilEnumDrivers -Lines $rawLines)
$drivers | Export-Csv -Path $allPath -NoTypeInformation -Encoding UTF8

$riskyClassPattern = '(?i)display|net|bluetooth|system|media|audio|sound|hdc|scsi|storage|disk|usb|printer|firmware|extension|softwarecomponent'
$candidates = New-Object System.Collections.Generic.List[object]
$candidateIndex = 0

$drivers |
    Where-Object { $_.PublishedName -match '^oem\d+\.inf$' } |
    Group-Object { Get-DriverGroupKey $_ } |
    Where-Object { $_.Count -gt 1 } |
    ForEach-Object {
        $items = @($_.Group | Sort-Object @{ Expression = 'DriverDate'; Descending = $true }, @{ Expression = 'DriverVersion'; Descending = $true }, PublishedName)
        $keep = $items[0]

        foreach ($old in $items | Select-Object -Skip 1) {
            $isRisky = $old.ClassName -match $riskyClassPattern
            if ($isRisky -and -not $IncludeRiskyClasses) {
                continue
            }

            $candidateIndex++
            $researchId = 'DRV-{0:D4}' -f $candidateIndex

            $candidates.Add([pscustomobject]@{
                ResearchId = $researchId
                PublishedName = $old.PublishedName
                OriginalName = $old.OriginalName
                Provider = $old.Provider
                ClassName = $old.ClassName
                DriverDate = $old.DriverDate
                DriverVersion = $old.DriverVersion
                KeepPublishedName = $keep.PublishedName
                KeepDriverDate = $keep.DriverDate
                KeepDriverVersion = $keep.DriverVersion
                Reason = 'Older duplicate; newest matching driver kept'
                WebSearchQuery = '"' + $old.Provider + '" "' + $old.OriginalName + '" "' + $old.DriverVersion + '" driver'
                VendorSearchQuery = '"' + $old.Provider + '" "' + $old.OriginalName + '" support driver download'
                LegacySearchQuery = '"' + $old.OriginalName + '" "' + $old.ClassName + '" legacy Windows XP Windows 7 required'
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
            })
        }
    }

$candidates | Export-Csv -Path $candidatePath -NoTypeInformation -Encoding UTF8
$candidates | Export-Csv -Path $reviewPath -NoTypeInformation -Encoding UTF8
$candidates | Export-Csv -Path $privateReviewPath -NoTypeInformation -Encoding UTF8

$publicReviewRows = foreach ($candidate in $candidates) {
    [pscustomobject]@{
        ResearchId = $candidate.ResearchId
        DriverName = $candidate.OriginalName
        WebSearchQuery = '"' + $candidate.OriginalName + '" driver'
        LegacySearchQuery = '"' + $candidate.OriginalName + '" legacy Windows XP Windows 7 required'
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
Export-PublicResearchCsv -Rows @($publicReviewRows) -Path $publicReviewPath

Write-Host "Raw output: $rawPath"
Write-Host "All drivers: $allPath"
Write-Host "Candidates: $candidatePath"
Write-Host "Research review CSV: $reviewPath"
Write-Host "Private session review CSV: $privateReviewPath"
Write-Host "Public anonymized review CSV: $publicReviewPath"
Write-Host "Candidate count: $($candidates.Count)"
if (-not $IncludeRiskyClasses) {
    Write-Host 'Risky driver classes were excluded. Re-run with -IncludeRiskyClasses only for manual investigation.'
}
