# Gradle Plugin Modules

- Select reusable implementation and test helpers from the [Gradle plugin tech stack](tech-stack.md#gradle-plugin-development).

## [Gradle] Public API and compatibility

- Apply these rules to modules using `io.technoirlab.conventions.gradle-plugin`.
- Set `gradlePluginConfig.packageName` explicitly for the plugin's package.
- Set `gradlePluginConfig.minGradleVersion` to the minimum Gradle version actually supported; the default is `9.6`, and supported values start at `9.0`.
- Let the convention derive Kotlin compatibility from that minimum, even when building on a newer Gradle version; follow the [Kotlin compatibility rules](#gradle-kotlin-compatibility).
- Put the plugin's public DSL and API types in `src/api/kotlin`; put implementation in `src/main/kotlin`.
- Declare API-source-set dependencies in `apiApi`, `apiImplementation`, or `apiCompileOnly`, according to their use.
- To depend only on another convention-built plugin's API, import `io.technoirlab.conventions.gradle.plugin.apiOf` and use `implementation(apiOf(project(":plugin-module")))` or `implementation(apiOf(libs.plugin.module))`.
- Reuse the provided Gradle API and compile-only Gradle Kotlin DSL dependencies.
- Declare plugin IDs and implementation classes in the standard `gradlePlugin.plugins` DSL; follow the shared [publication metadata rules](publishing.md#project-metadata).
- Follow the shared [ABI baseline rules](build-features.md#abi-baselines).

## [Gradle] Kotlin compatibility

- Use the convention-derived compiler limits for the minimum supported Gradle version:

| Source sets | Kotlin API level | Kotlin language level |
|---|---|---|
| Public `api` | Lower of Gradle's build-script API level and the compiler default | Lower of Gradle's build-script language level and the compiler default |
| Implementation and tests | Lower of Gradle's embedded runtime API level and the compiler default | Lower of the next language version after the embedded runtime's version and the compiler default |

- For example, with a compiler default of Kotlin 2.4, an embedded runtime on Kotlin 2.3 allows API level 2.3 and language level 2.4; an embedded runtime on Kotlin 2.4 keeps both levels at 2.4.
- Keep Kotlin core libraries aligned with the minimum Gradle version's embedded runtime; do not independently pin a newer Kotlin runtime.
- Keep the API level within that runtime's capabilities even when newer standard-library APIs appear on the compile classpath.
- Treat support for newer Kotlin language features or metadata separately from standard-library API availability.

## [Gradle] Functional tests

- Put TestKit integration tests in `src/functionalTest/kotlin`; the convention supplies `functionalTest`, Gradle TestKit, the project dependency, and JUnit.
- Run `./gradlew :module:functionalTest` for integration checks; `build` includes this suite, `check` does not.
- Reuse the suite's plugin test-source-set wiring and access to main compilation internals.
- Read `gradle.test.kit.plugin.ids`, `gradle.test.kit.plugin.version`, and `gradle.test.kit.min.gradle.version` system properties when fixtures need the plugin coordinates or compatibility floor.
- For fixture-only project plugins that must be published locally, add the project dependency to `functionalTestPublishOnly`.
- Follow the [Maven Local publication guidance](publishing.md#maven-local-publication), including version isolation when concurrent builds can publish to the same coordinates.
- Use the existing `validatePlugins` task; stricter plugin validation is already enabled.

## References

- [Kotlin: Choosing compatible language and API versions](https://kotlinlang.org/docs/api-guidelines-backward-compatibility.html#choose-compatible-language-and-api-versions)
- [Gradle: Embedded Kotlin and build-script language versions](https://docs.gradle.org/current/userguide/compatibility.html#kotlin)
- [Gradle plugin convention implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPlugin.kt)
- [Gradle plugin extension DSL](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/api/kotlin/io/technoirlab/conventions/gradle/plugin/api/GradlePluginExtension.kt)
- [Gradle plugin extension defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/internal/GradlePluginExtensionImpl.kt)
- [Gradle API variant and functional test configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/Plugin.kt)
- [Gradle and Kotlin compatibility mapping](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/internal/GradleCompatibility.kt)
- [Gradle plugin API dependency helper](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginDslExtensions.kt)
- [TestKit system property names](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/GradleTestKitProperties.kt)
