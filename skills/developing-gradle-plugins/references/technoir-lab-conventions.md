# Technoir Lab Conventions

## Applicability

Apply these deltas to Gradle plugin work in any repository owned by the `technoir-lab` GitHub organisation. Read the general pages first, then identify the repository layout.

## Repository placement

- Use `<name>-gradle-plugin` as the module name for a standalone domain plugin.
- Use the target repository's wrapper, version catalog, settings conventions, and existing module layout.
- Keep external plugin and library coordinates in `gradle/libs.versions.toml`.
- Apply `io.technoirlab.conventions.gradle-plugin` in every Gradle plugin module.
- Set `gradlePluginConfig.packageName` explicitly to the implementation package in every module.
- Set `gradlePluginConfig.metadata.description` for the plugin module when the repository-wide description is not specific enough.
- Set `gradlePluginConfig.minGradleVersion` only when the support floor differs from its `9.1` default.
- Include a new module in `settings.gradle.kts`, the root `dokka` and `nmcpAggregation` dependencies, and the root README index.

## Names and public surface

| Surface                       | Technoir Lab contract                                                            |
|-------------------------------|----------------------------------------------------------------------------------|
| Plugin ID                     | `io.technoirlab.<name>`                                                          |
| Implementation package        | `io.technoirlab.<domain>`                                                        |
| Public DSL and value types    | `src/api/kotlin/<implementation-package>/api`                                    |
| Plugin and configuration code | `src/main/kotlin/<implementation-package>`                                       |
| Task types                    | `src/main/kotlin/<implementation-package>/tasks`                                 |
| Implementation-only types     | `internal` in `src/main`, normally under `.internal` or another focused package  |
| ABI dump                      | `api/<module>.api`                                                               |

- Keep each marker implementation class public and ABI-tracked.
- Give each top-level extension interface a `companion object` `NAME`; use that constant when creating the extension.
- `gradlePluginConfig.buildFeatures.abiValidation` is enabled by default.
- Treat dumps from both `main` and `api` as the supported ABI. Update a checked-in dump only for an intentional API change.

## API feature dependencies

The Gradle plugin convention publishes `src/api` as a separate feature with capability `${group}:${module}-api`. Import and use `apiOf(...)` selector instead of spelling out that capability:

```kotlin
import io.technoirlab.conventions.gradle.plugin.apiOf

dependencies {
    apiApi(apiOf(project(":other-gradle-plugin")))
    implementation(project(":other-gradle-plugin"))
}
```

- Add `apiOf(...)` to `apiApi` when declarations in `src/api` use another Gradle plugin module's public API.
- Add the ordinary dependency separately when the module also uses or distributes the plugin dependency's implementation.
- Use `implementation(apiOf(...))` when only `src/main` consumes the plugin dependency's API and its implementation is supplied independently.

## Functional tests

- Use AssertJ for assertions instead of vanilla JUnit assertions.
- Do not use mocking libraries.
- Put a complete single-project or multi-project fixture in `src/functionalTest/resources/<fixture-name>`.
- Register `GradleRunnerExtension(<fixture-name>)` with `@RegisterExtension`; mutate the copied fixture through `GradleProject` helpers.
- Functional-test Kotlin can access `internal` declarations from `main`; the module convention wires the main compilation as a friend path.
- Use the harness defaults: Configuration Cache, configure-on-demand, Isolated Projects, `--stacktrace`, and no build cache. Disable a feature only for a test that cannot support it.
- Use the module convention's `publishToMavenLocal` and test-property wiring, but still satisfy the [functional-test publication contract](testing.md#functional-test-publication-contract) with a unique test publication GAV. The convention forwards `project.version`; ordinary `dev` or release coordinates are not unique.
- Use `functionalTestPublishOnly` for a project artifact needed by fixture builds but not by the functional-test classpath.
- Let the generated init script supply subject plugin marker versions, repositories, and `NO_IMPLICIT_LOOKUP_IN_PARENT_PROJECTS` when supported.
- By default, the harness runs `gradlePluginConfig.minGradleVersion`. Set `GradleConfig.gradleVersion` for compatibility-matrix cases; the harness rejects lower versions.

