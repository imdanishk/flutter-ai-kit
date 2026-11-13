# Roadmap

What comes next, in order. Last updated 2026-11-13 (kit 0.19.4). Items move or drop when trial reports say so.

## 1. Riverpod trial

The Cubit stack has been run on real projects. The Riverpod recipe has not. Run the feature, plan, review, testing and fix skills on a real Riverpod project (a clone, on a throwaway branch) and on a new project created with the new-project skill and Riverpod chosen. Fix what the reports show.

The step-by-step guide with copy-paste prompts is `RIVERPOD-TRIAL.md`.

## 2. Rollout kit for colleagues

- README "first 10 minutes" guide.
- A GitHub issue template that asks for the trial report fields (task, stack, what worked, what failed, command output, kit version).
- An update note: installed copies do not update themselves, so say how to re-run the installer. Rules and preferences in a project belong to that project and are not overwritten.
- Then give it to two or three colleagues on real tickets for a week and collect reports.

## 3. Dated-facts refresh passes

The notes pin dates and versions that change. Refresh (see `REFRESH.md`):

- Early December, after CocoaPods goes read-only on 2026-12-02.
- Late January, before the Firebase App Check delay limit of 2027-01-21.
- Before the Google Play 16 KB page-size requirement of 2027-02-01.
- On each new Flutter stable release.

The refresh-reminder workflow already lists guides older than 30 days.

## 4. When the means exist

- iOS on a Mac: build, simulator run, and the persistence package through Pods or SwiftPM.
- The design and store-assets skills on a real app.
- A release-skill dry run on a clone, nothing uploaded, with a real Fastlane setup.
- Real store accounts (Google Play, App Store) later.
- Check the 16 KB engine-alignment claim (currently marked Unverified).

## 5. Avoid for now

No new skills and no large new references before colleague feedback. Each new piece adds reading cost for every agent that loads the kit.
