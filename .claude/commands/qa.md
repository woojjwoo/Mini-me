# QA Loop Harness

You are running the QA harness for the Mini Me iOS app.
Scope: **$ARGUMENTS** (use "full" if no argument — checks everything changed since last commit)

You are in the Evaluator role. Do not rationalize away failures. Report what you find.

---

## Step 1 — Change Inventory

```bash
git diff --name-only HEAD
git diff --name-only HEAD~1 HEAD 2>/dev/null || git diff --cached --name-only
```

List changed files grouped by layer:
- Models (SwiftData schema changes — highest risk)
- Services (logic changes)
- Features/Views (UI changes)
- Scripts / Assets (pipeline changes)

---

## Step 2 — Syntax Check All Swift Files

```bash
bash mini-me/scripts/typecheck-all.sh
```

Any ❌ output is a blocker. Report file + line. Do not proceed past this step until all syntax errors are resolved.

---

## Step 3 — Architecture Regression Checks

For each category of changed files, run the corresponding check:

**If Models/ changed:**
- Do all `@Query` properties in views still reference valid model types?
- Do all services that take `ModelContext` still compile?
- Are all new SwiftData model properties declared with `@Attribute` where needed?

**If Services/ changed:**
- Does every service that writes widget data still use the correct App Group ID `group.com.woojjwoo.pixieme.shared`?
- Does `CoinService` still call `WidgetDataService.updateWidgetData()` after awarding coins?

**If RoomScene.swift or IsometricRoomView.swift changed:**
- Search for `anchorPoint` — every sprite added to `worldLayer` must have `anchorPoint = CGPoint(x: 0.5, y: 0)`
- Search for `zPosition` — no manual zPosition on floor-based items (only background at -2000, other fixed elements)

**If ShopItem.swift (ItemCatalog) changed:**
- Does every `spriteName` in ItemCatalog have a matching file in `Assets.xcassets`?
  ```bash
  # Quick check: list all spriteNames vs all imageset names
  grep 'spriteName:' mini-me/App/Models/ShopItem.swift | sed 's/.*"\(.*\)".*/\1/'
  ls mini-me/Assets.xcassets/ | grep imageset | sed 's/.imageset//'
  ```

---

## Step 4 — Dead Code & Orphan Audit

**Orphaned Swift files** (exist on disk, not referenced from Xcode project):
Look for Swift files that are NOT in the Xcode project's source groups. Common culprits:
- `StatsView.swift` — exists in Features/Stats/ but not wired to any tab
- Any file at the repo root (e.g. `MilestoneService.swift`, `TimeOfDayService.swift` at root level instead of App/Services/)

**Orphaned assets** (in .xcassets but no catalog reference):
- Check if any `.imageset` folders exist with no matching `spriteName` in ItemCatalog

**UI strings that say "pet"** (must say "Mini Me" or nothing):
```bash
grep -rn '"pet\|Pet ' mini-me/App/Features/ --include="*.swift" | grep -v "//\|PetMood\|PetColor\|PetActivity\|petNode\|petBed\|\.pet"
```

---

## Step 5 — QA Report

Output a structured report:

```
## QA Report — <date>

### Syntax: PASS | FAIL
<details if fail>

### Architecture: PASS | FAIL | WARNINGS
<list of regressions or warnings with file:line>

### Dead Code: CLEAN | ISSUES
<list of orphans>

### UI Language: CLEAN | ISSUES
<any "pet" strings in user-facing text>

### Verdict: SHIP-READY | NEEDS FIXES
<1-2 sentence summary>
```

If NEEDS FIXES: list specific actions in priority order. The user should run `/feature` for each fix.
