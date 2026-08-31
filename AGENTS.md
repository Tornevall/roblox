# Repository agent instructions

This repository is a workspace for multiple independent Roblox experiments.

## Structure

- Keep each experiment in its own top-level directory.
- Do not couple projects unless the relationship is intentional and documented.
- Prefer source-controlled text formats and Rojo-compatible project layouts over committing generated place binaries.

## Roblox and Luau

- Roblox game logic must be server-authoritative when it affects progression, rewards, persistence, permissions, or competitive state.
- Treat all client input as untrusted.
- Keep reusable gameplay logic in ModuleScripts where practical.
- Code comments must be written in English.
- Avoid hard-coded secrets, API keys, tokens, private endpoints, universe IDs, or place IDs.

## External services and AI

- External AI must be optional unless a project explicitly documents otherwise.
- Gameplay should have a deterministic or local fallback when an external provider is unavailable.
- Never send secrets or unnecessary player data to external providers.
- Validate any externally generated recipe or configuration before applying it to the Roblox data model.

## Documentation and verification

- Update the relevant project README when behavior or setup changes.
- Update CHANGELOG.md for material changes.
- Prefer the smallest meaningful deterministic verification first, such as a Rojo build and focused static checks.
- Do not claim Roblox Studio or live-provider verification unless it was actually performed.
