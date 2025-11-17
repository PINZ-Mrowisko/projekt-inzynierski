module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "indent": "off",
    "coma-dangle": "off",
    "linebreak-style": "off",
    "max-len": "off",
    "no-unused-vars": "off",
    "brace-style": "off",
    "object-curly-spacing": "off",
    "comma-dangle": "off",
    "prefer-const": "off",
    "spaced-comment": "off"
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
