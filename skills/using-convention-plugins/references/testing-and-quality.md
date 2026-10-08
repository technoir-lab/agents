# Testing and Quality

- Select test libraries from the [tech stack](tech-stack.md#testing).

## Kotlin compiler diagnostics

- Reuse the convention's compiler configuration in JVM, KMP, Android, and Gradle plugin modules; the conventions supply Kotlin `2.4.21`, with Gradle plugin language/API levels governed by the [compatibility rules](gradle-plugin-modules.md#gradle-kotlin-compatibility).
- Extra compiler warnings are enabled with `extraWarnings = true`.
- The return value checker uses `-Xreturn-value-checker=check`; review warnings for ignored results from marked APIs, including Kotlin standard-library functions. Consumers of compiled libraries do not have to enable the checker.
- Keep the supplied consistent data-class copy visibility and disabled `NOTHING_TO_INLINE` warning; do not duplicate these compiler flags in module scripts.

## [JVM] Regular JVM and Gradle plugin tests

- In JVM application/library and Gradle plugin modules, reuse the convention-provided JUnit Jupiter dependency and suite setup; do not add a duplicate JUnit version or engine configuration.

## [KMP] Tests on all targets

- Put portable tests in `commonTest` and add `implementation(kotlin("test"))` there.

## [Android] Local unit tests

- Reuse the supplied JUnit Jupiter dependency, JUnit Platform launcher, and unit-test task configuration; do not add duplicate framework versions.
- Use the supplied [Kover tasks](#jvm-coverage) for local unit-test coverage.
- Configure instrumented tests separately when required; the Android conventions do not configure their execution.

## [JVM] Shared test fixtures

- In JVM application/library and Gradle plugin modules, put reusable test support in the provided `src/testFixtures/kotlin` source set.
- Consume another module's fixtures through `testFixtures(project(":module"))` when sharing test helpers.
- Reuse the Kotlin, kotlinx.coroutines, and kotlinx.serialization BOMs now supplied to `testFixturesImplementation`; declare the libraries the fixtures use without duplicating managed versions.
- Add the fixture framework dependencies the fixtures themselves need; the convention applies `java-test-fixtures` but configures JUnit for test suites only.
- JVM fixture variants are excluded from publication; Android fixtures have separate [opt-in and publication behavior](android.md#android-build-features).
- For Gradle plugin integration tests, use the [provided functional test suite](gradle-plugin-modules.md#gradle-functional-tests).

## Existing checks

| When | Use | Convention behavior |
|---|---|---|
| Validate module changes | `./gradlew :module:check` | Runs configured checks, including unit tests, enabled ABI validation, and Kover HTML reporting; excludes [Gradle plugin functional tests](gradle-plugin-modules.md#gradle-functional-tests) |
| Check or correct Kotlin formatting | `:module:ktlintCheck` / `:module:ktlintFormat` | Uses the pinned KtLint version and Technoir Lab ruleset; excludes generated build-directory files |
| Normalize dependency ordering | `:module:sortDependencies` | Uses the already applied dependency-sorting plugin |
| Inspect JVM test coverage | [Kover tasks](#jvm-coverage) | Uses the supplied instrumentation and report filters |

- Extend the supplied lint and coverage configuration only for project-specific requirements.
- For API documentation generation, read [documentation guidance](publishing.md#documentation).

## Dependency analysis

- Run `./gradlew :module:projectHealth` to review a module's dependency declarations with the settings convention.
- Reuse the provided dependency analysis configuration and bundles; extend them only for project-specific requirements.
- Dependency analysis can report false positives; verify findings against actual dependency usage and the [dependency declaration and exposure rules](dependencies-and-serialization.md#dependency-declarations-and-exposure) before applying changes.
- Ignore advice to change `implementation` to `api`; retain the `implementation` declaration. Apply the linked direct-dependency rule to consumers that reference the dependency's types or symbols.

## [JVM] Coverage

| When | Command | Result |
|---|---|---|
| Get a quick coverage summary | `./gradlew :module:koverLog` | Prints coverage to the console |
| Inspect uncovered code visually | `./gradlew :module:koverHtmlReport` | Generates an HTML report; conventions also attach this task to `check` |
| Analyze uncovered lines or feed coverage tools | `./gradlew :module:koverXmlReport` | Generates a JaCoCo-compatible XML report |
| Enforce the project's configured coverage bounds | `./gradlew :module:koverVerify` | Checks existing verification rules; conventions do not define coverage thresholds |

- Use full task paths to scope execution; these tasks schedule the tests needed to collect coverage.
- Reuse existing reports when the relevant code and tests have not changed.
- Kover measures JVM test execution, including KMP common code exercised by JVM tests; it does not measure non-JVM test coverage.
- Conventions disable instrumentation for `functionalTest` and exclude declarations annotated with `javax.annotation.processing.Generated` from reports.
- When aggregate coverage is requested or required by an existing repository workflow, add `kover(project(":module"))` dependencies at the root for the selected modules; applying the root convention alone does not select child projects for aggregation.
- For root coverage reports and verification, replace `:module:` with `:` in the commands above; coverage includes the selected module dependencies.

## References

- [Root plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/root-conventions/src/main/kotlin/io/technoirlab/conventions/root/RootConventionPlugin.kt)
- [Root coverage aggregation examples](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/root-conventions/src/functionalTest/kotlin/io/technoirlab/conventions/root/RootConventionPluginFunctionalTest.kt)
- [Kover: Report tasks, verification, and project coverage](https://kotlin.github.io/kotlinx-kover/gradle-plugin/)
- [JUnit 6 user guide: Overview](https://docs.junit.org/6.1.3/overview.html)
- [Convention dependency versions](https://github.com/technoir-lab/convention-plugins/blob/main/gradle/libs.versions.toml)
- [JUnit suite configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/TestSuites.kt)
- [Test fixtures configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/TestFixtures.kt)
- [JVM application plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/jvm-conventions/src/main/kotlin/io/technoirlab/conventions/jvm/JvmApplicationConventionPlugin.kt)
- [JVM library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/jvm-conventions/src/main/kotlin/io/technoirlab/conventions/jvm/JvmLibraryConventionPlugin.kt)
- [Gradle plugin convention implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPlugin.kt)
- [KMP application plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformApplicationConventionPlugin.kt)
- [KMP library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformLibraryConventionPlugin.kt)
- [KMP test dependency example](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/functionalTest/resources/kotlin-multiplatform-project/kmp-library/build.gradle.kts)
- [Kover coverage configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Coverage.kt)
- [KtLint configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/KtLint.kt)
- [Common plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/CommonConventionPlugin.kt)
- [Settings plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/SettingsConventionPlugin.kt)
- [Dependency analysis configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/configuration/DependencyAnalysis.kt)
- [Shared compiler options](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/README.md#kotlin-compiler-options)
- [Kotlin compiler options and fixture BOM wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Kotlin.kt)
- [KMP compiler configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/KotlinMultiplatform.kt)
- [Kotlin: Extra compiler warnings](https://kotlinlang.org/docs/whatsnew22.html#support-for-enabling-extra-checkers)
- [Kotlin: Unused return value checker](https://kotlinlang.org/docs/unused-return-value-checker.html)
- [Android local unit-test dependencies](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/configuration/Testing.kt)
- [Android unit-test task configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/configuration/Android.kt)
- [Android convention behavior and limitations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/README.md)
