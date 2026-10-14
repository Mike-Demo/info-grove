import { writeFileSync } from "node:fs";
import { createSeed } from "@/lib/data/fixtures";

it("dumps fixtures", () => {
  writeFileSync("/tmp/dbgen/seed.json", JSON.stringify(createSeed()));
  expect(true).toBe(true);
});
