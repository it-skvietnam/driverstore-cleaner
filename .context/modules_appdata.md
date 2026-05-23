<!-- AUTO_START | hash: 918a872a | built: 2026-05-24T00:56 -->
# Context: `modules/appdata`

> **[auto-generated — không sửa tay phần này]**  
> Language: `powershell`  
> Source files: 1

## [auto] PowerShell Commands / External Tools

Các hàm được expose qua IPC bridge:

- **`Get-DirectorySizeBytes`**
  ```text
  function Get-DirectorySizeBytes([Parameter(Mandatory)][string]$Path)
  ```
- **`New-AppDataCandidate`**
  ```text
  function New-AppDataCandidate([Parameter(Mandatory)][string]$SessionId, [Parameter(Mandatory)][string]$ResearchId, [Parameter(Mandatory)][string]$ItemName, [Parameter(Mandatory)][string]$ItemType, [Parameter(Mandatory)][string]$LocalPath, [Parameter(Mandatory)][string]$RiskLevel, [Parameter(Mandatory)][string]$Assessment, [Parameter(Mandatory)][string]$CleanupMethod, [Parameter(Mandatory)][string]$PublicNotes)
  ```
- **`Export-PrivateAppDataCsv`**
  ```text
  function Export-PrivateAppDataCsv([Parameter(Mandatory)][object[]]$Rows, [Parameter(Mandatory)][string]$Path)
  ```
- **`Export-PublicAppDataCsv`**
  ```text
  function Export-PublicAppDataCsv([Parameter(Mandatory)][object[]]$Rows, [Parameter(Mandatory)][string]$Path)
  ```
- **`Get-AppDataTopLevelInventory`**
  ```text
  function Get-AppDataTopLevelInventory([Parameter(Mandatory)][string]$SessionId, [Parameter(Mandatory)][string]$RootPath, [Parameter(Mandatory)][int]$Top)
  ```
- **`Export-PublicInventoryCsv`**
  ```text
  function Export-PublicInventoryCsv([Parameter(Mandatory)][object[]]$Rows, [Parameter(Mandatory)][string]$Path, [switch]$PublicFolderNames)
  ```

## [auto] Public Functions

### `Analyze-AppDataCaches` (line 1)
```text
function Analyze-AppDataCaches([string]$OutputDir = (Join-Path $PSScriptRoot '..\..\reports'), [string]$SessionId = (Get-Date -Format 'yyyyMMdd-HHmmss'), [int]$MaxDepth = 6, [int]$TopLocalFolders = 30, [switch]$PublicFolderNames)
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