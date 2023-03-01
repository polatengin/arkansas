FROM node:18-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm ci

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

ARG AI_CONNECTION_STRING=""
ENV APPLICATION_INSIGHTS_CONNECTION_STRING=$AI_CONNECTION_STRING

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000

ENV PORT 3000

ENTRYPOINT ["node", "server.js"]

LABEL org.opencontainers.image.source https://github.com/polatengin/arkansas
