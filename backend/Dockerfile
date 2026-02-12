# Build
FROM node:24.13.0-slim AS build

# Copy, build static files; see .dockerignore for exclusions
WORKDIR /app
COPY . ./
ENV PRISMA_CLI_BINARY_TARGETS=debian-openssl-3.0.x
RUN npm run deploy

# Dependencies
FROM node:24.13.0-slim AS dependencies

# Copy, build static files; see .dockerignore for exclusions
WORKDIR /app
COPY . ./
ENV PRISMA_CLI_BINARY_TARGETS=debian-openssl-3.0.x
RUN npm ci --ignore-scripts --no-update-notifier --omit=dev

# Deploy using minimal Distroless image
FROM gcr.io/distroless/nodejs22-debian12:nonroot
ENV NODE_ENV=production

# Copy app and dependencies
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=build /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/node_modules/prisma ./node_modules/prisma
COPY --from=build /app/dist ./dist

# Boilerplate, not used in OpenShift/Kubernetes
EXPOSE 3001
HEALTHCHECK --start-period=2s --start-interval=5s --interval=30s --timeout=3s CMD ["/nodejs/bin/node", "-pe", "require('http').get('http://[::1]:3001/api/health', function(res){console.log('Health check status:', res.statusCode); process.exit(res.statusCode === 200 ? 0 : 1)}).on('error', function(err){console.error('Health check error:', err.message); process.exit(1);});"]


# Nonroot user, limit heap size to 50 MB
USER nonroot
CMD ["--max-old-space-size=150", "/app/dist/main"]
