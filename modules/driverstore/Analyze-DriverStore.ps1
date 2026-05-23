[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot 'reports'),
    [string]$SessionId = (Get-Date -Format 'yyyyMMdd-HHmmss'),
    [switch]$IncludeRiskyClasses,
    [int]$TopFileRepositoryFolders = 30,
    [switch]$PublicFolderNames
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
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Rows,
        [Parameter(Mandatory)][string]$Path
    )

    $headers = @(
        'ResearchId',
        'DriverName',
        'PackageFolderCount',
        'EstimatedPackageSizeBytes',
        'EstimatedPackageSizeMB',
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

function Get-DirectorySizeBytes {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return 0
    }

    $total = 0L
    Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
        ForEach-Object { $total += $_.Length }

    return $total
}

function Get-DriverStoreTopLevelInventory {
    param(
        [Parameter(Mandatory)][string]$SessionId,
        [Parameter(Mandatory)][string]$RootPath,
        [Parameter(Mandatory)][int]$Top
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        return @()
    }

    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($directory in Get-ChildItem -LiteralPath $RootPath -Directory -Force -ErrorAction SilentlyContinue) {
        $size = Get-DirectorySizeBytes -Path $directory.FullName
        $rows.Add([pscustomobject]@{
            SessionId = $SessionId
            Module = 'driverstore'
            InventoryId = ''
            Scope = 'DriverStoreFileRepositoryTopLevel'
            FolderName = $directory.Name
            LocalPath = $directory.FullName
            EstimatedSizeBytes = $size
            EstimatedSizeMB = [math]::Round($size / 1MB, 2)
            RiskLevel = 'ReviewRequired'
            Assessment = 'InventoryOnly'
            PublicNotes = 'Top-level DriverStore FileRepository inventory. This is not a cleanup candidate by itself.'
        })
    }

    $rank = 0
    foreach ($row in @($rows | Sort-Object EstimatedSizeBytes -Descending | Select-Object -First $Top)) {
        $rank++
        $row.InventoryId = 'DRVSTORE-TOP-{0:D4}' -f $rank
        $row
    }
}

function Get-DriverPackageFolderStats {
    param(
        [Parameter(Mandatory)][string]$FileRepositoryPath,
        [Parameter(Mandatory)][string]$OriginalName
    )

    if ([string]::IsNullOrWhiteSpace($OriginalName) -or
        -not (Test-Path -LiteralPath $FileRepositoryPath -PathType Container)) {
        return [pscustomobject]@{
            PackageFolderCount = 0
            EstimatedPackageSizeBytes = 0L
            EstimatedPackageSizeMB = 0
        }
    }

    $escapedName = [regex]::Escape($OriginalName)
    $folders = @(Get-ChildItem -LiteralPath $FileRepositoryPath -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "^$escapedName_" })

    $total = 0L
    foreach ($folder in $folders) {
        $total += Get-DirectorySizeBytes -Path $folder.FullName
    }

    [pscustomobject]@{
        PackageFolderCount = $folders.Count
        EstimatedPackageSizeBytes = $total
        EstimatedPackageSizeMB = [math]::Round($total / 1MB, 2)
    }
}

function Export-PublicInventoryCsv {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Rows,
        [Parameter(Mandatory)][string]$Path,
        [switch]$PublicFolderNames
    )

    $publicRows = foreach ($row in $Rows) {
        $rank = [int]($row.InventoryId -replace '\D', '')
        $displayName = if ($PublicFolderNames) {
            $row.FolderName
        } else {
            'DriverStore FileRepository top-level #{0:D2}' -f $rank
        }

        [pscustomobject]@{
            SessionId = $row.SessionId
            Module = $row.Module
            InventoryId = $row.InventoryId
            Scope = $row.Scope
            ItemName = $displayName
            ItemType = 'top-level-inventory'
            EstimatedSizeBytes = $row.EstimatedSizeBytes
            EstimatedSizeMB = $row.EstimatedSizeMB
            RiskLevel = $row.RiskLevel
            Assessment = $row.Assessment
            PublicNotes = if ($PublicFolderNames) {
                $row.PublicNotes
            } else {
                'Folder name redacted in public output; see private report locally.'
            }
        }
    }

    $publicRows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$rawPath = Join-Path $OutputDir 'driverstore-raw.txt'
$allPath = Join-Path $OutputDir 'driverstore-all.csv'
$candidatePath = Join-Path $OutputDir 'driverstore-candidates.csv'
$reviewPath = Join-Path $OutputDir 'driverstore-research-review.csv'
$sessionDir = Join-Path (Join-Path $OutputDir 'sessions') $SessionId
$privateReviewPath = Join-Path $sessionDir 'driverstore-research-private.csv'
$publicReviewPath = Join-Path $sessionDir 'driverstore-research-public.csv'
$topPrivatePath = Join-Path $sessionDir 'driverstore-filerepository-top-private.csv'
$topPublicPath = Join-Path $sessionDir 'driverstore-filerepository-top-public.csv'

New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null

$rawLines = & pnputil /enum-drivers
$rawLines | Set-Content -Path $rawPath -Encoding UTF8

$drivers = @(ConvertFrom-PnpUtilEnumDrivers -Lines $rawLines)
$drivers | Export-Csv -Path $allPath -NoTypeInformation -Encoding UTF8
$fileRepositoryPath = Join-Path $env:WINDIR 'System32\DriverStore\FileRepository'

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
            $packageStats = Get-DriverPackageFolderStats -FileRepositoryPath $fileRepositoryPath -OriginalName $old.OriginalName

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
                PackageFolderCount = $packageStats.PackageFolderCount
                EstimatedPackageSizeBytes = $packageStats.EstimatedPackageSizeBytes
                EstimatedPackageSizeMB = $packageStats.EstimatedPackageSizeMB
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
        PackageFolderCount = $candidate.PackageFolderCount
        EstimatedPackageSizeBytes = $candidate.EstimatedPackageSizeBytes
        EstimatedPackageSizeMB = $candidate.EstimatedPackageSizeMB
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

$topRows = @(Get-DriverStoreTopLevelInventory -SessionId $SessionId -RootPath $fileRepositoryPath -Top $TopFileRepositoryFolders)
$topRows | Export-Csv -Path $topPrivatePath -NoTypeInformation -Encoding UTF8
Export-PublicInventoryCsv -Rows $topRows -Path $topPublicPath -PublicFolderNames:$PublicFolderNames

$topTotalBytes = ($topRows | Measure-Object -Property EstimatedSizeBytes -Sum).Sum
if ($null -eq $topTotalBytes) {
    $topTotalBytes = 0
}

Write-Host "Raw output: $rawPath"
Write-Host "All drivers: $allPath"
Write-Host "Candidates: $candidatePath"
Write-Host "Research review CSV: $reviewPath"
Write-Host "Private session review CSV: $privateReviewPath"
Write-Host "Public anonymized review CSV: $publicReviewPath"
Write-Host "Private FileRepository top-level inventory: $topPrivatePath"
Write-Host "Public FileRepository top-level inventory: $topPublicPath"
Write-Host "Candidate count: $($candidates.Count)"
Write-Host "Top-level FileRepository inventory rows: $($topRows.Count)"
Write-Host "Top-level FileRepository inventory total MB: $([math]::Round($topTotalBytes / 1MB, 2))"
if (-not $IncludeRiskyClasses) {
    Write-Host 'Risky driver classes were excluded. Re-run with -IncludeRiskyClasses only for manual investigation.'
}