## Coordinates and publication

- Set the repository publication group through `project.groupId` in `gradle.properties`.
- The root project appends `.root` to its configured group to keep coordinates unique.
- Version resolution is `project.version`, then the GitHub tag, then `dev`. A leading `v` is stripped only from dotted version tags such as `v1.2.3`.
- Set shared project ID, developer, licence, and other repository metadata in `globalSettings`; keep module descriptions next to each plugin declaration.
- Publish each plugin module through root `nmcpAggregation`.

## Convention plugins

Apply these additional rules to organisation build conventions:

- Develop them under `convention-plugins/conventions/<module>` with project path `:conventions:<module>`.
- Use `<name>-conventions` as the module name.
- Use plugin IDs under `io.technoirlab.conventions.<name>`.
- Use implementation packages under `io.technoirlab.conventions.<domain>`.
- Distribute plugins that the convention applies, using `implementation` when it needs implementation types and `runtimeOnly` when it applies only by ID.
- Use publication group `io.technoirlab.conventions` through the repository's `project.groupId` property.

### References

- [Convention repository module index](https://github.com/technoir-lab/convention-plugins/blob/main/README.md)
- [Convention repository settings and module registration](https://github.com/technoir-lab/convention-plugins/blob/main/settings.gradle.kts)
- [Convention repository root aggregation](https://github.com/technoir-lab/convention-plugins/blob/main/build.gradle.kts)
- [Gradle plugin module build](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/build.gradle.kts)
- [Gradle plugin module usage](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/README.md)
- [Gradle plugin project convention](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPlugin.kt)
- [`api` feature and functional-test wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/Plugin.kt)
- [`apiOf(...)` feature selector](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginDslExtensions.kt)
- [Gradle plugin extension API](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/api/kotlin/io/technoirlab/conventions/gradle/plugin/api/GradlePluginExtension.kt)
- [Gradle plugin extension defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/internal/GradlePluginExtensionImpl.kt)
- [Project coordinate defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/ProjectSettingsImpl.kt)
- [Project group and version assignment](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Common.kt)
- [Shared TestKit runner extension](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/gradle-test-kit/src/main/kotlin/io/technoirlab/gradle/test/kit/GradleRunnerExtension.kt)
- [Shared TestKit configuration](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/gradle-test-kit/src/main/kotlin/io/technoirlab/gradle/test/kit/GradleConfig.kt)
- [Shared TestKit project helpers](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/gradle-test-kit/src/main/kotlin/io/technoirlab/gradle/test/kit/GradleProject.kt)
- [TestKit init-script generator](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/gradle-test-kit/src/main/kotlin/io/technoirlab/gradle/test/kit/InitScriptGenerator.kt)
- [TestKit init-script template](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/gradle-test-kit/src/main/resources/gradle-test-kit.init.gradle.kts)

## References

### Standalone domain plugin examples

- [KMP Gradle plugins repository settings and module registration](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/settings.gradle.kts)
- [KMP Gradle plugins repository root aggregation](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/build.gradle.kts)
- [KMP Gradle plugins repository version catalog](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/gradle/libs.versions.toml)
- [CMake import module build](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/cmake-import-gradle-plugin/build.gradle.kts)
- [CMake import plugin API](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/cmake-import-gradle-plugin/src/api/kotlin/io/technoirlab/cmake/import/api/CMakeImportExtension.kt)
- [CMake import plugin implementation](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/cmake-import-gradle-plugin/src/main/kotlin/io/technoirlab/cmake/import/CMakeImportPlugin.kt)
- [CMake public task API](https://github.com/technoir-lab/kmp-gradle-plugins/blob/main/cmake-import-gradle-plugin/src/main/kotlin/io/technoirlab/cmake/import/tasks/CMakeBuildTask.kt)
