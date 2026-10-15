.PHONY: backend-dev frontend-dev test migrate seed up down
backend-dev:
	cd backend && uvicorn app.main:app --reload --port 8000
frontend-dev:
	cd frontend && npm run dev
migrate:
	cd backend && alembic upgrade head
seed:
	cd backend && python -m app.seed
test:
	cd backend && pytest -q
up:
	docker compose up --build
down:
	docker compose down
