import { readFileSync } from "node:fs";
import { expect, it } from "vitest";

it("keeps strict TypeScript on", () => {
  const base = JSON.parse(readFileSync(new URL("../base.json", import.meta.url), "utf8")) as {
    compilerOptions: { strict: boolean };
  };
  expect(base.compilerOptions.strict).toBe(true);
});
