# Configurability

## Custom EditorConfig options

1. Define a typed `EditorConfigProperty<T>` with a default.
2. Add it to `Rule.usesEditorConfigProperties`.
3. Initialize the rule field from the property's default.
4. Read the filtered value in `beforeFirstNode`.
5. Test the default and every meaningful override.

The `EditorConfig` passed to a rule contains only its declared properties. Reading an undeclared property throws `IllegalStateException`.

```kotlin
import com.pinterest.ktlint.rule.engine.core.api.Rule
import com.pinterest.ktlint.rule.engine.core.api.RuleId
import com.pinterest.ktlint.rule.engine.core.api.editorconfig.EditorConfig
import com.pinterest.ktlint.rule.engine.core.api.editorconfig.EditorConfigProperty
import org.ec4j.core.model.PropertyType

internal class ConfigurableRule :
    Rule(
        ruleId = RuleId(RULE_ID),
        about = ExampleRuleSetProvider.ABOUT,
        usesEditorConfigProperties = setOf(IGNORE_ANNOTATED_PROPERTY),
    ) {
    private var ignoreAnnotated = IGNORE_ANNOTATED_PROPERTY.defaultValue

    override fun beforeFirstNode(editorConfig: EditorConfig) {
        ignoreAnnotated = editorConfig[IGNORE_ANNOTATED_PROPERTY]
    }

    internal companion object {
        private const val RULE_ID = "${ExampleRuleSetProvider.ID}:configurable"
        private val BOOLEAN_VALUES = setOf(true.toString(), false.toString())

        internal val IGNORE_ANNOTATED_PROPERTY = EditorConfigProperty(
            type = PropertyType.LowerCasingPropertyType(
                "ktlint_example_ignore_annotated",
                "Ignore annotated declarations.",
                PropertyType.PropertyValueParser.BOOLEAN_VALUE_PARSER,
                BOOLEAN_VALUES,
            ),
            defaultValue = false,
        )
    }
}
```

Use `propertyMapper`, `propertyWriter`, code-style-specific defaults, or deprecation messages only when the option requires them. Set an explicit property `name` when multiple properties share one `PropertyType`.

## Rule enablement

| Rule kind       | Declaration                          | Default                   | Enablement                                                      |
|-----------------|--------------------------------------|---------------------------|-----------------------------------------------------------------|
| Normal          | No marker                            | Enabled with its rule set | Disable or enable by rule-set or rule property                  |
| Experimental    | `Rule.Experimental`                  | Disabled                  | `ktlint_experimental = enabled` or the individual rule property |
| Explicit opt-in | `Rule.OnlyWhenEnabledInEditorconfig` | Disabled                  | Individual rule property only                                   |

`Rule.Experimental` is a runtime marker, not a Kotlin opt-in annotation. Do not combine `Rule.OnlyWhenEnabledInEditorconfig` with `Rule.Experimental` or `Rule.OfficialCodeStyle`.

```kotlin
import com.pinterest.ktlint.rule.engine.core.api.Rule
import com.pinterest.ktlint.rule.engine.core.api.RuleAutocorrectApproveHandler
import com.pinterest.ktlint.rule.engine.core.api.RuleId

internal class PreviewRule(
    ruleId: RuleId,
    about: Rule.About,
) : Rule(ruleId, about),
    RuleAutocorrectApproveHandler,
    Rule.Experimental

internal class ExplicitRule(
    ruleId: RuleId,
    about: Rule.About,
) : Rule(ruleId, about),
    RuleAutocorrectApproveHandler,
    Rule.OnlyWhenEnabledInEditorconfig
```

For contributions to KtLint itself, new rules start as `Rule.Experimental`. For a custom rule set, choose the marker from the rollout and compatibility policy of that rule set.

## EditorConfig examples

Keep the glob exactly as shown; a space inside `{kt,kts}` is mishandled by the parser version documented by KtLint 1.8.0.

```editorconfig
[*.{kt,kts}]
ktlint_experimental = enabled
ktlint_example = enabled
ktlint_example_preview = enabled
ktlint_example_explicit = enabled
ktlint_example_ignore_annotated = true
```

- Rule-set property: `ktlint_<rule-set-id>`.
- Rule property: `ktlint_<rule-set-id>_<rule-id>`.
- An individual rule property takes precedence over its rule-set property.
- Enabling one experimental rule directly does not require the global experimental switch.
- Enabling a rule set does not enable a `Rule.OnlyWhenEnabledInEditorconfig` rule.

## Review checklist

- [ ] Property names are namespaced and documented with accepted values and defaults.
- [ ] Property parsing is typed and invalid values fall back predictably.
- [ ] Every property read appears in `usesEditorConfigProperties`.
- [ ] Per-file fields start from the property's default and are refreshed in `beforeFirstNode`.
- [ ] Marker interfaces match the intended rollout policy.
- [ ] Tests cover default, enabled, disabled, and invalid-value behavior where applicable.
- [ ] Tests do not mistake helper-driven experimental enablement for the production default.

## References

- [KtLint configuration](https://ktlint.github.io/ktlint/1.8.0/rules/configuration-ktlint/)
- [Experimental rules](https://ktlint.github.io/ktlint/1.8.0/rules/experimental/)
- [Contributing guidelines](https://ktlint.github.io/ktlint/1.8.0/contributing/guidelines/#making-changes)
- [`Rule`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/Rule.kt)
- [`EditorConfigProperty`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/editorconfig/EditorConfigProperty.kt)
- [Rule-execution EditorConfig properties](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/editorconfig/RuleExecutionEditorConfigProperty.kt)
- [Rule-execution filter](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine/src/main/kotlin/com/pinterest/ktlint/rule/engine/internal/rulefilter/RuleExecutionRuleFilter.kt)
- [Configurable rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/BlankLineBetweenWhenConditions.kt)
- [Experimental rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/ExpressionOperandWrappingRule.kt)
- [Explicit opt-in rule example](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/main/kotlin/com/pinterest/ktlint/ruleset/standard/rules/NoUnusedImportsRule.kt)
