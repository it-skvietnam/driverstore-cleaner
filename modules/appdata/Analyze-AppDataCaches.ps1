[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\..\reports'),
    [string]$SessionId = (Get-Date -Format 'yyyyMMdd-HHmmss'),
    [int]$MaxDepth = 6,
    [int]$TopLocalFolders = 30,
    [switch]$RedactPublicFolderNames
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-DirectorySizeBytes {
    param(
        [Parameter(Mandatory)][string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return 0
    }

    try {
        $sum = (Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        if ($null -eq $sum) {
            return 0
        }
        return [int64]$sum
    }
    catch {
        return 0
    }
}

function New-AppDataCandidate {
    param(
        [Parameter(Mandatory)][string]$SessionId,
        [Parameter(Mandatory)][string]$ResearchId,
        [Parameter(Mandatory)][string]$ItemName,
        [Parameter(Mandatory)][string]$ItemType,
        [Parameter(Mandatory)][string]$LocalPath,
        [Parameter(Mandatory)][string]$RiskLevel,
        [Parameter(Mandatory)][string]$Assessment,
        [Parameter(Mandatory)][string]$CleanupMethod,
        [Parameter(Mandatory)][string]$PublicNotes
    )

    $size = Get-DirectorySizeBytes -Path $LocalPath
    [pscustomobject]@{
        SessionId = $SessionId
        Module = 'appdata'
        ResearchId = $ResearchId
        ItemName = $ItemName
        ItemType = $ItemType
        LocalPath = $LocalPath
        EstimatedSizeBytes = $size
        EstimatedSizeMB = [math]::Round($size / 1MB, 2)
        RiskLevel = $RiskLevel
        CleanupMethod = $CleanupMethod
        ResearchStatus = 'PendingResearch'
        Assessment = $Assessment
        EvidenceUrl1 = ''
        EvidenceUrl2 = ''
        DeleteApproved = 'FALSE'
        PublicNotes = $PublicNotes
    }
}

function Export-PublicAppDataCsv {
    param(
        [Parameter(Mandatory)][object[]]$Rows,
        [Parameter(Mandatory)][string]$Path
    )

    $headers = @(
        'SessionId',
        'Module',
        'ResearchId',
        'ItemName',
        'ItemType',
        'EstimatedSizeBytes',
        'EstimatedSizeMB',
        'RiskLevel',
        'CleanupMethod',
        'ResearchStatus',
        'Assessment',
        'EvidenceUrl1',
        'EvidenceUrl2',
        'DeleteApproved',
        'PublicNotes'
    )

    if ($Rows.Count -eq 0) {
        ($headers -join ',') | Set-Content -Path $Path -Encoding UTF8
        return
    }

    $Rows | Select-Object $headers | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
}

function Export-PrivateAppDataCsv {
    param(
        [Parameter(Mandatory)][object[]]$Rows,
        [Parameter(Mandatory)][string]$Path
    )

    $Rows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
}

function Get-AppDataTopLevelInventory {
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
            Module = 'appdata'
            InventoryId = ''
            Scope = 'LocalAppDataTopLevel'
            FolderName = $directory.Name
            LocalPath = $directory.FullName
            EstimatedSizeBytes = $size
            EstimatedSizeMB = [math]::Round($size / 1MB, 2)
            RiskLevel = 'ReviewRequired'
            Assessment = 'InventoryOnly'
            PublicNotes = 'Top-level LocalAppData inventory. This is not a cleanup candidate by itself.'
        })
    }

    $rank = 0
    foreach ($row in @($rows | Sort-Object EstimatedSizeBytes -Descending | Select-Object -First $Top)) {
        $rank++
        $row.InventoryId = 'LOCALTOP-{0:D4}' -f $rank
        $row
    }
}

