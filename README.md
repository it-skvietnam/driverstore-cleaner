# Windows Storage Research Cleaner with Agent

Windows Storage Research Cleaner with Agent is a proof-of-concept workflow for
researching Windows storage bloat before deleting anything. The repo started with
DriverStore cleanup, and now treats DriverStore as the first module in a broader
research-first cleanup system.

The goal is not to build a blind cleaner. The goal is to build an agent-assisted
research workflow that can scan storage domains, classify risk, keep local machine
details private, collect public evidence, and only execute cleanup after explicit
approval.

Current module:

- `driverstore`: stale Windows driver package research and gated cleanup via
  `pnputil`.

Planned modules:

- `winsxs`
- `appdata`
- `office-outlook`
- `browser-cache`
- `dev-cache`
- `wsl-docker`
- `restore-points`
- `windows-update`

## Problem gap

Existing cleanup flows usually cover only part of the problem:

- They can list old driver packages, but they do not prove whether a package is an
  outdated duplicate or a required legacy dependency.
- They expose local machine details when the user wants outside help researching
  drivers.
- They rarely separate public research evidence from private deletion mappings.
- They do not produce a clear report showing what was excluded, what was approved,
  what was deleted, and how effective the cleanup was.

This repo is designed to close that gap by splitting the process into private local
state, public anonymized research, review-gated deletion, and session reporting. The
same structure will be reused for AppData caches, WinSxS explanations, WSL/Docker
analysis, browser/dev caches, restore points, and Windows Update cache.

## Current safety model

- Never delete directly from protected system stores.
- Use module-supported cleanup APIs only, such as `pnputil` for DriverStore and
  DISM for WinSxS.
- Keep raw/local inventory private and git-ignored.
- Share only anonymized public research artifacts.
- Default unknown or legacy-looking drivers to keep.
- Require explicit approval before any real deletion.

## Module layout

```text
modules/
├─ MODULES.md
└─ driverstore/
   ├─ Analyze-DriverStore.ps1
   ├─ Research-DriverCandidates.ps1
   ├─ Merge-DriverResearchReview.ps1
   ├─ Remove-DriverStoreCandidates.ps1
   └─ README.md

schemas/
├─ candidate.schema.md
├─ module-policy.schema.md
├─ public-run-spec.schema.md
└─ research-note.schema.md
```

Root-level DriverStore scripts remain as compatibility wrappers.

## DriverStore cleanup workflow

This workflow cleans `C:\Windows\System32\DriverStore\FileRepository` safely by using
Windows driver APIs through `pnputil`. Do not delete files directly from DriverStore.

## 1. Analyze only

Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Analyze-DriverStore.ps1
```

The script writes:

- `reports\driverstore-raw.txt`: raw `pnputil /enum-drivers` output.
- `reports\driverstore-all.csv`: parsed third-party drivers.
- `reports\driverstore-candidates.csv`: conservative old-driver candidates.
- `reports\driverstore-research-review.csv`: candidates with web research fields.
- `reports\sessions\<session-id>\driverstore-research-private.csv`: full private
  review file for local execution.
- `reports\sessions\<session-id>\driverstore-research-public.csv`: anonymized
  research file containing only `ResearchId`, driver name, search prompts, and
  review fields.

Candidates are old duplicate packages where the newest matching package is kept.
The analyzer excludes risky classes by default: display, network, Bluetooth,
storage, system, USB controller, audio, printer, and firmware-related classes.

## Privacy split for research

For each analysis session, keep two paired files:

- Private file: keep this on the target machine. It contains `PublishedName`,
  installed version/date, class, provider, and the local deletion mapping.
- Public file: send this for research. It intentionally contains only
  `ResearchId`, `DriverName`, generated search prompts, evidence fields, and the
  final review decision.

This split avoids exposing local machine details such as `oemXX.inf`, installed
driver dates, installed versions, device class inventory, or vendor mix. The tradeoff
is that research from driver name alone can be ambiguous. Treat the public review as
evidence collection, not as the final deletion authority.

After the public file has been researched, merge it back into the private file:

```powershell
.\Merge-DriverResearchReview.ps1 `
  -PrivateCsv .\reports\sessions\<session-id>\driverstore-research-private.csv `
  -PublicCsv .\reports\sessions\<session-id>\driverstore-research-public.csv
