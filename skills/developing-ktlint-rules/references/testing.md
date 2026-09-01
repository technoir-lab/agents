# Testing

## Rule test matrix

| Case | Assertion |
|---|---|
| Compliant code | `hasNoLintViolations()` |
| One correctable finding | `hasLintViolation(...).isFormattedAs(...)` |
| Several correctable findings | `hasLintViolations(...).isFormattedAs(...)` |
| Non-correctable finding | `hasLintViolationWithoutAutoCorrect(...)` |
| Custom option | `withEditorConfigOverride(PROPERTY to typedValue)` |
| Kotlin script | `asKotlinScript()` |
| Path-sensitive rule | `asFileWithPath(...)` |

`hasNoLintViolations()` also formats the code, verifies that it is unchanged, and checks that the result parses.

## Rule tests

```kotlin
import com.pinterest.ktlint.test.KtLintAssertThat.Companion.assertThatRule
import org.junit.jupiter.api.Test

class NoVarRuleTest {
    private val noVarRuleAssertThat = assertThatRule { NoVarRule() }

    @Test
    fun `reports mutable local variable`() {
        val code =
            """
            fun example() {
                var value = 1
            }
            """.trimIndent()

        noVarRuleAssertThat(code)
            .hasLintViolationWithoutAutoCorrect(2, 5, "Unexpected var, use val instead")
    }
}
```

For an auto-correcting rule, assert both the diagnostic and the exact formatted source:

```kotlin
functionNameSpacingRuleAssertThat("fun example () = Unit")
    .hasLintViolation(1, 12, "Unexpected whitespace")
    .isFormattedAs("fun example() = Unit")
```

For configuration, override the typed property on the assertion:

```kotlin
configurableRuleAssertThat(code)
    .withEditorConfigOverride(ConfigurableRule.IGNORE_ANNOTATED_PROPERTY to true)
    .hasNoLintViolations()
```

Test the default value and each meaningful override. `assertThatRule` enables the tested rule set and experimental rules internally, so it verifies an experimental rule's behavior but not its disabled-by-default production behavior.

## Provider completeness

Extend the KtLint test helper to catch rule classes ending in `Rule` that were omitted from the provider:

```kotlin
import com.pinterest.ktlint.test.RuleSetProviderTest

class ExampleRuleSetProviderCompletenessTest :
    RuleSetProviderTest(
        rulesetClass = ExampleRuleSetProvider::class.java,
        packageName = "com.example.ktlint.rules",
    )
```

The helper does not verify the service descriptor, provider ID, duplicate IDs, fresh instances, or opt-in defaults. Add focused tests for those contracts.

## Service discovery

```kotlin
import com.pinterest.ktlint.cli.ruleset.core.api.RuleSetProviderV3
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.util.ServiceLoader

class ExampleRuleSetProviderServiceTest {
    @Test
    fun `provider is discoverable`() {
        val providerIds = ServiceLoader.load(RuleSetProviderV3::class.java)

        assertThat(providerIds)
            .flatExtracting({ it.id.value })
            .contains(ExampleRuleSetProvider.ID)
    }
}
```

## Provider checklist

- [ ] Every rule class in the package is provided.
- [ ] ServiceLoader finds the provider from test runtime resources.
- [ ] The provider ID is the expected custom ID.
- [ ] Rule IDs are unique within and across loaded providers.
- [ ] Each `RuleProvider` call returns a new instance.
- [ ] Experimental and explicit opt-in markers match policy.
- [ ] A dedicated engine-level test covers default enablement when that behavior is part of the contract.

## References

- [API overview](https://ktlint.github.io/ktlint/1.8.0/api/overview/)
- [`KtLintAssertThat`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-test/src/main/kotlin/com/pinterest/ktlint/test/KtLintAssertThat.kt)
- [`RuleSetProviderTest`](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-test/src/main/kotlin/com/pinterest/ktlint/test/RuleSetProviderTest.kt)
- [Template rule test](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-template/src/test/kotlin/yourpkgname/NoVarRuleTest.kt)
- [Explicit opt-in rule test](https://github.com/ktlint/ktlint/blob/1.8.0/ktlint-ruleset-standard/src/test/kotlin/com/pinterest/ktlint/ruleset/standard/rules/NoUnusedImportsRuleTest.kt)
