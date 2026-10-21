# Security audit 2026-10-21: ready-to-file backlog

Parent: https://github.com/Mike-Demo/info-grove/issues/1

Issue creation is unavailable in this session. Each title and body below is
ready to file in `Mike-Demo/info-grove`; no child issues have been created.
This is triage only: no application code, policies, or migrations are changed.

## Priority and grouping

The parent reports five confirmed findings (three medium, two low) and two
needs-validation leads, based on static inspection only. No deployed endpoint
or exploit was tested. The current application always selects a browser-local
mock repository; SQL grants/policies establish potential anonymous database
reachability if those migrations are deployed and the database API is exposed.
They do not establish that any live deployment exposes those paths.

Evidence for current mode:
`/home/runner/work/info-grove/info-grove/src/lib/data/client.ts:5–24`.

| Order | Remediation issue | Original severity | Risk, reachability, and fix scope |
| --- | --- | --- | --- |
| 1 | Enforce event registration invariants on every write path | medium | Anonymous SQL RPC permits non-public/past registrations; direct INSERT policy bypasses capacity without needing a race. Requires both RPC checks/locking and closure of direct lower-trust writes. |
| 2 | Enforce parent publication for variant reads and checkout | medium + low | Anonymous SQL checkout can mutate stock/create orders for unpublished products without a race. Mock checkout and public variant lookup share the missing parent-publication check, but affect only browser-local data today. Small predicate changes across these paths. |
| 3 | Make order stock decrement atomic | medium | Anonymous SQL callers can oversell public products by racing concurrent checkouts. Same conditional SQL reachability as above, but requires concurrency. A small guarded UPDATE or row lock fixes it. |
| 4 | Enforce email-gated resource access and downloads | low | An ordinary anonymous visitor can read the resource/download the static asset in the current app. Current files are fixtures; no sensitive production content is established. A real gate needs a checked download boundary and is larger than the predicate/locking fixes. |

Ordering follows severity, lower-trust reachability and exploitation conditions,
then fix size/safety. SQL findings should block exposing a connected database,
not be described as demonstrated attacks on the current mock-only app.

**Root-cause grouping:** the medium unpublished-variant checkout finding and
the low mock variant-read finding share failure to enforce the parent product's
publication predicate at variant access, so they have one remediation issue.
The stock race remains separate: it also affects published products and needs
atomicity, not a publication filter. The event RPC and direct INSERT weaknesses
are already one supplied finding and must be fixed together.

Repository evidence below uses absolute checkout paths and line ranges. These
refer to the audited source, not future remediation patches. SQL fixes should
ship as a new forward migration, not rewrite already-applied migrations.
Acceptance checklists describe future remediation tests, not tests run here.

## 1. Event registration

### Exact issue title

`[security][medium] Enforce event registration invariants on every write path`

### Issue body

Parent audit: https://github.com/Mike-Demo/info-grove/issues/1

**Priority:** 1. **Severity:** medium.
**Fingerprint:** `event-registration-bypasses-publication-and-capacity`.

**Evidence and impact**

- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0000_phase5_schema.sql:901–934`:
  `register_for_event` is `SECURITY DEFINER`, granted to `anon` and
  `authenticated`. It selects the event without a lock, checks
  `registration_open`, counts registrations, and inserts. It does not call
  `public.is_public_record` or reject past events; concurrent calls can pass
  the same capacity count.
- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0002_tighten_access_rules.sql:43–47`:
  the effective direct INSERT policy checks name/email shape, user identity
  consistency, and `registration_open`, but has no explicit publication,
  upcoming, or capacity check. Direct inserts bypass RPC capacity enforcement.
  The event subquery is also subject to applicable event read policies;
  the definer RPC independently omits publication enforcement.
- `/home/runner/work/info-grove/info-grove/src/lib/data/mock.ts:211–222`:
  the mock path instead resolves a visible event and requires upcoming/open
  registration.

**Root cause**

Neither SQL registration write path enforces all publication, upcoming, and
capacity invariants. A hardened RPC alone leaves the direct-write bypass open.

**Smallest complete fix**

In a forward migration, require `public.is_public_record` using the event's
status and published/scheduled timestamps, a future start time, and open
registration in `register_for_event`. Lock the event row `FOR UPDATE` before
counting registrations and keep the count/insert in that transaction.
Add publication/upcoming conditions to any retained INSERT policy, but do not
treat a policy as an atomic capacity guard. Revoke direct anonymous INSERT and
close equivalent direct writes by non-admin authenticated callers; route
lower-trust registrations only through the checked RPC. Preserve the existing
input/identity validation when consolidating writes into the RPC.

**Acceptance checks**

- [ ] Anonymous and non-admin authenticated callers cannot register for draft,
  archived, future-scheduled, past, or registration-closed events.
- [ ] Direct lower-trust table inserts are denied; the checked RPC still accepts
  valid public/upcoming registrations.
