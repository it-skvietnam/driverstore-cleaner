# AppData Cleanup Policy

## Risk Classes

| Assessment | Meaning |
|---|---|
| `CacheSafe` | Known cache folder, potentially cleanable when apps are closed. |
| `SafeWithClosedApps` | Cache can be cleaned only after the owning app is closed. |
| `ReviewRequired` | Needs human review because data may affect dev workflows or app state. |
| `DoNotDelete` | Report only; deletion is not part of this module. |

## Initial Policy

| Area | Assessment | Notes |
|---|---|---|
| Local temp | `SafeWithClosedApps` | Only future cleanup; analyze-only now. |
| Office file cache | `SafeWithClosedApps` | Close Office apps before future cleanup. |
| Outlook OST/PST | `DoNotDelete` | Adjust sync settings instead of deleting. |
| Browser cache | `SafeWithClosedApps` | Cache folders only, never entire profile. |
| npm/pip/NuGet/Gradle/Yarn | `ReviewRequired` | May affect dev workflow; use package-manager cleanup when possible. |
| Teams cache | `SafeWithClosedApps` | Close Teams before future cleanup. |

Unknown folders default to `ReviewRequired` or `DoNotDelete`.

