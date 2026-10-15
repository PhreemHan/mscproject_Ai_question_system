# AI Question Generator for Higher Education

**Project title:** Design and Development of a Generative-AI-Based Question Generation System for Higher Education

A production-oriented research MVP for source-grounded assessment authoring. Lecturers can upload PDF/DOCX/PPTX/TXT course materials, extract source-referenced content, generate questions with a configurable hosted or local LLM, review/edit/approve drafts, maintain a question bank, assemble assessments, export student/answer-key versions, and release selected practice activities.

> **Safety/academic-use notice:** AI-generated questions, answers, explanations, Bloom labels, and difficulty labels are drafts. The application requires lecturer/expert verification before formal assessment use.

## What is implemented

- Session authentication, CSRF protection, Argon2 password hashing, public lecturer/student registration, admin user management.
- Roles: administrator, lecturer, teaching assistant, student.
- Course membership and server-side course/resource authorization.
- Course metadata, outcomes/topics, learning objectives.
- PDF, DOCX, PPTX, TXT upload with content validation, duplicate SHA-256 detection, private storage, extraction, chunking, page/slide/section references, OCR hook, and injection-like content flagging.
- Document analysis: key concepts, explicit objectives, AI-suggested objectives clearly separated from explicit objectives.
- Provider-independent AI layer supporting hosted and local OpenAI-compatible endpoints, plus a deterministic mock provider for tests/development.
- Retrieval-grounded generation from authorized source chunks only.
- Question types: MCQ, true/false, short answer, essay, fill-in-the-blank, matching, scenario/case-study.
- Difficulty: easy/medium/hard; Revised Bloom categories: remember/understand/apply/analyze/evaluate/create.
- Structured JSON validation, source-chunk validation, duplicate checks, MCQ/TF structural checks, and independent advisory AI quality review.
- Question editing, regeneration, approval/rejection, version history, tags, filtering/search, source evidence display.
- Assessment builder with approved-question enforcement, marks calculation, publish/archive state, dates, randomization flags.
- Student-safe assessment/practice endpoints that omit restricted answer keys and block private lecturer materials/question bank.
- Practice attempts, controlled feedback, objective-item auto-marking, attempt history.
- DOCX/PDF assessment exports and CSV question-bank export; answer-key export is authorization-gated.
- Role dashboards, audit logs, AI usage records, administrative summaries.
- Alembic migrations, Dockerfiles, Docker Compose, tests, security/privacy/deployment documentation.

## Architecture at a glance

```text
Browser
  │
  ▼
Next.js + TypeScript + Tailwind
  │ same-origin /api/backend rewrite
  ▼
FastAPI
  ├── Authentication/RBAC/CSRF
  ├── Document processing (PyMuPDF, python-docx, python-pptx)
  ├── Retrieval + prompt construction
  ├── LLM provider abstraction
  ├── Question validation/review
  ├── Assessment/practice/export services
  └── Audit + AI usage
  │
  ├── PostgreSQL
  └── Protected file storage
```

See `docs/ARCHITECTURE.md` and `docs/ERD.md`.

## Project structure

```text
ai-question-generator-he/
├── backend/
│   ├── app/
│   │   ├── api/routes/           # HTTP endpoints
│   │   ├── services/ai/          # provider abstraction + prompts
│   │   ├── services/             # document/retrieval/generation/export/audit
│   │   ├── utils/                # secure file validation
│   │   ├── config.py
│   │   ├── db.py
│   │   ├── deps.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   ├── security.py
│   │   ├── seed.py
│   │   └── main.py
│   ├── alembic/                  # database migrations
│   ├── tests/
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── app/                      # Next.js App Router pages
│   ├── components/
│   ├── lib/
│   ├── public/
│   ├── package.json
│   └── Dockerfile
├── docs/
├── testdata/
├── docker-compose.yml
├── .env.example
└── Makefile
```

## Quick start with Docker

1. Copy the environment template.

```bash
cp .env.example .env
```

2. Change at least the PostgreSQL/admin passwords. For a real AI model, set `LLM_PROVIDER`, `LLM_BASE_URL`, `LLM_API_KEY`, and `LLM_MODEL`.

