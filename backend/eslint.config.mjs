import baseConfig, { baseIgnores } from "../eslint-base.config.mjs";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";

export default [
  ...baseConfig,
  {
    ignores: [
      ...baseIgnores,
      "**/prisma/**",
      "eslint.config.mjs", // ESLint config files don't need TypeScript project
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
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
];

