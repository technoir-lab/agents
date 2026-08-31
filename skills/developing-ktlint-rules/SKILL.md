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
3. Read only the pages relevant to the requested change.
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

## References

### KtLint 1.8.0 documentation

- [API overview](https://ktlint.github.io/ktlint/1.8.0/api/overview/)
- [Custom rule set](https://ktlint.github.io/ktlint/1.8.0/api/custom-rule-set/)
- [Custom integration](https://ktlint.github.io/ktlint/1.8.0/api/custom-integration/)
- [KtLint configuration](https://ktlint.github.io/ktlint/1.8.0/rules/configuration-ktlint/)
- [Experimental rules](https://ktlint.github.io/ktlint/1.8.0/rules/experimental/)
- [Contributing guidelines](https://ktlint.github.io/ktlint/1.8.0/contributing/guidelines/)

### KtLint 1.8.0 source

- [`Rule`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/Rule.kt)
- [`RuleAutocorrectApproveHandler`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/RuleAutocorrectApproveHandler.kt)
- [`AutocorrectDecision`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/AutocorrectDecision.kt)
- [`RuleProvider`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/RuleProvider.kt)
- [`RuleSetProviderV3`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-cli-ruleset-core/src/main/kotlin/com/pinterest/ktlint/cli/ruleset/core/api/RuleSetProviderV3.kt)
- [`EditorConfigProperty`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/editorconfig/EditorConfigProperty.kt)
- [Rule-execution EditorConfig properties](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/editorconfig/RuleExecutionEditorConfigProperty.kt)
- [Rule-execution filter](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine/src/main/kotlin/com/pinterest/ktlint/rule/engine/internal/rulefilter/RuleExecutionRuleFilter.kt)
- [ID naming policy](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/internal/IdNamingPolicy.kt)
- [`KtLintAssertThat`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-test/src/main/kotlin/com/pinterest/ktlint/test/KtLintAssertThat.kt)
- [`RuleSetProviderTest`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-test/src/main/kotlin/com/pinterest/ktlint/test/RuleSetProviderTest.kt)
- [Template rule](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/main/kotlin/yourpkgname/NoVarRule.kt)
- [Template rule test](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/test/kotlin/yourpkgname/NoVarRuleTest.kt)
- [Template rule-set provider](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/main/kotlin/yourpkgname/CustomRuleSetProvider.kt)
- [Template ServiceLoader descriptor](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/main/resources/META-INF/services/com.pinterest.ktlint.cli.ruleset.core.api.RuleSetProviderV3)
- [Auto-correcting rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/SpacingBetweenFunctionNameAndOpeningParenthesisRule.kt)
- [Configurable rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/BlankLineBetweenWhenConditions.kt)
- [Experimental rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/ExpressionOperandWrappingRule.kt)
- [Explicit opt-in rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/NoUnusedImportsRule.kt)
- [Explicit opt-in rule test](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/test/kotlin/com/pinterest/ktlint/ruleset/standard/rules/NoUnusedImportsRuleTest.kt)

### Technoir Lab sources

- [Convention Plugins settings](https://github.com/technoir-lab/convention-plugins/blob/main/settings.gradle.kts)
- [Common KtLint convention](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/KtLint.kt)
- [`ktlint-rules` library](https://github.com/technoir-lab/convention-plugins/tree/main/libraries/ktlint-rules)
- [`ktlint-rules` Gradle module](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/ktlint-rules/build.gradle.kts)
- [`TechnoirLabRuleSetProvider`](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/ktlint-rules/src/main/kotlin/io/technoirlab/ktlint/rules/TechnoirLabRuleSetProvider.kt)
