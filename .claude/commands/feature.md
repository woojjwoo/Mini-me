# Feature Build Loop Harness

You are implementing a feature for the Mini Me iOS app (SwiftUI + SpriteKit + SwiftData, iOS 17+).
Feature request: **$ARGUMENTS**

Follow this harness exactly. Do not skip steps.

---

## Step 1 — Sprint Contract (define done BEFORE coding)

Create `.claude/sprint-$SLUG.md` where `$SLUG` is a short kebab-case name for the feature.
The contract must include:

```markdown
# Sprint: <Feature Name>

## Done looks like
- [ ] <specific, observable outcome 1>
- [ ] <specific, observable outcome 2>
- [ ] <specific, observable outcome 3>

## Files that will change
- App/Features/...
- App/Models/...
- App/Services/...

## Must not break
- [ ] Onboarding gate (ContentView checks hasCompletedOnboarding)
- [ ] Coin economy (CoinService.awardCoins fires on block complete)
- [ ] Widget data sync (WidgetDataService writes to group.com.woojjwoo.pixieme.shared)
- [ ] Room Y-sorting (RoomScene update loop sets zPosition = -position.y)
- [ ] App builds without errors

## Acceptance test
How to verify in Simulator: <describe exact tap sequence>
```

Read the sprint contract aloud back to the user and get confirmation before proceeding to Step 2.

---

## Step 2 — Implement (Generator role)

Implement the feature. Hard constraints from CLAUDE.md:
- **Pixel art aesthetic is non-negotiable** — every visual addition must pass the vibe test ("does this belong on a lo-fi album cover?")
- SwiftData models store enums as raw String values — never store enum directly
- Widget App Group ID: `group.com.woojjwoo.pixieme.shared`
- Pet model = Mini Me avatar — never say "pet" in any UI string
- `visualNode.anchorPoint` MUST be `(0.5, 0)` for any SpriteKit sprite added to the world layer
- Do not set manual zPosition on floor-based items — the Y-sort update loop handles it

The PostToolUse hook runs `swiftc -parse` on every file you edit. Watch for ❌ outputs — fix them immediately, do not continue to the next file.

---

## Step 3 — Verify

Run the full syntax check:
```bash
bash mini-me/scripts/typecheck-all.sh
```

If any errors: fix them before reporting. Do not claim success while errors exist.

---

## Step 4 — Evaluate (Evaluator role)

You are now a fresh evaluator who did not write this code. Re-read the sprint contract from Step 1.
For each done-condition, state explicitly: **MET** or **NOT MET** with evidence.

Be honest. If something is not met, re-enter Step 2 to address it.

---

## Step 5 — Handoff

Append to `.claude/handoff.md`:
```markdown
## <Feature Name> — <date>
Status: COMPLETE | PARTIAL
Files changed: <list>
Sprint contract: .claude/sprint-<slug>.md
Open items: <any deferred work or known issues>
```

Report to the user: what was built, what acceptance test to run, any deferred items.
