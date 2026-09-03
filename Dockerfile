FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_DEV=1 \
    UV_PYTHON_DOWNLOADS=0

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=api/uv.lock,target=uv.lock \
    --mount=type=bind,source=api/pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project

COPY api/ /app

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

FROM python:3.12-slim-bookworm

RUN groupadd --system --gid 999 app \
    && useradd --system --gid 999 --uid 999 --create-home app

COPY --from=builder --chown=app:app /app /app

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    FORCE_UNHEALTHY=false

USER app
WORKDIR /app

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
