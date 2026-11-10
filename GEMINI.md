# OpenPro Autonomous Sprint Engineering Rules & Governance

These rules govern the autonomous execution of engineering sprints for OpenPro.

## Trigger Phrases
Whenever the user issues any of the following commands:
- `run daily sprint`
- `run sprint`
- `next sprint`

The AI agent MUST autonomously execute the following mandatory 6-Phase Protocol:

---

### MANDATORY 6-PHASE PROTOCOL FOR "run daily sprint"

#### PHASE 1: PRE-FLIGHT HEALTH CHECK (BEFORE TOUCHING NEW CODE)
- Never start a new feature on a broken or dirty repository.
- Run:
  1. `git status` and `git pull --rebase origin main` (ensure local branch is synced with GitHub).
  2. `flutter pub get`
  3. `flutter analyze`
  4. `flutter test`
- If ANY pre-flight error, warning, or unpushed commit exists from a previous session, fix and resolve it FIRST before reading the backlog.

#### PHASE 2: BACKLOG SELECTION & ARCHITECTURAL PLANNING
- Open `docs/AUTONOMOUS_BACKLOG.md` and select the first unchecked `[ ]` item.
- If all items in `docs/AUTONOMOUS_BACKLOG.md` are marked `[x]`, autonomously generate 15 new senior-level architectural or feature sprints in `docs/AUTONOMOUS_BACKLOG.md` and select the first new `[ ]` item.

#### PHASE 3: PRODUCTION IMPLEMENTATION & UI SAFETY
- Implement the selected feature end-to-end across `data/`, `domain/`, and `presentation/` following SOLID, DRY, and Clean Architecture.
- Enforce strict UI & Runtime Safety:
  - **Zero Emojis Policy:** Never use emojis anywhere in source code, UI strings, logs, or commit messages. Vector Material Symbols (`Icons.*`) exclusively.
  - **Zero Hardcoded Colors:** Resolve all colors dynamically via `Theme.of(context).colorScheme` (`surface`, `surfaceContainer`, `surfaceContainerHighest`, `onSurface`, `onSurfaceVariant`, `primary`, `secondary`, `outlineVariant`). Test both Dark and Light mode parity.
  - **Hero Tag Exclusivity:** Explicit unique `heroTag` string on every `FloatingActionButton` (e.g. `heroTag: 'fab_job_feed'`, `heroTag: 'fab_create_post'`).
  - **Landscape Safety (360dp Viewport):** Independent vertical scroll controllers, explicit `mainAxisExtent` on all `GridView` items, text wrapped in `Expanded` or `Flexible` with `overflow: TextOverflow.ellipsis`, and edge-to-edge charts.
  - **Complete Interactivity:** Every button, chip, dialog, filter, and share sheet must be 100% wired and functional with `AppFeedback` alerts and inline form validation.

#### PHASE 4: AUTOMATED & LIVE DEVICE RUNTIME VERIFICATION
- Add or update unit and widget tests in `test/` covering the new feature AND verifying zero landscape overflow (800x360 viewport).
- Execute the verification gate:
  ```powershell
  dart run tool/sprint_gate.dart
  ```
  (or run the full sequence: `flutter pub get` -> `dart format lib test` -> `flutter analyze` -> `flutter test`).
- **Live Connected Device Runtime Check:**
  - If a physical Android/iOS device or emulator is connected via USB, run the app on the connected device (`flutter run -d <deviceId>`).
  - Wait for the `SplashView` animation transition into the main shell.
  - Inspect device runtime logs (`adb logcat -d` / console output).
  - If ANY of the following prohibited exceptions appear, fix the code and re-test until 0 exceptions occur:
    - `EXCEPTION CAUGHT BY`
    - `A RenderFlex overflowed by`
    - `There are multiple heroes that share the same tag`
    - `No observables detected in the build method of Observer`
    - `setState() or markNeedsBuild() called during build`
    - `AndroidRuntime: FATAL EXCEPTION`
    - `Unhandled Exception:`

#### PHASE 5: ATOMIC GIT COMMIT & GUARANTEED GITHUB PUSH
- Mark the completed item as `[x]` in `docs/AUTONOMOUS_BACKLOG.md`.
- Stage all files:
  ```powershell
  git add -A
  ```
- Commit with a clean conventional commit message without emojis:
  ```powershell
  git commit --no-gpg-sign -m "feat(<module>): <concise senior description>"
  ```
- Push to GitHub:
  ```powershell
  git push origin main
  ```

#### PHASE 6: POST-PUSH PROOF VERIFICATION (NEVER SKIP)
- After running `git push origin main`, you MUST execute:
  ```powershell
  git status -sb
  git log origin/main..HEAD --oneline
  ```
- Verify that `git log origin/main..HEAD` returns 0 unpushed commits and the working tree is 100% clean.
- If the push failed due to network timeout or remote changes, run `git pull --rebase origin main` and `git push origin main` again until remote sync is confirmed.
- Report the exact Commit SHA, modified files, test count, device runtime status, and confirmed `origin/main` push status to the user.
