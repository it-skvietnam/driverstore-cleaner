# AppData Module

The AppData module finds cache-heavy areas under the current user's profile without
deleting anything. It is analyze-only during M3.

## Scope

The analyzer reports common cache locations:

- `%LOCALAPPDATA%\Temp`
- Microsoft Office file cache
- Microsoft Teams cache
- Chrome and Edge cache folders
- npm, pip, NuGet, Gradle, and Yarn caches

It does not delete cache files. It does not scan entire browser profiles or Outlook
mail stores as cleanup candidates.

## Safety Rules

- Analyze only in M3.
- Do not delete Outlook `.ost` or `.pst` files.
- Do not delete browser profile data, passwords, sessions, or extensions.
- Do not delete entire `%APPDATA%` or `%LOCALAPPDATA%`.
- Cache cleanup requires closed applications and explicit approval in a future
  milestone.

## Scripts

```text
Analyze-AppDataCaches.ps1
```

## Default Policy

```text
Module: appdata
DefaultRisk: SafeWithClosedApps / ReviewRequired
SupportedAnalyze: yes
SupportedResearch: yes
SupportedWhatIf: no, future
SupportedExecute: no, future
AllowedCleanupMethods: future DeleteCacheFolder for approved cache paths only
ForbiddenCleanupMethods: profile-wide deletion, mail-store deletion
```

