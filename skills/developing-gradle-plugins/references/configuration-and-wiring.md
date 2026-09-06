# Configuration and Wiring

## Kotlin DSL APIs

- Use Gradle Kotlin DSL extensions whenever they provide an equivalent API for the supported Gradle version, in both plugin source and build scripts.
- Use reified type parameters or `KClass` overloads where provided; preserve lazy configuration and the operation's semantics.
- Import the required `org.gradle.kotlin.dsl` extensions explicitly in Kotlin source files.

| Operation | Kotlin DSL example | Import |
|---|---|---|
| Apply a project plugin by type | `project.apply<ExamplePlugin>()` | `org.gradle.kotlin.dsl.apply` |
| Register an extension by type | `extensions.create<ExampleExtension>("example")` | `org.gradle.kotlin.dsl.create` |
| Register a task by type | `tasks.register<ExampleTask>("example") { }` | `org.gradle.kotlin.dsl.register` |
| Configure a named task by type | `tasks.named<ExampleTask>("example") { }` | `org.gradle.kotlin.dsl.named` |
| Configure each task of a type lazily | `tasks.withType<ExampleTask>().configureEach { }` | `org.gradle.kotlin.dsl.withType` |

## Configuration contract

| Do | Avoid |
|---|---|
| Register tasks and configurations lazily | Creating or resolving them eagerly |
| Wire `Provider` values with `set`, `convention`, `map`, and `flatMap` | Calling `get()` during configuration |
| Configure only the current target | Reaching into another project |
| Connect outputs to inputs | Adding coarse `dependsOn` edges |

Use `tasks.register`, `tasks.named`, and `withType<T>().configureEach`. Keep every task configuration action limited to that task.

## Extension-to-task wiring

```kotlin
import org.gradle.kotlin.dsl.create
import org.gradle.kotlin.dsl.register

val extension = extensions.create<ExampleExtension>("example")

tasks.register<ExampleTask>("publishMetadata") {
    endpoint.convention(extension.endpoint)
    outputFile.convention(layout.buildDirectory.file("metadata/result.json"))
}
```

## Task output-to-input wiring

Connect the producer's output provider directly to the consumer's input. The provider carries the implicit task dependency.

```kotlin
import org.gradle.kotlin.dsl.register

val producerTask = tasks.register<ProducerTask>("produce") {
    outputFile.convention(layout.buildDirectory.file("producer/output.txt"))
}

tasks.register<ConsumerTask>("consume") {
    inputFile.set(producerTask.flatMap { it.outputFile })
}
```

Finalize values only at a real ownership boundary:

- Use `finalizeValueOnRead()` when the first consumer read closes configuration.
- Use `disallowChanges()` after the plugin has finished assigning a fixed internal value.
- Preserve user overrides by using `convention`, not `set`, for defaults.

## External inputs

| Input | Provider |
|---|---|
| Gradle property | `providers.gradleProperty(name)` |
| Environment variable | `providers.environmentVariable(name)` |
| System property | `providers.systemProperty(name)` |
| File text | `providers.fileContents(file).asText` |
| Complex or computed value | Custom `ValueSource` |

```kotlin
import org.gradle.api.provider.ValueSource
import org.gradle.api.provider.ValueSourceParameters
import org.gradle.kotlin.dsl.of

internal abstract class ExampleValueSource :
    ValueSource<String, ValueSourceParameters.None> {
    override fun obtain(): String = UUID.randomUUID().toString()
}

val randomIdProvider = providers.of(ExampleValueSource::class) {}
```

- Connect providers directly to declared task properties.
- Read only named inputs; never enumerate all properties or environment variables.
- Keep `ValueSource.obtain()` fast and return an effectively immutable value.
- Keep secrets out of logs, task descriptions, problem details, and cacheable outputs.

## Logging

| Context | Logger |
|---|---|
| Project plugin configuration | `project.logger` |
| Task action | Task `logger` |
| Settings or init plugin | `Logging.getLogger(ExamplePlugin::class.java)` |
| `BuildService` | `Logging.getLogger(ExampleService::class.java)` |
| `WorkAction` | `Logging.getLogger(ExampleAction::class.java)` |
| `FlowAction` | `Logging.getLogger(ExampleAction::class.java)` |

Use parameterized messages and the narrowest useful level. Never use `println` or write directly to standard output.

## Common mistakes

| Mistake | Correction |
|---|---|
| `provider.get()` in `apply()` | Pass the provider into the next property |
| `tasks.getByName` or eager `withType` | Use `named` or `configureEach` |
| Direct `System.getenv` or broad map reads | Use a named `ProviderFactory` input |
| `afterEvaluate` wiring | Use providers or plugin callbacks; reserve `afterEvaluate` for final validation |

## References

- [Gradle Kotlin DSL: Plugin application extensions](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.kotlin.dsl/apply.html)
- [Gradle Kotlin DSL: Registration extensions](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.kotlin.dsl/register.html)
- [Gradle Kotlin DSL: Extension creation](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.kotlin.dsl/create.html)
- [Gradle Kotlin DSL: Named object extensions](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.kotlin.dsl/named.html)
- [Gradle Kotlin DSL: Type filtering extensions](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.kotlin.dsl/with-type.html)
- [Lazy configuration](https://docs.gradle.org/current/userguide/lazy_configuration.html)
- [Task configuration avoidance](https://docs.gradle.org/current/userguide/task_configuration_avoidance.html)
- [Task best practices](https://docs.gradle.org/current/userguide/best_practices_tasks.html)
- [Configuration Cache requirements](https://docs.gradle.org/current/userguide/configuration_cache_requirements.html)
- [Logging and output](https://docs.gradle.org/current/userguide/logging.html)
