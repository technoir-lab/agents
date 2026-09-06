# Dependency and Serialization Rules

## Dependency declarations and exposure

- Declare a direct dependency on every library or project whose types or symbols a module references, in the appropriate source-set configuration; do not rely on transitive dependencies. Reuse direct dependencies already supplied by the applied convention plugins without duplicating them.
- Use `implementation` for implementation dependencies needed at compile time and runtime, `compileOnly` for dependencies needed only at compile time, and `runtimeOnly` for dependencies needed only at runtime; use the corresponding source-set configurations where applicable.
- Use `compileOnly` for annotation-only dependencies with Kotlin `AnnotationRetention.SOURCE` or `AnnotationRetention.BINARY` when neither handwritten nor generated code requires the dependency at runtime. Keep annotation types needed by runtime reflection on the runtime classpath.
- Avoid exporting the module's implementation or runtime dependencies to consumers' compile classpaths through `api`; reserve `api` for deliberately exported API dependencies. `implementation` dependencies remain available transitively at runtime.
- For dependency checks and handling `projectHealth` advice, follow [dependency analysis](testing-and-quality.md#dependency-analysis).

## Version catalogs

- Keep entries alphabetically sorted by key within each version catalog section (`[versions]`, `[libraries]`, `[bundles]`, and `[plugins]`).
- Follow the version guidance in the relevant [tech stack category](tech-stack.md); omit managed versions from catalog entries, including `version`, `version.ref`, and rich version constraints.
- Declare the libraries the module uses explicitly; version management does not add those dependencies.
- Keep plugin version declarations in [settings plugin management](project-setup.md#plugin-loading).

Example: `gradle/libs.versions.toml`

```toml
[libraries]
gradle-test-kit = { module = "io.technoirlab.conventions:gradle-test-kit" }
kotlinx-coroutines-core = { module = "org.jetbrains.kotlinx:kotlinx-coroutines-core" }
kotlinx-coroutines-test = { module = "org.jetbrains.kotlinx:kotlinx-coroutines-test" }
kotlinx-serialization-core = { module = "org.jetbrains.kotlinx:kotlinx-serialization-core" }
kotlinx-serialization-json = { module = "org.jetbrains.kotlinx:kotlinx-serialization-json" }
```

## Serialization

- Select the format library from the [tech stack](tech-stack.md#serialization).
- When using generated serializers, set `buildFeatures.serialization = true` in the module's convention extension; the feature is disabled by default and applies the Kotlin serialization compiler plugin.
- Declare the required format library separately; enabling the compiler plugin does not add it.

## References

- [Gradle: API and implementation separation](https://docs.gradle.org/current/userguide/java_library_plugin.html#sec:java_library_separation)
- [Gradle: Dependency configurations](https://docs.gradle.org/current/userguide/java_library_plugin.html#sec:java_library_configurations_graph)
- [Kotlin: Annotation retention](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.annotation/-annotation-retention/)
- [Shared feature defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/internal/CommonBuildFeaturesImpl.kt)
- [Serialization feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Serialization.kt)
- [Gradle: Version catalogs](https://docs.gradle.org/current/userguide/version_catalogs.html)
- [kotlinx.serialization guide](https://github.com/Kotlin/kotlinx.serialization/blob/master/docs/serialization-guide.md)
- [kotaml: YAML support, dependency coordinates, and supported targets](https://github.com/Heapy/kotaml)
