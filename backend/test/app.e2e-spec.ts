import request from "supertest";
import { Test } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import { AppModule } from "../src/app.module";

describe("AppController (e2e)", () => {
  let app: INestApplication;

  beforeAll(async () => {
    // This e2e test requires a database connection.
    // In CI, the PostgreSQL service is available.
    // Locally, ensure you have a database running or skip this test.
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it("/ (GET)", () =>
    request(app.getHttpServer()).get("/").expect(200).expect("Hello Backend!"));
});
