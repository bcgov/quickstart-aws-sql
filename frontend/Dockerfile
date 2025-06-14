# Build
FROM node:22-slim AS build

# Copy, build static files; see .dockerignore for exclusions
WORKDIR /app
COPY . ./
RUN npm run deploy

# Deploy using Caddy to host static files
FROM caddy:2.9.1-alpine
RUN apk add --no-cache ca-certificates

# Copy static files, verify Caddyfile formatting
COPY --from=build /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
RUN caddy fmt /etc/caddy/Caddyfile

# Boilerplate, not used in OpenShift/Kubernetes
EXPOSE 3000 3001
HEALTHCHECK --interval=15s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/nodejs/bin/node", "-e", \
      "require('http').get({host: 'localhost', port: 3001, path: '/api/health'}, res => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1));" \
  ]

# Nonroot user
USER 1001
