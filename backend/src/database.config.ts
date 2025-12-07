export const DB_HOST = process.env.POSTGRES_HOST || "localhost";
export const DB_USER = process.env.POSTGRES_USER || "postgres";
export const DB_PWD = encodeURIComponent(
  process.env.POSTGRES_PASSWORD || "default",
); // this needs to be encoded, if the password contains special characters it will break connection string.
export const DB_PORT = process.env.POSTGRES_PORT || 5432;
export const DB_NAME = process.env.POSTGRES_DATABASE || "postgres";
export const DB_SCHEMA = process.env.POSTGRES_SCHEMA || "app";
export const DB_POOL_SIZE = parseInt(process.env.POSTGRES_POOL_SIZE || "5", 10);
export const DB_POOL_IDLE_TIMEOUT = parseInt(
  process.env.POSTGRES_POOL_IDLE_TIMEOUT || "30000",
  10,
);
export const DB_POOL_CONNECTION_TIMEOUT = parseInt(
  process.env.POSTGRES_POOL_CONNECTION_TIMEOUT || "2000",
  10,
);

// SSL settings for PostgreSQL 17+ which requires SSL by default
// Use 'prefer' for localhost or non-production environments, 'require' for production AWS deployments
const isLocalhost =
  DB_HOST === "localhost" || DB_HOST === "127.0.0.1" || DB_HOST === "database";
const isProduction = process.env.NODE_ENV === "production";
const SSL_MODE = isLocalhost || !isProduction ? "prefer" : "require";

/**
 * Constructs the PostgreSQL connection string with appropriate SSL mode and schema.
 * Note: connection_limit is not included as pool size is managed by pg.Pool's max option.
 */
export function getConnectionString(): string {
  return `postgresql://${DB_USER}:${DB_PWD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=${DB_SCHEMA}&sslmode=${SSL_MODE}`;
}
