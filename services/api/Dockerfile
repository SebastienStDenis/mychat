# syntax=docker/dockerfile:1.6
FROM python:3.12-slim@sha256:abc799c7ee22b0d66f46c367643088a35e048bbabd81212d73c2323aed38c64f AS base
WORKDIR /app

RUN adduser --disabled-password --gecos "" appuser
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir poetry==2.2.* \
 && apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_VIRTUALENVS_CREATE=false


FROM base AS deps
WORKDIR /app
COPY pyproject.toml poetry.lock* ./
RUN --mount=type=cache,target=/root/.cache/pypoetry \
  poetry install --only main --no-root

# ------ DEVELOPMENT ------

FROM deps AS dev-deps
WORKDIR /app
COPY pyproject.toml poetry.lock* ./
RUN --mount=type=cache,target=/root/.cache/pypoetry \
  poetry install --no-root


FROM base AS dev-runner
WORKDIR /app

COPY --from=dev-deps /usr/local /usr/local
COPY pyproject.toml poetry.lock* ./
 # Copy source code as a fallback in case it isn't bind-mounted (bind mount takes precedence since it's applied after image creation)
COPY --chown=appuser:appuser src/ ./src
RUN --mount=type=cache,target=/root/.cache/pypoetry \
  poetry install --only-root

USER appuser
EXPOSE 3001
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "3001", "--reload"]

# ------ TESTING ------

FROM dev-runner AS test-runner
WORKDIR /app

COPY tests/ ./tests

CMD ["pytest", "tests", "-q"]

# ------ PRODUCTION ------

FROM base AS builder
WORKDIR /app
RUN pip install --no-cache-dir --upgrade build
COPY pyproject.toml ./
COPY src/ ./src
RUN python -m build --wheel --outdir /dist


FROM base AS runner
LABEL org.opencontainers.image.authors="sebastien.stdenis@proton.me"
LABEL org.opencontainers.image.source="https://github.com/SebastienStDenis/mychat"
WORKDIR /app

COPY --from=deps /usr/local /usr/local
COPY --from=builder /dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && rm -f /tmp/*.whl

USER appuser
EXPOSE 3001
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "3001", "--workers", "2", "--proxy-headers", "--forwarded-allow-ips", "*"]