- [ ] Concurrent RPC calls for the final place admit at most one registration.
- [ ] Existing capacity semantics and name/email/identity checks are preserved.

## 2. Variant publication (two findings, one root-cause group)

### Exact issue title

`[security][medium] Enforce parent publication for variant reads and checkout`

### Issue body

Parent audit: https://github.com/Mike-Demo/info-grove/issues/1

**Priority:** 2. **Group severity:** medium.
**Fingerprints and original severities:**

- `order-placement-accepts-unpublished-variants` — medium.
- `mock-listvariants-leaks-unpublished-product` — low.

**Evidence and impact**

- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0000_phase5_schema.sql:829–899`:
  `place_order` is `SECURITY DEFINER`, executable by `anon` and `authenticated`.
  It resolves variants by ID without joining/checking the parent product,
  then decrements stock and creates an order.
- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0002_tighten_access_rules.sql:25–28`:
  the variant SELECT policy requires a public parent (or admin access), but
  does not constrain this definer function's variant lookup.
- `/home/runner/work/info-grove/info-grove/src/lib/data/mock.ts:231–260`:
  mock checkout resolves variants from all variants and parents from
  `d.products`, without `visible()`.
- `/home/runner/work/info-grove/info-grove/src/lib/data/mock.ts:147–158`:
  `listProductsByIds` filters parents through `visible()`, but `listVariants`
  does not, returning price, stock, SKU, and parent identity for hidden products.
- `/home/runner/work/info-grove/info-grove/src/lib/data/queries.ts:23`:
  `variantsQuery` forwards caller-supplied IDs to `listVariants`.

The SQL path permits lower-trust callers with a variant ID to order unpublished
products. The mock paths expose hidden-product data and permit equivalent local
checkout, but currently operate on the visitor's browser-local dataset.

**Shared root cause**

Variant reads and writes fail to re-check the parent product's publication
predicate. Hiding a product in listing UI or a table read policy does not
enforce the invariant at checkout.

**Smallest complete fix**

In a forward migration, join the parent product in `place_order` and reject
unless `public.is_public_record(status, published_at, scheduled_at)` holds,
before decrementing stock or creating an order. In mock checkout and
`listVariants`, resolve parents only from `visible(d.products)` using the
existing shared publication mechanism. Reject checkout for a hidden/missing
parent; return no variant rows for such parents. Keep the stock-concurrency
fix tracked separately.

**Acceptance checks**

- [ ] SQL and mock checkout reject variants of draft, archived, unpublished,
  and not-yet-public scheduled products without changing stock or orders.
- [ ] Mock `listVariants` returns no data for those parents, including IDs kept
  in carts/wishlists after a product is unpublished.
- [ ] Public parents (including due publication transitions) remain supported
  consistently with existing public product queries and the explicit test clock.

## 3. Stock concurrency

### Exact issue title

`[security][medium] Make order stock decrement atomic`

### Issue body

Parent audit: https://github.com/Mike-Demo/info-grove/issues/1

**Priority:** 3. **Severity:** medium.
**Fingerprint:** `place-order-stock-check-then-act-race`.

**Evidence and impact**

- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0000_phase5_schema.sql:862–875`:
  `place_order` reads a variant without `FOR UPDATE`, checks `v.stock`, then
  executes `stock = stock - qty` with only an ID predicate.
- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0000_phase5_schema.sql:288`:
  stock is an integer with no nonnegative CHECK backstop.
- `/home/runner/work/info-grove/info-grove/drizzle/migrations/0000_phase5_schema.sql:899`:
  anonymous and authenticated callers have RPC execution permission.

Under default PostgreSQL READ COMMITTED behavior, two concurrent calls can
read the same stock, pass the stale checks, and both decrement it below zero,
creating oversold orders. This is a static concurrency finding, not a
concurrency test performed against a deployed database.

**Root cause**

The stock check and decrement are separate operations on an unlocked row, and
the UPDATE does not guard against insufficient remaining stock.

**Smallest complete fix**

In a forward migration, make the decrement conditional on both variant ID and
`stock >= qty`; raise `Insufficient stock` if the UPDATE affects no row.
Alternatively, select the variant `FOR UPDATE` before testing stock.
Keep all line-item changes and order creation in the same transaction so a
failed line rolls back earlier decrements. A nonnegative CHECK can be defense
in depth, but is not a substitute for correct stock handling.

**Acceptance checks**

- [ ] Concurrent anonymous RPC calls for the last units cannot commit more
  units than available or leave negative stock.
- [ ] Insufficient stock produces a controlled failure, with no order and no
  partial stock changes for earlier lines.
- [ ] Valid quantities and repeated variant lines consume the correct stock.

## 4. Email-gated resources

### Exact issue title

`[security][low] Enforce email-gated resource access and downloads`

### Issue body