```

Use the merged private file for dry-run and deletion.

## 2. Web research review

Open `reports\driverstore-research-review.csv` and research each row before
deletion. Prefer official sources first:

- PC vendor support page for the exact model, such as Lenovo, Dell, HP, ASUS, Acer.
- Hardware vendor support page, such as Intel, AMD, NVIDIA, Realtek, Qualcomm.
- Microsoft Update Catalog only as supporting evidence.
- Community/forum posts only for legacy risk clues, not as the sole delete reason.

Use the generated search columns:

- `WebSearchQuery`: broad lookup for the INF, provider, and installed version.
- `VendorSearchQuery`: vendor support/download lookup.
- `LegacySearchQuery`: legacy-risk lookup for XP/Windows 7-era packages that may
  still be required for hotkeys, ACPI, chipset extensions, card readers, or vendor
  utilities.

Fill these review columns:

- `WebResearchStatus`: set to `Reviewed` only after checking sources.
- `DriverAssessment`: use `OutdatedDuplicate`, `LegacyKeep`, or `UnknownKeep`.
- `LatestVersionFound` and `LatestDriverDateFound`: newest version/date found on
  official or strong supporting sources.
- `EvidenceUrl1` and `EvidenceUrl2`: URLs used to justify the decision.
- `EvidenceSourceType`: for example `VendorSupport`, `HardwareVendor`,
  `MicrosoftCatalog`, or `Mixed`.
- `LegacyRisk`: use `Low`, `Medium`, `High`, or `Unknown`.
- `ResearchNotes`: short reason, especially if keeping a legacy driver.
- `DeleteApproved`: set to `TRUE` only when the row is a confirmed
  `OutdatedDuplicate`.

Keep `DeleteApproved=FALSE` for legacy drivers. A driver can look old because it
comes from Windows XP or Windows 7-era hardware support, but still be required for
ACPI, hotkeys, sensors, storage, touchpad, audio routing, or vendor system devices.

If you already have `driverstore-candidates.csv` and need to create a review file:

```powershell
.\Research-DriverCandidates.ps1 -CandidatesCsv .\reports\driverstore-candidates.csv
```

This also creates `driverstore-research-public.csv` beside the private review file.

## 3. Dry-run deletion

Still in an Administrator PowerShell:

```powershell
.\Remove-DriverStoreCandidates.ps1 -CandidatesCsv .\reports\sessions\<session-id>\driverstore-research-merged.csv -WhatIf
```

This prints the `pnputil` actions without deleting anything.
Rows are skipped unless `WebResearchStatus=Reviewed`,
`DriverAssessment=OutdatedDuplicate`, `EvidenceUrl1` is filled, and
`DeleteApproved=TRUE`.

## 4. Execute deletion

Review `reports\driverstore-research-review.csv` first. Then:

```powershell
.\Remove-DriverStoreCandidates.ps1 -CandidatesCsv .\reports\sessions\<session-id>\driverstore-research-merged.csv -Execute
```

The script calls:

```powershell
pnputil /delete-driver oemXX.inf /uninstall
```

It does not use `/force` unless you explicitly pass `-ForceDelete`.

## Recovery notes

Before deleting, create a restore point or at least confirm that you have a network
driver installer available offline. If a device stops working, reinstall the vendor
driver package or use Device Manager to update the driver.

## Reporting plan

When a session is executed, the workflow should produce both public and private
reports:

- Public report: anonymized metrics suitable for the README or sharing. It should
  include candidate count, reviewed count, approved deletions, legacy keeps, unknown
  keeps, failed deletions, and observed DriverStore size impact.
- Private audit report: local-only evidence with `ResearchId` to `PublishedName`
  mapping, exact `pnputil` commands, exit codes, pre/post snapshots, and recovery
  notes.

Do not publish private reports. Only append a public summary to this README after a
real execution has been explicitly approved and completed.

## Case study: risky duplicate research

Session `POC-DRYRUN-20260523` found no automatically deletable candidates under the
default conservative filter. A wider private inventory check found four duplicate
driver-name groups, but all are in risky device classes. The public conclusion is:
these are research candidates, not deletion candidates.

No drivers were deleted during this case study.

| Research area | Driver name | Role | Public evidence | Assessment | Public decision |
|---|---|---|---|---|---|
| System device | `heci.inf` | Intel Management Engine Interface / HECI | Intel says Intel ME drivers for laptops/desktops are customized by system design and recommends using the system or motherboard manufacturer driver first. Intel also provides generic ME drivers for some cases. Sources: [Intel ME OEM systems](https://www.intel.com/content/www/us/en/support/articles/000058834/software.html), [Intel ME laptop/desktop guidance](https://www.intel.com/content/www/us/en/support/articles/000058711/processors.html). | `LegacyKeep` | Do not auto-delete. Only review exact-model OEM evidence before considering an older duplicate. |
| Bluetooth | `ibtusb.inf` | Intel Wireless Bluetooth USB driver | Intel's current Windows 10/11 Bluetooth package is version 24.40.0, but Intel notes the driver version varies by installed adapter. Source: [Intel Wireless Bluetooth drivers](https://www.intel.com/content/www/us/en/download/18649/intel-wireless-bluetooth-for-windows-10-and-windows-11.html). | `UnknownKeep` | Do not auto-delete. Treat as candidate only after confirming the exact Bluetooth adapter is supported by the newer package and the old package is not bound to a device. |
| Display audio | `intcdaud.inf` | Intel Display Audio, usually shipped with Intel graphics packages | Intel graphics release notes show Intel Display Audio is versioned inside graphics packages; generation-specific package differences matter. Sources: [Intel graphics release notes with Display Audio 11.1.0.23](https://downloadmirror.intel.com/871509/ReleaseNotes_101.2140.pdf), [Intel community note on IntcDAud package differences](https://community.intel.com/t5/Graphics/Intel-Graphics-Driver-Version-24-20-100-6136-amp-Intel-Display/m-p/554045). | `UnknownKeep` | Do not auto-delete. A newer-looking Display Audio package does not prove older packages are safe without exact graphics generation and device binding checks. |
| Realtek audio | `hdxlvj.inf` | Realtek/Lenovo audio package | Lenovo publishes machine-family-specific Realtek audio packages, including newer Windows 10/11 packages, and older ThinkPad packages that support Windows 7/8/10. Sources: [Lenovo ThinkPad Realtek 6.0.9847.1](https://support.lenovo.com/us/en/downloads/ds555920-realtek-audio-driver-for-windows-11-version-21h2-or-later-thinkpad), [Lenovo ThinkPad Realtek 6.0.9239.1](https://support.lenovo.com/gb/en/downloads/ds500835-realtek-high-definition-audio-driver-for-windows-10-64-bit-thinkpad), [Lenovo legacy Realtek package](https://support.lenovo.com/us/en/downloads/ds104050-realtek-high-definition-audio-driver-for-windows-10-32-bit-81-32-bit-64-bit-8-32-bit-64-bit-7-32-bit-64-bit-thinkpad). | `UnknownKeep` | Do not auto-delete. Realtek audio packages are often OEM-customized; exact model support and installed audio extensions must be verified first. |

Research outcome:

- `OutdatedDuplicate`: 0
- `LegacyKeep`: 1
- `UnknownKeep`: 3
- `DeleteApproved`: 0

This validates the current safety model: a broad duplicate scan can reveal useful
research targets, but the default deletion list should stay empty until evidence
proves a package is only an outdated duplicate.

## PoC critique

The core weakness is that a public file with only driver names cannot always
distinguish between a generic INF name, a vendor-customized package, and a legacy
package that still supports a modern device path. This is good for privacy, but weak
for fully automated deletion.

Recommended safeguards:

- Use public research to collect sources and classify risk only.
- Keep deletion gated by the private file and `pnputil`.
- Require two evidence URLs for risky classes or legacy-looking drivers.
- Prefer `UnknownKeep` over deletion whenever the public evidence is ambiguous.
- Add a restore point and an offline network/storage driver backup before execution.
