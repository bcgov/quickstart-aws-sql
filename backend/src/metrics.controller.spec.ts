import { Test, TestingModule } from "@nestjs/testing";
import { MetricsController } from "./metrics.controller";
import { Response } from "express";
import { register } from "./middleware/prom";

describe("MetricsController", () => {
  let controller: MetricsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MetricsController],
    }).compile();

    controller = module.get<MetricsController>(MetricsController);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("getMetrics", () => {
    it("should return application metrics", async () => {
      // Arrange
      const mockMetrics =
        '# HELP nodejs_version_info Node.js version info\n# TYPE nodejs_version_info gauge\nnodejs_version_info{version="v24.11.1",major="24",minor="11",patch="1"} 1\n';
      const mockResponse = {
        end: vi.fn(),
      } as unknown as Response;

      vi.spyOn(register, "metrics").mockResolvedValue(mockMetrics);

      // Act
      await controller.getMetrics(mockResponse);

      // Assert
      expect(register.metrics).toHaveBeenCalled();
      expect(mockResponse.end).toHaveBeenCalledWith(mockMetrics);
    });

    it("should handle empty metrics", async () => {
      // Arrange
      const mockResponse = {
        end: vi.fn(),
      } as unknown as Response;

      vi.spyOn(register, "metrics").mockResolvedValue("");

      // Act
      await controller.getMetrics(mockResponse);

      // Assert
      expect(register.metrics).toHaveBeenCalled();
      expect(mockResponse.end).toHaveBeenCalledWith("");
    });
  });
});
