---
name: bump-convention-plugins-version
description: Bump conventionPluginsVersion in an individual project or across a workspace, apply relevant Technoir Lab convention plugin release adaptations, and carry one PR per repository through CI and merge. Use when asked to update the convention plugins version.
---

# Bump Convention Plugins Version

Respect any explicit limits on projects, commits, PRs, or merges.

## Select target projects

- Honor explicit project paths or selections. Otherwise, determine scope from the invocation's working directory, applicable guidance, and project layout, not the installed skill's location or Git repository membership:
  - Individual project or project subdirectory: locate the containing project root using its Gradle settings and project guidance. Target only that project; do not include sibling projects or expand to a parent workspace unless requested.
  - Workspace root: use workspace guidance and layout to discover its project roots. A workspace may itself be a Git repository, contain independent repositories, or both. Distinguish projects from Gradle subprojects and included builds using the project's settings and guidance.
- Select projects whose `settings.gradle.kts` sets `conventionPluginsVersion` for `io.technoirlab.conventions.*` plugins. Report when no selected project matches and stop before preparing an update.
- Resolve each selected project's owning repository with `git rev-parse --show-toplevel` from its project root. Group selected projects sharing a repository into one update branch, commit, and PR; keep independent repositories separate.
- Read applicable workspace and project guidance. An individual project does not require a parent workspace or sibling checkout of `convention-plugins`; use the upstream release and publication URLs below.
- Run Git and GitHub CLI commands from the owning repository root. Resolve settings paths and run Gradle commands from each selected project's root. When using a temporary worktree, preserve each project's path relative to its repository root. Run local checks one project at a time.

## Resolve and verify the target version

Complete this preflight before creating branches or worktrees or editing projects.

1. Use the user-specified version as `vNN`. If omitted, fetch `https://api.github.com/repos/technoir-lab/convention-plugins/releases/latest` and use the response's `tag_name` exactly, including its `v` prefix. Resolve it once for the whole update and provide the release's `html_url` to the user. This uses GitHub's latest published full release; see the [GitHub release API](https://docs.github.com/en/rest/releases/releases#get-the-latest-release).
2. For either an explicit or resolved version, fetch only the settings plugin marker POM from `https://repo.maven.apache.org/maven2/io/technoirlab/conventions/settings/io.technoirlab.conventions.settings.gradle.plugin/vNN/io.technoirlab.conventions.settings.gradle.plugin-vNN.pom`. Confirm it identifies the requested version. Perform this check once for the whole update; use it as the Maven Central publication check.
3. If the settings marker is missing, report the version as not yet available on Maven Central and stop before changing projects. Report network or authentication failures as an inability to verify publication. Do not silently substitute an older version; retry verification when publication is available.

## Steps

Repeat for each owning repository, including all selected projects in it.

1. Read each selected project's `settings.gradle.kts`; confirm its current version. Inspect the repository's current branch and tracked edits with `git status --porcelain --untracked-files=no` (includes staged and unstaged changes).
2. Before updating, review the target release notes at `https://github.com/technoir-lab/convention-plugins/releases/tag/vNN` and provide the resolved link to the user. Identify build-breaking changes and minor quality-of-life improvements relevant to each selected project.
3. Run `git fetch origin`, then prepare the update checkout before editing:
   - If there are tracked uncommitted edits, create a temporary worktree from `origin/main`: `git worktree add -b conventionPluginsVersion-vNN <temporary-path> origin/main`. Perform the update there; leave the original checkout's branch and edits intact.
   - Otherwise, check out `main`, run `git pull --ff-only origin main`, then `git checkout -b conventionPluginsVersion-vNN`. Untracked files alone do not require a worktree; preserve them. If they block a checkout or pull, report the collision without deleting or overwriting them.
4. Read each selected project's `settings.gradle.kts` in the prepared checkout and confirm its version before changing it.
5. For each selected project, set `val conventionPluginsVersion = "vNN"`. Adapt the project to build-breaking changes and, where feasible, apply relevant minor quality-of-life improvements from the release. Include these changes in the same update commit as the version bump.
6. Sanity check each selected project: `./gradlew ktlintCheck test checkSortDependencies`
7. Stage ONLY the selected projects' `settings.gradle.kts` files and related release adaptations and improvements — never stage unrelated dirty/untracked files
8. Commit: `Bump conventionPluginsVersion to vNN`
9. Push the branch
10. Create PR via `gh pr create`: title `Bump conventionPluginsVersion to vNN`, no body, label `dependencies`.
11. For public repositories only: `gh pr merge <url> --auto --squash`. Never enable auto-merge for private repositories or their pull requests: GitHub Free cannot enforce required status checks there, so auto-merge could merge before CI passes.
12. Verify per PR: label present; for public repositories, `autoMergeRequest` non-null (post-merge `UNKNOWN`/404 on auto-merge PUT is expected — check PR `state` first); for private repositories, auto-merge disabled.
13. Monitor CI checks on every PR. Investigate failures, push fixes, and repeat until all CI checks pass for the latest PR head commit.
    - Public repositories: continue monitoring and addressing failures until the PR is auto-merged; verify its state is `MERGED`.
    - Private repositories: once all CI checks pass for the latest PR head commit, merge with `gh pr merge <url> --squash --match-head-commit <verified-head-sha>` and verify its state is `MERGED`. If the head changes, check CI again before merging.
14. When done with a temporary worktree, leave its directory and remove it with `git worktree remove <temporary-path>`. Do not force-remove uncommitted work; if unfinished changes prevent cleanup, preserve them and report the retained path and reason. After each PR is merged, switch the original local checkout to `main` and run `git pull --ff-only origin main` if possible without disturbing unrelated local changes. Leave an originally dirty checkout on its original branch with its edits intact. Report any checkout or update that could not be completed.

15. After verifying the PR is `MERGED` and completing checkout/worktree cleanup, delete the local update branch with `git branch -d conventionPluginsVersion-vNN`. First confirm its tip still matches the merged PR head and it is not checked out in any worktree. If `-d` rejects the branch because squash merging did not preserve its ancestry, use `git branch -D conventionPluginsVersion-vNN` only after those checks pass. Otherwise, preserve the branch and report why it could not be deleted.

## Constraints

- One PR per owning repository, all branches named `conventionPluginsVersion-vNN`
- Report final PR URLs + merge state per repo

## References

- [Git repository root discovery](https://git-scm.com/docs/git-rev-parse#Documentation/git-rev-parse.txt---show-toplevel)
- [GitHub latest release API](https://docs.github.com/en/rest/releases/releases#get-the-latest-release)
- [Git branch deletion options](https://git-scm.com/docs/git-branch#Documentation/git-branch.txt--d)
