# Plugin Structure

## Plugin targets

| Type | Contract | Apply from | Owns |
|---|---|---|---|
| Project plugin | `Plugin<Project>` | Project `plugins {}` | One project's extensions, tasks, configurations, dependencies |
| Settings plugin | `Plugin<Settings>` | Settings `plugins {}` | Build structure, settings DSL, plugin/dependency resolution, project lifecycle defaults |
| Init plugin | `Plugin<Gradle>` in `*.init.gradle.kts` | Init script or init-script plugin application | One Gradle invocation before settings and projects |

- Name the `apply` parameter after its concrete target: `project` for `Project`, `settings` for `Settings`, and `gradle` for `Gradle`.
- Keep init plugins environment-local. Do not make a published project plugin depend on an init plugin being present.

## Standalone project

Use one independent plugin build and the standard layout:

```text
build.gradle.kts
settings.gradle.kts
src/main/kotlin/com/example/plugin/ExamplePlugin.kt
src/main/kotlin/com/example/plugin/api/...
src/test/kotlin/...
src/functionalTest/kotlin/...
```

Apply Kotlin JVM support, `java-gradle-plugin`, and `maven-publish`. Let `java-gradle-plugin` supply Gradle API, TestKit, validation, descriptors, and marker publications.

## Marker registration

```kotlin
gradlePlugin {
    plugins {
        register("exampleProject") {
            id = "com.example.plugin"
            implementationClass = "com.example.plugin.ExamplePlugin"
        }
        register("exampleSettings") {
            id = "com.example.plugin.settings"
            implementationClass = "com.example.plugin.ExampleSettingsPlugin"
        }
    }
}
```

Register every published plugin ID. Keep the ID, implementation class, display name, and description stable.

## Plugin dependencies

- Apply plugins using the [Kotlin DSL API rules](configuration-and-wiring.md#kotlin-dsl-apis).

| Relationship | Dependency | Application |
|---|---|---|
| Distributed plugin with implementation types in use | `implementation` | Apply by class or ID |
| Distributed plugin without implementation types in use | `runtimeOnly` | Apply by ID |
| Consumer-supplied required plugin | `compileOnly` its public or compile artifact | React with `pluginManager.withPlugin(id)`; fail after evaluation when absent |
| Consumer-supplied optional plugin | `compileOnly` its public or compile artifact | React with `pluginManager.withPlugin(id)` |

```kotlin
import org.gradle.kotlin.dsl.configure

internal class ExamplePlugin : Plugin<Project> {
    override fun apply(project: Project) {
        project.whenPluginApplied("com.example.required") {
            project.configureRequiredPlugin()
        }

        project.pluginManager.withPlugin("com.example.optional") {
            project.configureOptionalPlugin()
        }
    }

    private fun Project.configureRequiredPlugin() {
        extensions.configure<RequiredPluginExtension> {
            something.convention(true)
        }
    }

    private fun Project.configureOptionalPlugin() {
        extensions.configure<OptionalPluginExtension> {
            something.convention("value")
        }
    }
}

private fun Project.whenPluginApplied(id: String, action: () -> Unit) {
    var pluginApplied = false
    pluginManager.withPlugin(id) {
        pluginApplied = true
        action()
    }
    afterEvaluate {
        check(pluginApplied) { "Plugin '$id' is not applied" }
    }
}
```

- Prefer `com.android.tools.build:gradle-api` for Android Gradle Plugin API types.
- Prefer `org.jetbrains.kotlin:kotlin-gradle-plugin-api` for Kotlin Gradle Plugin API types.
- Do not apply a consumer-supplied plugin from the production plugin; require the consuming build to supply and apply the matching implementation.
- Keep types from `compileOnly` plugin dependencies out of the plugin's public API.
- Never depend on `.internal.`, `Internal`, or `Impl` types.

## Common mistakes

| Mistake | Correction |
|---|---|
| Assuming plugin application order | Use `withPlugin`; configure inside its callback |
| Silently ignoring a missing required plugin | Fail during final validation |
| Bundling a consumer-supplied plugin implementation | Use `compileOnly` for its public or compile artifact |
| Implementing a published plugin in a build script | Move it to the standalone plugin source set |
| Omitting marker registration | Register the plugin under `gradlePlugin.plugins` |

## References

- [Plugin introduction](https://docs.gradle.org/current/userguide/plugin_introduction_advanced.html)
- [Binary plugins](https://docs.gradle.org/current/userguide/implementing_gradle_plugins_binary.html)
- [Gradle Plugin Development Plugin](https://docs.gradle.org/current/userguide/java_gradle_plugin.html)
- [Initialization scripts and init plugins](https://docs.gradle.org/current/userguide/init_scripts.html)
- [General best practices](https://docs.gradle.org/current/userguide/best_practices_general.html)
- [Dependency configurations](https://docs.gradle.org/current/userguide/dependency_configurations.html)

## Documentation for common plugin dependencies

- [Android Gradle Plugin public APIs](https://developer.android.com/build/extend-agp)
- [Kotlin Gradle Plugin API](https://kotlinlang.org/api/kotlin-gradle-plugin/kotlin-gradle-plugin-api/)
- [Kotlin plugin configuration callbacks](https://kotlinlang.org/docs/gradle-configure-project.html#triggering-configuration-actions-with-the-kotlinbaseplugin-interface)
