# Gate: security

You are checking someone else's work. Do not fix anything. Report only.
Report only real problems with a concrete case: "a player does X, and gets Y". No case, no finding.

Look at the changed code first (git diff), then the code it calls. Check:

1. Money and rewards. Coins, gems, wallet, bets, prizes, IAP, rewarded ads.
   - Does the client decide the result or the balance? The server must (or the platform's receipt check).
   - Can a reward be claimed twice (double tap, replay a request, close the ad early, refresh the page)?
   - Can the balance go negative, or overflow? Rounding on bets or payouts?
2. Saves and progress. Can a player edit localStorage or a save file to unlock or get currency, and does it matter
   for this game (single player offline: low; shared economy or leaderboard: high)?
3. Secrets. API keys, tokens, passwords or admin URLs in code, config or the build output. Committed .env files.
4. Input. Anything from users, URLs or the network put into HTML (XSS), SQL, shell commands or eval.
5. Accounts and network. Missing auth on an endpoint, trusting a user id sent by the client, no rate limit
   on something that pays out.
6. Third party. New dependencies: are they needed? Known bad versions (`npm audit` if available).

After the check, fixes follow the `security-hardening` skill.

Output, short:
- Threat model in one line (who could attack, what they gain)
- Findings, most serious first: **What**, file:line, the concrete case, the smallest fix
- Last line: `GATE security: PASS | FAIL | NEEDS-REVIEW`
