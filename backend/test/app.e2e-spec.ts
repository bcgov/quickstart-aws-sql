import request from "supertest";
import { Test } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma.service";

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
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(new MockPrismaService())
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it("/ (GET)", () =>
    request(app.getHttpServer()).get("/").expect(200).expect("Hello Backend!"));
});
