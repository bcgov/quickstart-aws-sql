import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService } from "./prisma.service";
import { Pool } from "pg";

// Mock the database config module
vi.mock("src/database.config", () => ({
  getConnectionString: vi.fn(
    () => "postgresql://test:test@localhost:5432/test",
  ),
  DB_POOL_SIZE: 5,
  DB_POOL_IDLE_TIMEOUT: 30000,
  DB_POOL_CONNECTION_TIMEOUT: 2000,
}));

// Mock the pg module
vi.mock("pg", () => {
  const mockPool = {
    end: vi.fn().mockResolvedValue(undefined),
  };
  return {
    Pool: vi.fn(() => mockPool),
  };
});

// Mock @prisma/adapter-pg
vi.mock("@prisma/adapter-pg", () => ({
  PrismaPg: vi.fn(() => ({})),
}));

describe("PrismaService", () => {
  let service: PrismaService;
  let poolMock: any;

  beforeEach(async () => {
    // Clear all mocks before each test
    vi.clearAllMocks();

    // Get the mocked Pool constructor
    poolMock = new Pool();

    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("onModuleInit", () => {
    it("should connect to the database", async () => {
      // Arrange
      const connectSpy = vi
        .spyOn(service, "$connect")
        .mockResolvedValue(undefined);
      const onSpy = vi.spyOn(service, "$on").mockImplementation(() => {});

      // Act
      await service.onModuleInit();

      // Assert
      expect(connectSpy).toHaveBeenCalled();
      expect(onSpy).toHaveBeenCalledWith("query", expect.any(Function));
    });
  });

  describe("onModuleDestroy", () => {
    it("should disconnect from the database and close the pool", async () => {
      // Arrange
      const disconnectSpy = vi
        .spyOn(service, "$disconnect")
        .mockResolvedValue(undefined);

      // Act
      await service.onModuleDestroy();

      // Assert
      expect(disconnectSpy).toHaveBeenCalled();
      expect(poolMock.end).toHaveBeenCalled();
    });

    it("should handle pool cleanup errors gracefully", async () => {
      // Arrange
      const disconnectSpy = vi
        .spyOn(service, "$disconnect")
        .mockResolvedValue(undefined);
      poolMock.end.mockRejectedValueOnce(new Error("Pool cleanup error"));

      // Act & Assert
      await expect(service.onModuleDestroy()).rejects.toThrow(
        "Pool cleanup error",
      );
      expect(disconnectSpy).toHaveBeenCalled();
      expect(poolMock.end).toHaveBeenCalled();
    });
  });

  describe("singleton pattern", () => {
    it("should return the same instance when created multiple times", () => {
      // The service is already created in beforeEach
      const service1 = service;

      // Create another instance
      const service2 = new PrismaService();

      // Assert
      expect(service1).toBe(service2);
    });
  });
});
