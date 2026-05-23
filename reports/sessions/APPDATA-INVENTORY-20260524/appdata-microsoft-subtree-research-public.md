# AppData Microsoft Subtree Research - Public

Session ID: APPDATA-INVENTORY-20260524
Date: 2026-05-24
Mode: Research
Agent: Codex

## Scope

This note researches the visible `%LOCALAPPDATA%\Microsoft` subtree from the
TreeSize screenshot. It is discovery-only and does not approve deletion.

## Observed Public Inventory

| Item | Observed size | Initial assessment | Cleanup direction |
|---|---:|---|---|
| Microsoft | 3.2 GB | ReviewRequired | Drill down before cleanup |
| Microsoft/Office | 1.3 GB | ReviewRequired | Do not delete whole folder |
| Microsoft/Office/16.0 | 737.1 MB | ReviewRequired | Target known cache subfolders only |
| Microsoft/Office/SolutionPackages | 604.3 MB | ReviewRequired | Research-only; likely Office cache/state |
| Microsoft/Windows | 745.3 MB | UnknownKeep | Do not delete whole folder |
| Microsoft/WinGet | 651.4 MB | ReviewRequired | Prefer WinGet source commands |
| Microsoft/OneDrive | 307.0 MB | ReviewRequired | Prefer OneDrive reset/sync tooling |
| Microsoft/Edge | 114.4 MB | SafeWithClosedApps | Clear browser cache through Edge or cache-only folders |
| Microsoft/FontCache | 89.4 MB | ReviewRequired | Use font cache rebuild procedure, not broad delete |
| Microsoft/Outlook | 16.0 MB | DoNotDelete | OST/PST/mail state; report-only unless explicit recovery workflow |

## Evidence Notes

- Microsoft documents Office Document Cache size management and identifies the
  default cache location as `%LOCALAPPDATA%\Microsoft\Office\16.0\OfficeFileCache`.
  Source: https://support.microsoft.com/en-us/topic/managing-office-document-cache-size-ea64af72-b597-408e-8ecf-fd55daa02476
- Microsoft Learn documents Office add-in cache clearing under
  `%LOCALAPPDATA%\Microsoft\Office\16.0\...`; this supports cache-specific cleanup,
  not deleting the whole Office tree.
  Source: https://learn.microsoft.com/office/dev/add-ins/testing/clear-cache
- Microsoft Learn documents `winget source update` and `winget source reset`.
  This implies WinGet source/cache recovery should use WinGet tooling first.
  Source: https://learn.microsoft.com/windows/package-manager/winget/source
- Microsoft Support documents OneDrive reset using
  `%localappdata%\Microsoft\OneDrive\onedrive.exe /reset`. This supports
  tool-mediated cleanup/recovery rather than deleting the OneDrive folder.
  Source: https://support.microsoft.com/en-gb/office/reset-onedrive-34701e00-bf7b-42db-b960-84905399050c
- Microsoft Support documents clearing Microsoft Edge browsing data through Edge.
  Browser cache cleanup should target cache data, not the entire profile.
  Source: https://support.microsoft.com/en-au/microsoft-edge/view-and-delete-browser-history-in-microsoft-edge-00cf7943-a9e1-975a-a33d-ac10ce454ca4
- Microsoft Learn Q&A guidance for font cache rebuild involves stopping the cache
  service and deleting cache contents from the documented font cache locations.
  Treat this as a specialized repair workflow, not a general cleaner rule.
  Source: https://learn.microsoft.com/en-us/answers/questions/3860093/how-to-clear-the-windows-font-cache
- Microsoft Learn troubleshooting for Outlook OST corruption says an OST may be
  deleted and redownloaded in a specific recovery case. This is not a general
  storage cleanup rule.
  Source: https://learn.microsoft.com/en-us/troubleshoot/outlook/data-files/errors-have-been-detected-in-.ost-file

## Research Conclusion

The Microsoft subtree contains several recoverable caches, but the correct cleanup
unit is not `%LOCALAPPDATA%\Microsoft`. The most promising future cleanup targets
are:

- `Microsoft\Office\16.0\OfficeFileCache` after closing Office apps,
- Edge cache folders after closing Edge,
- WinGet source/cache repair via `winget source update` or `winget source reset`,
- OneDrive cache/state only through OneDrive reset tooling.

Keep or research-only:

- whole `Microsoft\Office`,
- whole `Microsoft\Office\16.0`,
- `SolutionPackages` until stronger Office-specific evidence exists,
- whole `Microsoft\Windows`,
- whole `Microsoft\OneDrive`,
- whole `Microsoft\Outlook`.

## Privacy

No local path, username, file name, account name, mailbox name, or browser profile
contents are published here.
