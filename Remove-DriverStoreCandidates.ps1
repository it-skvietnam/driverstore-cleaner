[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CandidatesCsv,

    [switch]$Execute,
    [switch]$ForceDelete,
    [switch]$AllowUnreviewed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $Execute -and -not $WhatIfPreference) {
    Write-Host 'Dry run only. Add -WhatIf to see PowerShell WhatIf output, or add -Execute to delete.'
}

$candidates = @(Import-Csv -Path $CandidatesCsv)
if ($candidates.Count -eq 0) {
    Write-Host 'No driver candidates found.'
    return
}

foreach ($candidate in $candidates) {
    $publishedName = [string]$candidate.PublishedName
    if ($publishedName -notmatch '^oem\d+\.inf$') {
        Write-Warning "Skipping suspicious PublishedName: $publishedName"
        continue
    }

    $hasReviewFields = $candidate.PSObject.Properties.Name -contains 'DeleteApproved'
    if (-not $AllowUnreviewed) {
        if (-not $hasReviewFields) {
            Write-Warning "Skipping $publishedName because the CSV has no research review fields. Re-run Analyze-DriverStore.ps1."
            continue
        }

        $deleteApproved = ([string]$candidate.DeleteApproved).Trim()
        $researchStatus = ([string]$candidate.WebResearchStatus).Trim()
        $assessment = ([string]$candidate.DriverAssessment).Trim()
        $hasEvidence = -not [string]::IsNullOrWhiteSpace([string]$candidate.EvidenceUrl1)

        if ($deleteApproved -ne 'TRUE' -or $researchStatus -ne 'Reviewed' -or $assessment -ne 'OutdatedDuplicate' -or -not $hasEvidence) {
            Write-Warning "Skipping $publishedName because it is not approved by web research review."
            continue
        }
    }

    $args = @('/delete-driver', $publishedName, '/uninstall')
    if ($ForceDelete) {
        $args += '/force'
    }

    $description = "pnputil $($args -join ' ')"
    if ($Execute) {
        if ($PSCmdlet.ShouldProcess($publishedName, $description)) {
            & pnputil @args
        }
    } else {
        Write-Host "[dry-run] $description"
    }
}
