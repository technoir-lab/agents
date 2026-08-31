# Conventions

## Applicability

Apply this page only in repositories owned by the `technoir-lab` GitHub organisation. Use the other pages for the KtLint mechanics.

## Destination

| Rule scope | Destination | Provider |
|---|---|---|
| Common to Technoir Lab projects | `convention-plugins/libraries/ktlint-rules` | `TechnoirLabRuleSetProvider` |
| Specific to one project | That project's existing `ktlint-rules` library | That library's existing `RuleSetProviderV3` |
| New project-local rule set, when explicitly requested | A library named `ktlint-rules` | A new provider in that library |

- Convention plugins ship and automatically apply the common rules for all Technoir Lab projects.
- Keep common rules in `convention-plugins/libraries/ktlint-rules` and provide them through `TechnoirLabRuleSetProvider`.
- A Technoir Lab project may or may not contain a local KtLint rules library.
- When a local rules library exists, its conventional name is `ktlint-rules`.
- Do not create a project-local library merely because none exists; create one only when the request includes a new local rule set.

## New project-local library

- Add the `ktlint-rules` module to `settings.gradle.kts` using the repository's project layout.
- Create `ktlint-rules/build.gradle.kts`, or the equivalent path for that layout:

```kotlin
plugins {
    id("io.technoirlab.conventions.jvm-library")
}

jvmLibrary {
    buildFeatures {
        abiValidation = true
    }
}

dependencies {
    implementation(libs.ktlint.cli.ruleset.core)
    implementation(libs.ktlint.rule.engine.core)

    testImplementation(libs.assertj.core)
    testImplementation(libs.ktlint.test)
}
```

- Use the repository's version-catalog aliases; keep KtLint dependencies on `1.8.0`.
- Add the rule sources, provider, ServiceLoader descriptor, and tests described on the other pages.

## Placement checklist

- [ ] Decide whether the rule is organisation-wide or project-local.
- [ ] For an explicitly requested new local rule set, register and configure the `ktlint-rules` Gradle module.
- [ ] Use the existing provider when adding a rule to an existing rule set.
- [ ] Keep the rule, provider update, service descriptor, and tests in the selected `ktlint-rules` library.

## References

- [Convention Plugins settings](https://github.com/technoir-lab/convention-plugins/blob/main/settings.gradle.kts)
- [Common KtLint convention](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/KtLint.kt)
- [`ktlint-rules` library](https://github.com/technoir-lab/convention-plugins/tree/main/libraries/ktlint-rules)
- [`ktlint-rules` Gradle module](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/ktlint-rules/build.gradle.kts)
- [`TechnoirLabRuleSetProvider`](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/ktlint-rules/src/main/kotlin/io/technoirlab/ktlint/rules/TechnoirLabRuleSetProvider.kt)
