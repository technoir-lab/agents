---
name: developing-ktlint-rules
description: Use when implementing, modifying, reviewing, or unit testing custom KtLint rules and RuleSetProviderV3 rule sets, including EditorConfig options, opt-in markers, and auto-correction.
---

# Developing KtLint Rules

## Baseline

- KtLint version: `1.8.0`.
- API packages: `com.pinterest.ktlint.*`.
- Rule API: `Rule` plus `RuleAutocorrectApproveHandler`.
- Ignore current `master` examples that use `io.github.ktlint.*` or `RuleV2`; those target a later API.
- Use an existing rules library, or create one when the request explicitly requires a new local rule set.

## Workflow

1. Read [repository conventions](references/conventions.md) when they apply and select the correct rules library.
2. Inspect the existing rule, `RuleSetProviderV3`, service descriptor, tests, and Gradle wiring; create missing library wiring only for an explicitly requested new local rule set.
3. Read only the pages relevant to the requested change; for Technoir Lab projects, apply the [Kotlin code style skill](../kotlin-code-style/SKILL.md).
4. Implement the rule contract, configuration, marker interfaces, and auto-correction together.
5. Add the rule to its provider; create or register a provider only for a new rule set.
6. Unit test lint findings, formatting, configuration branches, provider completeness, and service discovery.
7. Review the diff against the checklists on the selected pages.

## Page index

| Need | Read |
|---|---|
| Repository placement and policy delta | [Conventions](references/conventions.md) |
| Rule lifecycle, IDs, diagnostics, state, review, auto-correction | [Implementation](references/implementation.md) |
| Custom EditorConfig options, experimental rules, explicit opt-in | [Configurability](references/configurability.md) |
| Rule and provider unit tests | [Testing](references/testing.md) |
| `RuleSetProviderV3`, `RuleProvider`, and ServiceLoader wiring | [Rule sets](references/rule-sets.md) |

## Boundaries

- Add or modify Gradle module configuration only when the requested rule set requires a new rules library.
- Do not copy unpinned examples from KtLint `master`.
- Do not reuse one `Rule` instance across provider calls.
