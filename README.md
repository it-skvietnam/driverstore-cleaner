# DriverStore cleanup workflow

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
