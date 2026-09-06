# Plugin API Design

## Support boundary

- Default every Kotlin declaration to `internal`. Promote a type only when supported consumer source code must reference it, such as for typed configuration, subclassing, or instantiation.
- A user-facing task name does not require a public task class. Invocation from the command line, lifecycle wiring, and configuration by name can use an internal implementation type.

| Surface | Default visibility | Package |
|---|---|---|
| Plugin implementation | `internal` | `com.example.plugin` |
| Supported extension/DSL type | public | `com.example.plugin.api` |
| Task type consumers must reference in source | public | `com.example.plugin.api` |
| Task implementation type | `internal` | `com.example.plugin` |
| Public enum, value type, or interface | public | `com.example.plugin.api` |
| Internal managed implementation | `internal` | `com.example.plugin` |

Treat Kotlin `internal` as a support contract, not a JVM-access barrier.

## Defining DSL

- Prefer abstract classes or interfaces created through `ObjectFactory`, `ExtensionContainer`, or another Gradle container.
- Expose `Property<T>`, `ListProperty<T>`, `SetProperty<T>`, `MapProperty<K,V>`, `RegularFileProperty`, and `DirectoryProperty`.
- Apply one custom `@DslMarker` annotation to the extension and its nested DSL types.
- Avoid mutable fields, collection getters returning raw mutable collections, and constructors that accept project state.
- Put public bases in `.api`; let internal DSL types subclass them when implementation-only properties are required.

```kotlin
import org.gradle.api.tasks.Nested

@DslMarker
@Target(AnnotationTarget.CLASS)
annotation class ExampleDsl

@ExampleDsl
interface ExampleExtension {
    val endpoint: Property<String>

    @get:Nested
    val nested: ExampleNestedExtension

    fun nested(action: Action<ExampleNestedExtension>) {
        action.execute(nested)
    }
}

@ExampleDsl
interface ExampleNestedExtension {
    val enabled: Property<Boolean>
}
```

## Stable names

Treat these as public API when users reference them:

- Plugin IDs and marker coordinates
- Extension and nested DSL names
- Public type and property names
- User-invocable task names and CLI option names
- Declarable configuration names
- Consumable attributes and capabilities
- Problem group and problem IDs

Keep implementation-only task names and configurations undocumented.

## Custom configurations

Give each configuration exactly one role:

| Role | Purpose | Resolve? | Publish? |
|---|---|---:|---:|
| Declarable | User dependencies | No | No |
| Resolvable | Plugin/task input classpath | Yes | No |
| Consumable | Outgoing variant | No | Yes |

```kotlin
import org.gradle.api.attributes.Category
import org.gradle.api.attributes.Usage
import org.gradle.kotlin.dsl.named
import org.gradle.kotlin.dsl.register

internal abstract class ExampleTask : DefaultTask() {
    @get:Classpath
    abstract val codegenClasspath: ConfigurableFileCollection
}

val codegenDependencies = configurations.dependencyScope("codegenDependencies") {
    description = "Declares dependencies used by code generation"
    defaultDependencies {
        add(project.dependencies.create("com.example:code-generator:1.0"))
    }
}

val codegenClasspath = configurations.resolvable("codegenClasspath") {
    description = "Resolves the code generation runtime classpath"
    extendsFrom(codegenDependencies.get())
    attributes {
        attribute(Category.CATEGORY_ATTRIBUTE, objects.named(Category.LIBRARY))
        attribute(Usage.USAGE_ATTRIBUTE, objects.named(Usage.JAVA_RUNTIME))
    }
}

tasks.register<ExampleTask>("generateSources") {
    this.codegenClasspath.from(codegenClasspath)
}
```

- Use `defaultDependencies` only as an overridable fallback.
- Add meaningful attributes to every resolvable and consumable configuration.
- Extend only between configurations in the same project.
- Select variants by attributes and capabilities, not another project's configuration name.
- Keep configuration names public only when consumers declare dependencies against them.

## Common mistakes

| Mistake | Correction |
|---|---|
| Exposing implementation types in public signatures | Move the type to `.api` or hide it behind a public abstraction |
| Making every task type public | Apply the [support boundary](#support-boundary) |
| Combining configuration roles | Split declarable, resolvable, and consumable roles |
| Adding setters to managed properties | Expose abstract managed property getters |

## References

- [Kotlin visibility modifiers](https://kotlinlang.org/docs/visibility-modifiers.html)
- [Public Gradle APIs](https://docs.gradle.org/current/userguide/public_apis.html)
- [Gradle managed types](https://docs.gradle.org/current/userguide/gradle_managed_types.html)
- [Properties and providers](https://docs.gradle.org/current/userguide/properties_providers.html)
- [Creating dependency configurations](https://docs.gradle.org/current/userguide/declaring_configurations.html)
- [Dependency best practices](https://docs.gradle.org/current/userguide/best_practices_dependencies.html)
- [Kotlin type-safe builders and `@DslMarker`](https://kotlinlang.org/docs/type-safe-builders.html#scope-control-dslmarker)
