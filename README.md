# TML State MVR Status Dashboard

A portfolio project emulating a real production system built for TML Information Services. It displays the near-real-time connectivity status of driving record (MVR) data feeds from all 50 US states, color-coded by operational status.

Each state card shows invented-but-realistic data: the state's DMV department name, a contact person, and the proprietary integration protocol details (SOAP quirks, OAuth flows, SFTP batch formats, etc.). A background job simulates live status changes every 2 minutes.

**Stack:** Ruby on Rails 7.2 (API mode) · PostgreSQL · Vite · React 19 · TypeScript · Material UI v9 · TanStack Query v5

---

## Prerequisites

| Tool | Version |
|------|---------|
| Ruby | 3.2.6 |
| Rails | 7.2.3 |
| Node | 20+ |
| npm | 9+ |
| PostgreSQL | 17 (Homebrew) |

> **PostgreSQL note:** This project uses the Homebrew-managed PostgreSQL 17 instance, which runs on **port 5433** to avoid conflicts with any system-installed Postgres. Start it before running the app.

---

## First-time setup

### 1. Start PostgreSQL

```bash
brew services start postgresql@17
```

### 2. Install Ruby dependencies

```bash
bundle install
```

### 3. Install JavaScript dependencies

```bash
cd client && npm install && cd ..
```

### 4. Create and seed the database

```bash
rails db:create db:migrate db:seed
```

This creates the database, runs migrations, and seeds all 50 states with their simulated status data.

---

## Running in development

```bash
foreman start -f Procfile.dev
```

This starts two processes in parallel:

| Process | URL |
|---------|-----|
| Rails API | `http://localhost:3000` |
| Vite dev server | `http://localhost:5173` |

Open `http://localhost:5173` in your browser.

> **Don't have foreman?** Install it once with `gem install foreman`, or run the two processes in separate terminals:
> ```bash
> # Terminal 1
> bundle exec rails server -p 3000
>
> # Terminal 2
> cd client && npm run dev
> ```

---

## How the simulation works

The app mocks a live data feed by running `StatusSimulatorJob` in the background. On each tick (every 2 minutes) it:

1. Updates `last_checked_at` and adds slight noise to response times on all 50 states
2. Randomly flips 1–2 currently-up states to **down**
3. Auto-recovers states that have been down for 6+ minutes back to **up**
4. Activates and deactivates **planned outage** windows based on their scheduled time range

**Demo shortcut:** Click the "Simulate" button in the dashboard header to trigger a status change immediately without waiting for the 2-minute interval. The UI will refresh automatically.

To trigger manually from the Rails console:

```bash
bundle exec rails console
# then:
StatusSimulatorJob.perform_now
```

---

## API

The Rails backend exposes two endpoints:

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/states` | All 50 states with current status — called on load and every 2 min by TanStack Query |
| `POST` | `/api/v1/simulate` | Triggers `StatusSimulatorJob` immediately (demo/dev use) |

---

## Re-seeding

If you want to reset the database to its initial state:

```bash
rails db:seed
```

The seed file is idempotent — it uses `find_or_create_by!` so it is safe to re-run without duplicating data. For a full reset:

```bash
rails db:drop db:create db:migrate db:seed
```

---

## Production build

To generate a production build of the React app (outputs to `public/`):

```bash
cd client && npm run build
```

Rails serves the built files from `public/` automatically in production.

---

## Deployment (Railway)

1. Push the repo to GitHub
2. Create a new Railway project → **Deploy from GitHub repo**
3. Add the **Postgres** plugin — `DATABASE_URL` is set automatically
4. Set environment variables:
   - `RAILS_ENV=production`
   - `SECRET_KEY_BASE` — generate with `rails secret`
5. Set build command:
   ```
   cd client && npm run build && cd ..
   ```
6. Set start command:
   ```
   bundle exec rails server -p $PORT
   ```

Railway will run `db:migrate` automatically if you add it to the build command or a release phase.

---

## Project structure

```
tml-status-dashboard/
├── app/
│   ├── controllers/api/v1/
│   │   ├── states_controller.rb        # GET /api/v1/states
│   │   └── simulations_controller.rb   # POST /api/v1/simulate
│   ├── jobs/
│   │   └── status_simulator_job.rb     # Background status simulator
│   ├── models/
│   │   ├── state.rb                    # Static: name, dept, contact, protocol
│   │   └── state_status.rb             # Mutable: status, outage times, response_ms
│   └── serializers/
│       └── state_blueprint.rb          # Flat JSON shape via Blueprinter
├── client/                             # Vite + React + TypeScript app
│   ├── src/
│   │   ├── components/
│   │   │   ├── Dashboard/              # Layout, header, summary bar
│   │   │   ├── StateGrid/              # 50-card grid + filter chips
│   │   │   ├── StateCard/              # Individual state card
│   │   │   ├── StatusBadge/            # Animated status dot + label
│   │   │   └── OutageModal/            # Detail drawer (click any card)
│   │   ├── hooks/
│   │   │   ├── useStates.ts            # TanStack Query fetch + polling
│   │   │   └── useSyncCountdown.ts     # Countdown timer to next sync
│   │   ├── lib/
│   │   │   └── statusHelpers.ts        # Colors, labels, sort, formatters
│   │   └── types/
│   │       └── index.ts                # StateRecord, StatusValue
│   └── vite.config.ts                  # Proxy /api → :3000
├── db/
│   ├── migrate/                        # CreateStates, CreateStateStatuses
│   └── seeds.rb                        # 50 states with invented protocol data
├── Procfile.dev                        # foreman: rails + vite
└── Procfile                            # Production: rails only
```
# tml-status-dashboard
