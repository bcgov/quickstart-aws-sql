import baseConfig, { baseIgnores } from "./eslint-base.config.mjs";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";

export default [
  ...baseConfig,
  {
    ignores: [
      ...baseIgnores,
      "**/routeTree.gen.ts",
      "eslint-base.config.mjs", // ESLint base config files don't need TypeScript project
    ],
  },
  {
    plugins: {
      react,
      "react-hooks": reactHooks,
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },

      parser: tsParser,
      ecmaVersion: "latest",
      sourceType: "module",

      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
        project: ["./tsconfig.json", "./tsconfig.node.json"],
      },
    },

    settings: {
      react: {
        version: "detect",
      },
    },

    rules: {
      // React rules
      "react/jsx-uses-react": "off",
      "react/react-in-jsx-scope": "off",
      "react/prop-types": "off",
      "react/display-name": "off",
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",

      // Frontend-specific overrides
      "no-use-before-define": "off",
      "@typescript-eslint/no-use-before-define": [
        "error",
        {
          functions: false,
        },
      ],

      // Restricted imports
      "no-restricted-imports": [
        "error",
        {
          paths: [
            {
              name: "react",
              importNames: ["default"],
              message: "Please import from 'react/jsx-runtime' instead.",
            },
          ],
        },
      ],

      // Consistent type imports should be enforced for frontend
      "@typescript-eslint/consistent-type-imports": [
        "error",
        {
          prefer: "type-imports",
        },
      ],
    },
  },
];


