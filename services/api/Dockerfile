FROM python:3.12-slim@sha256:abc799c7ee22b0d66f46c367643088a35e048bbabd81212d73c2323aed38c64f AS base
WORKDIR /app

RUN adduser --disabled-password --gecos "" appuser
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN pip install --no-cache-dir --upgrade pip
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

# ------ DEVELOPMENT ------

FROM base AS dev
WORKDIR /app

COPY requirements.txt requirements-dev.txt pyproject.toml ./
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt -r requirements-dev.txt

 # Copy source code as a fallback in case it isn't bind-mounted
COPY --chown=appuser:appuser src/ ./src
RUN pip install --no-cache-dir -e .

USER appuser
EXPOSE 3001
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "3001", "--reload"]

# ------ PRODUCTION ------

FROM base AS deps
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt


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