function Export-PublicInventoryCsv {
    param(
        [Parameter(Mandatory)][object[]]$Rows,
        [Parameter(Mandatory)][string]$Path,
        [switch]$RedactPublicFolderNames
    )

    $publicRows = foreach ($row in $Rows) {
        $displayName = if ($RedactPublicFolderNames) {
            'LocalAppData top-level #{0:D2}' -f ([int]($row.InventoryId -replace '\D', ''))
        } else {
            $row.FolderName
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
            PublicNotes = if ($RedactPublicFolderNames) {
                'Folder name redacted in public output; see private report locally.'
            } else {
                $row.PublicNotes
            }
        }
    }

    $publicRows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
}

$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
$roamingAppData = [Environment]::GetFolderPath('ApplicationData')
$userProfile = [Environment]::GetFolderPath('UserProfile')

$sessionDir = Join-Path (Join-Path $OutputDir 'sessions') $SessionId
New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null

$privatePath = Join-Path $sessionDir 'appdata-research-private.csv'
$publicPath = Join-Path $sessionDir 'appdata-research-public.csv'
$topPrivatePath = Join-Path $sessionDir 'appdata-localtop-private.csv'
$topPublicPath = Join-Path $sessionDir 'appdata-localtop-public.csv'

$definitions = @(
    @{
        ItemName = 'Local Temp'
        ItemType = 'temp-cache'
        LocalPath = Join-Path $localAppData 'Temp'
        RiskLevel = 'SafeWithClosedApps'
        Assessment = 'SafeWithClosedApps'
        CleanupMethod = 'FutureDeleteCacheFolder'
        PublicNotes = 'User temp files. Future cleanup requires closed apps and explicit approval.'
    },
    @{
        ItemName = 'Microsoft Office File Cache'
        ItemType = 'office-cache'
        LocalPath = Join-Path $localAppData 'Microsoft\Office\16.0\OfficeFileCache'
        RiskLevel = 'SafeWithClosedApps'
        Assessment = 'SafeWithClosedApps'
        CleanupMethod = 'FutureDeleteCacheFolder'
        PublicNotes = 'Office document cache. Close Office apps before future cleanup.'
    },
    @{
        ItemName = 'Microsoft Teams Cache'
        ItemType = 'teams-cache'
        LocalPath = Join-Path $roamingAppData 'Microsoft\Teams'
        RiskLevel = 'SafeWithClosedApps'
        Assessment = 'SafeWithClosedApps'
        CleanupMethod = 'FutureDeleteCacheFolder'
        PublicNotes = 'Teams cache/state area. Needs narrower cache subfolder policy before cleanup.'
    },
    @{
        ItemName = 'Chrome Cache'
        ItemType = 'browser-cache'
        LocalPath = Join-Path $localAppData 'Google\Chrome\User Data\Default\Cache'
        RiskLevel = 'SafeWithClosedApps'
        Assessment = 'SafeWithClosedApps'
        CleanupMethod = 'FutureDeleteCacheFolder'
        PublicNotes = 'Browser cache folder only. Never delete entire browser profile.'
    },
    @{
        ItemName = 'Edge Cache'
        ItemType = 'browser-cache'
        LocalPath = Join-Path $localAppData 'Microsoft\Edge\User Data\Default\Cache'
        RiskLevel = 'SafeWithClosedApps'
        Assessment = 'SafeWithClosedApps'
        CleanupMethod = 'FutureDeleteCacheFolder'
        PublicNotes = 'Browser cache folder only. Never delete entire browser profile.'
    },
    @{
        ItemName = 'npm Cache'
        ItemType = 'dev-cache'
        LocalPath = Join-Path $roamingAppData 'npm-cache'
        RiskLevel = 'ReviewRequired'
        Assessment = 'ReviewRequired'
        CleanupMethod = 'FuturePackageManagerClean'
        PublicNotes = 'Prefer npm cache tooling in future cleanup.'
    },
    @{
        ItemName = 'pip Cache'
        ItemType = 'dev-cache'
        LocalPath = Join-Path $localAppData 'pip\Cache'
        RiskLevel = 'ReviewRequired'
        Assessment = 'ReviewRequired'
        CleanupMethod = 'FuturePackageManagerClean'
        PublicNotes = 'Prefer pip cache tooling in future cleanup.'
    },
    @{
        ItemName = 'NuGet Cache'
        ItemType = 'dev-cache'
        LocalPath = Join-Path $userProfile '.nuget\packages'
        RiskLevel = 'ReviewRequired'
        Assessment = 'ReviewRequired'
        CleanupMethod = 'FuturePackageManagerClean'
        PublicNotes = 'Global package cache. May affect dev workflow.'
    },
    @{
        ItemName = 'Gradle Cache'
        ItemType = 'dev-cache'
        LocalPath = Join-Path $userProfile '.gradle\caches'
        RiskLevel = 'ReviewRequired'
        Assessment = 'ReviewRequired'
        CleanupMethod = 'FuturePackageManagerClean'
        PublicNotes = 'Gradle cache. May affect dev workflow.'
    },
    @{
        ItemName = 'Yarn Cache'
        ItemType = 'dev-cache'
        LocalPath = Join-Path $localAppData 'Yarn\Cache'
        RiskLevel = 'ReviewRequired'
        Assessment = 'ReviewRequired'
        CleanupMethod = 'FuturePackageManagerClean'
        PublicNotes = 'Prefer Yarn cache tooling in future cleanup.'
    },
    @{
        ItemName = 'Outlook Offline Store'
        ItemType = 'mail-store'
        LocalPath = Join-Path $localAppData 'Microsoft\Outlook'
        RiskLevel = 'DoNotDelete'
        Assessment = 'DoNotDelete'
        CleanupMethod = 'ExplainOnly'
        PublicNotes = 'Outlook OST/PST area. Report only; adjust sync settings instead of deleting.'
    }
)

