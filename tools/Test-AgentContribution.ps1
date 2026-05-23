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

    $publicCsvs = @($tracked | Where-Object { ($_ -replace '\\', '/') -match '^reports/sessions/[^/]+/[^/]+-research-public\.csv$' })
    $requiredDriverStoreHeaders = @(
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
    $requiredGenericHeaders = @(
        'SessionId',
        'Module',
        'ResearchId',
        'ItemName',
        'ItemType',
        'EstimatedSizeBytes',
        'RiskLevel',
        'CleanupMethod',
        'ResearchStatus',
        'Assessment',
        'EvidenceUrl1',
        'EvidenceUrl2',
        'DeleteApproved',
        'PublicNotes'
    )

    foreach ($csv in $publicCsvs) {
        $content = Get-Content -Path $csv -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($content)) {
            $failures.Add("Public CSV is empty and missing schema header: $csv")
            continue
        }

        $firstLine = ($content -split "`r?`n" | Select-Object -First 1).Trim()
        $actualHeaders = @($firstLine -split ',' | ForEach-Object { $_.Trim().Trim('"') })
        $requiredHeaders = if (($csv -replace '\\', '/') -like '*/driverstore-research-public.csv') {
            $requiredDriverStoreHeaders
        } else {
            $requiredGenericHeaders
        }
        foreach ($header in $requiredHeaders) {
            if ($actualHeaders -notcontains $header) {
                $failures.Add("Public CSV missing required header '$header': $csv")
            }
        }

        foreach ($header in @('PublishedName', 'Provider', 'ClassName', 'DriverDate', 'DriverVersion', 'SignerName', 'LocalPath', 'LocalPathOrId', 'ExactCommand')) {
            if ($content -match "(^|,)$header(,|$)") {
                $failures.Add("Public CSV contains private column '$header': $csv")
            }
        }
        if ($content -match 'oem\d+\.inf') {
            $failures.Add("Public CSV contains local PublishedName pattern: $csv")
        }
        if ($content -match '(?i)([A-Z]:\\|/mnt/[a-z]/|\\Users\\|/home/)') {
            $failures.Add("Public CSV appears to contain a local path: $csv")
        }

        $sessionDir = Split-Path -Parent $csv
        $specs = @(Get-ChildItem -Path $sessionDir -Filter '*-run-spec-public.md' -File -ErrorAction SilentlyContinue)
        if ($specs.Count -eq 0) {
            $failures.Add("Missing public run spec for $csv")
        }
    }

    $publicSpecs = @($tracked | Where-Object { ($_ -replace '\\', '/') -match '^reports/sessions/[^/]+/[^/]+-run-spec-public\.md$' })
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
        if ($content -match '(?i)([A-Z]:\\|/mnt/[a-z]/|\\Users\\|/home/)') {
            $failures.Add("Public run spec appears to contain a local path: $spec")
        }
    }

    $researchNotes = @($tracked | Where-Object { ($_ -replace '\\', '/') -match '^research-notes/\d{4}-\d{2}-\d{2}-.+\.md$' -and ($_ -replace '\\', '/') -notmatch '^research-notes/(README|TEMPLATE)\.md$' })
    foreach ($note in $researchNotes) {
        $content = Get-Content -Path $note -Raw -Encoding UTF8
        foreach ($required in @('Entry ID:', 'Session ID:', 'Agent tool:', 'Agent model:', 'Windows generation:', 'OEM:', 'Machine family:', 'What Was Learned', 'Privacy Review')) {
            if ($content -notmatch [regex]::Escape($required)) {
                $failures.Add("Research note missing '$required': $note")
            }
        }
        if ($content -match 'oem\d+\.inf') {
            $failures.Add("Research note contains local PublishedName pattern: $note")
        }
    }

    foreach ($csv in $publicCsvs) {
        $sessionId = (($csv -replace '\\', '/') -split '/')[2]
        $matchingNotes = @($researchNotes | Where-Object {
            $content = Get-Content -Path $_ -Raw -Encoding UTF8
            $content -match [regex]::Escape("Session ID: $sessionId")
        })
        if ($matchingNotes.Count -eq 0) {
            $failures.Add("Missing research note for public CSV session: $sessionId")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ }
        throw "Agent contribution validation failed with $($failures.Count) issue(s)."
    }

    Write-Host "Agent contribution validation passed."
    Write-Host "Tracked public research CSVs: $($publicCsvs.Count)"
    Write-Host "Tracked public run specs: $($publicSpecs.Count)"
    Write-Host "Tracked research notes: $($researchNotes.Count)"
}
finally {
    Pop-Location
}
