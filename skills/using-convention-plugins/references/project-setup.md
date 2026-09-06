# Project Setup

## Initial setup

1. Check the latest stable Gradle release and configure the wrapper to use that exact version. Run subsequent builds through `./gradlew`.
2. Create the root `.gitignore` using the [initial Git ignores](#initial-git-ignores); preserve existing project-specific rules.
3. Create the root `.editorconfig` by adapting the [convention plugins EditorConfig](https://github.com/technoir-lab/convention-plugins/blob/main/.editorconfig) to the project's file types and formatting requirements; preserve existing project-specific settings. KtLint needs this file to apply the project's formatting and rule configuration.
4. Initialize the root `gradle.properties` with the [initial Gradle properties](#initial-gradle-properties), preserving existing values.
5. Configure the settings convention's version and apply it in `settings.gradle.kts` using [plugin loading](#plugin-loading).
6. Set the mandatory `globalSettings.projectId`; initially default to the project's root folder name.
7. Generate `gradle/gradle-daemon-jvm.properties` using the [daemon JVM instructions](#gradle-daemon-jvm) after the settings convention is configured.

## Module setup

- Perform these steps when adding modules.
- Prefer separate subprojects for application, library, and Gradle plugin code, even when only one module is needed; reserve the root project for aggregation. Use a single root module only when explicitly requested or required by an existing project constraint.

1. Create the module directory and build script; add subproject includes using [settings and coordinates](#settings-and-coordinates).
2. Select the required [convention plugins](#plugin-selection) and extend the version declarations and settings classloader loading using [plugin loading](#plugin-loading).
3. Apply the selected project convention plugins in their root/module build scripts and configure the relevant extensions. Follow [plugin selection](#plugin-selection) for the root convention's multi-module restriction and `packageName` requirements.
4. Configure the project's coordinates using [settings and coordinates](#settings-and-coordinates); follow [Maven Central publication](publishing.md#maven-central-publication) when applicable.

## Gradle daemon JVM

- Select a daemon JVM version compatible with the project's Gradle version; preserve existing JVM criteria unless a change is required.
- Run from the project root after applying the settings convention, which supplies the Foojay toolchain resolver needed to generate JVM download URLs. Example for a Java 21 daemon:

```shell
./gradlew updateDaemonJvm --jvm-version=21
```

## Plugin selection

- Always apply `io.technoirlab.conventions.settings` in `settings.gradle.kts`.
- In builds with subprojects, always apply `io.technoirlab.conventions.root` in the root project's `build.gradle.kts`, including builds with only one subproject; apply it only to the root project. Do not apply it when the root project is the sole code module.
- Apply the plugin matching the module's role; use its extension for convention-owned settings.
- Set the extension's `packageName` explicitly when generated code, entry points, or published APIs require a stable package.
- Reuse the Kotlin, KSP, KtLint, and Kover plugins already applied by the module convention; configure the supplied extensions when needed.
- [JVM] Reuse the configured Java 21 toolchain unless the project has an explicit compatibility requirement.

| Scope | When | Plugin ID | Extension |
|---|---|---|---|
| Settings | Configure build-wide defaults | `io.technoirlab.conventions.settings` | `globalSettings` |
| Root project | Aggregate documentation and coverage | `io.technoirlab.conventions.root` | See [documentation](publishing.md#documentation) and [coverage](testing-and-quality.md#jvm-coverage) |
| [JVM] | Build a runnable JVM application | `io.technoirlab.conventions.jvm-application` | `jvmApplication` |
| [JVM] | Build a regular JVM library | `io.technoirlab.conventions.jvm-library` | `jvmLibrary` |
| [KMP] | Build a multiplatform application | `io.technoirlab.conventions.kotlin-multiplatform-application` | `kotlinMultiplatformApplication` |
| [KMP] | Build a multiplatform library | `io.technoirlab.conventions.kotlin-multiplatform-library` | `kotlinMultiplatformLibrary` |
| [Gradle] | Build a Gradle plugin | `io.technoirlab.conventions.gradle-plugin` | `gradlePluginConfig` |

## Plugin loading

- Declare all Gradle plugin versions managed by the project in the `pluginManagement.plugins` block of `settings.gradle.kts`; apply plugins without versions in settings and project `plugins` blocks. Do not declare plugin versions in version catalogs or root/module build scripts; reuse convention-supplied plugin versions without adding duplicate declarations.
- Declare one `conventionPluginsVersion` variable in `pluginManagement.plugins` and use it for every convention plugin version declaration.
- List every public convention plugin used by the build in the top-level `plugins` block of `settings.gradle.kts` so they are loaded once in the settings classloader. Use `apply false` for project convention plugins and apply the settings convention there.

Minimal `settings.gradle.kts` for initial setup before any modules exist; use the root folder name in place of `example`:

```kotlin
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
    plugins {
        val conventionPluginsVersion = "v55"
        id("io.technoirlab.conventions.settings") version conventionPluginsVersion
    }
}

plugins {
    id("io.technoirlab.conventions.settings")
}

dependencyResolutionManagement {
    repositories {
        mavenCentral()
    }
}

globalSettings {
    projectId = "example"
}
```

## Settings and coordinates

- Put project `include(...)` declarations at the bottom of `settings.gradle.kts`, after all other settings configuration; sort them alphabetically by project path across and within calls.
- `globalSettings.projectId` also sets the root project name.
- Keep `project.version` out of `gradle.properties`; use the GitHub tag or the `dev` fallback. A leading `v` is stripped only from dotted version tags such as `v1.2.3`.
- When an invocation requires an explicit version, pass `-Pproject.version=<version>`; follow [Maven Local version isolation](publishing.md#concurrent-publication) for concurrent publication.
- Account for the root project's automatic `.root` group suffix when configuring root artifact coordinates.
- Add dependency repositories and component metadata rules in settings; project-level declarations fail under the settings convention.
- Reuse Maven Central, Google, and Gradle Plugin Portal repositories already provided; Maven Local is added outside GitHub Actions.
- Use fixed dependency versions where versions are required; the settings convention rejects dynamic and changing versions.
- Set `globalSettings.develocityUrl` when build scans should use a Develocity server; scan publishing is enabled only when this property is present.

## Initial Git ignores

- Use this baseline from the Technoir Lab project examples; add missing entries to an existing `.gitignore`.

```gitignore
.gradle/
.idea/
.kotlin/
build/
.DS_Store
local.properties
```

## Initial Gradle properties

- For every project, use these initial defaults in the root `gradle.properties`; add only properties that are missing.
- Preserve existing values when they differ, including JVM heap sizes and garbage collector options in `org.gradle.jvmargs` and `kotlin.daemon.jvmargs`.

```properties
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.configuration-cache.parallel=true
org.gradle.isolated-projects=true
org.gradle.parallel=true
org.gradle.tooling.parallel=true
org.gradle.jvmargs=-Xmx4g -XX:+UseParallelGC
kotlin.daemon.jvmargs=-Xmx1g -XX:+UseParallelGC
```

## [JVM] JVM application execution

- For `jvm-application` modules, set `jvmApplication.mainClass` and `jvmApplication.jvmArgs`.
- Use a fully qualified main class or a relative name such as `.MainKt`, resolved against `packageName`.
- Use the supplied application plugin's run and distribution tasks when running or packaging the application.

## References

- [Convention plugins EditorConfig](https://github.com/technoir-lab/convention-plugins/blob/main/.editorconfig)
- [Convention plugins Git ignore example](https://github.com/technoir-lab/convention-plugins/blob/main/.gitignore)
- [Vulkan Kotlin Git ignore example](https://github.com/technoir-lab/vulkan-kotlin/blob/main/.gitignore)
- [Gradle: Generating daemon JVM criteria](https://docs.gradle.org/current/userguide/gradle_daemon.html#sec:daemon_jvm_criteria)
- [Gradle: Plugin version management](https://docs.gradle.org/current/userguide/plugins_intermediate.html#sec:plugin_version_management)
- [Gradle: Plugin repositories](https://docs.gradle.org/current/userguide/plugins_intermediate.html#sec:plugin_repositories)
- [Gradle: Centralizing repository declarations](https://docs.gradle.org/current/userguide/centralizing_repositories.html)
- [Convention plugins settings example](https://github.com/technoir-lab/convention-plugins/blob/main/settings.gradle.kts)
- [Common plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/CommonConventionPlugin.kt)
- [Common extension DSL](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/api/kotlin/io/technoirlab/conventions/common/api/CommonExtension.kt)
- [Java toolchain configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Java.kt)
- [JVM application plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/jvm-conventions/src/main/kotlin/io/technoirlab/conventions/jvm/JvmApplicationConventionPlugin.kt)
- [JVM library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/jvm-conventions/src/main/kotlin/io/technoirlab/conventions/jvm/JvmLibraryConventionPlugin.kt)
- [KMP application plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformApplicationConventionPlugin.kt)
- [KMP library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformLibraryConventionPlugin.kt)
- [KMP library extension name](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/api/kotlin/io/technoirlab/conventions/kotlin/multiplatform/api/KotlinMultiplatformLibraryExtension.kt)
- [Gradle plugin convention implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPlugin.kt)
- [Settings plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/SettingsConventionPlugin.kt)
- [Root plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/root-conventions/src/main/kotlin/io/technoirlab/conventions/root/RootConventionPlugin.kt)
- [Project group and version properties](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/ProjectSettingsImpl.kt)
- [Project coordinate assignment](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Common.kt)
- [Repository and dependency resolution policy](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/configuration/DependencyResolution.kt)
- [Develocity configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/configuration/Develocity.kt)
- [common plugin ID declarations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/build.gradle.kts)
- [gradle-plugin plugin ID declarations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/build.gradle.kts)
- [jvm plugin ID declarations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/jvm-conventions/build.gradle.kts)
- [kotlin-multiplatform plugin ID declarations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/build.gradle.kts)
- [root plugin ID declarations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/root-conventions/build.gradle.kts)
- [settings plugin ID declarations](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/build.gradle.kts)
