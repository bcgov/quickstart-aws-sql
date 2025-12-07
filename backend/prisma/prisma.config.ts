import { defineConfig } from "prisma/config";

const DB_HOST = process.env.POSTGRES_HOST || "localhost";
const DB_USER = process.env.POSTGRES_USER || "postgres";
const DB_PWD = encodeURIComponent(process.env.POSTGRES_PASSWORD || "default");
const DB_PORT = process.env.POSTGRES_PORT || "5432";
const DB_NAME = process.env.POSTGRES_DATABASE || "postgres";
const DB_SCHEMA = process.env.POSTGRES_SCHEMA || "app";
const DB_POOL_SIZE = parseInt(process.env.POSTGRES_POOL_SIZE || "5", 10);

// SSL settings for PostgreSQL 17+ which requires SSL by default
const isLocalhost =
  DB_HOST === "localhost" || DB_HOST === "127.0.0.1" || DB_HOST === "database";
const isProduction = process.env.NODE_ENV === "production";
const SSL_MODE = isLocalhost || !isProduction ? "prefer" : "require";

export default defineConfig({
  datasources: {
    db: {
      url: `postgresql://${DB_USER}:${DB_PWD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=${DB_SCHEMA}&connection_limit=${DB_POOL_SIZE}&sslmode=${SSL_MODE}`,
    },
  },
});
