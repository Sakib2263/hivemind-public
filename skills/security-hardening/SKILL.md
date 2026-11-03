---
name: security-hardening
description: "Fix security and encryption problems in games, web apps and mobile apps: secrets in code, cheatable coins and rewards, fake purchases, save tampering, weak or home-made encryption, insecure network and storage, exposed Android components, risky dependencies. Use after a security check or review finds issues, before a release, or when asked to secure, encrypt, harden or anti-cheat something."
---

# Security hardening

The finder is the `security` gate (Hivemind `gates/security.md`) or a review. This skill is the fixer:
it turns each finding into the smallest safe change, then proves it with a re-check.
House style: plain language, short. Ponytail: smallest complete fix, reuse platform features, never weaken
validation to make something pass.

## 1. Start from evidence
1. Get the findings: run the `security` gate (relay `worker: gate`, `gate: security`) or read the latest
   review. No findings list? Run the gate first; don't guess.
2. Write a one-line threat model: who attacks (a curious player, a cheater, a bot, someone who steals the
   APK), what they gain (free coins, paid items, other players' data, our keys). Fix what that attacker can
   actually do; skip theoretical issues.
3. Order: data loss and other people's data > money and purchases > secrets > cheating in a shared
   economy or leaderboard > cheating in a single-player game > hygiene.

## 2. Fix patterns (use these, don't invent new ones)

**Secrets**
- No secret in client code, ever: a web game, an APK or a Unity build can be unpacked in minutes (REA can
  show you exactly what is visible in your own build). Secrets live on a server or in CI secrets.
- Public-by-design ids (AdMob app id, Firebase web config, analytics keys) may ship, but restrict them:
  package name + SHA-1 restriction on Google API keys, Firebase security rules, App Check.
- A leaked key: rotate it first, then remove it from the code and from git history.
- Keys for builds and signing stay in `secrets/` (git-ignored), never in a project repo.

**Coins, rewards, purchases (the most common game hole)**
- Shared economy, leaderboards, real-money items: the server decides balances and results; the client only
  asks. Rewards are granted by the server after it verifies the event (rewarded-ad callbacks with SSV,
  server-side verification for AdMob / AppLovin MAX).
- Purchases: verify every Google Play purchase on a server (Play Developer API: purchases.products /
  subscriptions), acknowledge it, and grant once by purchase token (idempotent). Never trust a client-side
  "purchase successful". Unity IAP receipt validation is a first line, not a replacement.
- Claim-twice bugs: one-use tokens or server-side "already claimed" flags; disable the button while a
  request is in flight.

**Saves and local data**
- Single-player, offline: tampering mostly hurts the cheater; add an integrity check, not a fortress.
  Store the save as JSON + an HMAC-SHA256 of it; on mismatch, fall back to the last good save. Say plainly
  that a key inside the client only slows cheaters down; it doesn't stop them.
- Anything that matters (paid items, rankings, shared progress): keep the truth on the server.
- Android: EncryptedSharedPreferences / Jetpack DataStore with the Android Keystore for tokens.
  Unity: never put tokens or paid state in PlayerPrefs. Web: no tokens in localStorage if avoidable;
  prefer HttpOnly, Secure, SameSite cookies.

**Encryption done right**
- Use the platform library, never home-made crypto: Web Crypto `AES-GCM` (browser), `javax.crypto`
  AES/GCM/NoPadding with Android Keystore keys, .NET `AesGcm` (Unity / C#), libsodium on servers.
- AES-GCM: a fresh random 12-byte IV for every message, stored with the ciphertext; never reuse an IV with
  the same key. No ECB, no CBC without a MAC, no MD5 or SHA-1 for security.
- Passwords: never encrypt them; hash on the server with Argon2id (or bcrypt / scrypt) with a per-user salt.
- Random values for tokens, IVs, ids: `crypto.getRandomValues`, `SecureRandom`,
  `RandomNumberGenerator`. Never `Math.random` or `UnityEngine.Random` for security.
- Data in transit: HTTPS only (TLS 1.2+). Android: no `usesCleartextTraffic`; a network security config if
  needed. Certificate pinning only with a rotation plan.

**Android build**
- Release builds: R8 / ProGuard minify on, `debuggable` false, no test or cheat menus.
- `android:allowBackup="false"` (or backup rules) when local data is sensitive.
- Every `exported` activity, service, receiver or provider has a reason; others `exported="false"`.
- WebView (Capacitor): no `addJavascriptInterface` to untrusted content, load only bundled or HTTPS pages.
- Play Integrity API for apps with real money or competitive play (checked on the server).
- Unity: IL2CPP builds; an obfuscator only slows reverse engineering, it doesn't hide secrets.

**Web**
- Escape everything user-made before it goes into HTML (no `innerHTML` with user text); no `eval`.
- A Content-Security-Policy that portals allow; Subresource Integrity on CDN scripts, or bundle them.
- Server APIs: validate input on the server, rate-limit anything that pays out, check auth on every call,
  never trust a user id sent by the client.

**Dependencies**
- `npm audit` / Unity package updates; fix high and critical issues that are reachable in our code.
- Remove SDKs and packages we don't use; each one is attack surface and app size.

## 3. Prove the fix
1. Re-run the `security` gate on the changed code. Every fixed finding needs its "attacker does X" case to
   fail now. Say what you ran.
2. Release builds: check what a stranger sees in our own shipped build (REA on our APK or web build, or at
   least a search of the build for keys and URLs). Our own builds only.
3. Record anything accepted rather than fixed as a `shortcut:` comment with its limit and the trigger to
   revisit (ponytail debt ledger).

## Output
A table: finding, risk (who gains what), fix made (file:line), proof (what was run), status
(fixed / accepted with reason / needs the owner: for example a server, a Play Console setting, or a key
rotation only the owner can do). End with the one thing the owner must do, if any.
