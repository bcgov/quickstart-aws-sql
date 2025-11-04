import request from "supertest";
import { Test } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma.service";

// Mock PrismaService for local development (no database available)
// In CI, the database service is available, so we don't override
class MockPrismaService implements Partial<PrismaService> {
  async $connect() {
    return Promise.resolve();
  }

  async $disconnect() {
    return Promise.resolve();
  }

  async onModuleInit() {
    return Promise.resolve();
  }

  async onModuleDestroy() {
    return Promise.resolve();
  }
}

describe("AppController (e2e)", () => {
  let app: INestApplication;

  beforeAll(async () => {
    // Only mock PrismaService locally (when not in CI)
    // In CI, the PostgreSQL service is available, so use real PrismaService
    let moduleBuilder = Test.createTestingModule({
      imports: [AppModule],
    });

    // Mock only when not in CI (CI has database service available)
    if (!process.env.CI) {
      moduleBuilder = moduleBuilder
        .overrideProvider(PrismaService)
        .useValue(new MockPrismaService());
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
