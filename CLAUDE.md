# CLAUDE.md — TML Status Dashboard

## What this project is

Portfolio emulation of a real production app from TML Information Services. It displays near-real-time MVR (driving record) data feed status for all 50 US states. Each state shows a green/yellow/red status, invented API protocol details, and a department contact. A background job (`StatusSimulatorJob`) simulates live status changes every 2 minutes.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Backend | Rails 7.2.3, API mode, Ruby 3.2.6 |
| Database | PostgreSQL 17 (Homebrew, port 5433) |
| Serializer | Blueprinter (flat JSON — no nesting) |
| Frontend | Vite + React 19 + TypeScript (strict) |
| UI | Material UI v9 |
| Data fetching | TanStack Query v5 (`refetchInterval: 120_000`) |
| Dev runner | Foreman (`Procfile.dev`) |
| Deployment | Railway |

---

## Critical environment detail

This machine has **two PostgreSQL installations** running simultaneously:

- **Official installer** (PG 16 + PG 18) on port **5432** — requires a password, not used by this project
- **Homebrew postgresql@17** on port **5433** — trust auth, no password required

`config/database.yml` is set to `host: /tmp, port: 5433`. If the database won't connect, run:

```bash
brew services start postgresql@17
```

---

## Running the app

```bash
brew services start postgresql@17   # if not already running
bundle install                       # first time only
cd client && npm install && cd ..    # first time only
rails db:create db:migrate db:seed  # first time only
foreman start -f Procfile.dev
```

Open `http://localhost:5173`.

---

## Architecture decisions

**No ActionCable / no Redis.** The original system polled every 2 minutes. TanStack Query's `refetchInterval` handles this natively and is more idiomatic. ActionCable would require Redis and fight TQ's data model for no meaningful UX gain at this polling frequency.

**Flat JSON from the API.** The blueprint merges `State` + `StateStatus` into one flat object. The frontend `StateRecord` type mirrors this exactly — no nested unpacking.

**`StatusSimulatorJob` is the only source of truth for status changes.** It runs on `perform_later` triggered either by the scheduler or the `POST /api/v1/simulate` endpoint. Don't mutate `StateStatus` directly outside of this job in application code.

**MUI v9 system props were removed.** All spacing, alignment, and typography shorthand props (`mb`, `fontWeight`, `justifyContent`, etc.) must go inside the `sx` prop. Direct props like `direction`, `spacing`, `variant`, `size`, `color` on their respective components still work.

---

## Key files

| File | Purpose |
|------|---------|
| `app/jobs/status_simulator_job.rb` | Flips states down/up, manages planned outage windows |
| `app/serializers/state_blueprint.rb` | Flat JSON merge of State + StateStatus |
| `app/controllers/api/v1/states_controller.rb` | `GET /api/v1/states` — eager loads both models |
| `app/controllers/api/v1/simulations_controller.rb` | `POST /api/v1/simulate` — triggers job for demo |
| `db/seeds.rb` | All 50 states with invented protocol notes, contacts, departments |
| `client/src/types/index.ts` | `StateRecord` and `StatusValue` — source of truth for API shape |
| `client/src/hooks/useStates.ts` | TanStack Query fetch + 2-min polling |
| `client/src/hooks/useSyncCountdown.ts` | Countdown timer derived from TQ query state |
| `client/src/lib/statusHelpers.ts` | Colors, labels, sort order, formatters |
| `client/src/components/Dashboard/index.tsx` | Top-level layout, header, summary bar, simulate button |
| `client/src/components/StateGrid/index.tsx` | Card grid + filter chips (All / Outage / Planned / Operational) |
| `client/src/components/StateCard/index.tsx` | Individual card — click opens OutageModal |
| `client/src/components/StatusBadge/index.tsx` | Animated pulsing dot + status label chip |
| `client/src/components/OutageModal/index.tsx` | Right drawer with full state + protocol details |
| `client/vite.config.ts` | Proxy `/api` → `localhost:3000`; builds to `../public` |

---

## Data model

### `states` (seeded once, static)
Holds the identity and protocol data for each state — department name, contact, API type, version, data format, auth method, and a `protocol_notes` text field with the invented integration quirk.

### `state_statuses` (one row per state, mutated by the simulator)
| column | type | notes |
|--------|------|-------|
| `status` | string | `"up"` / `"planned_outage"` / `"down"` |
| `planned_outage_start` | datetime | nil unless a window is scheduled |
| `planned_outage_end` | datetime | nil unless a window is scheduled |
| `outage_reason` | string | nil for unplanned outages |
| `response_time_ms` | integer | random noise added each tick |
| `uptime_30d` | decimal(5,2) | seeded once, not recalculated |
| `last_checked_at` | datetime | updated on every simulator tick |

---

## Coding conventions

- No `any` types in TypeScript — use explicit types or generics
- No business logic in controllers — keep it in models and jobs
- Handle `null` explicitly — `planned_outage_start` and `outage_reason` are nullable; always guard before use
- All MUI layout/spacing goes in `sx` — no shorthand system props as direct attributes
- Named exports from all components and hooks — no anonymous default components
- The Rails API is read-only from the frontend's perspective (except `/simulate` which is a dev/demo tool)

---

## Adding a new state or modifying seed data

Edit `db/seeds.rb`. The seed is idempotent (`find_or_create_by!` on `abbreviation`). Re-run with:

```bash
rails db:seed
```

For a full reset:

```bash
rails db:drop db:create db:migrate db:seed
```

---

## Testing the simulator

Fastest way to see status changes without waiting:

1. Click the **Simulate** button in the dashboard header — triggers `POST /api/v1/simulate`, which enqueues the job and auto-refreshes the UI after 600ms.
2. Or from the Rails console: `StatusSimulatorJob.perform_now`

The job always flips 1–2 states to `down`. States recover automatically after 6 minutes of being down.
