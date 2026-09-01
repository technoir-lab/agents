# Rule Sets

## Add a rule to an existing provider

Add one `RuleProvider` factory. Leave the service descriptor unchanged when the provider class is unchanged.

```kotlin
import com.pinterest.ktlint.cli.ruleset.core.api.RuleSetProviderV3
import com.pinterest.ktlint.rule.engine.core.api.Rule
import com.pinterest.ktlint.rule.engine.core.api.RuleProvider
import com.pinterest.ktlint.rule.engine.core.api.RuleSetId

class ExampleRuleSetProvider : RuleSetProviderV3(RuleSetId(ID)) {
    override fun getRuleProviders(): Set<RuleProvider> = setOf(
        RuleProvider { ExampleRule() },
        RuleProvider { AnotherRule() },
    )

    internal companion object {
        internal const val ID = "example"
        internal val ABOUT = Rule.About(
            maintainer = "Example maintainers",
            repositoryUrl = "https://example.com/example-rules",
            issueTrackerUrl = "https://example.com/example-rules/issues",
        )
    }
}
```

Define one `Rule.About` in the provider companion and reference it from every rule in that rule set.

`RuleProvider` calls the factory once while constructing the provider to inspect rule metadata, then again for execution instances. Keep the factory deterministic and side-effect-free, and always return a fresh rule.

## Create a rule set

- [ ] Choose a unique ID matching `[a-z]+(-[a-z]+)*`; never use the reserved `standard` ID.
- [ ] Create a public `RuleSetProviderV3` with a public zero-argument constructor.
- [ ] Return one `RuleProvider { NewRule() }` per rule.
- [ ] Give each rule a qualified ID whose prefix matches the provider ID.
- [ ] Register the provider through the Java ServiceLoader descriptor.
- [ ] Add rule tests, provider completeness tests, and service-discovery tests.

## ServiceLoader registration

Create exactly this resource path:

```text
src/main/resources/META-INF/services/com.pinterest.ktlint.cli.ruleset.core.api.RuleSetProviderV3
```

Put the fully qualified provider class name on its own line:

```text
com.example.ktlint.rules.ExampleRuleSetProvider
```

Multiple rule sets can be loaded together. Use one descriptor line per provider when a library exposes more than one.

## Review checklist

- [ ] The provider ID and every rule ID use the same rule-set prefix.
- [ ] All factories create new instances; none capture a singleton or mutable shared state.
- [ ] Every rule is included exactly once.
- [ ] The service descriptor spelling and package match the provider class.
- [ ] The provider is public and constructible by ServiceLoader.
- [ ] Tests distinguish provider completeness from service discovery.

## References

- [Custom rule set](https://ktlint.github.io/ktlint/1.8.0/api/custom-rule-set/)
- [`RuleSetProviderV3`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-cli-ruleset-core/src/main/kotlin/com/pinterest/ktlint/cli/ruleset/core/api/RuleSetProviderV3.kt)
- [`RuleProvider`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-rule-engine-core/src/main/kotlin/com/pinterest/ktlint/rule/engine/core/api/RuleProvider.kt)
- [Template rule-set provider](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/main/kotlin/yourpkgname/CustomRuleSetProvider.kt)
- [Template ServiceLoader descriptor](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/main/resources/META-INF/services/com.pinterest.ktlint.cli.ruleset.core.api.RuleSetProviderV3)
- [`RuleSetProviderTest`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-test/src/main/kotlin/com/pinterest/ktlint/test/RuleSetProviderTest.kt)
