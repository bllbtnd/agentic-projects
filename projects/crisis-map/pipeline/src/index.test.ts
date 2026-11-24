import { expect, it } from "vitest";
import { packageName } from "./index.js";

it("names this workspace package", () => {
  expect(packageName()).toContain("crisis-map");
});