Parent audit: https://github.com/Mike-Demo/info-grove/issues/1

**Priority:** 4. **Severity:** low.
**Fingerprint:** `email-gated-resource-download-not-enforced`.

**Evidence and impact**

- `/home/runner/work/info-grove/info-grove/src/lib/data/mock.ts:171–177`:
  `listResources` and `getResource` return visible records, including body and
  file path, without enforcing `access`.
- `/home/runner/work/info-grove/info-grove/src/routes/resources.$slug.tsx:37–41`:
  the detail page renders a download whenever `filePath` exists and renders
  the body unconditionally.
- `/home/runner/work/info-grove/info-grove/src/lib/data/fixtures.ts:205–208`:
  whitepapers are marked `email-gated` but use `/files/dxs-fixture-sample.txt`.
- `/home/runner/work/info-grove/info-grove/public/files/dxs-fixture-sample.txt`:
  the download is a public static asset, independently accessible by URL.

Anonymous visitors can bypass the advertised email requirement. The supplied
asset is a fixture; no sensitive production file exposure is established.

**Root cause**

The access flag is presentational only. Repository reads, detail rendering,
and static file delivery do not enforce a resource-specific email gate.

**Smallest complete fix**

Withhold gated body and file path from public reads until email capture for
that resource is completed; cover both detail and list responses so the list
cannot bypass the gate. Render the capture state instead of protected content.
Move gated files out of `public/` and serve them through a download route that
checks resource-specific capture completion. Merely hiding the button or
changing the URL is insufficient. For connected deployments, enforce that
check at the trusted data/download boundary, not only in browser state.
Keep UI data access behind the existing query/mutation repository boundary.

**Acceptance checks**

- [ ] Before capture, detail/list responses and the page withhold gated body
  and file path; direct download requests are denied.
- [ ] Capture for one resource does not unlock other gated resources.
- [ ] After capture, that resource's body and checked download work.
- [ ] Public resources remain accessible; the old static URL no longer serves
  any protected file.

## 5. Needs-validation checklist

### Exact issue title

`[security][needs-validation] Audit leads to validate`

### Issue body

Parent audit: https://github.com/Mike-Demo/info-grove/issues/1

These are leads, not confirmed findings. No severity is assigned. Resolve the
missing trust/deployment facts before promoting either to a remediation issue.

- [ ] **Private/admin route tree has no authentication or authorization guard**
  — fingerprint: `private-routes-have-no-authentication-guard`.
  **Claimed root cause:** the `_private` route tree and `PrivateRepository`
  lack an authentication/authorization guard; shared/real data would make
  private reads and admin writes reachable by unauthenticated visitors.
  **Exact missing fact (from parent):**
  > Whether any deployment ever wires these same _private routes to a connected (Supabase/cloud) repository adapter or other shared/real dataset, replacing the always-mock localStorage dataset — if so, the same missing guard would expose real private records and admin writes; if the build stays mock-only, impact remains self-only.

  **Static pointers:** `/home/runner/work/info-grove/info-grove/src/routes/_private.tsx:4–6,27`
  defines the layout without a guard and identifies demo authentication;
  `/home/runner/work/info-grove/info-grove/src/lib/data/client.ts:5–24`
  always selects mock browser-local storage today.
  **Validation:** obtain deployment configuration and adapter/data ownership
  evidence from the operator. Record whether any deployment uses shared data
  and what guards apply there. If all deployments remain local-only, document
  that boundary rather than claiming cross-user exposure.

- [ ] **Rich-text link hrefs are stored without validation and rendered verbatim,
  allowing javascript: URLs in published content**
  — fingerprint: `richtext-link-href-scheme-not-validated`.
  **Claimed root cause:** bodies lack href scheme validation, so a lower-trust
  writer or verbatim external import could supply unsafe links for publication.
  **Exact missing fact (as supplied in parent, including its truncation):**
  > Whether, in any real deployment of this code, a principal lower-trust than the site operator (a non-admin content author, or an external CMS/migration source whose bodies are imported verbatim) can write post bodies that reach saveContent or a connected adapter and then be published for other visitors — no such writer, importer, role separation or…

  The parent itself ends this sentence at `or…`; recover any omitted audit
  wording from the operator rather than infer it.
  **Static pointers:** `/home/runner/work/info-grove/info-grove/src/lib/data/private-ops.ts:263–276`
  saves the supplied body;
  `/home/runner/work/info-grove/info-grove/src/components/site/RichText.tsx:7–15`
  passes link hrefs to anchors. This alone does not establish an exploitable
  deployed browser behavior.
  **Validation:** establish who can write/import and publish bodies, the trust
  relationship to the operator, and whether other visitors receive them.
  Record role/import/deployment evidence; if the required writer exists,
  separately validate actual browser handling of unsafe schemes before
  claiming script execution. Do not treat operator-only local content as a
  confirmed cross-user vulnerability.
