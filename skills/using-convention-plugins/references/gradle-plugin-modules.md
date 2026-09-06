# Gradle Plugin Modules

- Select reusable implementation and test helpers from the [Gradle plugin tech stack](tech-stack.md#gradle-plugin-development).

## [Gradle] Public API and compatibility

- Apply these rules to modules using `io.technoirlab.conventions.gradle-plugin`.
- Set `gradlePluginConfig.packageName` explicitly for the plugin's package.
- Set `gradlePluginConfig.minGradleVersion` to the minimum Gradle version actually supported; the default is `9.1`, and supported values start at `9.0`.
- Let the convention derive Kotlin API/core-library compatibility from that value; do not independently pin a newer Kotlin runtime than the supported Gradle supplies.
- Put the plugin's public DSL and API types in `src/api/kotlin`; put implementation in `src/main/kotlin`.
- Declare API-source-set dependencies in `apiApi`, `apiImplementation`, or `apiCompileOnly`, according to their use.
- To depend only on another convention-built plugin's API, import `io.technoirlab.conventions.gradle.plugin.apiOf` and use `implementation(apiOf(project(":plugin-module")))` or `implementation(apiOf(libs.plugin.module))`.
- Reuse the provided Gradle API and compile-only Gradle Kotlin DSL dependencies.
- Declare plugin IDs and implementation classes in the standard `gradlePlugin.plugins` DSL; follow the shared [publication metadata rules](publishing.md#project-metadata).
- Follow the shared [ABI baseline rules](build-features.md#abi-baselines).

## [Gradle] Functional tests

- Put TestKit integration tests in `src/functionalTest/kotlin`; the convention supplies `functionalTest`, Gradle TestKit, the project dependency, and JUnit.
- Run `./gradlew :module:functionalTest` for integration checks; `check` already includes this suite.
- Reuse the suite's plugin test-source-set wiring and access to main compilation internals.
- Read `gradle.test.kit.plugin.ids`, `gradle.test.kit.plugin.version`, and `gradle.test.kit.min.gradle.version` system properties when fixtures need the plugin coordinates or compatibility floor.
- For fixture-only project plugins that must be published locally, add the project dependency to `functionalTestPublishOnly`.
- Follow the [Maven Local publication guidance](publishing.md#maven-local-publication), including version isolation when concurrent builds can publish to the same coordinates.
- Use the existing `validatePlugins` task; stricter plugin validation is already enabled.

## References

- [Gradle plugin convention implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPlugin.kt)
- [Gradle plugin extension DSL](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/api/kotlin/io/technoirlab/conventions/gradle/plugin/api/GradlePluginExtension.kt)
- [Gradle API variant and functional test configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/Plugin.kt)
- [Gradle and Kotlin compatibility mapping](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/internal/GradleCompatibility.kt)
- [Gradle plugin API dependency helper](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginDslExtensions.kt)
- [TestKit system property names](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/GradleTestKitProperties.kt)
