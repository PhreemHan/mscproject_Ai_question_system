# Project status at delivery

## Implemented end-to-end in source

Authentication/RBAC, course membership, course/objective management, secure document ingestion and extraction, retrieval-grounded AI orchestration, provider abstraction, structured generation, quality checks, lecturer review/versioning, question bank, assessment builder, protected exports, student practice, dashboards, audit/AI usage logging, PostgreSQL/Alembic schema, Docker configuration, and deployment/security/testing documentation.

## Verified in the delivery environment

- Python backend compiles successfully.
- Backend automated test suite: **6 passed**.
- Alembic migrations apply cleanly from an empty SQLite database to head (`b55b6a27382a`).
- TypeScript source received a dependency-free parser check with no TypeScript syntax/parse-error codes; normal module/type errors were expected because Next/React dependencies could not be downloaded in this sandbox.

## Not claimed as verified

- A real hosted/local LLM call: no user API key or local model endpoint was available. The real provider adapters and configuration are implemented; deterministic tests use `LLM_PROVIDER=mock`.
- Frontend `npm install`, `npm test`, `npm run build`, browser E2E, and Docker image build: external npm registry access was unavailable in the delivery environment.
- Cloud deployment: no cloud credentials were supplied, so no deployment success is claimed.

These remaining checks are documented as staging/release tasks rather than being represented as completed.
