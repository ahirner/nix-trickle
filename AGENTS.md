# Developer Guide

## Nix Development
- **Build**: `nix build .#<package>` (e.g. `nix build .#superset`)
- **Test**: `nix flake check` runs all checks. `tests/templates.sh` handles template verification.
- **Format**: `nix fmt` (uses `alejandra`).
- **Style**: 
  - Prefer `lib.eachSystem'` for multi-system outputs.
  - Keep overlays in `overlays/` and mapped in `overlays.nix`.
- DO NOT EVER COMMIT or push

## Superset Development (from .cursor/rules)
- **Frontend**: TypeScript only (no JS), no `any` types. Use functional components + hooks. 
  - Use `@superset-ui/core` (not direct `antd`). 
  - Tests: Jest + React Testing Library (NO Enzyme).
- **Backend**: Python with strict type hints.
  - Run `pre-commit run mypy` to validate.
  - Use SQLAlchemy models with proper annotations.
