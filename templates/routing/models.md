# Models: allocation, priority and switching (read when dispatching a batch or when a model keeps failing)

Model ids: `config/models.env`. Usage left: `USAGE.md` "At a glance". This file says who gets which job and why.

## The pool (cheapest Claude quota first)
| Spec (relay) | Model | Cost and limit | Best at |
|---|---|---|---|
| `opencode:free` | GLM-5.3-Flash (OpenCode Zen) | free, shared rate limit, zero retention | main builder: features, core drafts |
| `opencode:free2` | DeepSeek V4.1 Flash (OpenCode Zen) | free, shared rate limit, zero retention | mechanical work, bulk edits, second builder |
| `opencode:nvglm` / `nvds` | GLM-5.3-Flash / DeepSeek V4.1 Flash on NVIDIA | NVIDIA bucket (below) | same model as free / free2 when Zen is busy |
| `opencode:nv` | MiniMax M3.1 Flash (NVIDIA) | NVIDIA bucket | builder; cross-vendor reviewer and gate |
| `opencode:nv2` | Nemotron 3.5 Super (NVIDIA) | NVIDIA bucket | reasoning, reviews |
| `opencode:nvmistral` | Mistral Large 4 (NVIDIA) | NVIDIA bucket | another vendor for reviews |
| `opencode:nvcode` | Poolside Laguna XS 2.1 (NVIDIA) | NVIDIA bucket | small coding agent: mechanical rows |
| `opencode:nvbig` | Nemotron 3 Ultra 550B (NVIDIA) | NVIDIA bucket, slow | hard reasoning, second opinions |
| `opencode:nvlong` | Step 5 preview, 1M context (NVIDIA) | NVIDIA bucket | reading big folders and logs |
| `agy` / `agy:hard` | Gemini Flash / Gemini 3.1 Pro (Antigravity) | free tier, weekly quota | reviews (first choice), big reading, hard second opinions |
| `codex` | Codex (any ChatGPT login) | plan quota, small on free | reviews and builds when logged in |
| `deepseek` | DeepSeek API | pay per use, needs key | last resort |

Weekly quotas (Antigravity, Codex) are the scarce ones after Claude: spend them on reviews and hard questions,
not on builds a free model can do. Per-minute limits (NVIDIA) recover in minutes: use them for volume.

**The NVIDIA bucket.** NVIDIA publishes no number for its free endpoints; users report about 40 requests a minute per
account, shared by all models, and no daily cap. So more NVIDIA models add choice, not capacity: one agentic job
uses most of it. Run at most one NVIDIA job at a time next to a Zen job. A 429 benches that model for 5 minutes and
the chain moves on; the other nv models usually answer with 429 too and are passed in seconds.

## Who gets the job (first choice > automatic fallback)
| Job | First | Fallback chain (relay does it) |
|---|---|---|
| feature, core draft | `opencode` (GLM) | GLM on NVIDIA > DeepSeek > DeepSeek on NVIDIA > MiniMax > Nemotron > Antigravity > Codex > DeepSeek API |
| mechanical | `opencode` `model: free2` (DeepSeek) | DeepSeek on NVIDIA > Laguna > GLM > GLM on NVIDIA > MiniMax > ... |
| review | `review` (REVIEW_ENGINES) | Antigravity > MiniMax > Mistral > Codex > Nemotron > DeepSeek > GLM |
| gate | `gate` (GATE_ENGINES) | GLM > GLM on NVIDIA > DeepSeek > MiniMax > Antigravity > Codex |
| read, "how does X work" | `graph` question (free, seconds), then `agy` | Gemini Pro > Step 5 (1M context) > Nemotron Ultra > Nemotron > GLM |
| second opinion | `agy` `model: hard` | Step 5 > Nemotron Ultra > Nemotron > GLM > Codex |

Chains per model live in `config/models.env` (`FALLBACK_opencode_free2` and so on) and win over the worker's chain.

## Max efficiency
- **Spread parallel jobs across providers.** Two jobs at once: give them different first models (for example
  `model: free` and `model: nv`, or `free` and `free2`) so they don't fight over one rate limit.
- **Review is always another vendor.** Read `worker used:` in the build's `.last`. GLM or DeepSeek built it: the
  default review chain is fine. MiniMax built it: send the review with `model: agy codex opencode:nv2`.
  Nemotron built it: `model: agy opencode:nv codex`. Gemini built it: `model: opencode:nv codex opencode:free2`.
- **Batch small rows** into one job for one model (same folder, same files) instead of many tiny jobs: each job
  re-reads the project.
- **Volume work to per-minute limits, judgement to weekly quotas.** Long mechanical runs: DeepSeek, then NVIDIA.
  Keep Antigravity and Codex for reviews and second opinions.
- **Before a batch, read `USAGE.md`.** A provider marked LIMIT HIT or OUT: start the batch on its fallback instead
  (`model:` header), don't wait for the relay to discover it job by job.
- **NDA, client, company rules (ROUTING section 8) beat efficiency.** NVIDIA free endpoints are trial
  endpoints: our own code only, never client or NDA work, company work only with the owner's OK.

## How the switch works (relay)
1. A job runs its own model first (`worker` + `model:`; plain `opencode` = GLM), then its chain:
   `fallback:` header if given, else `FALLBACK_<worker>` in `config/models.env`. `fallback: none` = no switching.
   A model listed twice is tried once.
2. A try moves to the next model only when it could not take the job: exit 127 (tool missing), exit 124
   (stalled: no output and no file change for OPENCODE_IDLE_SECONDS, default 6 min), or a provider message in the
   last 40 lines (rate limit, 429, quota, unauthorized, not logged in, model not found, overloaded, 503).
   A real failure (build error, failing test) is reported as is: never hidden behind another model.
3. A model that hit a limit or stalled is skipped by later jobs for SKIP_STUCK_MINUTES (60), NVIDIA for
   SKIP_STUCK_MINUTES_NVIDIA (5). The last model in a chain is never skipped.
4. No key or login (NVIDIA, Codex, DeepSeek API): the try fails in seconds with "model unavailable" and the chain
   moves on, so optional providers can stay in every chain.
5. Every try is a line in `logs/usage-ledger.csv`; `.last` ends with `worker used: <spec>`.

## When to change the order
- A model id stops working: `5 Check Everything` says so (NVIDIA: "NOT LISTED" with candidates). Fix the id in
  `config/models.env`, keep the date comment.
- A paid plan or key added: move that provider earlier in the chains.
- One provider keeps hitting limits by midday: put its fallback first for that class of job.

## Adding NVIDIA (optional)
Free key at build.nvidia.com (sign in, Get API Key, starts `nvapi-`) > `4 Add API Keys` > paste on
NVIDIA_API_KEY. That writes the key into opencode and adds the `nvidia` provider to `~/.config/opencode/opencode.json`
(base URL https://integrate.api.nvidia.com/v1). `5 Check Everything` then tests both models.
