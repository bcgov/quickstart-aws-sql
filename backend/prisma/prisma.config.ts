import { defineConfig } from "prisma/config";
import { getConnectionString } from "../src/database.config";

export default defineConfig({
  datasources: {
    db: {
      url: getConnectionString(),
    },
  },
});
