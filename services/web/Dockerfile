FROM node:24-alpine@sha256:3e843c608bb5232f39ecb2b25e41214b958b0795914707374c8acc28487dea17 AS base
WORKDIR /app
RUN apk add --no-cache curl

# ------ DEVELOPMENT ------

FROM base AS dev
WORKDIR /app
ENV NODE_ENV=development PORT=3000 HOSTNAME=0.0.0.0

RUN mkdir -p /app/node_modules /home/node/.npm \
 && chown -R node:node /app /home/node
# Copy all project files as a fallback in case they aren't bind-mounted
COPY --chown=node:node . .

USER node
EXPOSE 3000
# predev target configured in package.json to run npm ci before each run
CMD ["npm", "run", "dev"]

# ------ PRODUCTION ------
# Reference: https://github.com/vercel/next.js/blob/8e93b202e0ef7d3215f1a6b9a7b253bc611ebed0/examples/with-docker/Dockerfile

FROM base AS deps
WORKDIR /app
COPY package*.json ./
# mount npm cache for faster installs
RUN --mount=type=cache,target=/root/.npm \
    npm ci --no-audit --no-fund

FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
# .dockerignore lists node_modules so the step below doesn't override the above step
COPY . .

RUN npm run build


FROM base AS runner
LABEL org.opencontainers.image.authors="sebastien.stdenis@proton.me"
LABEL org.opencontainers.image.source="https://github.com/SebastienStDenis/mychat"
WORKDIR /app

# Note: HOSTNAME gets overridden by Fargate, set it in the ECS task definition as well (https://github.com/vercel/next.js/issues/58657)
ENV NODE_ENV=production PORT=3000 HOSTNAME=0.0.0.0

COPY --from=builder /app/public ./public
COPY --from=builder --chown=node:node /app/.next/standalone ./
COPY --from=builder --chown=node:node /app/.next/static ./.next/static

USER node
EXPOSE 3000
CMD ["node", "server.js"]
