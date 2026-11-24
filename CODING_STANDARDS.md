# Coding standards

These rules apply to the whole repo. The wording is the owner's. Each rule has
one short TypeScript example. Lint and CI enforce the rules that have a
mechanical check. Everything else is a review check.

## 1) Clean code

Well-structured, easy-to-understand code with clear, intention-revealing names
and a clear folder structure (one concept per module, folders by
feature/responsibility, no "utils" dumping grounds).

```ts
// Good
export function clusterKey(layer: string, day: string): string {
  return `${layer}|${day}`;
}

// Bad
export function doStuff(a: string, b: string): string {
  return helper(a, b);
}
```

**Reviewer-checked.** Biome cannot see that a folder is a dumping ground.

## 2) Functions are small and single-purpose

```ts
// Good
export function isStale(ageMs: number, intervalMs: number): boolean {
  return ageMs > intervalMs * 2;
}

// Bad
export function runEverything(ageMs: number, rows: string[]): boolean {
  const stale = ageMs > 86_400_000;
  const unique = new Set(rows);
  writeFileSync("out.json", JSON.stringify([...unique]));
  return stale && unique.size > 0;
}
```

**Lint-enforced.** Biome `noExcessiveCognitiveComplexity` with
`maxAllowedComplexity` 10, and `noExcessiveLinesPerFunction` with `maxLines`
30 (`skipBlankLines: true`). Test files are exempt from those two limits so
one test can spell out a behavior. The limit on production code still holds.

## 3) Extract a function only when it is reused

No single-use helper functions: inline them. When 2) and 3) pull against each
other, 3) wins: keep functions small through simple design and clear control
flow, not by splitting one-off helpers. Allowed exceptions, stated explicitly:
exported module entry points, callbacks/handlers passed to a framework, and
React components.

```ts
// Good — inlined, because nothing else validates this payload
export function readBudget(text: string): Budget {
  const parsed = JSON.parse(text) as unknown;
  if (typeof parsed !== "object" || parsed === null) {
    throw new Error("budget must be an object");
  }
  return budgetSchema.parse(parsed);
}

// Bad — helper has exactly one caller
function ensureObject(value: unknown): object {
  if (typeof value !== "object" || value === null) {
    throw new Error("budget must be an object");
  }
  return value;
}
```

**Reviewer-checked.** Do not add a helper only to get under the line cap.
Simplify the function instead. A recursive algorithm and the exceptions above
are the cases that stay as their own functions.

## 4) Write tests for the code

Every behavior change ships with Vitest tests; bug fixes start with a failing
test.

```ts
// Good
it("rejects a cyber event with an attacker and no citation", () => {
  expect(() => eventSchema.parse(attackerWithoutUrl)).toThrow();
});

// Bad
it("works", () => {
  expect(true).toBe(true);
});
```

**Lint and CI.** `@crisis-map/pipeline` and `@crisis-map/shared` fail CI below
80% line and branch coverage. Every package has at least one real Vitest
test. Reviewers still check that a bug fix started from a failing test and
that a new behavior is the thing the test asserts.

## 5) Comment the why and the non-obvious

Comment the why and the non-obvious (constraints, license/safety rules,
surprising decisions, links to ADRs); don't over-comment or restate the code.

```ts
// Good — the 24h delay is a civilian-safety rule, not obvious from the number
const UNREST_DELAY_MS = 24 * 60 * 60 * 1000;

// Bad
// Add one to index
index += 1;
```

**Reviewer-checked.**

## 6) UI must meet WCAG 2.2 AA

UI must meet WCAG 2.2 AA.

```tsx
// Good
<button type="button" aria-pressed={on} onClick={toggle}>
  Conflict
</button>

// Bad
<div onClick={toggle} style={{ color: "#777", background: "#888" }}>
  conflict
</div>
```

**Reviewer-checked.** Use real controls, text that is not color alone, visible focus, and
contrast that meets AA. An automated scanner is not a substitute for this review.

## Where the gates live

| Rule                                                                      | Enforcement                                                                                                           |
| ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Cognitive complexity ≤ 10                                                 | Biome `complexity.noExcessiveCognitiveComplexity`                                                                     |
| Function body ≤ 30 lines                                                  | Biome `complexity.noExcessiveLinesPerFunction`                                                                        |
| Naming conventions                                                        | Biome `style.useNamingConvention`                                                                                     |
| No unused code                                                            | Biome `correctness.noUnusedVariables`, `noUnusedImports`, `noUnusedFunctionParameters`, `noUnusedPrivateClassMembers` |
| No explicit `any`                                                         | Biome `suspicious.noExplicitAny`                                                                                      |
| Coverage ≥ 80% lines and branches                                         | Vitest on `@crisis-map/pipeline` and `@crisis-map/shared`                                                             |
| Single-use helpers, folder structure, comment quality, failing-test-first | Review                                                                                                                |
| UI meets WCAG 2.2 AA                                                      | Review                                                                                                                |
