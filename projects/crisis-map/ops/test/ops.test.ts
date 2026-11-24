import { readFileSync } from "node:fs";
import { expect, it } from "vitest";
import { opsLabel } from "../src/index.ts";

it("names the ops package", () => {
  expect(opsLabel(true)).toBe("@crisis-map/ops");
  expect(opsLabel(false)).toBe("ops");
});

it("reads the budget file schema version", () => {
  const budget = JSON.parse(readFileSync(new URL("../budgets.json", import.meta.url), "utf8")) as {
    schemaVersion: number;
  };
  expect(budget.schemaVersion).toBe(1);
});
