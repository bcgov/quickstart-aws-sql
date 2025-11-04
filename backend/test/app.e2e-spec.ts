import request from "supertest";
import { Test } from "@nestjs/testing";
import {
  INestApplication,
  OnModuleDestroy,
  OnModuleInit,
} from "@nestjs/common";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma.service";

// Mock PrismaService class that properly implements lifecycle interfaces
class MockPrismaService implements OnModuleInit, OnModuleDestroy {
  async $connect() {
    // No-op for local testing
  }

  async $disconnect() {
    // No-op for local testing
  }

  async onModuleInit() {
    // No-op for local testing
  }

  async onModuleDestroy() {
    // No-op for local testing
  }
}

const mockPrismaServiceInstance = new MockPrismaService();

describe("AppController (e2e)", () => {
  let app: INestApplication;

  beforeAll(async () => {
    // Check if we're in CI (where database is available) or locally (need mock)
    const isCI =
      process.env.CI === "true" || process.env.GITHUB_ACTIONS === "true";

    let moduleBuilder = Test.createTestingModule({
      imports: [AppModule],
    });

    // Only mock PrismaService locally (when not in CI)
    // In CI, use real PrismaService with database connection
    // Note: PrismaService singleton is disabled in test mode, so override should work
    if (!isCI) {
      moduleBuilder = moduleBuilder
        .overrideProvider(PrismaService)
        .useValue(mockPrismaServiceInstance);
    }

    const moduleFixture = await moduleBuilder.compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it("/ (GET)", () =>
    request(app.getHttpServer()).get("/").expect(200).expect("Hello Backend!"));
});
