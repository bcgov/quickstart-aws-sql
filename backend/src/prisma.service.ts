import {
  Injectable,
  OnModuleDestroy,
  OnModuleInit,
  Logger,
  Scope,
} from "@nestjs/common";
import { PrismaClient, Prisma } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";
import {
  getConnectionString,
  DB_POOL_SIZE,
  DB_POOL_IDLE_TIMEOUT,
  DB_POOL_CONNECTION_TIMEOUT,
} from "src/database.config";

@Injectable({ scope: Scope.DEFAULT })
class PrismaService
  extends PrismaClient<Prisma.PrismaClientOptions, "query">
  implements OnModuleInit, OnModuleDestroy
{
  private static instance: PrismaService;
  private logger = new Logger("PRISMA");
  private pool: Pool;

  constructor() {
    if (PrismaService.instance) {
      console.log("Returning existing PrismaService instance");
      return PrismaService.instance;
    }

    // Create pg connection pool with configuration
    const pool = new Pool({
      connectionString: getConnectionString(),
      max: DB_POOL_SIZE,
      idleTimeoutMillis: DB_POOL_IDLE_TIMEOUT,
      connectionTimeoutMillis: DB_POOL_CONNECTION_TIMEOUT,
    });
    const adapter = new PrismaPg(pool);

    super({
      errorFormat: "pretty",
      adapter,
      log: [
        { emit: "event", level: "query" },
        { emit: "stdout", level: "info" },
        { emit: "stdout", level: "warn" },
        { emit: "stdout", level: "error" },
      ],
    });
    this.pool = pool;
    PrismaService.instance = this;
  }

  async onModuleInit() {
    await this.$connect();
    this.$on<any>("query", (e: Prisma.QueryEvent) => {
      // dont print the health check queries
      if (e?.query?.includes("SELECT 1")) return;
      this.logger.log(
        `Query: ${e.query} - Params: ${e.params} - Duration: ${e.duration}ms`,
      );
    });
  }

  async onModuleDestroy() {
    await this.$disconnect();
    await this.pool.end();
  }
}

export { PrismaService };