$rows = New-Object System.Collections.Generic.List[object]
$index = 0
foreach ($definition in $definitions) {
    $index++
    $researchId = 'APPDATA-{0:D4}' -f $index
    $rows.Add((New-AppDataCandidate `
        -SessionId $SessionId `
        -ResearchId $researchId `
        -ItemName $definition.ItemName `
        -ItemType $definition.ItemType `
        -LocalPath $definition.LocalPath `
        -RiskLevel $definition.RiskLevel `
        -Assessment $definition.Assessment `
        -CleanupMethod $definition.CleanupMethod `
        -PublicNotes $definition.PublicNotes))
}

$sortedRows = @($rows | Sort-Object EstimatedSizeBytes -Descending)
Export-PrivateAppDataCsv -Rows $sortedRows -Path $privatePath
Export-PublicAppDataCsv -Rows $sortedRows -Path $publicPath

$topRows = @(Get-AppDataTopLevelInventory -SessionId $SessionId -RootPath $localAppData -Top $TopLocalFolders)
Export-PrivateAppDataCsv -Rows $topRows -Path $topPrivatePath
Export-PublicInventoryCsv -Rows $topRows -Path $topPublicPath -RedactPublicFolderNames:$RedactPublicFolderNames

$totalBytes = ($sortedRows | Measure-Object -Property EstimatedSizeBytes -Sum).Sum
if ($null -eq $totalBytes) {
    $totalBytes = 0
}
$topTotalBytes = ($topRows | Measure-Object -Property EstimatedSizeBytes -Sum).Sum
if ($null -eq $topTotalBytes) {
    $topTotalBytes = 0
}

Write-Host "Private AppData report: $privatePath"
Write-Host "Public AppData report: $publicPath"
Write-Host "Private LocalAppData top-level inventory: $topPrivatePath"
Write-Host "Public LocalAppData top-level inventory: $topPublicPath"
Write-Host "Rows: $($sortedRows.Count)"
Write-Host "Estimated total MB: $([math]::Round($totalBytes / 1MB, 2))"
Write-Host "Top-level inventory rows: $($topRows.Count)"
Write-Host "Top-level inventory total MB: $([math]::Round($topTotalBytes / 1MB, 2))"
Write-Host 'Analyze-only: no files were deleted.'
