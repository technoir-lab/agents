# Configuration and Wiring

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
val extension = extensions.create<ExampleExtension>("example")

tasks.register<ExampleTask>("publishMetadata") {
    endpoint.convention(extension.endpoint)
    outputFile.convention(layout.buildDirectory.file("metadata/result.json"))
}
```

## Task output-to-input wiring

Connect the producer's output provider directly to the consumer's input. The provider carries the implicit task dependency.

```kotlin
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

- [Lazy configuration](https://docs.gradle.org/current/userguide/lazy_configuration.html)
- [Task configuration avoidance](https://docs.gradle.org/current/userguide/task_configuration_avoidance.html)
- [Task best practices](https://docs.gradle.org/current/userguide/best_practices_tasks.html)
- [Configuration Cache requirements](https://docs.gradle.org/current/userguide/configuration_cache_requirements.html)
- [Logging and output](https://docs.gradle.org/current/userguide/logging.html)
