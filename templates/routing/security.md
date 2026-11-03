# Security fixes and reverse engineering (read only for that work)

- Finding problems: the `security` gate and `review`. Fixing them: the `security-hardening` skill
  (smallest fix per finding, then re-run the gate). Money, purchases and other people's data first.
- REA (reverse engineering, `8 Optional - Reverse Engineering (REA).bat`, skill `reverse-engineer-anything`):
  - Use it on software we own or are allowed to analyse: our own APKs and web builds (what a stranger can
    see: keys, URLs, SDKs, size), open-source apps, client apps with written permission.
  - Never use it to get around a licence, a login, a paywall or DRM, and never paste decompiled code from
    someone else's app into our projects. To build our own version of another app's feature, use the
    Replica skills (clean-room: public information only) and use REA only to understand our own build.
  - Analysis runs locally. Keep its evidence in the project's `research/` folder, not in chat.
