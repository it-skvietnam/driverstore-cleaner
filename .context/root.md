<!-- AUTO_START | hash: 1ee02ee0 | built: 2026-05-24T01:00 -->
# Context: `.`

> **[auto-generated — không sửa tay phần này]**  
> Language: `powershell`  
> Source files: 4

## [auto] Public Functions

### `Analyze-DriverStore` (line 1)
```text
function Analyze-DriverStore([string]$OutputDir = (Join-Path $PSScriptRoot 'reports'), [string]$SessionId = (Get-Date -Format 'yyyyMMdd-HHmmss'), [switch]$IncludeRiskyClasses)
```

### `Merge-DriverResearchReview` (line 1)
```text
function Merge-DriverResearchReview([Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$PrivateCsv, [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$PublicCsv, [string]$OutputCsv = '')
```

### `Remove-DriverStoreCandidates` (line 1)
```text
function Remove-DriverStoreCandidates([Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CandidatesCsv, [switch]$Execute, [switch]$ForceDelete, [switch]$AllowUnreviewed)
```

### `Research-DriverCandidates` (line 1)
```text
function Research-DriverCandidates([Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CandidatesCsv, [string]$OutputCsv = '', [string]$PublicOutputCsv = '')
```

<!-- AUTO_END -->

<!-- MANUAL_START -->
## [manual] Design Decisions
> Tại sao module này được thiết kế như vậy? Trade-off gì đã được chọn?

_Chưa có ghi chú._

## [manual] Invariants & Constraints
> Các quy tắc KHÔNG BAO GIỜ được vi phạm khi sửa code ở đây.

_Chưa có ghi chú._

## [manual] Test Strategy
> Cách test module này: unit/integration, mock gì, test case quan trọng nhất là gì?

_Chưa có ghi chú._

## [manual] Behavior chưa implement (TODO)
> Các behavior đã thiết kế nhưng chưa code. LLM đọc để không "sáng tác" sai hướng.

_Chưa có ghi chú._
<!-- MANUAL_END -->