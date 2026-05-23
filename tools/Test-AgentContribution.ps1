[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
    $tracked = @(& git ls-files)
    if ($LASTEXITCODE -ne 0) {
        throw "This validation script must run inside a git repository."
    }
    $failures = New-Object System.Collections.Generic.List[string]

    $privatePathPatterns = @(
        '^docs/private/',
        '^reports/driverstore-raw\.txt$',
        '^reports/driverstore-all\.csv$',
        '^reports/driverstore-candidates\.csv$',
        '^reports/driverstore-research-review\.csv$',
        '^reports/sessions/[^/]+/driverstore-research-private\.csv$',
        '^reports/sessions/[^/]+/driverstore-research-merged\.csv$',
        '^reports/sessions/[^/]+/.*private.*\.csv$',
        '^reports/sessions/[^/]+/.*merged.*\.csv$',
        '^reports/sessions/[^/]+/.*\.log$'
    )

    foreach ($file in $tracked) {
        $normalized = $file -replace '\\', '/'
        foreach ($pattern in $privatePathPatterns) {
            if ($normalized -match $pattern) {
                $failures.Add("Private file is tracked: $file")
            }
        }
    }

    $publicCsvs = @($tracked | Where-Object { ($_ -replace '\\', '/') -match '^reports/sessions/[^/]+/driverstore-research-public\.csv$' })
    $requiredPublicHeaders = @(
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

    foreach ($csv in $publicCsvs) {
        $content = Get-Content -Path $csv -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($content)) {
            $failures.Add("Public CSV is empty and missing schema header: $csv")
            continue
        }

        $firstLine = ($content -split "`r?`n" | Select-Object -First 1).Trim()
        $actualHeaders = @($firstLine -split ',')
        foreach ($header in $requiredPublicHeaders) {
            if ($actualHeaders -notcontains $header) {
                $failures.Add("Public CSV missing required header '$header': $csv")
            }
        }

        foreach ($header in @('PublishedName', 'Provider', 'ClassName', 'DriverDate', 'DriverVersion', 'SignerName')) {
            if ($content -match "(^|,)$header(,|$)") {
                $failures.Add("Public CSV contains private column '$header': $csv")
            }
        }
        if ($content -match 'oem\d+\.inf') {
            $failures.Add("Public CSV contains local PublishedName pattern: $csv")
        }

        $sessionDir = Split-Path -Parent $csv
        $spec = Join-Path $sessionDir 'driverstore-run-spec-public.md'
        if (-not (Test-Path $spec -PathType Leaf)) {
            $failures.Add("Missing public run spec for $csv")
        }
    }

    $publicSpecs = @($tracked | Where-Object { ($_ -replace '\\', '/') -match '^reports/sessions/[^/]+/driverstore-run-spec-public\.md$' })
    foreach ($spec in $publicSpecs) {
        $content = Get-Content -Path $spec -Raw -Encoding UTF8
        foreach ($required in @('Windows generation', 'OEM', 'Machine family', 'Model line', 'Privacy Checklist')) {
            if ($content -notmatch [regex]::Escape($required)) {
                $failures.Add("Public run spec missing '$required': $spec")
            }
        }
        if ($content -match 'oem\d+\.inf') {
            $failures.Add("Public run spec contains local PublishedName pattern: $spec")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ }
        throw "Agent contribution validation failed with $($failures.Count) issue(s)."
    }

    Write-Host "Agent contribution validation passed."
    Write-Host "Tracked public research CSVs: $($publicCsvs.Count)"
    Write-Host "Tracked public run specs: $($publicSpecs.Count)"
}
finally {
    Pop-Location
}
