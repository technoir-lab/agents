# Implementation

## Rule contract

| Concern | Contract |
|---|---|
| ID | Use `<rule-set-id>:<rule-id>`; both parts match `[a-z]+(-[a-z]+)*` |
| Ownership | Use a custom rule-set ID; `standard` is reserved for KtLint |
| Metadata | Use the provider's shared `Rule.About` with an accurate maintainer, repository, and issue tracker |
| Instances | Let `RuleProvider` create a fresh rule every time |
| File setup | Initialize configuration and per-file state in `beforeFirstNode` |
| Traversal | Inspect nodes in `beforeVisitChildNodes` or `afterVisitChildNodes` |
| Cleanup | Use `afterLastNode` only when end-of-file aggregation or cleanup is needed |
| Compatibility | Implement visitor hooks from `RuleAutocorrectApproveHandler` |

Digits, underscores, uppercase letters, repeated hyphens, trailing hyphens, and unqualified rule IDs are invalid in KtLint 1.8.0.

## Lint-only rule

```kotlin
import com.pinterest.ktlint.rule.engine.core.api.AutocorrectDecision
import com.pinterest.ktlint.rule.engine.core.api.ElementType.VAR_KEYWORD
import com.pinterest.ktlint.rule.engine.core.api.Rule
import com.pinterest.ktlint.rule.engine.core.api.RuleAutocorrectApproveHandler
import com.pinterest.ktlint.rule.engine.core.api.RuleId
import org.jetbrains.kotlin.com.intellij.lang.ASTNode

internal class NoVarRule :
    Rule(
        ruleId = RuleId(RULE_ID),
        about = ExampleRuleSetProvider.ABOUT,
    ),
    RuleAutocorrectApproveHandler {

    override fun beforeVisitChildNodes(
        node: ASTNode,
        emit: (offset: Int, errorMessage: String, canBeAutoCorrected: Boolean) -> AutocorrectDecision,
    ) {
        if (node.elementType == VAR_KEYWORD) {
            emit(node.startOffset, "Unexpected var, use val instead", false)
        }
    }

    internal companion object {
        private const val RULE_ID = "${ExampleRuleSetProvider.ID}:no-var"
    }
}
```

## Auto-correction

Emit the finding before changing the AST. Advertise correction only when approval performs a real mutation.

```kotlin
import com.pinterest.ktlint.rule.engine.core.api.ifAutocorrectAllowed
import com.pinterest.ktlint.rule.engine.core.api.remove

emit(whiteSpace.startOffset, "Unexpected whitespace", true)
    .ifAutocorrectAllowed {
        whiteSpace.remove()
    }
```

- Put every mutation inside `ifAutocorrectAllowed`.
- Use `canBeAutoCorrected = false` when no safe correction exists.
- Keep corrections deterministic, parseable, and convergent across repeated formatting passes.
- Preserve comments and surrounding whitespace deliberately.
- Recalculate or avoid cached node positions after AST mutation.

## Change and review checklist

- [ ] The behavior has one focused responsibility and a stable diagnostic message.
- [ ] The rule ID is valid, namespaced, and unchanged unless a breaking rename is intended.
- [ ] `Rule.About` points to the actual maintainer and project.
- [ ] The rule implements `RuleAutocorrectApproveHandler`, not the deprecated `autoCorrect: Boolean` hooks.
- [ ] Mutable state is per rule instance and initialized for each file.
- [ ] Every EditorConfig read is declared in `usesEditorConfigProperties`.
- [ ] Each emitted offset points at the smallest useful node or leaf.
- [ ] `canBeAutoCorrected` matches the implementation.
- [ ] Denied correction leaves the AST unchanged.
- [ ] Approved correction preserves syntax and stabilizes after formatting.
- [ ] The provider returns a new instance rather than a singleton.
- [ ] Tests cover compliant code, each violation branch, and formatting when supported.

When wrapping or adapting a KtLint rule, change its rule ID and use the owning provider's `Rule.About`.

## References

- [Custom rule set](https://ktlint.github.io/ktlint/1.8.0/api/custom-rule-set/)
- [Custom integration: rule and approved auto-correction](https://ktlint.github.io/ktlint/1.8.0/api/custom-integration/#rule--ruleautocorrectapprovehandler)
- [`Rule`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/Rule.kt)
- [`RuleAutocorrectApproveHandler`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/RuleAutocorrectApproveHandler.kt)
- [`AutocorrectDecision`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/AutocorrectDecision.kt)
- [AST node extensions](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/ASTNodeExtension.kt)
- [`RuleProvider`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/RuleProvider.kt)
- [ID naming policy](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/internal/IdNamingPolicy.kt)
- [Template rule](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/main/kotlin/yourpkgname/NoVarRule.kt)
- [Auto-correcting rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/SpacingBetweenFunctionNameAndOpeningParenthesisRule.kt)
