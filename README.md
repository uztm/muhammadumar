# GovBot 🇺🇿

> **Government Information Made Simple Through AI.**

GovBot is a multilingual (Uzbek · Russian · English) AI-powered web app that gives
citizens, foreign residents, and tourists in Uzbekistan plain-language answers to
government-related questions — public services, legal procedures, administrative
requirements, regulations — through natural conversation, without forcing them to navigate
multiple official sites.

Two ways to get answers:

1. **AI chat** — a conversational assistant (OpenAI) answering free-form questions.
2. **Scenario Catalog** — curated, predefined answers for common topics (passport renewal,
   business registration, taxation, healthcare, visas, transport rules, residence
   registration, …).

---

## Tech stack

| Layer    | Technology |
|----------|------------|
| Frontend | React 18, Vite, React Router, react-i18next, axios |
| Backend  | Python 3.12, Django 5, Django REST Framework, SimpleJWT |
| Auth     | Email + password → app-issued JWT |
| AI       | OpenAI Chat Completions (mockable) |
| Database | PostgreSQL 16 |
| Deploy   | Docker + Docker Compose |

See [`CLAUDE.md`](CLAUDE.md) for the full architecture spec.

---

## Quick start (Docker — recommended)

```bash
cp .env.example .env          # then edit values (see "Configuration" below)
docker compose up --build
```

- Frontend → http://localhost:5173
- Backend API → http://localhost:8000/api
- Django admin → http://localhost:8000/admin

The backend container runs migrations and seeds the Scenario Catalog automatically on
startup. To create an admin user:

```bash
docker compose exec backend python manage.py createsuperuser
```

---

## Local development (without Docker)

### Backend

```bash
cd backend
python3.12 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # DATABASE_URL defaults to local sqlite if unset
python manage.py migrate
python manage.py seed_scenarios
python manage.py runserver     # http://localhost:8000
```

> Without `DATABASE_URL` / `POSTGRES_*` set, the backend falls back to a local SQLite
> database so you can run it instantly. Set the Postgres vars for a production-like setup.

### Frontend

```bash
cd frontend
cp .env.example .env           # set VITE_API_BASE_URL
npm install
npm run dev                    # http://localhost:5173
```

---

## Configuration

All secrets live in `.env` files (git-ignored). Templates are committed as `.env.example`.

### Authentication

GovBot uses **email + password** accounts. Register at `/register` (or via
`POST /api/auth/register/`); the response includes JWT access/refresh tokens and signs you
in automatically. There is no third-party provider to configure. Passwords are hashed with
Django's PBKDF2 and validated for minimum length.

### OpenAI

Set `OPENAI_API_KEY` and optionally `OPENAI_MODEL` (default `gpt-4o-mini`).
**Leave the key blank to run in mock mode** — the chat works end-to-end with a clearly
labelled canned response, so you can develop the UI without spending tokens.

---

## API overview

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | `/api/auth/register/` | public | Create account → JWT + user |
| POST | `/api/auth/login/` | public | Email + password → JWT + user |
| POST | `/api/auth/refresh/` | public | Refresh access token |
| GET/PATCH | `/api/auth/me/` | JWT | Current user profile |
| GET/POST | `/api/conversations/` | JWT | List / create conversations |
| GET/DELETE | `/api/conversations/{id}/` | JWT | Retrieve / delete a conversation |
| POST | `/api/conversations/{id}/messages/` | JWT | Send a message, get AI reply (JSON) |
| POST | `/api/conversations/{id}/messages/stream/` | JWT | Send a message, stream reply (SSE) |
| GET | `/api/scenarios/categories/` | public | List categories |
| GET | `/api/scenarios/` | public | List/search scenarios |
| GET | `/api/scenarios/{slug}/` | public | Scenario detail |

Add `?lang=uz|ru|en` to scenario endpoints to localize content.

---

## Tests

```bash
cd backend
pytest
```

Covers: register/login flow (password auth), message creation (mocked OpenAI), scenario
list/filter.

---

## Project layout

```
umar/
├── CLAUDE.md            # full spec — source of truth
├── docker-compose.yml
├── backend/             # Django + DRF
└── frontend/            # React + Vite
```

## License

Graduation project — for educational use.
# muhammadumar
