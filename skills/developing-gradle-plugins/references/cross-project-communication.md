# Cross-Project Communication

## Contents

- [Isolation rules](#isolation-rules)
- [Settings defaults to project extras](#settings-defaults-to-project-extras)
- [Lifecycle selection](#lifecycle-selection)
- [Artifact sharing](#artifact-sharing)
- [Shared build services](#shared-build-services)

## Isolation rules

- Configure only the target supplied to the current plugin or lifecycle callback.
- Never read or mutate another project's tasks, configurations, extensions, extras, layout, providers, group, or version.
- Use settings lifecycle callbacks for build-wide defaults.
- Use variant-aware project dependencies for artifacts.
- Use build services only for execution-time resources shared by tasks.

## Settings defaults to project extras

Create a typed settings extension. Pass its providers into each target project's own extras from `beforeProject`; let the Project plugin adopt them as conventions.

```kotlin
import org.gradle.api.initialization.Settings
import org.gradle.kotlin.dsl.apply
import org.gradle.kotlin.dsl.create
import org.gradle.kotlin.dsl.extra

// Public API
abstract class ExampleExtension {
    abstract val endpoint: Property<String>
}

// Internal transport
internal const val EXAMPLE_ENDPOINT = "com.example.plugin.globalEndpoint"

class ExampleSettingsPlugin : Plugin<Settings> {
    override fun apply(settings: Settings) = with(settings) {
        val extension = extensions.create<ExampleExtension>("example")
        gradle.lifecycle.beforeProject {
            project.extra[EXAMPLE_ENDPOINT] = extension.endpoint
            pluginManager.apply(ExampleProjectPlugin::class)
        }
    }
}

class ExampleProjectPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        @Suppress("UNCHECKED_CAST")
        val globalEndpoint = project.extra[EXAMPLE_ENDPOINT] as Provider<String>
        val extension = project.extensions.create<ExampleExtension>("example")
        extension.endpoint.convention(globalEndpoint)
    }
}
```

- Namespace every extra key with the plugin ID.
- Store typed `Provider<T>` values, never resolved values.
- Read only the current project's extra.
- Register `beforeProject` from a Settings plugin early enough to precede project evaluation.
- Decide whether the Settings plugin is required: report a clear missing-extra error when required; supply a project-local provider convention when optional.

## Lifecycle selection

| Callback | Use |
|---|---|
| `beforeProject` | Install provider defaults, extras, or required model before the project script runs |
| `afterProject` | Validate the target project's final DSL/model after its script runs |

```kotlin
import org.gradle.kotlin.dsl.findByType

gradle.lifecycle.afterProject {
    val extension = extensions.findByType<ExampleExtension>()
    check(extension == null || extension.endpoint.isPresent) {
        "example.endpoint must be configured"
    }
}
```

Keep both callbacks isolated to their supplied target. Never use `afterProject` to transport defaults needed during plugin application.

## Artifact sharing

| Producer | Consumer |
|---|---|
| Register a task with a declared output | Create a declarable dependency scope |
| Create a consumable configuration | Create a resolvable configuration extending that scope |
| Add matching attributes/capabilities | Request matching attributes/capabilities |
| Publish `taskProvider.flatMap { output }` | Add `project(":producer")` to the dependency scope |

Resolve only the consumer's configuration. Let the artifact provider carry the producer task dependency; do not look up cross-project tasks or use path-based `dependsOn`.

## Shared build services

- Register with `gradle.sharedServices.registerIfAbsent` and configure parameters inside the registration action.
- Implement `AutoCloseable` for connections, servers, clients, and other closeable resources.
- Make service methods thread-safe; use `maxParallelUsages` only when the resource requires a concurrency limit.
- Expose a task `Property<ExampleService>` annotated with `@ServiceReference`.
- Match a named registration with `@get:ServiceReference(SERVICE_NAME)`, or set the registered provider on the annotated property explicitly.
- Use an `@Internal` property plus `usesService(provider)` only when `@ServiceReference` cannot express the relationship.
- Never call the service provider's `get()` during configuration.

```kotlin
import org.gradle.api.services.BuildService
import org.gradle.api.services.BuildServiceParameters
import org.gradle.api.services.ServiceReference

internal abstract class ExampleService : BuildService<ExampleService.Parameters>, AutoCloseable {
    override fun close() {
        // Close shared resources here
    }

    interface Parameters : BuildServiceParameters {
        val param1: Property<String>
    }

    internal companion object {
        const val NAME = "exampleService"
    }
}

// In a task type
@get:ServiceReference(ExampleService.NAME)
abstract val exampleService: Property<ExampleService>
```

## Common mistakes

| Mistake | Correction |
|---|---|
| Root plugin configures subprojects | Apply a Project plugin to each target or use an isolated settings callback |
| Passing a resolved settings value | Put its typed provider in each project's own extras |
| Resolving a producer configuration from the consumer | Declare a project dependency and resolve the consumer configuration |
| Opening one connection per task | Share an `AutoCloseable` build service |

## References

- [Isolated Projects](https://docs.gradle.org/current/userguide/isolated_projects.html)
- [Build lifecycle](https://docs.gradle.org/current/userguide/build_lifecycle.html)
- [Extra properties](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.api.plugins/-extra-properties-extension/index.html)
- [Sharing outputs between projects](https://docs.gradle.org/current/userguide/how_to_share_outputs_between_projects.html)
- [Shared build services](https://docs.gradle.org/current/userguide/build_services.html)
