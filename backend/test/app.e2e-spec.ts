import request from "supertest";
import { Test } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma.service";

describe("AppController (e2e)", () => {
  let app: INestApplication;

  beforeAll(async () => {
    // Create a proper mock that implements the required PrismaService interface
    const mockPrismaService = {
      onModuleInit: async () => {
        // Mock implementation - no database connection needed
        return Promise.resolve();
      },
      onModuleDestroy: async () => {
        // Mock implementation - no cleanup needed
        return Promise.resolve();
      },
      $connect: async () => {
        // Mock $connect to prevent database connection
        return Promise.resolve();
      },
      $disconnect: async () => {
        // Mock $disconnect
        return Promise.resolve();
      },
      $on: () => {
        // Mock $on event listener
      },
      // Add any other PrismaClient methods that might be accessed
      $transaction: async () => Promise.resolve([]),
      $use: () => {},
      $extends: () => mockPrismaService,
    };

    // Override PrismaService to use mock instead of real database connection
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(mockPrismaService as unknown as PrismaService)
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