3. Start the application.

```bash
docker compose up --build
```

4. Seed an administrator after the backend is healthy.

```bash
docker compose exec backend python -m app.seed
```

5. Open `http://localhost:3000`.

The default `.env.example` uses the deterministic mock AI provider so the application can be explored without sending course content to an external model. `ENVIRONMENT=production` intentionally refuses to start with the mock provider.

## Local development without Docker

### Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export ENVIRONMENT=development
export DATABASE_URL=sqlite:///./aiqg.db
export STORAGE_DIR=./storage
export LLM_PROVIDER=mock
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

### Frontend

```bash
cd frontend
npm install
BACKEND_INTERNAL_URL=http://localhost:8000 npm run dev
```

Open `http://localhost:3000`.

## Configure a real AI provider

The hosted adapter uses an OpenAI-compatible chat-completions API.

```env
LLM_PROVIDER=openai_compatible
LLM_BASE_URL=https://api.openai.com/v1
LLM_API_KEY=...
LLM_MODEL=...
```

For a local OpenAI-compatible service:

```env
LLM_PROVIDER=local_openai_compatible
LLM_BASE_URL=http://localhost:11434/v1
LLM_API_KEY=
LLM_MODEL=...
```

No API secret is ever sent to frontend code. A real external model was **not** called during delivery because no user credential was provided; the integration is implemented and should be verified in staging.

## AI grounding and hallucination controls

1. Documents are extracted and split into source-addressable chunks.
2. Relevant chunks are selected by the retrieval service using the topic/learning objective/request metadata.
3. Prompts explicitly mark source material as untrusted data and prohibit following embedded instructions.
4. The model must cite only supplied chunk IDs.
5. The backend validates returned IDs and maps them to stored page/slide/section references.
6. Programmatic checks detect structural problems and near duplicates.
7. A second model call provides an advisory quality review.
8. Every generated item starts as `needs_review`.
9. Staff must approve items before they can enter a finalized assessment.

This reduces risk; it does **not** guarantee factual or pedagogical correctness.

## Supported question types

- Multiple choice
- True/false
- Short answer
- Essay
- Fill-in-the-blank
- Matching
- Scenario/case-study

MCQ approval is blocked unless the current item has exactly four options and exactly one correct option. True/false approval requires exactly two options and one correct option.

## Testing

Backend tests were executed during implementation:

```bash
cd backend
pytest -q
```

Observed result: **6 passed**.

See `docs/TESTING_REPORT.md` for scope and limitations. Frontend dependencies could not be downloaded in the delivery sandbox, so frontend build/e2e success is **not** claimed. Run `npm install`, `npm test`, and `npm run build` in network-enabled CI/staging.

## Database migrations

```bash
cd backend
alembic upgrade head
```

The initial migration is committed under `backend/alembic/versions/`.

## Documentation

- `docs/ARCHITECTURE.md` — architecture and technical decisions
- `docs/ERD.md` — entity relationships and confidentiality boundaries
- `docs/API.md` — endpoint map
- `docs/SECURITY_PRIVACY.md` — implemented controls and Ghana data-protection deployment checklist
- `docs/DEPLOYMENT.md` — local/Docker/production deployment process
- `docs/TESTING_REPORT.md` — tests actually run vs. still required
- `docs/LIMITATIONS.md` — known constraints and future improvements
- `docs/ROADMAP.md` — implementation phase mapping

## Important production requirements

Before real institutional deployment:

- use HTTPS and `COOKIE_SECURE=true`;
- run on managed/hardened PostgreSQL;
- move secrets to a secret manager;
- configure encrypted private object storage and malware scanning;
- configure a transactional email provider;
- move long-running extraction/AI jobs to queue workers;
- run staging tests against PostgreSQL and the approved real model;
- perform accessibility, load, security, IDOR, prompt-injection, and penetration tests;
- establish backup/restore and incident-response processes;
- complete institutional ethics/security/privacy review and Ghana Data Protection Act 2012 (Act 843) compliance work.

## License / institutional use

No license is asserted by this generated project. The institution should select and add an appropriate license after reviewing third-party dependency licenses and intended research/deployment conditions.
