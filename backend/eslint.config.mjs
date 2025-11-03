import baseConfig, { baseIgnores } from "../eslint-base.config.mjs";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";

export default [
  ...baseConfig,
  {
    ignores: [
      ...baseIgnores,
      "**/*.config.*",
      "**/prisma/**",
    ],
  },
  {
    languageOptions: {
      globals: {
        ...globals.node,
      },

      parser: tsParser,
      ecmaVersion: "latest",
      sourceType: "module",

      parserOptions: {
        project: ["./tsconfig.json"],
      },
    },
  },
];

